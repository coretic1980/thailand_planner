// Meerdere reizen: de lijst met reizen, een reis ophalen, en een nieuwe reis laten opzetten door Claude.

const db = require("./db");
const { metReis, cleanValue, UserError } = require("./assistant");

const API_KEY = process.env.ANTHROPIC_API_KEY || "";
const MODEL = process.env.ANTHROPIC_MODEL || "claude-sonnet-5-5";

// ---------- Lezen ----------

const iso = (d) => (d instanceof Date ? d.toISOString().slice(0, 10) : String(d).slice(0, 10));
function vorm(r) {
  return { id: r.id, naam: r.naam, land: r.land, start: iso(r.start_datum), einde: iso(r.eind_datum), tijdzone: r.tijdzone, kaart: r.kaart || {}, notities: r.notities };
}

async function lijst() {
  const r = await db.query("select id, naam, land, to_char(start_datum,'YYYY-MM-DD') as start_datum, to_char(eind_datum,'YYYY-MM-DD') as eind_datum, tijdzone, kaart, notities from reizen order by start_datum, sort, id");
  return r.rows.map(vorm);
}

async function haal(id) {
  const r = await db.query("select id, naam, land, to_char(start_datum,'YYYY-MM-DD') as start_datum, to_char(eind_datum,'YYYY-MM-DD') as eind_datum, tijdzone, kaart, notities from reizen where id = $1", [String(id || "")]);
  return r.rows[0] ? vorm(r.rows[0]) : null;
}

// De reis die je ziet als je er nog geen gekozen hebt: de eerstvolgende (of lopende) reis, anders de laatste
async function standaard() {
  const alle = await lijst();
  if (!alle.length) return null;
  const vandaag = new Date().toISOString().slice(0, 10);
  return alle.find((r) => r.einde >= vandaag) || alle[alle.length - 1];
}

async function verwijder(id) {
  const n = (await db.query("select count(*)::int as n from reizen")).rows[0].n;
  if (n <= 1) throw new UserError("De laatste reis kan niet worden verwijderd.");
  const r = await db.query("delete from reizen where id = $1 returning id", [String(id)]);
  if (!r.rowCount) throw new UserError("Deze reis bestaat niet.");
  return { id };
}

// ---------- Kaart ----------

// Kies het kaartgebied rond alle punten, met wat ruimte eromheen en een prettige verhouding.
// Projectie in de app: x = (lon - lonMin) * schaal * cos, y = (latMax - lat) * schaal.
function kaartInstellingen(punten, labels, gebied) {
  const lats = punten.map((p) => p.lat), lons = punten.map((p) => p.lon);
  let latMin = Math.min(...lats), latMax = Math.max(...lats), lonMin = Math.min(...lons), lonMax = Math.max(...lons);
  const marge = (a, b, min) => { const s = Math.max(b - a, min); const m = s * 0.18; const mid = (a + b) / 2; return [mid - s / 2 - m, mid + s / 2 + m]; };
  [latMin, latMax] = marge(latMin, latMax, 0.6);
  [lonMin, lonMax] = marge(lonMin, lonMax, 0.6);
  const cos = Math.cos(((latMin + latMax) / 2) * Math.PI / 180);
  // Verhouding hoogte/breedte tussen 0,7 en 1,9 houden (een telefoon is staand)
  let breed = (lonMax - lonMin) * cos, hoog = latMax - latMin;
  if (hoog / breed > 1.9) { const extra = (hoog / 1.9 - breed) / cos / 2; lonMin -= extra; lonMax += extra; breed = (lonMax - lonMin) * cos; }
  if (hoog / breed < 0.7) { const extra = (breed * 0.7 - hoog) / 2; latMin -= extra; latMax += extra; hoog = latMax - latMin; }
  const schaal = 370 / breed;
  const r4 = (n) => Math.round(n * 10000) / 10000;
  return {
    latMin: r4(latMin), latMax: r4(latMax), lonMin: r4(lonMin), lonMax: r4(lonMax),
    schaal: Math.round(schaal * 1000) / 1000, cos: Math.round(cos * 10000) / 10000,
    vb: [-24, 0, 394, Math.round(hoog * schaal)],
    land: [], // leeg: de app tekent de kustlijn uit een wereldkaart
    labels, gebied,
  };
}

