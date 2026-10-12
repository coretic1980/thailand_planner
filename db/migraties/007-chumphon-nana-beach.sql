-- Chumphon 6–8 feb: Nana Beach Hotel in plaats van Moonrise Villa.
-- 2 bungalows × 2 nachten, € 257,48 via Agoda, later betalen.

update bases set
  hotel = 'Nana Beach Hotel',
  alternative = null,
  why = '2 bungalows × 2 nachten voor € 257,48 via Agoda. Later betalen. Direct aan het strand van Thung Wua Laen.',
  hotel_url = 'https://www.agoda.com/nl-nl/nana-beach-hotel/hotel/chumphon-th.html?checkIn=2027-02-06&los=2&rooms=2&adults=3&children=1&childAges=15&currencyCode=EUR',
  maps_query = 'Nana Beach Resort Chumphon',
  lat = 10.5697, lon = 99.2742
  where id = 'chp';

update checklist set
  title = 'Nana Beach Hotel, Chumphon, 6–8 feb',
  note = '2 bungalows, € 257,48 via Agoda. Later betalen. Vraag bij het hotel naar de snorkeltrip',
  updated_at = now()
  where id = 'chp';

update kaart set route = (
  select jsonb_agg(case when e->>'naam' = 'Chumphon'
                        then jsonb_set(jsonb_set(e, '{lat}', '10.5697'), '{lon}', '99.2742') else e end order by o)
    from jsonb_array_elements(route) with ordinality t(e, o))
  where id = 'kaart';
