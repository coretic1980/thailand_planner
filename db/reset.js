// Zet de database terug naar de oorspronkelijke reisgegevens.
// Let op: dit wist ook je afgevinkte reserveringen.
// Gebruik: DATABASE_URL=... npm run db:reset

const db = require("./index");

(async () => {
  await db.query("drop table if exists change_log, checklist, legs, days, kaart, bases cascade");
  await db.init();
  console.log("Database opnieuw opgebouwd.");
  await db.pool.end();
})().catch((e) => {
  console.error(e);
  process.exit(1);
});
