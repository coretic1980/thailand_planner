// Wijzigingen via prompts: Claude doet een voorstel, de gebruiker keurt goed,
// de server past het toe in Neon en houdt een log bij zodat je kunt terugdraaien.

const db = require("./db");

const API_KEY = process.env.ANTHROPIC_API_KEY || "";
const MODEL = process.env.ANTHROPIC_MODEL || "claude-sonnet-5-5";

// Wat Claude mag wijzigen. Alleen deze tabellen en velden.
const ENTITIES = {
  dag: {
    table: "days", key: "day_date", label: "Dag",
    fields: { title: "text", drive: "textnull", items: "list", photo: "photo" },
  },
  overnachting: {
    table: "bases", key: "id", label: "Overnachting",
    fields: { name: "text", dates: "text", nights: "text", hotel: "text", alternative: "textnull", why: "textnull", todo: "list", lat: "lat", lon: "lon", links: "bool" },
  },
  rit: {
    table: "legs", key: "sort", label: "Rit",
    fields: { date_label: "text", route: "text", duration: "text" },
  },
  kaart: {
    table: "kaart", key: "id", label: "Kaart",
    fields: { route: "route", tussenstops: "points", dagtrips: "points" },
  },
  reservering: {
    table: "checklist", key: "id", label: "Reservering",
    fields: { title: "text", note: "textnull", done: "bool" },
  },
};
const FIELD_LABELS = {
  title: "titel", drive: "rijtijd", items: "programma", photo: "foto", name: "naam", dates: "data",
  nights: "nachten", hotel: "hotel", alternative: "alternatief", why: "beschrijving", todo: "activiteiten",
  date_label: "datum", route: "route", duration: "duur", note: "toelichting", done: "geregeld",
  lat: "breedtegraad", lon: "lengtegraad", links: "label links", tussenstops: "tussenstops", dagtrips: "dagtrips",
};
// Het gebied dat de kaart toont (Zuid-Thailand)
const BOUNDS = { latMin: 7.5, latMax: 14.2, lonMin: 97.5, lonMax: 101.2 };
const PHOTOS = [
  "01-wat-arun", "02-wat-arun-avond", "03-bangkok-fietsen", "04-maeklong", "05-sam-roi-yot-grot",
  "06-prachuap", "07-kui-buri-olifant", "08-cheow-lan-meer", "09-raft-house", "10-railay",
  "11-railay-kliffen", "12-phang-nga-mangrove", "13-samet-nangshe", "14-khao-lak-strand", "15-surin", "16-zonsondergang-golf", "17-chumphon-kust", "18-tempel-ban-krut", "19-khao-sok-jungle", "20-junglepad",
];

class UserError extends Error {}

function status() {
  if (!API_KEY) return { enabled: false, reason: "ANTHROPIC_API_KEY is niet ingesteld op de server." };
  if (!process.env.APP_PASSWORD) return { enabled: false, reason: "Aanpassen werkt alleen als APP_PASSWORD is ingesteld." };
  return { enabled: true };
}

// ---------- Validatie ----------

