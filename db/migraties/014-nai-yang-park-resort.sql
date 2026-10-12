-- Laatste nacht 16–17 feb: Naiyang Park Resort, 2 Deluxe-kamers, € 298,20 via Agoda (later betalen, gratis annuleren, zonder ontbijt)

update bases set
  hotel = 'Naiyang Park Resort',
  alternative = null,
  why = '2 kamers × 1 nacht voor € 298,20 via Agoda. Later betalen, gratis annuleren, zonder ontbijt. Resort met zwembad en kinderbad aan de rustige kant van Nai Yang, bij het nationale park; 5 minuten van het vliegveld en receptie 24 uur open.',
  hotel_url = 'https://www.agoda.com/nl-nl/partners/partnersearch.aspx?hid=14874647&checkIn=2027-02-16&los=1&rooms=2&adults=3&children=1&childAges=15&currencyCode=EUR',
  maps_query = 'Naiyang Park Resort Phuket'
  where id = 'hkt';
update bases set todo = array_prepend('Middag aan het zwembad van het resort', todo)
  where id = 'hkt' and not ('Middag aan het zwembad van het resort' = any(todo));

-- Dag 16: in de vaste volgorde als het programma nog ongewijzigd is, anders alleen de regels vervangen
update days set items = case
  when items = array['Laatste ochtend aan het strand in Khao Lak','Uitchecken en rit naar Nai Yang, vlak bij Phuket Airport','Avond: zonsondergang en eten aan het strand van Nai Yang','Vraag de verhuurder of je de auto vanavond al kunt inleveren']::text[]
  then array['Laatste ochtend aan het strand in Khao Lak','Uitchecken en rit naar Nai Yang (ca. 1,5 uur); inchecken bij Naiyang Park Resort vanaf 14:00','Middag: zwembad van het resort','Avond: zonsondergang en eten aan het strand van Nai Yang']::text[]
  else array_replace(array_replace(items,
    'Uitchecken en rit naar Nai Yang, vlak bij Phuket Airport',
    'Uitchecken en rit naar Nai Yang (ca. 1,5 uur); inchecken bij Naiyang Park Resort vanaf 14:00'),
    'Vraag de verhuurder of je de auto vanavond al kunt inleveren',
    'Middag: zwembad van het resort')
  end
  where day_date = '2027-02-16';
update days set items = array_replace(items,
    'Korte rit naar Phuket Airport, om 06:45 aanwezig',
    'Rond 06:15 uitchecken (receptie is 24 uur open) en 5 minuten naar Phuket Airport, om 06:45 aanwezig')
  where day_date = '2027-02-17';

update checklist set
  title = 'Naiyang Park Resort, Nai Yang, 16–17 feb',
  note = '2 kamers, € 298,20 via Agoda. Later betalen, gratis annuleren. Zonder ontbijt',
  updated_at = now()
  where id = 'hkt';
