-- Controle van de route: kleine correcties

-- Bangkok: pin op het Amara Bangkok Hotel (Surawong Road) in plaats van bij Wat Arun
update bases set lat = 13.7295, lon = 100.5268, maps_query = 'Amara Bangkok Hotel Surawong'
  where id = 'bkk' and hotel = 'Amara Bangkok Hotel';
update kaart set route = (
  select jsonb_agg(case when e->>'naam' = 'Bangkok'
                        then jsonb_set(jsonb_set(e, '{lat}', '13.7295'), '{lon}', '100.5268') else e end order by o)
    from jsonb_array_elements(route) with ordinality t(e, o))
  where id = 'kaart';

-- Huurauto: inleveren op 17 feb 's ochtends (zoals in Info en het dagprogramma)
update checklist set
  note = 'Ophalen 4 feb in Bangkok, inleveren 17 feb rond 06:30 op Phuket Airport. Vraag naar de toeslag en of de balie dan open is',
  updated_at = now()
  where id = 'car' and note = 'Ophalen 4 feb, inleveren 16 feb avond of 17 feb vroeg';

-- Amara: euroteken bij de prijs
update checklist set note = '1 nacht voor € 237,67. Gratis annuleren vóór 29 januari 2027', updated_at = now()
  where id = 'h1' and note = '1 nacht voor 237,67. Gratis annuleren vóór 29 januari 2027';
update bases set why = '1 nacht voor € 237,67. Gratis annuleren vóór 29 januari 2027.'
  where id = 'bkk' and why = '1 nacht voor 237,67. Gratis annuleren vóór 29 januari 2027.';

-- 17 feb: rijtijd gelijk aan de rit (5 minuten vanaf Naiyang Park Resort)
update days set drive = '5 min' where day_date = '2027-02-17';
update legs set duration = '5 min' where sort = 7;
