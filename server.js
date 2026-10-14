// Thailand reisapp: Express-server met Neon (Postgres) als database.
// Omgevingsvariabelen:
//   DATABASE_URL  - Neon connection string (verplicht)
//   APP_PASSWORD  - optioneel; als gezet, toont de app eerst een inlogscherm (gastwachtwoord)
//   ADMIN_PASSWORD - optioneel; als gezet, kan alleen wie hiermee inlogt iets aanpassen.
//                   Wie met APP_PASSWORD inlogt, kan dan alleen kijken.
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
const ADMIN_PASSWORD = process.env.ADMIN_PASSWORD || "";
const COOKIE = "reis_sessie";
const MAX_AGE = 30 * 24 * 3600; // seconden
function safeEqual(a, b) {
  const ha = crypto.createHash("sha256").update(String(a)).digest();
  const hb = crypto.createHash("sha256").update(String(b)).digest();
  return crypto.timingSafeEqual(ha, hb);
}
// Eén sessietoken per rol. Zonder ADMIN_PASSWORD is iedereen die inlogt beheerder (zoals vroeger).
const sessionToken = (rol) => crypto.createHmac("sha256", PASSWORD + "|" + ADMIN_PASSWORD)
  .update(rol === "admin" && ADMIN_PASSWORD ? "thailand-reisapp-sessie-v2-admin" : "thailand-reisapp-sessie-v2-gast").digest("hex");
function readCookie(req, name) {
  for (const part of (req.headers.cookie || "").split(";")) {
    const i = part.indexOf("=");
    if (i > 0 && part.slice(0, i).trim() === name) return decodeURIComponent(part.slice(i + 1).trim());
  }
  return "";
}
// Welke rol heeft deze bezoeker? "admin", "gast" of null (niet ingelogd)
function roleOf(req) {
  if (!PASSWORD) return ADMIN_PASSWORD ? "gast" : "admin";
  const c = readCookie(req, COOKIE);
  if (!c) return null;
  if (ADMIN_PASSWORD && safeEqual(c, sessionToken("admin"))) return "admin";
  if (safeEqual(c, sessionToken("gast"))) return ADMIN_PASSWORD ? "gast" : "admin";
  return null;
}
const loggedIn = (req) => roleOf(req) !== null;
const isAdmin = (req) => roleOf(req) === "admin";
function requireAdmin(req, res, next) {
  if (isAdmin(req)) return next();
  res.status(403).json({ error: "Je bent ingelogd als gast en kunt alleen kijken. Log in met het beheerderswachtwoord om iets aan te passen." });
}
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
  let rol = null;
  if (pw && ADMIN_PASSWORD && safeEqual(pw, ADMIN_PASSWORD)) rol = "admin";
  else if (pw && safeEqual(pw, PASSWORD)) rol = ADMIN_PASSWORD ? "gast" : "admin";
  if (!rol) return res.status(401).json({ error: "Dat wachtwoord klopt niet." });
  attempts.delete(req.ip);
  setCookie(req, res, sessionToken(rol), MAX_AGE);
  res.json({ ok: true, rol });
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

// Wie ben ik? (de app verbergt de knoppen om aan te passen voor gasten)
app.get("/api/me", (req, res) => res.json({ rol: roleOf(req) }));

