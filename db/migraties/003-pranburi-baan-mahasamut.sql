-- 4–6 feb: Baan Mahasamut Pranburi in plaats van Prachuap Khiri Khan.
-- 2 kamers × 2 nachten, € 195,13 via Agoda, direct betalen, niet restitueerbaar.
-- Prachuap Khiri Khan blijft een stop onderweg naar Chumphon (6 feb).

update bases set
  name = 'Pranburi',
  hotel = 'Baan Mahasamut Pranburi',
  alternative = null,
  why = '2 kamers × 2 nachten voor € 195,13 via Agoda. Direct betalen, niet restitueerbaar. Rustig tussen de rijstvelden en bergen, met zwembad; vlak bij Sam Roi Yot.',
  todo = array['Phraya Nakhon-grot in Sam Roi Yot (dichtbij)','Safari met wilde olifanten in Kui Buri','Zonsondergang op Khao Daeng','Fietsen of zwemmen bij het huis']::text[],
  lat = 12.3075, lon = 99.9754, links = true,
  unsplash_query = 'sam-roi-yot',
  maps_query = 'Baan Mahasamut Pranburi',
  photo = '05-sam-roi-yot-grot',
  photo_caption = 'Phraya Nakhon-grot in Sam Roi Yot, vlak bij het huis',
  gallery = '[["04-maeklong","Maeklong-spoorwegmarkt, onderweg"],["07-kui-buri-olifant","Olifant, Kui Buri"],["06-prachuap","Prachuap Khiri Khan, onderweg naar Chumphon"]]'::jsonb
  where id = 'pkk';

update days set title = 'Naar Pranburi', drive = '3,5 u',
  items = array['Huurauto ophalen','Maeklong-spoorwegmarkt (check de treintijden)','Aankomst bij Baan Mahasamut, zwembad met uitzicht op de bergen']::text[]
  where day_date = '2027-02-04';
update days set title = 'Sam Roi Yot en Kui Buri', drive = '2 u',
  items = array['Ochtend: Phraya Nakhon-grot, licht rond 10–11 uur (kort rijden)','Laat in de middag: safari met wilde olifanten in Kui Buri','Op de terugweg: zonsondergang op Khao Daeng']::text[]
  where day_date = '2027-02-05';
update days set title = 'Naar Chumphon', drive = '4 u',
  items = array['Chinees Nieuwjaar: reken op drukte langs de kust','Onderweg: strand van Ao Manao en de apenberg in Prachuap Khiri Khan','Onderweg: de tempel Wat Thang Sai bij Ban Krut','Avond: zonsondergang en vis aan het strand van Thung Wua Laen']::text[]
  where day_date = '2027-02-06';

update legs set route = 'Bangkok → Maeklong → Pranburi', duration = '3,5 u' where sort = 1;
update legs set route = 'Pranburi → Prachuap → Chumphon', duration = '4 u' where sort = 2;

update checklist set
  title = 'Baan Mahasamut Pranburi, 4–6 feb',
  note = '2 kamers × 2 nachten, € 195,13 via Agoda. Direct betalen, niet restitueerbaar',
  updated_at = now()
  where id = 'h2';

-- Kaart: Pranburi in de route, Prachuap Khiri Khan wordt een tussenstop
update kaart set route = (
  select jsonb_agg(case when e->>'naam' = 'Prachuap Khiri Khan'
                        then '{"naam":"Pranburi","lat":12.3075,"lon":99.9754}'::jsonb else e end order by o)
    from jsonb_array_elements(route) with ordinality t(e, o))
  where id = 'kaart';
update kaart set tussenstops = jsonb_insert(tussenstops, '{1}', '{"naam":"Prachuap Khiri Khan","lat":11.745,"lon":99.79}'::jsonb)
  where id = 'kaart' and not tussenstops @> '[{"naam":"Prachuap Khiri Khan"}]'::jsonb;
