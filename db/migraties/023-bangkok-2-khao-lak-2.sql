-- Bangkok 2 nachten (3–5 feb), Khao Lak 2 nachten (14–16 feb); Pranburi t/m Railay schuiven één dag op.
-- Muay Thai terug naar Bangkok (do 4 feb, Rajadamnern), weg uit Khao Lak.
-- De hotels moeten hun boeking nog aanpassen; dat staat bij Reserveren.

update days set title = 'Khao Sok', drive = null, photo = '20-junglepad',
  items = array['Junglewandeling in het nationale park naar een waterval','Middag: zwemmen in de rivier of het zwembad van het hotel']::text[]
  where day_date = '2027-02-10';
update days set title = 'Naar Krabi (Railay)', drive = '2,5 u', photo = '10-railay',
  items = array['Ontbijt in de jungle en uitchecken','Rit van Khao Sok naar de pier van Ao Nam Mao (ca. 2,5 uur)','Auto parkeren bij Ao Nam Mao; hij blijft daar 3 nachten staan (vraag het resort vooraf waar dat veilig kan)','Bagage mee in de longtail naar de eigen pier van het resort op Railay East (ca. 15 min; het resort regelt de boot)','Avond: zonsondergang op Railay West']::text[]
  where day_date = '2027-02-11';
update days set title = 'Railay', drive = null, photo = '11-railay-kliffen',
  items = array['Ochtend: klimcursus of deep water soloing','Middag: Phra Nang-strand en de Princess Cave','Voor de durvers: uitzichtpunt en lagune van Railay (steile klim)']::text[]
  where day_date = '2027-02-12';
update days set title = 'Railay', drive = null, photo = '12-phang-nga-mangrove',
  items = array['Ochtend: Hong-eilanden met een vroege longtailboot vanaf Railay, vóór de tourboten','Middag: kajakken langs de kalkrotsen of rust bij het zwembad']::text[]
  where day_date = '2027-02-13';
update days set title = 'Via Phang Nga naar Khao Lak', drive = '3–3,5 u', photo = '13-samet-nangshe',
  items = array['08:00 Uitchecken; longtail van het resort naar de pier van Ao Nam Mao (ca. 15 min). Vraag het resort de dag ervoor om deze boot','08:30 Auto ophalen bij Ao Nam Mao en de bagage in de kofferbak','Rijden naar de pier in Phang Nga via Ao Luek (ca. 1,5 uur)','10:15 Longtail naar Koh Panyee en kajakken door de grotten; lunch op het dorp op palen','Auto blijft op slot bij de pier; paspoorten en waardevolle spullen gaan mee','13:30 Uitzichtpunt Samet Nangshe (ca. 30 min rijden)','14:15 Door naar Khao Lak (ca. 1 tot 1,5 uur)','Ca. 15:30 Inchecken in het Khaolak Relax Resort']::text[]
  where day_date = '2027-02-14';
update days set title = 'Surin-eilanden', drive = null, photo = '15-surin',
  items = array['Dagtrip met de speedboot, vroeg ophalen bij het hotel','Snorkelen en het dorp van de Moken','Alternatief: de Similan-eilanden','Avond: rustig eten in Bang Niang']::text[]
  where day_date = '2027-02-15';
update days set title = 'Naar Nai Yang', drive = '1,5 u', photo = '21-nai-yang-zonsondergang',
  items = array['Uitchecken; onderweg korte stop bij de waterval van Lam Ru','Rit naar Nai Yang (ca. 1,5 uur); inchecken bij Naiyang Park Resort vanaf 14:00','Middag: zwembad van het resort','Avond: zonsondergang en eten aan het strand van Nai Yang']::text[]
  where day_date = '2027-02-16';
update days set title = 'Bangkok', drive = null, photo = '03-bangkok-fietsen',
  items = array['Ochtend: fietstour door Bang Krachao, de groene long van Bangkok (ca. 4 uur)','Middag: Grand Palace en Wat Arun (bedekte schouders en knieën), of rust bij het zwembad','Avond 18:00: Muay Thai in het Rajadamnern-stadion (ca. 25 min met de taxi vanaf het hotel)','Daarna: Jodd Fairs-nachtmarkt']::text[]
  where day_date = '2027-02-04';
update days set title = 'Naar Pranburi', drive = '3,5 u', photo = '04-maeklong',
  items = array['Huurauto ophalen','Maeklong-spoorwegmarkt (check de treintijden)','Aankomst bij Baan Mahasamut, zwembad met uitzicht op de bergen','Laat in de middag: boottocht door de mangroves van Khlong Khao Daeng (ca. 500 baht per boot)','Avond: verse vis in het vissersdorp Pak Nam Pran']::text[]
  where day_date = '2027-02-05';