// ---------- Hulpjes ----------

const slug = (t) => String(t || "").normalize("NFD").replace(/[\u0300-\u036f]/g, "").toLowerCase().replace(/[^a-z0-9]+/g, "-").replace(/^-|-$/g, "").slice(0, 40);
function offset(tz, datum) {
  try {
    const p = new Intl.DateTimeFormat("en-US", { timeZone: tz, timeZoneName: "longOffset" }).formatToParts(new Date(datum + "T12:00:00Z"));
    const t = (p.find((x) => x.type === "timeZoneName") || {}).value || "GMT";
    const m = t.match(/GMT([+-]\d\d):?(\d\d)?/);
    return m ? `${m[1]}:${m[2] || "00"}` : "+00:00";
  } catch (_) { return "+00:00"; }
}
function geldigeTijdzone(tz) {
  try { new Intl.DateTimeFormat("en-US", { timeZone: tz }); return true; } catch (_) { return false; }
}
const tekst = (v, max, leeg = null) => {
  if (v === null || v === undefined || v === "") return leeg;
  if (typeof v !== "string" && typeof v !== "number") throw new UserError("Ongeldige tekst in de opzet.");
  const t = String(v).trim();
  return t ? t.slice(0, max) : leeg;
};
const datums = (start, einde) => {
  const out = [];
  for (let d = new Date(start + "T12:00:00Z"); d <= new Date(einde + "T12:00:00Z"); d.setUTCDate(d.getUTCDate() + 1)) out.push(d.toISOString().slice(0, 10));
  return out;
};
const MND = ["jan", "feb", "mrt", "apr", "mei", "jun", "jul", "aug", "sep", "okt", "nov", "dec"];

// ---------- Claude ----------

