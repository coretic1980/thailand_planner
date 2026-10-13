-- Krabi 10–13 feb: Sand Sea Resort in Ao Nang (in plaats van Railay Great View).
-- 2 × Tropical Chalet Sunrise, 3 nachten, € 1.066,36 via Agoda, met ontbijt; gratis annuleren vóór 27 dec 2026.
-- Ao Nang is met de auto bereikbaar; Railay wordt een dagtrip met de longtail.

update bases set
  name = 'Krabi (Ao Nang)',
  hotel = 'Sand Sea Resort',
  alternative = null,
  why = '2 × Tropical Chalet Sunrise, 3 nachten voor € 1.066,36 via Agoda, met ontbijt. Gratis annuleren vóór 27 december 2026; je betaalt pas op 24 december. Aan de boulevard van Ao Nang, met zwembad; de longtails naar Railay vertrekken vanaf het strand.',
  todo = array['Longtail naar Railay: klimcursus of deep water soloing','Phra Nang-strand en de Princess Cave','Uitzichtpunt en lagune van Railay (steile klim, goede schoenen)','Hong-eilanden met een vroege boot vanaf Ao Nang','Met de auto: Dragon Crest (vroeg) of Khlong Rut','Boulevard en avondmarkt van Ao Nang']::text[],
  lat = 8.033, lon = 98.822,
  maps_query = 'Sand Sea Resort Ao Nang Krabi',
  hotel_url = null, hotel_foto = null,
  prijs = 1066.36
  where id = 'kr';

update days set title = 'Naar Ao Nang (Krabi)', drive = '2,5 u',
  items = array['Ontbijt in de jungle en uitchecken','Rit van Khao Sok naar Ao Nang (ca. 2,5 uur)','Inchecken bij Sand Sea Resort, aan de boulevard','Avond: zonsondergang op het strand van Ao Nang']::text[]
  where day_date = '2027-02-10';
update days set title = 'Railay', drive = null,
  items = array['Longtail vanaf het strand van Ao Nang naar Railay West (ca. 15 min)','Ochtend: klimcursus of deep water soloing','Middag: Phra Nang-strand en de Princess Cave','Voor de durvers: uitzichtpunt en lagune van Railay (steile klim)','Laatste longtail terug rond zonsondergang']::text[]
  where day_date = '2027-02-11';
update days set title = 'Hong-eilanden',
  items = array['Ochtend: Hong-eilanden met een vroege longtail of speedboot vanaf Ao Nang, vóór de drukte','Middag: rust bij het zwembad of kajakken','Alternatief: met de auto vroeg naar Dragon Crest of naar Khlong Rut']::text[]
  where day_date = '2027-02-12';
update days set
  items = array['08:00 Uitchecken en rijden naar de pier in Phang Nga via Ao Luek (ca. 1,5 uur)','10:00 Longtail naar Koh Panyee en kajakken door de grotten; lunch op het dorp op palen','Auto blijft op slot bij de pier; paspoorten en waardevolle spullen gaan mee','13:30 Uitzichtpunt Samet Nangshe (ca. 30 min rijden)','14:15 Door naar Khao Lak (ca. 1 tot 1,5 uur)','Ca. 15:30 Inchecken in het Khaolak Relax Resort']::text[]
  where day_date = '2027-02-13';

update legs set route = 'Khao Sok → Ao Nang (Krabi)' where sort = 4;
update legs set route = 'Ao Nang → Phang Nga Bay → Khao Lak' where sort = 5;

update checklist set title = 'Sand Sea Resort, Ao Nang, 10–13 feb',
  note = '2 × Tropical Chalet Sunrise, € 1.066,36 via Agoda, met ontbijt. Gratis annuleren vóór 27 december 2026, betalen op 24 december. Elk chalet heeft één tweepersoonsbed: vraag een extra bed voor de kinderen. Annuleer Railay Great View', updated_at = now()
  where id = 'h4';
update checklist set title = 'Longtail Ao Nang – Railay, 11 feb',
  note = 'Kaartje aan het loket op het strand van Ao Nang; de laatste boot terug gaat rond zonsondergang', updated_at = now()
  where id = 'park';

-- Kaart: Krabi naar Ao Nang, Railay als dagtrip
update kaart set route = (
  select jsonb_agg(case when e->>'naam' = 'Krabi (Railay)' then '{"naam":"Krabi (Ao Nang)","lat":8.033,"lon":98.822}'::jsonb else e end order by o)
    from jsonb_array_elements(route) with ordinality t(e, o)),
  dagtrips = (select jsonb_agg(case when e->>'naam' = 'Hong-eilanden' then e || '{"tekst":"Vroeg met de longtail of speedboot vanaf Ao Nang naar de lagune van Koh Hong, vóór de drukte."}'::jsonb else e end order by o)
    from jsonb_array_elements(dagtrips) with ordinality t(e, o))
    || '[{"naam":"Railay","lat":8.011,"lon":98.838,"dag":"2027-02-11","tekst":"Longtail vanaf het strand van Ao Nang (ca. 15 min): klimmen, Phra Nang-strand en de Princess Cave, uitzichtpunt en lagune.","foto":"11-railay-kliffen"}]'::jsonb
  where id = 'kaart' and route @> '[{"naam":"Krabi (Railay)"}]'::jsonb;
