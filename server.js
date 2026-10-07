// Thailand reisapp: Express-server met Neon (Postgres) als database.
// Omgevingsvariabelen:
//   DATABASE_URL  - Neon connection string (verplicht)
//   APP_PASSWORD  - optioneel; als gezet, vraagt de app om dit wachtwoord
//   PORT          - wordt door Render gezet

const express = require("express");
const path = require("path");
const crypto = require("crypto");
const db = require("./db");

const app = express();
app.disable("x-powered-by");
app.use(express.json({ limit: "20kb" }));

// Health check voor Render (zonder wachtwoord)
app.get("/healthz", async (_req, res) => {
  try {
    await db.query("select 1");
    res.json({ ok: true });
  } catch (e) {
    res.status(503).json({ ok: false });
  }
});

// Optionele wachtwoordbeveiliging (HTTP Basic Auth, gebruikersnaam maakt niet uit)
const PASSWORD = process.env.APP_PASSWORD || "";
function safeEqual(a, b) {
  const ha = crypto.createHash("sha256").update(a).digest();
  const hb = crypto.createHash("sha256").update(b).digest();
  return crypto.timingSafeEqual(ha, hb);
}
app.use((req, res, next) => {
  if (!PASSWORD) return next();
  const h = req.headers.authorization || "";
  if (h.startsWith("Basic ")) {
    const decoded = Buffer.from(h.slice(6), "base64").toString();
    const pw = decoded.slice(decoded.indexOf(":") + 1);
    if (safeEqual(pw, PASSWORD)) return next();
  }
  res.set("WWW-Authenticate", 'Basic realm="Thailand 2027", charset="UTF-8"');
  res.status(401).send("Wachtwoord nodig");
});

// Alle reisgegevens in één keer
app.get("/api/trip", async (_req, res, next) => {
  try {
    const [bases, days, legs, check, kaart] = await Promise.all([
      db.query("select * from bases order by nr"),
      db.query("select to_char(day_date,'YYYY-MM-DD') as iso, * from days order by day_date"),
      db.query("select * from legs order by sort"),
      db.query("select * from checklist order by sort"),
      db.query("select route, tussenstops, dagtrips from kaart where id = 'kaart'"),
    ]);
    const k = kaart.rows[0] || { route: [], tussenstops: [], dagtrips: [] };
    res.set("Cache-Control", "no-store");
    res.json({
      bases: bases.rows.map((b) => ({
        id: b.id, n: b.nr, name: b.name, dates: b.dates, nights: b.nights,
        lat: Number(b.lat), lon: Number(b.lon),
        hotel: b.hotel, alt: b.alternative, why: b.why, todo: b.todo,
        q: b.unsplash_query, g: b.maps_query,
        img: [b.photo, b.photo_caption], gal: b.gallery || [], links: b.links,
      })),
      kaart: { route: k.route, tussenstops: k.tussenstops, dagtrips: k.dagtrips },
      days: days.rows.map((d) => ({
        iso: d.iso, title: d.title, drive: d.drive, items: d.items, photo: d.photo,
      })),
      legs: legs.rows.map((l) => [l.date_label, l.route, l.duration]),
      checklist: check.rows.map((c) => ({
        id: c.id, title: c.title, note: c.note, done: c.done,
        updatedAt: c.updated_at,
      })),
    });
  } catch (e) {
    next(e);
  }
});

// Een reservering afvinken of terugzetten
app.patch("/api/checklist/:id", async (req, res, next) => {
  try {
    if (typeof req.body?.done !== "boolean") {
      return res.status(400).json({ error: "Stuur { done: true } of { done: false }." });
    }
    const r = await db.query(
      "update checklist set done = $1, updated_at = now() where id = $2 returning id, done, updated_at",
      [req.body.done, req.params.id]
    );
    if (!r.rowCount) return res.status(404).json({ error: "Onbekend item." });
    res.json({ id: r.rows[0].id, done: r.rows[0].done, updatedAt: r.rows[0].updated_at });
  } catch (e) {
    next(e);
  }
});

// ---------- Aanpassen via prompts ----------
const assistant = require("./assistant");

// Eenvoudige limiet: maximaal 30 voorstellen per uur (beschermt je API-tegoed)
let windowStart = Date.now(), proposals = 0;
function underLimit() {
  if (Date.now() - windowStart > 3600_000) { windowStart = Date.now(); proposals = 0; }
  return ++proposals <= 30;
}
function requireAssistant(_req, res, next) {
  const s = assistant.status();
  if (!s.enabled) return res.status(403).json({ error: s.reason });
  next();
}
function handle(fn) {
  return async (req, res) => {
    try {
      res.json(await fn(req));
    } catch (e) {
      if (e instanceof assistant.UserError) return res.status(400).json({ error: e.message });
      console.error(e);
      res.status(500).json({ error: "Er ging iets mis op de server." });
    }
  };
}

app.get("/api/assistant/status", (_req, res) => res.json(assistant.status()));
app.get("/api/assistant/history", requireAssistant, handle(() => assistant.history()));
app.post("/api/assistant/propose", requireAssistant, (req, res, next) => {
  if (!underLimit()) return res.status(429).json({ error: "Je hebt het maximum van 30 voorstellen per uur bereikt." });
  next();
}, handle((req) => assistant.propose(req.body?.prompt)));
app.post("/api/assistant/apply", requireAssistant, handle((req) =>
  assistant.apply(req.body?.prompt, req.body?.samenvatting, req.body?.wijzigingen)));
app.post("/api/assistant/undo", requireAssistant, handle(() => assistant.undoLast()));

app.use(express.static(path.join(__dirname, "public"), { maxAge: "7d", index: "index.html" }));

app.use((err, _req, res, _next) => {
  console.error(err);
  res.status(500).json({ error: "Er ging iets mis op de server." });
});

const port = process.env.PORT || 3000;
db.init()
  .then(() => app.listen(port, () => console.log(`Reisapp draait op poort ${port}`)))
  .catch((e) => {
    console.error("Database niet bereikbaar of setup mislukt:", e.message);
    process.exit(1);
  });