const punt = { type: "object", properties: { naam: { type: "string" }, lat: { type: "number" }, lon: { type: "number" } }, required: ["naam", "lat", "lon"] };
const uitstapje = { type: "object", properties: { naam: { type: "string" }, lat: { type: "number" }, lon: { type: "number" }, dag: { type: "string", description: "YYYY-MM-DD" }, tekst: { type: "string", description: "Eén of twee zinnen." } }, required: ["naam", "lat", "lon", "dag", "tekst"] };
const TOOL = {
  name: "nieuwe_reis",
  description: "Lever de complete eerste opzet van de reis.",
  input_schema: {
    type: "object",
    properties: {
      naam: { type: "string", description: "Korte naam, bijvoorbeeld 'Japan · april 2028'." },
      land: { type: "string" },
      gebied: { type: "string", description: "Naam van het gebied dat de kaart toont, bijvoorbeeld 'Midden-Japan'." },
      start: { type: "string", description: "Eerste dag (aankomst), YYYY-MM-DD." },
      einde: { type: "string", description: "Laatste dag (vertrek), YYYY-MM-DD." },
      tijdzone: { type: "string", description: "IANA-tijdzone van het land, bijvoorbeeld 'Asia/Tokyo'." },
      aankomst_tijd: { type: "string", description: "Lokale tijd van aankomst op de eerste dag, HH:MM; gok 12:00 als het niet bekend is." },
      vertrek_tijd: { type: "string", description: "Lokale tijd van vertrek op de laatste dag, HH:MM; gok 12:00 als het niet bekend is." },
      kop: {
        type: "object",
        properties: {
          bovenregel: { type: "string", description: "Bijvoorbeeld 'Gezinsreis · 3–17 april 2028'." },
          titel: { type: "string", description: "Bijvoorbeeld 'Tokyo → Osaka'." },
          ondertitel: { type: "string", description: "Eén zin over het karakter van de reis." },
          afstand: { type: "string", description: "Totale afstand over land, bijvoorbeeld '±900'." },
          reizigers: { type: "integer" },
        },
        required: ["bovenregel", "titel", "ondertitel"],
      },
      overnachtingen: {
        type: "array",
        description: "In reisvolgorde. De data sluiten op elkaar aan en dekken alle nachten.",
        items: {
          type: "object",
          properties: {
            naam: { type: "string", description: "Plaats of gebied." },
            van: { type: "string", description: "Aankomstdatum YYYY-MM-DD." },
            tot: { type: "string", description: "Vertrekdatum YYYY-MM-DD." },
            hotel: { type: "string", description: "Een concrete suggestie, als 'Suggestie: <naam>'; nog niet geboekt." },
            beschrijving: { type: "string", description: "Waarom deze plek en dit hotel, kort." },
            activiteiten: { type: "array", items: { type: "string" }, description: "Maximaal 5." },
            lat: { type: "number" }, lon: { type: "number" },
          },
          required: ["naam", "van", "tot", "hotel", "lat", "lon"],
        },
      },
      dagen: {
        type: "array",
        description: "Precies één per datum van start tot en met einde.",
        items: {
          type: "object",
          properties: {
            datum: { type: "string" }, titel: { type: "string" },
            reistijd: { type: ["string", "null"], description: "Bijvoorbeeld '2,5 u' als je die dag reist, anders null." },
            programma: { type: "array", items: { type: "string" }, description: "3 tot 6 korte regels." },
          },
          required: ["datum", "titel", "programma"],
        },
      },
      ritten: {
        type: "array",
        items: { type: "object", properties: { datum: { type: "string" }, route: { type: "string" }, duur: { type: "string" } }, required: ["datum", "route", "duur"] },
      },
      kaart: {
        type: "object",
        properties: {
          route: { type: "array", items: punt, description: "De reislijn van aankomst tot vertrek, inclusief de overnachtingsplekken." },
          tussenstops: { type: "array", items: uitstapje, description: "Stops onderweg op reisdagen (maximaal 15)." },
          dagtrips: { type: "array", items: uitstapje, description: "Uitstapjes vanaf een overnachting (maximaal 15)." },
          zeeen: { type: "array", items: punt, description: "Namen van zeeën of meren als label op de kaart (maximaal 3), alleen als ze binnen het gebied liggen." },
        },
        required: ["route"],
      },
      reserveringen: {
        type: "array",
        items: {
          type: "object",
          properties: {
            titel: { type: "string" }, toelichting: { type: "string" },
            groep: { type: "string", enum: ["hotels", "vervoer", "activiteiten", "vertrek"] },
            deadline: { type: ["string", "null"] }, deadline_label: { type: ["string", "null"] },
          },
          required: ["titel", "groep"],
        },
      },
      info: {
        type: "object",
        properties: {
          vluchten: { type: "array", items: { type: "object", properties: { label: { type: "string" }, tijd: { type: "string" }, tekst: { type: "string" } }, required: ["label"] } },
          praktisch: { type: "array", items: { type: "object", properties: { label: { type: "string" }, tekst: { type: "string" } }, required: ["label", "tekst"] } },
          noodnummers: { type: "array", items: { type: "object", properties: { label: { type: "string" }, nummer: { type: "string" }, opmerking: { type: "string" } }, required: ["label", "nummer"] } },
          woorden: { type: "array", items: { type: "object", properties: { nederlands: { type: "string" }, vertaling: { type: "string" } }, required: ["nederlands", "vertaling"] } },
        },
      },
      budget: {
        type: "array",
        description: "Geschatte kosten die nog niet geboekt zijn, in euro voor het hele gezelschap en de hele reis.",
        items: { type: "object", properties: { label: { type: "string" }, bedrag: { type: "number" }, toelichting: { type: "string" } }, required: ["label", "bedrag"] },
      },
    },
    required: ["naam", "land", "gebied", "start", "einde", "tijdzone", "kop", "overnachtingen", "dagen", "ritten", "kaart", "reserveringen", "info", "budget"],
  },
};