function cleanValue(type, v) {
  const text = (s, max) => {
    if (typeof s !== "string") throw new UserError("Ongeldige tekst in het voorstel.");
    const t = s.trim();
    if (!t || t.length > max) throw new UserError("Tekst in het voorstel is leeg of te lang.");
    return t;
  };
  switch (type) {
    case "text": return text(v, 300);
    case "textnull": return v === null || v === "" ? null : text(v, 300);
    case "list":
      if (!Array.isArray(v) || v.length > 10) throw new UserError("Ongeldige lijst in het voorstel.");
      return v.map((x) => text(x, 200));
    case "bool":
      if (typeof v !== "boolean") throw new UserError("Ongeldige ja/nee-waarde in het voorstel.");
      return v;
    case "lat":
    case "lon": {
      const n = typeof v === "string" ? Number(v) : v;
      const [min, max] = type === "lat" ? [BOUNDS.latMin, BOUNDS.latMax] : [BOUNDS.lonMin, BOUNDS.lonMax];
      if (typeof n !== "number" || !Number.isFinite(n) || n < min || n > max) {
        throw new UserError("Deze plek valt buiten de kaart (alleen Zuid-Thailand).");
      }
      return Math.round(n * 10000) / 10000;
    }
    case "points":
    case "route": {
      const max = type === "route" ? 30 : 15;
      if (!Array.isArray(v) || v.length > max || (type === "route" && v.length < 2)) {
        throw new UserError(type === "route" ? "De route moet 2 tot 30 punten hebben." : "Maximaal 15 punten per lijst.");
      }
      return v.map((p) => {
        if (!p || typeof p !== "object") throw new UserError("Ongeldig kaartpunt.");
        const out = { naam: text(p.naam, 60), lat: cleanValue("lat", p.lat), lon: cleanValue("lon", p.lon) };
        if (p.links === true) out.links = true;
        return out;
      });
    }
    case "photo":
      if (v === null || v === "") return null;
      if (!PHOTOS.includes(v)) throw new UserError(`Onbekende foto: ${v}`);
      return v;
  }
  throw new UserError("Onbekend veldtype.");
}

function cleanChange(c) {
  if (!c || typeof c !== "object") throw new UserError("Ongeldige wijziging.");
  const ent = ENTITIES[c.soort];
  if (!ent) throw new UserError(`Onbekend soort: ${c.soort}`);
  const actie = c.actie;
  if (!["wijzigen", "toevoegen", "verwijderen"].includes(actie)) throw new UserError(`Onbekende actie: ${actie}`);
  if (actie !== "wijzigen" && c.soort !== "reservering") {
    throw new UserError("Toevoegen en verwijderen kan alleen bij reserveringen.");
  }
  const out = { actie, soort: c.soort, sleutel: c.sleutel == null ? null : String(c.sleutel), velden: {} };
  if (actie !== "toevoegen" && !out.sleutel) throw new UserError("Wijziging zonder sleutel.");
  if (c.soort === "kaart" && out.sleutel !== "kaart") throw new UserError('De kaart heeft als sleutel altijd "kaart".');
  if (actie === "verwijderen") return out;
  const velden = c.velden && typeof c.velden === "object" ? c.velden : {};
  for (const [k, v] of Object.entries(velden)) {
    if (!ent.fields[k]) throw new UserError(`Veld ${k} kan niet worden aangepast.`);
    out.velden[k] = cleanValue(ent.fields[k], v);
  }
  if (actie === "toevoegen" && !out.velden.title) throw new UserError("Een nieuwe reservering heeft een titel nodig.");
  if (!Object.keys(out.velden).length) throw new UserError("Wijziging zonder velden.");
  return out;
}

// ---------- Huidige gegevens ----------

async function getRow(client, ent, key) {
  const r = await client.query(`select row_to_json(t) as row from ${ent.table} t where ${ent.key}::text = $1`, [key]);
  return r.rows[0] ? r.rows[0].row : null;
}

async function snapshot() {
  const q = (sql) => db.query(sql).then((r) => r.rows);
  return {
    dagen: await q("select to_char(day_date,'YYYY-MM-DD') as sleutel, title, drive, items, photo from days order by day_date"),
    overnachtingen: await q("select id as sleutel, name, dates, nights, hotel, alternative, why, todo, lat::float as lat, lon::float as lon, links from bases order by nr"),
    ritten: await q("select sort::text as sleutel, date_label, route, duration from legs order by sort"),
    reserveringen: await q("select id as sleutel, title, note, done from checklist order by sort"),
    kaart: (await q("select id as sleutel, route, tussenstops, dagtrips from kaart"))[0] || null,
  };
}

// ---------- Beschrijving voor de gebruiker ----------

