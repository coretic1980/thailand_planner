-- Khao Lak 13–16 feb: Khaolak Relax Resort, € 305,73 via Booking.com.
-- Laatste nacht 16–17 feb: Nai Yang, vlak bij Phuket Airport (hotel nog te boeken).

update bases set
  dates = '13–16 feb', nights = '3 nachten',
  hotel = 'Khaolak Relax Resort',
  alternative = null,
  why = '2 kamers × 3 nachten voor € 305,73 via Booking.com. Rustig eco-resort met tuin en zwembad, ca. 20 minuten van het strand.',
  hotel_url = 'https://www.booking.com/hotel/th/khaolak-relax-resort.nl.html?checkin=2027-02-13&checkout=2027-02-16&group_adults=4&no_rooms=2',
  maps_query = 'Khaolak Relax Eco Resort',
  lat = 8.6940, lon = 98.2493, links = true
  where id = 'kl';

insert into bases (id, nr, name, dates, nights, lat, lon, hotel, alternative, why, todo, unsplash_query, maps_query, photo, photo_caption, gallery, links)
values ('hkt', 7, 'Nai Yang', '16–17 feb', '1 nacht', 8.0899, 98.2975,
  'Nog te boeken', null,
  'Laatste nacht vlak bij Phuket Airport: 10 minuten naar de terminal, zodat de vlucht van 08:45 zonder haast lukt.',
  array['Zonsondergang en eten aan het strand van Nai Yang','Vliegtuigen spotten aan het eind van de landingsbaan (Mai Khao Beach)']::text[],
  'nai-yang-beach', 'Nai Yang Beach Phuket', null, null, '[]'::jsonb, false)
on conflict (id) do nothing;

update days set title = 'Naar Nai Yang', drive = '1,5 u', photo = '14-khao-lak-strand',
  items = array[
    'Laatste ochtend aan het strand in Khao Lak',
    'Uitchecken en rit naar Nai Yang, vlak bij Phuket Airport',
    'Avond: zonsondergang en eten aan het strand van Nai Yang',
    'Vraag de verhuurder of je de auto vanavond al kunt inleveren'
  ]::text[]
  where day_date = '2027-02-16';
update days set title = 'Naar huis', drive = '10 min',
  items = array['Korte rit naar Phuket Airport, om 06:45 aanwezig','Auto inleveren, vlucht EY429 om 08:45']::text[]
  where day_date = '2027-02-17';

update legs set date_label = '16 feb', route = 'Khao Lak → Nai Yang', duration = '1,5 u' where sort = 6;
insert into legs (sort, date_label, route, duration) values (7, '17 feb', 'Nai Yang → Phuket Airport', '10 min')
  on conflict (sort) do nothing;

update checklist set
  title = 'Khaolak Relax Resort, 13–16 feb',
  note = '2 kamers, € 305,73 via Booking.com',
  updated_at = now()
  where id = 'h5';
insert into checklist (id, sort, title, note)
  values ('hkt', 16, 'Hotel in Nai Yang, 16–17 feb', 'Nog boeken; vlak bij Phuket Airport')
  on conflict (id) do nothing;

-- Kaart: Khao Lak naar het resort, Nai Yang toegevoegd vóór het vliegveld
update kaart set route = (
  select jsonb_agg(case when e->>'naam' = 'Khao Lak'
                        then jsonb_set(jsonb_set(e, '{lat}', '8.694'), '{lon}', '98.2493') else e end order by o)
    from jsonb_array_elements(route) with ordinality t(e, o))
  where id = 'kaart';
update kaart set route = jsonb_insert(route, array[(jsonb_array_length(route) - 1)::text], '{"naam":"Nai Yang","lat":8.0899,"lon":98.2975}'::jsonb)
  where id = 'kaart' and not route @> '[{"naam":"Nai Yang"}]'::jsonb;

update days set items = array_replace(items, 'Inchecken in The Sands', 'Inchecken in het Khaolak Relax Resort')
  where day_date = '2027-02-13';