function systeem() {
  return `Je zet een complete eerste opzet klaar voor een reisapp. De gebruiker beschrijft in gewone taal een reis; jij levert via het hulpmiddel "nieuwe_reis" alles wat de app nodig heeft.

Regels:
- Alles in het Nederlands, kort en concreet, zonder emoji. Houd de stijl van een goede reisgids aan.
- Neem over wat de gebruiker noemt (data, plaatsen, vervoer, wie er meegaat, vluchten). Vul de rest in met een realistische, haalbare planning. Heeft de gebruiker geen data genoemd, kies dan logische data en zeg dat in de ondertitel niet, maar zet ze gewoon in start en einde.
- Overnachtingen: de data sluiten op elkaar aan (vertrek van de ene = aankomst van de volgende) en dekken alle nachten van start tot einde. Gebruik niet meer dan 8 plekken.
- Hotels zijn suggesties, nog niet geboekt: schrijf "Suggestie: <naam>". Verzin geen prijzen, boekingsnummers of links.
- Dagen: precies één per datum, van start tot en met einde. Reisdagen hebben een reistijd en beginnen met de titel "Naar <plek>".
- Coördinaten: de echte ligging in decimale graden.
- De kaart: de route loopt in reisvolgorde langs alle overnachtingen. Uitstapjes (dagtrips) en stops onderweg (tussenstops) hebben een dag binnen de reis en een korte tekst.
- Reserveringen: wat er vóór vertrek geregeld moet worden (hotels boeken, vervoer, tickets, papieren). Zet een deadline alleen als die echt bekend is.
- Info: vluchten (als de gebruiker ze noemt, anders een regel "Heen" en "Terug" met wat je weet), praktische info voor het land (geld, stroom, vervoer, weer in die periode, gewoontes), de echte noodnummers van het land en 4 tot 6 handige woorden in de taal van het land (met uitspraak als het schrift anders is).
- Budget: realistische schattingen voor eten en drinken, uitstapjes en entree, en vervoer ter plaatse, in euro voor het hele gezelschap en de hele reis. Zet in de toelichting waarop de schatting is gebaseerd (bijvoorbeeld een bedrag per dag).`;
}

async function vraagClaude(beschrijving) {
  if (!API_KEY) throw new UserError("ANTHROPIC_API_KEY is niet ingesteld op de server.");
  const ctrl = new AbortController();
  const timer = setTimeout(() => ctrl.abort(), 240000);
  let res;
  try {
    res = await fetch("https://api.anthropic.com/v1/messages", {
      method: "POST",
      signal: ctrl.signal,
      headers: { "content-type": "application/json", "x-api-key": API_KEY, "anthropic-version": "2023-06-01" },
      body: JSON.stringify({
        model: MODEL,
        max_tokens: 20000,
        system: systeem(),
        tools: [TOOL],
        tool_choice: { type: "tool", name: "nieuwe_reis" },
        messages: [{ role: "user", content: `Vandaag is het ${new Date().toISOString().slice(0, 10)}.\n\nDe reis:\n${beschrijving}` }],
      }),
    });
  } catch (e) {
    throw new UserError(e.name === "AbortError" ? "Claude deed er te lang over. Probeer het opnieuw, eventueel met een kortere beschrijving." : "Claude is nu niet bereikbaar. Probeer het later opnieuw.");
  } finally {
    clearTimeout(timer);
  }
  if (!res.ok) {
    const body = await res.text().catch(() => "");
    console.error("Claude API-fout (nieuwe reis)", res.status, body.slice(0, 500));
    if (res.status === 401) throw new UserError("De Anthropic API-sleutel wordt geweigerd. Controleer ANTHROPIC_API_KEY.");
    if (res.status === 429) throw new UserError("Even te veel verzoeken bij Claude. Probeer het over een minuut opnieuw.");
    throw new UserError("Claude gaf een foutmelding. Probeer het opnieuw.");
  }
  const json = await res.json();
  if (json.stop_reason === "max_tokens") throw new UserError("De opzet werd te lang. Probeer een kortere reis of minder details.");
  const block = (json.content || []).find((b) => b.type === "tool_use" && b.name === "nieuwe_reis");
  if (!block) throw new UserError("Claude gaf geen bruikbare opzet. Probeer je beschrijving anders te formuleren.");
  return block.input;
}

// ---------- Nieuwe reis ----------

