-- Khao Sok 8–10 feb: Khao Sok River & Jungle Resort via Booking.com, € 283.

update bases set
  hotel = 'Khao Sok River & Jungle Resort',
  alternative = null,
  why = '2 kamers × 2 nachten voor € 283 via Booking.com. Bungalows aan de Sok-rivier, midden in het dorp en vlak bij de ingang van het nationale park.',
  hotel_url = 'https://www.booking.com/hotel/th/khaosok-river-amp-jungle.nl.html?checkin=2027-02-08&checkout=2027-02-10&group_adults=3&group_children=1&age=15&no_rooms=2',
  maps_query = 'Khao Sok River & Jungle Resort',
  lat = 8.9123, lon = 98.5252
  where id = 'ks';

update checklist set
  title = 'Khao Sok River & Jungle Resort, 8–10 feb',
  note = '2 kamers, € 283 via Booking.com',
  updated_at = now()
  where id = 'h3';

update kaart set route = (
  select jsonb_agg(case when e->>'naam' = 'Khao Sok'
                        then jsonb_set(jsonb_set(e, '{lat}', '8.9123'), '{lon}', '98.5252') else e end order by o)
    from jsonb_array_elements(route) with ordinality t(e, o))
  where id = 'kaart';
