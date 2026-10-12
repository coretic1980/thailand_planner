-- Krabi 10–13 feb: Railay Great View Resort & Spa (Railay East), € 305 via Agoda.
-- Railay is alleen per boot bereikbaar: auto parkeren bij Ao Nam Mao, longtail naar het resort.

update bases set
  name = 'Krabi (Railay)',
  hotel = 'Railay Great View Resort & Spa',
  alternative = null,
  why = '2 kamers × 3 nachten voor € 305 via Agoda. Houten bungalows op palen tegen de jungleheuvel, met zwembad en uitzicht op zee. Alleen per boot bereikbaar: het resort regelt de longtail vanaf Ao Nam Mao naar de eigen pier.',
  hotel_url = 'https://www.agoda.com/nl-nl/railay-great-view-resort/hotel/krabi-th.html?checkIn=2027-02-10&los=3&rooms=2&adults=3&children=1&childAges=15&currencyCode=EUR',
  maps_query = 'Railay Great View Resort & Spa',
  lat = 8.0135, lon = 98.8485, links = false,
  todo = array[
    'Klimcursus of deep water soloing op Railay',
    'Phra Nang-strand en de Princess Cave',
    'Uitzichtpunt en lagune van Railay (steile klim, goede schoenen)',
    'Hong-eilanden met een vroege longtailboot vanaf Railay',
    'Kajakken langs de kalkrotsen',
    'Met boot en auto: Dragon Crest of Khlong Rut'
  ]::text[]
  where id = 'kr';

update days set title = 'Naar Krabi (Railay)', drive = '2,5 u', photo = '10-railay',
  items = array[
    'Rustig ontbijt in de jungle',
    'Rit naar de pier van Ao Nam Mao; auto parkeren',
    'Longtailboot naar Railay East, ca. 15 min (laat het resort de overtocht regelen; neem alleen mee wat je nodig hebt)',
    'Avond: zonsondergang op Railay West'
  ]::text[]
  where day_date = '2027-02-10';
update days set title = 'Railay', drive = null, photo = '11-railay-kliffen',
  items = array[
    'Ochtend: klimcursus of deep water soloing',
    'Middag: Phra Nang-strand en de Princess Cave',
    'Voor de durvers: uitzichtpunt en lagune van Railay (steile klim)'
  ]::text[]
  where day_date = '2027-02-11';
update days set title = 'Railay', drive = null, photo = '12-phang-nga-mangrove',
  items = array[
    'Ochtend: Hong-eilanden met een vroege longtailboot vanaf Railay, vóór de tourboten',
    'Middag: kajakken langs de kalkrotsen of rust bij het zwembad'
  ]::text[]
  where day_date = '2027-02-12';
update days set
  items = array_prepend('Vroeg met de longtail terug naar Ao Nam Mao en de auto ophalen', items)
  where day_date = '2027-02-13' and not ('Vroeg met de longtail terug naar Ao Nam Mao en de auto ophalen' = any(items));

update legs set route = 'Khao Sok → Ao Nam Mao, boot naar Railay' where sort = 4;
update legs set route = 'Ao Nam Mao → Phang Nga Bay → Khao Lak' where sort = 5;

update checklist set
  title = 'Railay Great View Resort, 10–13 feb',
  note = '2 kamers, € 305 via Agoda. Vraag het resort de longtail vanaf Ao Nam Mao te regelen',
  updated_at = now()
  where id = 'h4';
insert into checklist (id, sort, title, note)
  values ('park', 15, 'Parkeerplek voor de auto bij Ao Nam Mao, 10–13 feb', 'Vraag het resort waar je de auto veilig kunt laten staan')
  on conflict (id) do nothing;

update kaart set route = (
  select jsonb_agg(case when e->>'naam' like 'Krabi%'
                        then '{"naam":"Krabi (Railay)","lat":8.0135,"lon":98.8485}'::jsonb else e end order by o)
    from jsonb_array_elements(route) with ordinality t(e, o))
  where id = 'kaart';
