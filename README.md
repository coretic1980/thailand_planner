# Thailand Reisapp 2027

Reisapp voor de roadtrip Bangkok → Phuket (3–17 februari 2027).
Node/Express-app op Render, met de reisgegevens in Neon (Postgres).

## Wat zit erin

| Pad | Inhoud |
|---|---|
| `server.js` | Express-server: serveert de app en de API |
| `assistant.js` | Aanpassen via prompts: Claude-voorstel, controle, toepassen, terugdraaien |
| `db/schema.sql` | Tabellen: `bases`, `days`, `legs`, `checklist`, `kaart`, `change_log` |
| `db/kaart-seed.sql` | Routelijn, tussenstops en dagtrips voor de kaart |
| `db/seed.sql` | Alle reisgegevens (overnachtingen, dagprogramma, ritten, reserveringen) |
| `db/index.js` | Databaseverbinding; maakt bij de eerste start de tabellen aan en vult ze |
| `public/` | De app zelf (`index.html`) en de 15 foto's |
| `render.yaml` | Render-configuratie (regio Frankfurt, net als je Neon-database) |

## API

| Route | Doet |
|---|---|
| `GET /api/trip` | Alle reisgegevens in één JSON |
| `PATCH /api/checklist/:id` | Reservering afvinken, body `{ "done": true }` |
| `POST /api/assistant/propose` | Voorstel laten maken, body `{ "prompt": "..." }` |
| `POST /api/assistant/apply` | Voorstel toepassen |
| `POST /api/assistant/undo` | Laatste wijziging terugdraaien |
| `GET /api/assistant/history` | Laatste 15 wijzigingen |
| `GET /healthz` | Health check voor Render |

## Deployen

### 1. Neon-database
1. Maak in Neon een nieuw project aan, bijvoorbeeld `thailand-reisapp`, regio **Frankfurt (aws-eu-central-1)**.
2. Kopieer de **connection string** (de "pooled" variant). Die ziet er zo uit:
   `postgresql://user:wachtwoord@ep-xxx-pooler.eu-central-1.aws.neon.tech/neondb?sslmode=require`

Je hoeft zelf geen SQL te draaien: de app maakt bij de eerste start de tabellen aan en vult ze.

### 2. GitHub
Zet deze map in een nieuwe (private) GitHub-repository.

### 3. Render
1. Kies in Render **New → Blueprint** en selecteer de repository. Render leest `render.yaml`.
2. Vul de omgevingsvariabelen in:
   - `DATABASE_URL`: de Neon connection string
   - `APP_PASSWORD`: een wachtwoord voor de app (aanbevolen, want er staan hotels en reisdata in). Laat je dit leeg, dan is de app openbaar en staat Aanpassen uit.
   - `ANTHROPIC_API_KEY`: nodig voor het tabblad Aanpassen.
3. Deploy. In de logs zie je bij de eerste start: `Database gevuld met de reisgegevens.`

De app toont eerst een inlogscherm. Na het juiste wachtwoord blijf je 30 dagen ingelogd op dat apparaat; uitloggen kan onder Info. Verander je `APP_PASSWORD`, dan moet iedereen opnieuw inloggen. Na 10 foute pogingen in een kwartier blokkeert de app dat IP-adres tijdelijk.

### Lokaal draaien
```bash
npm install
DATABASE_URL="postgresql://..." APP_PASSWORD="geheim" npm start
# open http://localhost:3000
```

## Aanpassen via prompts (tabblad "Aanpassen")
Typ in gewone taal wat er moet veranderen, bijvoorbeeld:
- "Verplaats de klimcursus op Railay naar 13 februari"
- "Voeg een reservering toe voor een Thaise kookcursus in Krabi"
- "Zet het hotel in Krabi op Dusit Thani Krabi"
- "Vink de reisverzekering af"

Zo werkt het:
1. De server stuurt je vraag plus de huidige reisgegevens naar Claude.
2. Claude doet een voorstel. Je ziet per wijziging de oude en nieuwe waarde.
3. Pas na **Toepassen** wordt het in Neon opgeslagen.
4. Elke wijziging komt in de tabel `change_log`. Met **Laatste wijziging terugdraaien** zet je hem terug, ook meerdere keren achter elkaar.

Wat Claude mag aanpassen:
| Soort | Velden | Toevoegen/verwijderen |
|---|---|---|
| Dag | titel, rijtijd, programma, foto | nee |
| Overnachting | naam, data, nachten, hotel, alternatief, beschrijving, activiteiten, ligging op de kaart | nee |
| Kaart | routelijn, tussenstops, dagtrips | nee |
| Rit | datum, route, duur | nee |
| Reservering | titel, toelichting, geregeld | ja |

De server controleert elk voorstel opnieuw: alleen deze velden, alleen bestaande foto's, alleen plekken binnen het kaartgebied (Zuid-Thailand), maximaal 20 wijzigingen per keer.

Verandert de route, dan past Claude in één voorstel ook de kaart, de ritten en het dagprogramma aan.

Benodigd op Render:
- `ANTHROPIC_API_KEY`: maak een sleutel aan op console.anthropic.com. Kosten per voorstel zijn een paar cent.
- `APP_PASSWORD` moet gezet zijn; zonder wachtwoord staat Aanpassen uit.
- Optioneel `ANTHROPIC_MODEL` (standaard `claude-sonnet-5-5`).
- Maximaal 30 voorstellen per uur, om je API-tegoed te beschermen.

## Al gedeployd vóór 7 oktober?
De startgegevens worden alleen geladen in een lege database. Heb je de app al eerder gedeployd, draai dan één keer `npm run db:reset` om de nieuwe indeling (met Chumphon) te laden.

## Gegevens aanpassen zonder prompts
- Kleine wijzigingen (een hotel, een activiteit): pas de rij aan in de Neon SQL Editor, bijvoorbeeld
  `update bases set hotel = 'Nieuw hotel' where id = 'kr';`
- Alles opnieuw vanuit `db/seed.sql` laden: `DATABASE_URL=... npm run db:reset`
  (let op: dit wist ook de afgevinkte reserveringen).

## Goed om te weten
- Op het gratis plan van Render slaapt de app na 15 minuten zonder bezoek. Het eerste bezoek daarna duurt ongeveer een halve minuut.
- De foto's komen van Unsplash; de fotografen staan in de app onder Info.