// Zet de opzet van Claude om naar rijen voor de database (met controle). Gooit UserError bij onzin.
function bouw(o) {
  const naam = tekst(o.naam, 80);
  if (!naam) throw new UserError("De opzet heeft geen naam.");
  const start = String(o.start || ""), einde = String(o.einde || "");
  if (!/^\d{4}-\d\d-\d\d$/.test(start) || !/^\d{4}-\d\d-\d\d$/.test(einde) || einde < start) throw new UserError("De opzet heeft geen geldige begin- en einddatum.");
  const alleDagen = datums(start, einde);
  if (alleDagen.length > 60) throw new UserError("Een reis kan maximaal 60 dagen duren.");
  const tijdzone = geldigeTijdzone(o.tijdzone) ? o.tijdzone : "Europe/Amsterdam";
  const ov = (Array.isArray(o.overnachtingen) ? o.overnachtingen : []).slice(0, 12);
  if (!ov.length) throw new UserError("De opzet heeft geen overnachtingen.");
  const k = o.kaart || {};
  const pts = (l) => (Array.isArray(l) ? l : []).filter((p) => p && Number.isFinite(Number(p.lat)) && Number.isFinite(Number(p.lon))).map((p) => ({ ...p, lat: Number(p.lat), lon: Number(p.lon) }));
  const route = pts(k.route).slice(0, 30), tussen = pts(k.tussenstops).slice(0, 15), trips = pts(k.dagtrips).slice(0, 15);
  const alle = [...ov.map((b) => ({ lat: Number(b.lat), lon: Number(b.lon) })), ...route, ...tussen, ...trips].filter((p) => Number.isFinite(p.lat) && Number.isFinite(p.lon) && Math.abs(p.lat) <= 85 && Math.abs(p.lon) <= 180);
  if (!alle.length) throw new UserError("De opzet heeft geen plekken met coördinaten.");
  const kaart = kaartInstellingen(alle, pts(k.zeeen).slice(0, 3).map((p) => ({ naam: tekst(p.naam, 40), lat: p.lat, lon: p.lon })), tekst(o.gebied, 60) || tekst(o.land, 60) || naam);
  const reis = { id: null, naam, land: tekst(o.land, 60), start, einde, tijdzone, kaart, notities: null };

  return metReis(reis, () => {
    const C = cleanValue;
    // Overnachtingen
    const ids = new Set();
    const bases = ov.map((b, i) => {
      let id = slug(b.naam).slice(0, 12) || "plek";
      while (ids.has(id)) id += "-" + (i + 1);
      ids.add(id);
      const van = String(b.van || ""), tot = String(b.tot || "");
      const dv = new Date(van + "T12:00:00Z"), dt = new Date(tot + "T12:00:00Z");
      const n = Math.round((dt - dv) / 864e5);
      const datumTekst = isNaN(n) ? tekst(b.van, 30, "?") : dv.getUTCMonth() === dt.getUTCMonth()
        ? `${dv.getUTCDate()}–${dt.getUTCDate()} ${MND[dt.getUTCMonth()]}` : `${dv.getUTCDate()} ${MND[dv.getUTCMonth()]} – ${dt.getUTCDate()} ${MND[dt.getUTCMonth()]}`;
      const plek = C("text", tekst(b.naam, 60) || `Plek ${i + 1}`);
      const hotel = C("text", tekst(b.hotel, 120) || "Nog te kiezen");
      return {
        id, nr: i + 1, name: plek, dates: datumTekst, nights: isNaN(n) ? "?" : `${n} ${n === 1 ? "nacht" : "nachten"}`,
        lat: C("lat", Number(b.lat)), lon: C("lon", Number(b.lon)), hotel,
        why: C("textnull", tekst(b.beschrijving, 300)), todo: C("list", (Array.isArray(b.activiteiten) ? b.activiteiten : []).slice(0, 8).map((x) => tekst(x, 200)).filter(Boolean)),
        unsplash_query: slug(plek), maps_query: `${hotel.replace(/^Suggestie:\s*/i, "")}, ${plek}`,
      };
    });
    // Dagen: precies één per datum
    const perDatum = new Map((Array.isArray(o.dagen) ? o.dagen : []).map((d) => [String(d.datum || ""), d]));
    const days = alleDagen.map((datum) => {
      const d = perDatum.get(datum) || {};
      return {
        day_date: datum, title: C("text", tekst(d.titel, 120) || "Vrije dag"),
        drive: C("textnull", tekst(d.reistijd, 40)),
        items: C("list", (Array.isArray(d.programma) ? d.programma : []).slice(0, 8).map((x) => tekst(x, 200)).filter(Boolean)),
      };
    });
    const legs = (Array.isArray(o.ritten) ? o.ritten : []).slice(0, 30).map((l, i) => {
      const d = String(l.datum || "");
      const label = /^\d{4}-\d\d-\d\d$/.test(d) ? `${Number(d.slice(8))} ${MND[Number(d.slice(5, 7)) - 1]}` : tekst(l.datum, 20, "?");
      return { sort: i + 1, date_label: C("text", label), route: C("text", tekst(l.route, 200) || "?"), duration: C("text", tekst(l.duur, 30) || "?") };
    });
    const punten = (l) => C("points", l.map((p) => ({ naam: tekst(p.naam, 60) || "?", lat: p.lat, lon: p.lon, dag: alleDagen.includes(p.dag) ? p.dag : null, tekst: tekst(p.tekst, 250) })));
    const kaartRij = {
      route: route.length >= 2 ? C("route", route.map((p) => ({ naam: tekst(p.naam, 60) || "?", lat: p.lat, lon: p.lon }))) : bases.map((b) => ({ naam: b.name, lat: b.lat, lon: b.lon })),
      tussenstops: punten(tussen), dagtrips: punten(trips),
    };
    const checklist = (Array.isArray(o.reserveringen) ? o.reserveringen : []).slice(0, 30).map((c, i) => ({
      id: "r" + (i + 1), sort: i + 1, title: C("text", tekst(c.titel, 200) || "?"), note: C("textnull", tekst(c.toelichting, 300)),
      groep: ["hotels", "vervoer", "activiteiten", "vertrek"].includes(c.groep) ? c.groep : null,
      deadline: /^\d{4}-\d\d-\d\d$/.test(String(c.deadline || "")) ? c.deadline : null, deadline_label: C("textnull", tekst(c.deadline_label, 120)),
    }));
    // Info: kop, vluchten, praktisch, noodnummers, woorden
    const kop = o.kop || {};
    const tijd = (t) => (/^\d\d:\d\d$/.test(String(t || "")) ? t : "12:00");
    const info = [
      ["hero_label", "algemeen", "Bovenregel", tekst(kop.bovenregel, 120) || naam, null],
      ["hero_titel", "algemeen", "Titel", tekst(kop.titel, 80) || tekst(o.land, 60) || naam, null],
      ["hero_tekst", "algemeen", "Ondertitel", tekst(kop.ondertitel, 300), null],
      ["hero_foto", "algemeen", "Grote foto", null, null],
      ["reis_start", "algemeen", "Begin reis (aankomst)", `${start}T${tijd(o.aankomst_tijd)}:00${offset(tijdzone, start)}`, null],
      ["reis_einde", "algemeen", "Einde reis (vertrek)", `${einde}T${tijd(o.vertrek_tijd)}:00${offset(tijdzone, einde)}`, null],
      ["reisdagen", "algemeen", "Aantal dagen", String(alleDagen.length), null],
      ["afstand", "algemeen", "Afstand in km", tekst(kop.afstand, 20), null],
      ["fotos", "algemeen", "Foto's", null, null],
      ["reizigers", "algemeen", "Aantal reizigers", String(Number.isInteger(kop.reizigers) && kop.reizigers > 0 && kop.reizigers < 50 ? kop.reizigers : 4), null],
    ].map(([id, sectie, label, waarde, t], i) => ({ id, sectie, sort: i + 1, label, waarde, tekst: t }));
    const I = o.info || {};
    const regels = (lijst, sectie, prefix, map) => (Array.isArray(lijst) ? lijst : []).slice(0, 12).map((x, i) => ({ id: `${prefix}${i + 1}`, sectie, sort: i + 1, ...map(x) }))
      .filter((r) => r.label);
    info.push(
      ...regels(I.vluchten, "vlucht", "vlucht_", (x) => ({ label: tekst(x.label, 60), waarde: tekst(x.tijd, 20), tekst: tekst(x.tekst, 300) })),
      ...regels(I.praktisch, "praktisch", "p_", (x) => ({ label: tekst(x.label, 60), waarde: null, tekst: tekst(x.tekst, 1000) })),
      ...regels(I.noodnummers, "nood", "nood_", (x) => ({ label: tekst(x.label, 60), waarde: tekst(x.nummer, 20), tekst: tekst(x.opmerking, 120) })),
      ...regels(I.woorden, "woorden", "woord_", (x) => ({ label: tekst(x.nederlands, 60), waarde: null, tekst: tekst(x.vertaling, 200) })),
    );
    const budget = (Array.isArray(o.budget) ? o.budget : []).slice(0, 10).map((b, i) => ({
      id: "b" + (i + 1), sort: i + 1, label: C("text", tekst(b.label, 80) || "?"), bedrag: C("prijs", b.bedrag ?? null), toelichting: C("textlong", tekst(b.toelichting, 1000)), geboekt: false,
    }));
    return { reis, bases, days, legs, kaart: kaartRij, checklist, info, budget };
  });
}