update days set title = 'Sam Roi Yot en Kui Buri', drive = '2 u', photo = '05-sam-roi-yot-grot',
  items = array['Chinees Nieuwjaar: reken op drukte bij de grot en in het park','Ochtend: Phraya Nakhon-grot, licht tussen 9 en 12 uur (entree 200 baht p.p., stevige schoenen)','Lunch en rust bij het zwembad','Laat in de middag: safari met wilde olifanten in Kui Buri (ca. 1 uur rijden)','Nog energie? Zaterdagavond Cicada Market in Hua Hin, 16–23 uur (ca. 40 min)']::text[]
  where day_date = '2027-02-06';
update days set title = 'Naar Chumphon', drive = '4 u', photo = '18-tempel-ban-krut',
  items = array['Dag na Chinees Nieuwjaar: reken nog op drukte langs de kust','Vroeg: vlonderpad van Bueng Bua, op de route naar het zuiden (vogels in de ochtend)','Onderweg: strand van Ao Manao en de apenberg in Prachuap Khiri Khan','Onderweg: de tempel Wat Thang Sai bij Ban Krut','Avond: zonsondergang en vis aan het strand van Thung Wua Laen']::text[]
  where day_date = '2027-02-07';
update days set title = 'Chumphon', drive = null, photo = '17-chumphon-kust',
  items = array['Snorkeltrip naar de eilanden van Mu Ko Chumphon','Middag: stranddag aan Thung Wua Laen']::text[]
  where day_date = '2027-02-08';
update days set title = 'Naar Khao Sok', drive = '3 u', photo = '19-khao-sok-jungle',
  items = array['Rit door het binnenland naar Khao Sok','Middag: tuben over de Sok-rivier','Avond: nachtsafari in de jungle']::text[]
  where day_date = '2027-02-09';

update bases set dates = '3–5 feb', nights = '2 nachten', why = '2 nachten. Nu geboekt: 1 nacht voor € 237,67; met een nacht verlengen. Gratis annuleren vóór 29 januari 2027.', todo = array['Wat Pho en de expressboot over de Chao Phraya','Fietstour door Bang Krachao','Grand Palace en Wat Arun','Muay Thai in het Rajadamnern-stadion (do 4 feb)','Jodd Fairs-nachtmarkt','Rooftopbar met uitzicht over de stad']::text[]
  where id = 'bkk';
update bases set prijs = null where id = 'bkk';
update bases set dates = '5–7 feb', hotel_url = 'https://www.agoda.com/nl-nl/baan-mahasamut-pranburi/hotel/all/hua-hin-cha-am-th.html?checkIn=2027-02-05&los=2&rooms=2&adults=3&children=1&childAges=15&currencyCode=EUR', why = '2 kamers × 2 nachten voor € 195,13 via Agoda. Direct betalen, niet restitueerbaar; geboekt voor 4–6 feb, datum laten wijzigen. Rustig tussen de rijstvelden en bergen, met zwembad; vlak bij Sam Roi Yot.', todo = array['Phraya Nakhon-grot: licht op het paviljoen tussen 9 en 12 uur','Boottocht door de mangroves van Khlong Khao Daeng (45 min, laat in de middag)','Bueng Bua: vlonderpad over het grootste zoetwatermoeras van Thailand','Safari met wilde olifanten in Kui Buri (laat in de middag)','Pranburi Forest Park: vlonderpaden door de mangroves (gratis)','Verse vis in het vissersdorp Pak Nam Pran','Rustige stranden bij Khao Kalok en Dolphin Bay','Zaterdagavond: Cicada Market in Hua Hin (16–23 uur)']::text[]
  where id = 'pkk';
update bases set dates = '7–9 feb', hotel_url = 'https://www.agoda.com/nl-nl/nana-beach-hotel/hotel/chumphon-th.html?checkIn=2027-02-07&los=2&rooms=2&adults=3&children=1&childAges=15&currencyCode=EUR'
  where id = 'chp';
update bases set dates = '9–11 feb', hotel_url = 'https://www.booking.com/hotel/th/khaosok-river-amp-jungle.nl.html?checkin=2027-02-09&checkout=2027-02-11&group_adults=3&group_children=1&age=15&no_rooms=2'
  where id = 'ks';
update bases set dates = '11–14 feb', hotel_url = 'https://www.agoda.com/nl-nl/railay-great-view-resort/hotel/krabi-th.html?checkIn=2027-02-11&los=3&rooms=2&adults=3&children=1&childAges=15&currencyCode=EUR'
  where id = 'kr';
update bases set dates = '14–16 feb', nights = '2 nachten', hotel_url = 'https://www.booking.com/hotel/th/khaolak-relax-resort.nl.html?checkin=2027-02-14&checkout=2027-02-16&group_adults=4&no_rooms=2', why = '2 kamers × 2 nachten via Booking.com. Nu geboekt: 13–16 feb voor € 305,73; inkorten tot 14–16 feb. Rustig eco-resort met tuin en zwembad, ca. 20 minuten van het strand.', todo = array['Phang Nga Bay: Koh Panyee, kajakken, Samet Nangshe','Dagtrip naar de Surin-eilanden (of de Similan-eilanden)','Waterval in Lam Ru, op weg naar Nai Yang']::text[]
  where id = 'kl';
update bases set prijs = null where id = 'kl';

