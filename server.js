// Thailand reisapp: Express-server met Neon (Postgres) als database.
// Omgevingsvariabelen:
//   DATABASE_URL  - Neon connection string (verplicht)
//   APP_PASSWORD  - optioneel; als gezet, toont de app eerst een inlogscherm
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

// ---------- Inloggen met een wachtwoord (eigen inlogscherm) ----------
// Na een juist wachtwoord krijgt de browser een cookie dat 30 dagen geldig is.
// Verander je APP_PASSWORD, dan moet iedereen opnieuw inloggen.
app.set("trust proxy", 1); // Render zet een proxy voor de app
const PASSWORD = process.env.APP_PASSWORD || "";
const COOKIE = "reis_sessie";
const MAX_AGE = 30 * 24 * 3600; // seconden
function safeEqual(a, b) {
  const ha = crypto.createHash("sha256").update(String(a)).digest();
  const hb = crypto.createHash("sha256").update(String(b)).digest();
  return crypto.timingSafeEqual(ha, hb);
}
const sessionToken = () => crypto.createHmac("sha256", PASSWORD).update("thailand-reisapp-sessie-v1").digest("hex");
function readCookie(req, name) {
  for (const part of (req.headers.cookie || "").split(";")) {
    const i = part.indexOf("=");
    if (i > 0 && part.slice(0, i).trim() === name) return decodeURIComponent(part.slice(i + 1).trim());
  }
  return "";
}
const loggedIn = (req) => !PASSWORD || safeEqual(readCookie(req, COOKIE), sessionToken());
function setCookie(req, res, value, maxAge) {
  const secure = req.secure ? "; Secure" : "";
  res.set("Set-Cookie", `${COOKIE}=${encodeURIComponent(value)}; Path=/; Max-Age=${maxAge}; HttpOnly; SameSite=Lax${secure}`);
}

// Rem op raden: maximaal 10 pogingen per kwartier per IP-adres
const attempts = new Map();
function tooManyAttempts(ip) {
  const now = Date.now();
  const a = attempts.get(ip) || { n: 0, since: now };
  if (now - a.since > 15 * 60_000) { a.n = 0; a.since = now; }
  a.n++;
  attempts.set(ip, a);
  if (attempts.size > 5000) attempts.clear();
  return a.n > 10;
}

app.post("/login", (req, res) => {
  if (!PASSWORD) return res.json({ ok: true });
  if (tooManyAttempts(req.ip)) {
    return res.status(429).json({ error: "Te veel pogingen. Probeer het over een kwartier opnieuw." });
  }
  const pw = typeof req.body?.password === "string" ? req.body.password : "";
  if (!pw || !safeEqual(pw, PASSWORD)) {
    return res.status(401).json({ error: "Dat wachtwoord klopt niet." });
  }
  attempts.delete(req.ip);
  setCookie(req, res, sessionToken(), MAX_AGE);
  res.json({ ok: true });
});

app.get("/logout", (req, res) => {
  setCookie(req, res, "", 0);
  res.redirect("./");
});

// Het inlogscherm en de foto's mogen zonder wachtwoord; de rest niet
app.use((req, res, next) => {
  if (loggedIn(req)) return next();
  if (req.path.startsWith("/img/")) return next();
  if (req.path.startsWith("/api/")) return res.status(401).json({ error: "Je bent niet ingelogd. Ververs de pagina." });
  res.set("Cache-Control", "no-store");
  res.sendFile(path.join(__dirname, "public", "login.html"));
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