async function nieuw(beschrijving, { claude = vraagClaude } = {}) {
  if (typeof beschrijving !== "string" || beschrijving.trim().length < 10) throw new UserError("Beschrijf de reis in een paar zinnen: waarheen, wanneer, met wie en hoe je wilt reizen.");
  if (beschrijving.length > 3000) throw new UserError("De beschrijving is te lang (maximaal 3000 tekens).");
  const opzet = await claude(beschrijving.trim());
  const d = bouw(opzet);
  // Unieke id, bijvoorbeeld japan-2028
  let basis = slug(`${d.reis.land || d.reis.naam}-${d.reis.start.slice(0, 4)}`) || "reis";
  let id = basis, n = 2;
  while ((await db.query("select 1 from reizen where id = $1", [id])).rowCount) id = `${basis}-${n++}`;
  d.reis.id = id;
  const client = await db.pool.connect();
  try {
    await client.query("begin");
    await client.query(
      "insert into reizen (id, naam, land, start_datum, eind_datum, tijdzone, kaart, notities, sort) values ($1,$2,$3,$4,$5,$6,$7::jsonb,$8,(select coalesce(max(sort),0)+1 from reizen))",
      [id, d.reis.naam, d.reis.land, d.reis.start, d.reis.einde, d.reis.tijdzone, JSON.stringify(d.reis.kaart), `- Deze reis is opgezet uit de beschrijving: ${beschrijving.trim().slice(0, 600).replace(/\n+/g, " ")}`]
    );
    for (const b of d.bases) {
      await client.query(
        "insert into bases (reis_id, id, nr, name, dates, nights, lat, lon, hotel, why, todo, unsplash_query, maps_query) values ($1,$2,$3,$4,$5,$6,$7,$8,$9,$10,$11,$12,$13)",
        [id, b.id, b.nr, b.name, b.dates, b.nights, b.lat, b.lon, b.hotel, b.why, b.todo, b.unsplash_query, b.maps_query]
      );
    }
    for (const x of d.days) await client.query("insert into days (reis_id, day_date, title, drive, items) values ($1,$2,$3,$4,$5)", [id, x.day_date, x.title, x.drive, x.items]);
    for (const l of d.legs) await client.query("insert into legs (reis_id, sort, date_label, route, duration) values ($1,$2,$3,$4,$5)", [id, l.sort, l.date_label, l.route, l.duration]);
    await client.query("insert into kaart (reis_id, id, route, tussenstops, dagtrips) values ($1,'kaart',$2::jsonb,$3::jsonb,$4::jsonb)",
      [id, JSON.stringify(d.kaart.route), JSON.stringify(d.kaart.tussenstops), JSON.stringify(d.kaart.dagtrips)]);
    for (const c of d.checklist) {
      await client.query("insert into checklist (reis_id, id, sort, title, note, done, groep, deadline, deadline_label) values ($1,$2,$3,$4,$5,false,$6,$7,$8)",
        [id, c.id, c.sort, c.title, c.note, c.groep, c.deadline, c.deadline_label]);
    }
    for (const r of d.info) await client.query("insert into info (reis_id, id, sectie, sort, label, waarde, tekst) values ($1,$2,$3,$4,$5,$6,$7)", [id, r.id, r.sectie, r.sort, r.label, r.waarde, r.tekst]);
    for (const b of d.budget) await client.query("insert into budget (reis_id, id, sort, label, bedrag, toelichting, geboekt) values ($1,$2,$3,$4,$5,$6,$7)", [id, b.id, b.sort, b.label, b.bedrag, b.toelichting, b.geboekt]);
    await client.query("commit");
  } catch (e) {
    await client.query("rollback").catch(() => {});
    throw e;
  } finally {
    client.release();
  }
  return { id, naam: d.reis.naam };
}

module.exports = { lijst, haal, standaard, verwijder, nieuw, bouw, kaartInstellingen };
