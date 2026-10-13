-- Correctie: Sand Sea Resort ligt op Railay West (alleen per boot), niet aan het strand van Ao Nang.
update bases set
  name = 'Krabi (Railay)',
  why = '2 × Tropical Chalet Sunrise, 3 nachten voor € 1.066,36 via Agoda, met ontbijt. Gratis annuleren vóór 27 december 2026; je betaalt pas op 24 december. Direct aan het strand van Railay West, met twee zwembaden. Alleen per boot bereikbaar: longtail vanaf Ao Nam Mao of het strand van Ao Nang (ca. 15 min).',
  todo = array['Klimcursus of deep water soloing op Railay','Phra Nang-strand en de Princess Cave','Uitzichtpunt en lagune van Railay (steile klim, goede schoenen)','Hong-eilanden met een vroege longtailboot vanaf Railay','Kajakken langs de kalkrotsen','Met boot en auto: Dragon Crest of Khlong Rut']::text[],
  lat = 8.0115, lon = 98.8375,
  maps_query = 'Sand Sea Resort Railay Beach'
  where id = 'kr';

update days set title = 'Naar Krabi (Railay)', drive = '2,5 u',
  items = array['Ontbijt in de jungle en uitchecken','Rit van Khao Sok naar de pier van Ao Nam Mao (ca. 2,5 uur)','Auto parkeren bij Ao Nam Mao; hij blijft daar 3 nachten staan (vraag het resort vooraf waar dat veilig kan)','Bagage mee in de longtail naar Railay East (ca. 15 min), daarna 5–10 minuten lopen naar Sand Sea op Railay West','Avond: zonsondergang op Railay West']::text[]
  where day_date = '2027-02-10';
update days set title = 'Railay', drive = null,
  items = array['Ochtend: klimcursus of deep water soloing','Middag: Phra Nang-strand en de Princess Cave','Voor de durvers: uitzichtpunt en lagune van Railay (steile klim)']::text[]
  where day_date = '2027-02-11';
update days set title = 'Railay',
  items = array['Ochtend: Hong-eilanden met een vroege longtailboot vanaf Railay, vóór de tourboten','Middag: kajakken langs de kalkrotsen of rust bij het zwembad']::text[]
  where day_date = '2027-02-12';
update days set
  items = array['08:00 Uitchecken; longtail van Railay naar de pier van Ao Nam Mao (ca. 15 min). Regel de boot de dag ervoor bij het resort','08:30 Auto ophalen bij Ao Nam Mao en de bagage in de kofferbak','Rijden naar de pier in Phang Nga via Ao Luek (ca. 1,5 uur)','10:15 Longtail naar Koh Panyee en kajakken door de grotten; lunch op het dorp op palen','Auto blijft op slot bij de pier; paspoorten en waardevolle spullen gaan mee','13:30 Uitzichtpunt Samet Nangshe (ca. 30 min rijden)','14:15 Door naar Khao Lak (ca. 1 tot 1,5 uur)','Ca. 15:30 Inchecken in het Khaolak Relax Resort']::text[]
  where day_date = '2027-02-13';

update legs set route = 'Khao Sok → Ao Nam Mao, boot naar Railay' where sort = 4;
update legs set route = 'Ao Nam Mao → Phang Nga Bay → Khao Lak' where sort = 5;

update checklist set title = 'Parkeerplek voor de auto bij Ao Nam Mao, 10–13 feb',
  note = 'Vraag Sand Sea waar je de auto veilig kunt laten staan en of ze de longtail regelen', updated_at = now()
  where id = 'park';

update kaart set route = (
  select jsonb_agg(case when e->>'naam' = 'Krabi (Ao Nang)' then '{"naam":"Krabi (Railay)","lat":8.0115,"lon":98.8375}'::jsonb else e end order by o)
    from jsonb_array_elements(route) with ordinality t(e, o)),
  dagtrips = (select jsonb_agg(case when e->>'naam' = 'Hong-eilanden' then e || '{"tekst":"Vroeg met de longtail vanaf Railay naar de lagune van Koh Hong, vóór de tourboten."}'::jsonb else e end order by o)
    from jsonb_array_elements(dagtrips) with ordinality t(e, o) where e->>'naam' <> 'Railay')
  where id = 'kaart';