// Alle reisgegevens in één keer
app.get("/api/trip", async (_req, res, next) => {
  try {
    const [bases, days, legs, check, kaart, info, autos, budget] = await Promise.all([
      db.query("select * from bases order by nr"),
      db.query("select to_char(day_date,'YYYY-MM-DD') as iso, * from days order by day_date"),
      db.query("select * from legs order by sort"),
      db.query("select *, to_char(deadline,'YYYY-MM-DD') as deadline_iso from checklist order by sort"),
      db.query("select route, tussenstops, dagtrips from kaart where id = 'kaart'"),
      db.query("select id, sectie, label, waarde, tekst from info order by sectie, sort, id"),
      db.query("select * from autohuur order by sort, id"),
      db.query("select * from budget order by sort, id"),
    ]);
    const k = kaart.rows[0] || { route: [], tussenstops: [], dagtrips: [] };
    res.set("Cache-Control", "no-store");
    res.json({
      bases: bases.rows.map((b) => ({
        id: b.id, n: b.nr, name: b.name, dates: b.dates, nights: b.nights,
        lat: Number(b.lat), lon: Number(b.lon),
        hotel: b.hotel, alt: b.alternative, why: b.why, todo: b.todo,
        q: b.unsplash_query, g: b.maps_query,
        img: [b.photo, b.photo_caption], gal: b.gallery || [], links: b.links, hotelUrl: b.hotel_url || null, hotelFoto: b.hotel_foto || null,
        prijs: b.prijs == null ? null : Number(b.prijs),
      })),
      kaart: { route: k.route, tussenstops: k.tussenstops, dagtrips: k.dagtrips },
      days: days.rows.map((d) => ({
        iso: d.iso, title: d.title, drive: d.drive, items: d.items, photo: d.photo,
      })),
      legs: legs.rows.map((l) => [l.date_label, l.route, l.duration]),
      checklist: check.rows.map((c) => ({
        id: c.id, title: c.title, note: c.note, done: c.done,
        updatedAt: c.updated_at, groep: c.groep || null, deadline: c.deadline_iso || null, deadlineLabel: c.deadline_label || null,
      })),
      info: info.rows,
      autos: autos.rows.map((a) => ({
        id: a.id, verhuurder: a.verhuurder, auto: a.auto, reservering: a.reservering, status: a.status,
        ophalen: a.ophalen, ophalenPlek: a.ophalen_plek, inleveren: a.inleveren, inleverenPlek: a.inleveren_plek,
        prijs: a.prijs == null ? null : Number(a.prijs), terPlaatse: a.ter_plaatse == null ? null : Number(a.ter_plaatse),
        terPlaatseTekst: a.ter_plaatse_tekst, borg: a.borg, details: a.details || [], url: a.url, notitie: a.notitie,
      })),
      budget: budget.rows.map((b) => ({ id: b.id, label: b.label, bedrag: b.bedrag == null ? null : Number(b.bedrag), toelichting: b.toelichting })),
    });
  } catch (e) {
    next(e);
  }
});

// Een reservering afvinken of terugzetten
app.patch("/api/checklist/:id", requireAdmin, async (req, res, next) => {
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

// Prijs van een overnachting direct aanpassen (veld in de kostenlijst)
app.patch("/api/budget/:id", requireAdmin, handle((req) => assistant.setBudget(req.params.id, req.body?.bedrag ?? null)));
app.patch("/api/autohuur/:id/prijs", requireAdmin, handle((req) => assistant.setAutoPrice(req.params.id, req.body?.veld, req.body?.prijs ?? null)));
app.patch("/api/bases/:id/prijs", requireAdmin, handle((req) => assistant.setPrice(req.params.id, req.body?.prijs ?? null)));

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

app.get("/api/assistant/status", (req, res) => {
  const s = assistant.status();
  if (s.enabled && !isAdmin(req)) return res.json({ enabled: false, gast: true, reason: "je bent ingelogd als gast. Log in met het beheerderswachtwoord om iets aan te passen." });
  res.json(s);
});
app.get("/api/assistant/history", requireAdmin, requireAssistant, handle(() => assistant.history()));
app.post("/api/assistant/propose", requireAdmin, requireAssistant, (req, res, next) => {
  if (!underLimit()) return res.status(429).json({ error: "Je hebt het maximum van 30 voorstellen per uur bereikt." });
  next();
}, handle((req) => assistant.propose(req.body?.prompt)));
app.get("/api/assistant/open", requireAdmin, requireAssistant, handle(() => assistant.openProposal()));
app.post("/api/assistant/apply", requireAdmin, requireAssistant, handle((req) => assistant.applyProposal(req.body?.id)));
app.post("/api/assistant/cancel", requireAdmin, requireAssistant, handle((req) => assistant.cancel(req.body?.id)));
app.post("/api/assistant/undo", requireAdmin, requireAssistant, handle(() => assistant.undoLast()));

// Versie van de app zelf: een vingerafdruk van de bestanden in public/ (behalve foto's).
// Verandert alleen als een deploy de app echt aanpast, niet als Render de server herstart.
const APP_VERSIE = (() => {
  const h = crypto.createHash("sha256");
  const map = path.join(__dirname, "public");
  for (const f of require("fs").readdirSync(map).filter((f) => /\.(html|js|css|json)$/.test(f)).sort()) {
    h.update(f); h.update(require("fs").readFileSync(path.join(map, f)));
  }
  return h.digest("hex").slice(0, 12);
})();

// Versie van de gegevens en van de app: de app vraagt dit elke 30 seconden op.
// Andere gegevens: opnieuw laden. Nieuwe app (na een deploy): de pagina ververst zichzelf.
app.get("/api/versie", handle(async (req) => {
  req.res.setHeader("Cache-Control", "no-store");
  return { versie: await assistant.dataVersion(), app: APP_VERSIE };
}));

// Foto's mogen lang in de cache; de pagina en de service worker niet, zodat een nieuwe versie meteen zichtbaar is
app.use(express.static(path.join(__dirname, "public"), {
  maxAge: "7d", index: "index.html",
  setHeaders: (res, file) => { if (/\.(html|js)$/.test(file)) res.setHeader("Cache-Control", "no-cache"); },
}));

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