const fmt = (v) => (v === null || v === undefined || v === "" ? "(leeg)"
  : Array.isArray(v) ? (v.length && typeof v[0] === "object" ? v.map((p) => p.naam).join(" → ") : v.join(" · "))
  : typeof v === "boolean" ? (v ? "ja" : "nee") : String(v));

async function describe(change) {
  const ent = ENTITIES[change.soort];
  if (change.actie === "toevoegen") {
    return { titel: `Nieuwe reservering: ${change.velden.title}`, regels: change.velden.note ? [`toelichting: ${change.velden.note}`] : [] };
  }
  const row = await getRow(db, ent, change.sleutel);
  if (!row) throw new UserError(`${ent.label} "${change.sleutel}" bestaat niet.`);
  const naam = change.soort === "kaart" ? "routelijn, tussenstops en dagtrips" : (row.title || row.name || row.route || change.sleutel);
  const wie = change.soort === "dag" ? `${ent.label} ${change.sleutel} (${naam})` : `${ent.label}: ${naam}`;
  if (change.actie === "verwijderen") return { titel: `Verwijderen: ${wie}`, regels: [] };
  const regels = [];
  for (const [k, v] of Object.entries(change.velden)) {
    const oud = row[k] ?? null;
    if (JSON.stringify(typeof oud === "string" && typeof v === "number" ? Number(oud) : oud) === JSON.stringify(v)) continue;
    let voor = fmt(oud), na = fmt(v);
    // Bij een kaartlijst met dezelfde namen maar andere posities: toon dat de ligging verandert
    if (voor === na) { voor += " (oude ligging)"; na += " (nieuwe ligging)"; }
    regels.push({ veld: FIELD_LABELS[k] || k, voor, na });
  }
  return { titel: wie, regels };
}

// ---------- Claude ----------

const TOOL = {
  name: "voorstel",
  description: "Stel de wijzigingen voor die de gebruiker vraagt.",
  input_schema: {
    type: "object",
    properties: {
      samenvatting: { type: "string", description: "Eén of twee zinnen in het Nederlands: wat er verandert, of waarom niets kan." },
      wijzigingen: {
        type: "array",
        items: {
          type: "object",
          properties: {
            actie: { type: "string", enum: ["wijzigen", "toevoegen", "verwijderen"] },
            soort: { type: "string", enum: ["dag", "overnachting", "rit", "kaart", "reservering"] },
            sleutel: { type: ["string", "null"], description: "De 'sleutel' uit de huidige gegevens; null bij toevoegen." },
            velden: { type: "object", description: "Alleen de velden die veranderen, met hun complete nieuwe waarde." },
          },
          required: ["actie", "soort"],
        },
      },
    },
    required: ["samenvatting", "wijzigingen"],
  },
};

