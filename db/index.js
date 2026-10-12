// Databaseverbinding en automatische setup.
// Bij de eerste start worden de tabellen aangemaakt en gevuld met de reisgegevens.
// Daarna blijven je wijzigingen (zoals afgevinkte reserveringen) gewoon staan.

const fs = require("fs");
const path = require("path");
const { Pool } = require("pg");

if (!process.env.DATABASE_URL) {
  console.error("DATABASE_URL ontbreekt. Zet de Neon connection string in je omgevingsvariabelen.");
  process.exit(1);
}

const isLocal = /@(localhost|127\.0\.0\.1)[:/]/.test(process.env.DATABASE_URL);
const pool = new Pool({
  connectionString: process.env.DATABASE_URL,
  ssl: isLocal ? false : { rejectUnauthorized: true },
  max: 5,
});

const query = (text, params) => pool.query(text, params);

async function init() {
  const schema = fs.readFileSync(path.join(__dirname, "schema.sql"), "utf8");
  await query(schema);
  const { rows } = await query("select count(*)::int as n from bases");
  if (rows[0].n === 0) {
    const seed = fs.readFileSync(path.join(__dirname, "seed.sql"), "utf8");
    await query(seed);
    console.log("Database gevuld met de reisgegevens.");
  }
  const k = await query("select count(*)::int as n from kaart");
  if (k.rows[0].n === 0) {
    const kaartSeed = fs.readFileSync(path.join(__dirname, "kaart-seed.sql"), "utf8");
    await query(kaartSeed);
    console.log("Kaartgegevens toegevoegd.");
  }
  await migrate();
}

// Wijzigingen in de reisgegevens staan als losse SQL-bestanden in db/migraties/.
// Elk bestand wordt precies één keer uitgevoerd, in volgorde van de bestandsnaam.
async function migrate() {
  await query("create table if not exists migraties (naam text primary key, toegepast timestamptz not null default now())");
  const dir = path.join(__dirname, "migraties");
  if (!fs.existsSync(dir)) return;
  const files = fs.readdirSync(dir).filter((f) => f.endsWith(".sql")).sort();
  const done = new Set((await query("select naam from migraties")).rows.map((r) => r.naam));
  for (const f of files) {
    if (done.has(f)) continue;
    const sql = fs.readFileSync(path.join(dir, f), "utf8");
    const client = await pool.connect();
    try {
      await client.query("begin");
      await client.query(sql);
      await client.query("insert into migraties (naam) values ($1)", [f]);
      await client.query("commit");
      console.log("Wijziging toegepast:", f);
    } catch (e) {
      await client.query("rollback").catch(() => {});
      throw new Error(`Wijziging ${f} mislukt: ${e.message}`);
    } finally {
      client.release();
    }
  }
}

module.exports = { query, init, pool };