update checklist set title = 'Huurauto Bangkok → Phuket Airport', note = 'Ophalen 5 feb in Bangkok, inleveren 17 feb rond 06:30 op Phuket Airport. Vraag naar de toeslag en of de balie dan open is', updated_at = now() where id = 'car';
update checklist set title = 'Amara Bangkok Hotel, Bangkok, 3–5 feb', note = 'Verlengen naar 2 nachten (nu geboekt: 3–4 feb, € 237,67). Gratis annuleren vóór 29 januari 2027', updated_at = now() where id = 'h1';
update checklist set title = 'Baan Mahasamut Pranburi, 5–7 feb', note = 'Let op: geboekt voor 4–6 feb en niet restitueerbaar. Vraag Agoda of het hotel om 5–7 feb. 2 kamers × 2 nachten, € 195,13', updated_at = now() where id = 'h2';
update checklist set title = 'Nana Beach Hotel, Chumphon, 7–9 feb', note = 'Datum wijzigen (nu geboekt: 6–8 feb). 2 bungalows, € 257,48 via Agoda. Later betalen. Vraag bij het hotel naar de snorkeltrip', updated_at = now() where id = 'chp';
update checklist set title = 'Khao Sok River & Jungle Resort, 9–11 feb', note = 'Datum wijzigen (nu geboekt: 8–10 feb). 2 kamers, € 283 via Booking.com', updated_at = now() where id = 'h3';
update checklist set title = 'Railay Great View Resort, 11–14 feb', note = 'Datum wijzigen (nu geboekt: 10–13 feb). 2 kamers, € 305 via Agoda. Vraag het resort de longtail vanaf Ao Nam Mao te regelen', updated_at = now() where id = 'h4';
update checklist set title = 'Khaolak Relax Resort, 14–16 feb', note = 'Inkorten naar 2 nachten (nu geboekt: 13–16 feb, € 305,73 via Booking.com)', updated_at = now() where id = 'h5';
update checklist set title = 'Dagtrip Surin-eilanden, 15 feb', note = 'Check of de eilanden open zijn', updated_at = now() where id = 'surin';
update checklist set title = 'Olifantensafari Kui Buri, 6 feb', note = null, updated_at = now() where id = 'kui';
update checklist set title = 'Snorkeltrip Mu Ko Chumphon, 8 feb', note = 'Via het hotel', updated_at = now() where id = 'snork';
update checklist set title = 'Klimcursus Railay, 12 feb', note = null, updated_at = now() where id = 'climb';
update checklist set title = 'Tickets Muay Thai, 4 feb', note = 'Rajadamnern-stadion, Bangkok. Donderdagavond vanaf 18:00 (zaal open 17:00). Online vooraf boeken is meestal goedkoper', updated_at = now() where id = 'muay';
update checklist set title = 'Parkeerplek voor de auto bij Ao Nam Mao, 11–14 feb', note = 'Vraag het resort waar je de auto veilig kunt laten staan', updated_at = now() where id = 'park';

-- Ritten
update legs set date_label = '5 feb' where sort = 1;
update legs set date_label = '7 feb' where sort = 2;
update legs set date_label = '9 feb' where sort = 3;
update legs set date_label = '11 feb' where sort = 4;
update legs set date_label = '14 feb' where sort = 5;

-- Info
update info set tekst = 'Ophalen 5 feb in Bangkok, inleveren op Phuket Airport op 17 feb vroeg in de ochtend (Nai Yang ligt op 10 minuten). Vraag naar de toeslag voor inleveren op een andere plek en of de balie rond 06:00 open is.' where id = 'huurauto';
update info set tekst = 'Za 6 feb 2027, jullie dag in Sam Roi Yot en Kui Buri. Reken op drukte bij de bezienswaardigheden en langs de kust, ook op zo 7 feb tijdens de rit naar Chumphon.' where id = 'nieuwjaar';

-- Kaart: uitstapjes schuiven mee
update kaart set
  tussenstops = (select jsonb_agg(case
      when e->>'dag' between '2027-02-04' and '2027-02-13' then jsonb_set(e, '{dag}', to_jsonb(to_char((e->>'dag')::date + 1, 'YYYY-MM-DD')))
      else e end order by o) from jsonb_array_elements(tussenstops) with ordinality t(e, o)),
  dagtrips = (select jsonb_agg(case
      when e->>'naam' = 'Similan-eilanden' then e || '{"dag":"2027-02-15","tekst":"Alternatief voor de Surin-eilanden: dagtrip met de speedboot naar de Similan-eilanden."}'::jsonb
      when e->>'naam' = 'Lam Ru' then e || '{"dag":"2027-02-16","tekst":"Waterval in het nationale park Lam Ru; korte stop op de rit naar Nai Yang."}'::jsonb
      when e->>'dag' between '2027-02-04' and '2027-02-14' then jsonb_set(e, '{dag}', to_jsonb(to_char((e->>'dag')::date + 1, 'YYYY-MM-DD')))
      else e end order by o) from jsonb_array_elements(dagtrips) with ordinality t(e, o))
  where id = 'kaart';