function systemPrompt(data) {
  return `Je beheert de gegevens van een reisapp voor een gezinsroadtrip door Thailand (3–17 februari 2027).
De gebruiker vraagt in gewone taal om iets aan te passen. Jij stelt via het hulpmiddel "voorstel" precies die wijzigingen voor, niets meer.

Regels:
- Gebruik alleen de sleutels uit de huidige gegevens hieronder.
- Je kunt wijzigen: dag (title, drive, items, photo), overnachting (name, dates, nights, hotel, alternative, why, todo, lat, lon, links), rit (date_label, route, duration), kaart (route, tussenstops, dagtrips; sleutel "kaart"), reservering (title, note, done).
- Toevoegen en verwijderen kan alleen bij reserveringen. Dagen, overnachtingen en ritten kun je niet toevoegen of verwijderen; leg dat dan uit in de samenvatting.
- De kaart: "route" is de rode lijn, in reisvolgorde, van vliegveld tot vliegveld, inclusief de overnachtingsplekken. "tussenstops" zijn plekken op de route waar je niet slaapt, "dagtrips" zijn uitstapjes vanaf een overnachting. Elk punt is {"naam","lat","lon"} met optioneel "links": true als het label links van de pin moet (bijvoorbeeld als het rechts tegen een ander label aan zou staan). Lijsten geef je altijd compleet terug.
- Verandert de route (een andere overnachtingsplek, een extra stop of een omweg), pas dan in één voorstel alles aan wat erbij hoort: de lat/lon van de overnachting, de kaart (route en eventueel tussenstops of dagtrips), de ritten en het dagprogramma.
- Coördinaten: gebruik de echte ligging van de plek in decimale graden. De kaart toont alleen Zuid-Thailand (breedtegraad ${BOUNDS.latMin}–${BOUNDS.latMax}, lengtegraad ${BOUNDS.lonMin}–${BOUNDS.lonMax}); een plek daarbuiten kan niet, leg dat dan uit.
- Lijsten (items, todo) geef je altijd compleet terug, inclusief de punten die blijven staan.
- Foto's: kies alleen uit ${PHOTOS.join(", ")}, of null.
- Houd de stijl van de bestaande teksten aan: kort, Nederlands, geen emoji.
- Als iets in het verzoek niet kan of onduidelijk is, geef dan een lege lijst wijzigingen en leg in de samenvatting uit wat je nodig hebt.
- Verander nooit iets waar de gebruiker niet om vraagt. Als een verzoek ook een andere dag raakt (bijvoorbeeld iets verplaatsen), pas dan beide dagen aan.

Huidige gegevens (JSON):
${JSON.stringify(data)}`;
}

async function callClaude(prompt, data) {
  const ctrl = new AbortController();
  const timer = setTimeout(() => ctrl.abort(), 90000);
  let res;
  try {
    res = await fetch("https://api.anthropic.com/v1/messages", {
      method: "POST",
      signal: ctrl.signal,
      headers: {
        "content-type": "application/json",
        "x-api-key": API_KEY,
        "anthropic-version": "2023-06-01",
      },
      body: JSON.stringify({
        model: MODEL,
        max_tokens: 4000,
        system: systemPrompt(data),
        tools: [TOOL],
        tool_choice: { type: "tool", name: "voorstel" },
        messages: [{ role: "user", content: prompt }],
      }),
    });
  } catch (e) {
    throw new UserError(e.name === "AbortError" ? "Claude reageerde niet op tijd. Probeer het opnieuw." : "Claude is nu niet bereikbaar. Probeer het later opnieuw.");
  } finally {
    clearTimeout(timer);
  }
  if (!res.ok) {
    const body = await res.text().catch(() => "");
    console.error("Claude API-fout", res.status, body.slice(0, 500));
    if (res.status === 401) throw new UserError("De Anthropic API-sleutel wordt geweigerd. Controleer ANTHROPIC_API_KEY.");
    if (res.status === 429) throw new UserError("Even te veel verzoeken bij Claude. Probeer het over een minuut opnieuw.");
    throw new UserError("Claude gaf een foutmelding. Probeer het opnieuw.");
  }
  const json = await res.json();
  const block = (json.content || []).find((b) => b.type === "tool_use" && b.name === "voorstel");
  if (!block) throw new UserError("Claude gaf geen bruikbaar voorstel. Probeer je vraag anders te formuleren.");
  return block.input;
}

// ---------- Publieke functies ----------

async function propose(prompt, { claude = callClaude } = {}) {
  if (typeof prompt !== "string" || !prompt.trim()) throw new UserError("Typ eerst wat je wilt aanpassen.");
  if (prompt.length > 1000) throw new UserError("Je vraag is te lang (maximaal 1000 tekens).");
  const data = await snapshot();
  const raw = await claude(prompt.trim(), data);
  const changes = (Array.isArray(raw.wijzigingen) ? raw.wijzigingen : []).slice(0, 20).map(cleanChange);
  const beschrijving = [];
  for (const c of changes) beschrijving.push(await describe(c));
  return { samenvatting: String(raw.samenvatting || "").slice(0, 600), wijzigingen: changes, beschrijving };
}

