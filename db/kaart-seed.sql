-- Startgegevens voor de kaart. Wordt geladen als de tabel kaart nog leeg is.
begin;

insert into kaart (id, route, tussenstops, dagtrips) values ('kaart',
  '[{"naam": "Suvarnabhumi Airport", "lat": 13.69, "lon": 100.75}, {"naam": "Bangkok", "lat": 13.745, "lon": 100.491}, {"naam": "Maeklong", "lat": 13.4075, "lon": 100.0003}, {"naam": "Prachuap Khiri Khan", "lat": 11.745, "lon": 99.79}, {"naam": "Chumphon", "lat": 10.5651, "lon": 99.2729}, {"naam": "Khao Sok", "lat": 8.89, "lon": 98.53}, {"naam": "Krabi (Tubkaek)", "lat": 8.09, "lon": 98.75}, {"naam": "Phang Nga Bay", "lat": 8.3, "lon": 98.5}, {"naam": "Khao Lak", "lat": 8.65, "lon": 98.25}, {"naam": "Phuket Airport", "lat": 8.113, "lon": 98.317}]',
  '[{"naam": "Maeklong", "lat": 13.4075, "lon": 100.0003}, {"naam": "Phang Nga Bay", "lat": 8.3, "lon": 98.5}, {"naam": "Phuket Airport", "lat": 8.113, "lon": 98.317, "links": true}]',
  '[{"naam": "Sam Roi Yot", "lat": 12.19, "lon": 100.0}, {"naam": "Kui Buri NP", "lat": 12.05, "lon": 99.62, "links": true}, {"naam": "Surin-eilanden", "lat": 9.43, "lon": 97.87}]'
) on conflict (id) do nothing;

commit;
