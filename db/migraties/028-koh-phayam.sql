-- Chumphon vervangen door Koh Phayam (Ranong), 6–8 feb: Barefoot Project (voorheen Baan Klong Kleng),
-- 1 standaard tweepersoonskamer + 1 villa, € 409,21 via Booking.com. Auto blijft bij de pier in Ranong.

update bases set
  name = 'Koh Phayam',
  hotel = 'Barefoot Project (voorheen Baan Klong Kleng)',
  alternative = null,
  why = '1 standaard tweepersoonskamer + 1 villa, 2 nachten voor € 409,21 via Booking.com (met korting voor online betalen). Direct aan Aow Khao Kwai (Buffalo Bay) met zonsondergang boven zee; restaurant aan het strand, kajaks en sup-boards. Het eiland heeft geen auto''s: scooter of motortaxi.',
  todo = array['Zonsondergang aan Aow Khao Kwai (Buffalo Bay)','Met de scooter of motortaxi over het eiland (geen auto''s)','Lang strand van Aow Yai: zwemmen en bodyboarden','Kajak of sup van het resort','Gouden Boeddha bij het dorp en de pier']::text[],
  lat = 9.738, lon = 98.39, links = true,
  unsplash_query = 'koh-phayam', maps_query = 'Barefoot Project Koh Phayam',
  photo = null, photo_caption = null,
  gallery = '[["18-tempel-ban-krut","Tempel bij Ban Krut, onderweg"]]'::jsonb,
  hotel_url = null, hotel_foto = null,
  prijs = 409.21
  where id = 'chp';

update days set items = array['Ochtend: Phraya Nakhon-grot, licht tussen 9 en 12 uur (entree 200 baht p.p., stevige schoenen)','Daarna: vlonderpad van Bueng Bua (ca. 20 min rijden)','Lunch en rust bij het zwembad','Laat in de middag: safari met wilde olifanten in Kui Buri (ca. 1 uur rijden)','Nog energie? Vrijdagavond Cicada Market in Hua Hin, 16–23 uur (ca. 40 min)']::text[]
  where day_date = '2027-02-05';
update days set title = 'Naar Koh Phayam', drive = '5–5,5 u', photo = '18-tempel-ban-krut',
  items = array['Vroeg vertrekken (ca. 07:00): lange reisdag van ca. 380 km via Chumphon naar Ranong','Chinees Nieuwjaar: reken op drukte langs de weg','Onderweg: korte stop bij het strand van Ao Manao in Prachuap Khiri Khan of de tempel Wat Thang Sai bij Ban Krut','Auto parkeren bij de pier in Ranong; hij blijft daar 2 nachten staan','Speedboot naar Koh Phayam (ca. 40 min, ongeveer elk half uur tot ca. 16:30)','Avond: zonsondergang aan Aow Khao Kwai']::text[]
  where day_date = '2027-02-06';
update days set title = 'Koh Phayam', drive = null, photo = null,
  items = array['Ochtend: met de scooter of motortaxi naar het lange strand van Aow Yai','Middag: kajakken of suppen vanaf het resort','Avond: zonsondergang en eten aan Buffalo Bay']::text[]
  where day_date = '2027-02-07';
update days set title = 'Naar Khao Sok', drive = '3–3,5 u',
  items = array['Ochtend: speedboot terug naar Ranong (ca. 40 min) en de auto ophalen','Rit langs de Andamankust via Kuraburi en Takua Pa naar Khao Sok (ca. 3 uur)','Laat in de middag: tuben over de Sok-rivier','Avond: nachtsafari in de jungle']::text[]
  where day_date = '2027-02-08';

update legs set route = 'Pranburi → Chumphon → Ranong, boot naar Koh Phayam', duration = '5–5,5 u' where sort = 2;
update legs set route = 'Koh Phayam, boot naar Ranong → Khao Sok', duration = '3–3,5 u' where sort = 3;

update checklist set title = 'Barefoot Project, Koh Phayam, 6–8 feb',
  note = '1 standaard tweepersoonskamer + 1 villa, € 409,21 via Booking.com (online betalen). Check of de standaardkamer airco heeft. Annuleer Nana Beach Hotel in Chumphon (later betalen)', updated_at = now()
  where id = 'chp';
update checklist set title = 'Parkeren bij de pier in Ranong, 6–8 feb',
  note = 'Vraag het resort of de bootmaatschappij waar de auto 2 nachten veilig kan staan', updated_at = now()
  where id = 'snork';

update info set tekst = 'Za 6 feb 2027, de lange rijdag naar Ranong en Koh Phayam. Reken op drukte langs de weg; vertrek vroeg.' where id = 'nieuwjaar';
update info set waarde = 'Roadtrip langs de Golf en de Andamanzee, meestal maximaal ongeveer 4 uur rijden per dag (6 feb is een lange dag).' where id = 'hero_tekst';

-- Kaart: route via Chumphon en Ranong naar Koh Phayam en terug; pier Ranong als stop; Mu Ko Chumphon eraf
update kaart set route = (
  select jsonb_agg(x order by o, s) from (
    select e as x, o, 0 as s from jsonb_array_elements(route) with ordinality t(e, o) where e->>'naam' <> 'Chumphon'
    union all
    select v, o, s from jsonb_array_elements(route) with ordinality t(e, o),
      jsonb_array_elements('[{"naam":"Chumphon (onderweg)","lat":10.493,"lon":99.18},{"naam":"Ranong","lat":9.966,"lon":98.635},{"naam":"Koh Phayam","lat":9.738,"lon":98.39},{"naam":"Ranong (terug)","lat":9.966,"lon":98.635}]'::jsonb) with ordinality u(v, s)
      where e->>'naam' = 'Chumphon') q),
  tussenstops = tussenstops || '[{"naam":"Ranong","lat":9.966,"lon":98.635,"dag":"2027-02-06","tekst":"Pier van Ranong: auto parkeren en met de speedboot naar Koh Phayam (ca. 40 min). Op 8 feb terug en de auto ophalen."}]'::jsonb,
  dagtrips = (select coalesce(jsonb_agg(case when e->>'naam' = 'Bueng Bua' then jsonb_set(e, '{dag}', '"2027-02-05"') else e end order by o), '[]'::jsonb)
    from jsonb_array_elements(dagtrips) with ordinality t(e, o) where e->>'naam' <> 'Mu Ko Chumphon')
  where id = 'kaart' and route @> '[{"naam":"Chumphon"}]'::jsonb;