async function apply(prompt, summary, changes) {
  if (!Array.isArray(changes) || !changes.length) throw new UserError("Er zijn geen wijzigingen om toe te passen.");
  if (changes.length > 20) throw new UserError("Te veel wijzigingen in één keer.");
  const clean = changes.map(cleanChange);
  const client = await db.pool.connect();
  try {
    await client.query("begin");
    const log = [];
    for (const c of clean) {
      const ent = ENTITIES[c.soort];
      if (c.actie === "toevoegen") {
        const id = "r" + Date.now().toString(36) + Math.random().toString(36).slice(2, 6);
        const { rows } = await client.query("select coalesce(max(sort),0)+1 as s from checklist");
        await client.query(
          "insert into checklist (id, sort, title, note, done) values ($1,$2,$3,$4,coalesce($5,false))",
          [id, rows[0].s, c.velden.title, c.velden.note ?? null, c.velden.done ?? null]
        );
        log.push({ table: ent.table, key: ent.key, keyValue: id, before: null });
        continue;
      }
      const before = await getRow(client, ent, c.sleutel);
      if (!before) throw new UserError(`${ent.label} "${c.sleutel}" bestaat niet (meer).`);
      if (c.actie === "verwijderen") {
        await client.query(`delete from ${ent.table} where ${ent.key}::text = $1`, [c.sleutel]);
      } else {
        const cols = Object.keys(c.velden);
        const sets = cols.map((k, i) => `${k} = $${i + 2}${["route", "points"].includes(ent.fields[k]) ? "::jsonb" : ""}`);
        if (ent.table === "checklist") sets.push("updated_at = now()");
        await client.query(
          `update ${ent.table} set ${sets.join(", ")} where ${ent.key}::text = $1`,
          [c.sleutel, ...cols.map((k) => (["route", "points"].includes(ent.fields[k]) ? JSON.stringify(c.velden[k]) : c.velden[k]))]
        );
      }
      log.push({ table: ent.table, key: ent.key, keyValue: c.sleutel, before });
    }
    const r = await client.query(
      "insert into change_log (prompt, summary, changes) values ($1,$2,$3) returning id",
      [String(prompt || "").slice(0, 1000), String(summary || "").slice(0, 600), JSON.stringify({ wijzigingen: clean, log })]
    );
    await client.query("commit");
    return { id: r.rows[0].id };
  } catch (e) {
    await client.query("rollback").catch(() => {});
    throw e;
  } finally {
    client.release();
  }
}

async function undoLast() {
  const client = await db.pool.connect();
  try {
    await client.query("begin");
    const r = await client.query("select * from change_log where undone_at is null order by id desc limit 1 for update");
    if (!r.rows[0]) throw new UserError("Er is niets om terug te draaien.");
    const entry = r.rows[0];
    for (const l of [...entry.changes.log].reverse()) {
      await client.query(`delete from ${l.table} where ${l.key}::text = $1`, [l.keyValue]);
      if (l.before) {
        await client.query(`insert into ${l.table} select * from json_populate_record(null::${l.table}, $1)`, [JSON.stringify(l.before)]);
      }
    }
    await client.query("update change_log set undone_at = now() where id = $1", [entry.id]);
    await client.query("commit");
    return { id: entry.id, prompt: entry.prompt };
  } catch (e) {
    await client.query("rollback").catch(() => {});
    throw e;
  } finally {
    client.release();
  }
}

async function history() {
  const r = await db.query(
    "select id, prompt, summary, created_at, undone_at, jsonb_array_length(changes->'wijzigingen') as aantal from change_log order by id desc limit 15"
  );
  return r.rows;
}

module.exports = { status, propose, apply, undoLast, history, UserError };
