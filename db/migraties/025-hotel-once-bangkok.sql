-- Bangkok 3–5 feb: Hotel Once Bangkok, 2 nachten, € 291 via Booking.com, gratis annuleren vóór 31 januari 2027

update bases set
  hotel = 'Hotel Once Bangkok',
  alternative = null,
  why = '2 nachten voor € 291 via Booking.com. Gratis annuleren vóór 31 januari 2027. Aan Charoen Krung soi 72, in het zuiden van de oude stad, bij Asiatique en de rivier; met zwembad.',
  hotel_url = 'https://www.booking.com/Share-LfShFa',
  hotel_foto = null,
  maps_query = 'Hotel Once Bangkok Charoen Krung',
  prijs = 291.00,
  lat = 13.708, lon = 100.506
  where id = 'bkk';
update kaart set route = (
  select jsonb_agg(case when e->>'naam' = 'Bangkok'
                        then jsonb_set(jsonb_set(e, '{lat}', '13.708'), '{lon}', '100.506') else e end order by o)
    from jsonb_array_elements(route) with ordinality t(e, o))
  where id = 'kaart';

update checklist set
  title = 'Hotel Once Bangkok, 3–5 feb',
  note = '2 nachten, € 291 via Booking.com. Gratis annuleren vóór 31 januari 2027. Vraag of je om ca. 08:00 al kunt inchecken. Annuleer de Amara-boeking (gratis vóór 29 januari)',
  updated_at = now()
  where id = 'h1';

update days set items = array_replace(array_replace(items,
    'Landing 06:35, inchecken (kamer vanaf 2 feb) en een paar uur slapen',
    'Landing 06:35; naar Hotel Once (ca. 45 min), bagage achterlaten of vroeg inchecken als dat kan'),
    'Middag: Wat Pho en de expressboot over de Chao Phraya',
    'Middag: Wat Pho en de expressboot over de Chao Phraya (pier Sathorn bij Saphan Taksin)')
  where day_date = '2027-02-03';
update days set items = array_replace(items,
    'Avond 18:00: Muay Thai in het Rajadamnern-stadion (ca. 25 min met de taxi vanaf het hotel)',
    'Avond 18:00: Muay Thai in het Rajadamnern-stadion (ca. 30–40 min met de taxi vanaf het hotel)')
  where day_date = '2027-02-04';
