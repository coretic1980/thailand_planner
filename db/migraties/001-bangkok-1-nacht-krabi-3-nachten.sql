-- Bangkok 1 nacht (3–4 feb), Krabi 3 nachten (10–13 feb).
-- Prachuap, Chumphon en Khao Sok schuiven een dag naar voren; Khao Lak blijft 13–17 feb.
-- Afgevinkte reserveringen blijven afgevinkt: alleen titels, data en toelichtingen veranderen.

-- Overnachtingen
update bases set dates = '3–4 feb', nights = '1 nacht',
  todo = array['Wat Pho en de expressboot over de Chao Phraya','Muay Thai in Rajadamnern en een rooftopbar']::text[]
  where id = 'bkk';
update bases set dates = '4–6 feb' where id = 'pkk';
update bases set dates = '6–8 feb' where id = 'chp';
update bases set dates = '8–10 feb' where id = 'ks';
update bases set dates = '10–13 feb', nights = '3 nachten',
  todo = array['Wandeling naar Dragon Crest (vóór 7 uur)','Klimcursus of deep water soloing op Railay','Hong-eilanden met een vroege longtailboot','Suppen of kajakken in Khlong Rut']::text[]
  where id = 'kr';

-- Dagprogramma 3 t/m 12 februari
update days set title = 'Bangkok', drive = null, photo = '01-wat-arun',
  items = array['Landing 06:35, inchecken (kamer vanaf 2 feb) en een paar uur slapen','Middag: Wat Pho en de expressboot over de Chao Phraya','Avond: Muay Thai in Rajadamnern en een rooftopbar']::text[]
  where day_date = '2027-02-03';
update days set title = 'Naar Prachuap Khiri Khan', drive = '4,5 u', photo = '04-maeklong',
  items = array['Huurauto ophalen','Maeklong-spoorwegmarkt (check de treintijden)','Aankomst aan zee, Ao Manao']::text[]
  where day_date = '2027-02-04';
update days set title = 'Sam Roi Yot en Kui Buri', drive = '2,5 u', photo = '05-sam-roi-yot-grot',
  items = array['Ochtend: Phraya Nakhon-grot, licht rond 10–11 uur','Laat in de middag: safari met wilde olifanten in Kui Buri, op de terugweg']::text[]
  where day_date = '2027-02-05';
update days set title = 'Naar Chumphon', drive = '3 u', photo = '18-tempel-ban-krut',
  items = array['Chinees Nieuwjaar: reken op drukte langs de kust','Ochtend: strand van Ao Manao en de apenberg','Onderweg: de tempel Wat Thang Sai bij Ban Krut','Avond: zonsondergang en vis aan het strand van Thung Wua Laen']::text[]
  where day_date = '2027-02-06';
update days set title = 'Chumphon', drive = null, photo = '17-chumphon-kust',
  items = array['Snorkeltrip naar de eilanden van Mu Ko Chumphon','Middag: stranddag aan Thung Wua Laen']::text[]
  where day_date = '2027-02-07';
update days set title = 'Naar Khao Sok', drive = '3 u', photo = '19-khao-sok-jungle',
  items = array['Rit door het binnenland naar Khao Sok','Middag: tuben over de Sok-rivier','Avond: nachtsafari in de jungle']::text[]
  where day_date = '2027-02-08';
update days set title = 'Khao Sok', drive = null, photo = '20-junglepad',
  items = array['Junglewandeling in het nationale park naar een waterval','Middag: zwemmen in de rivier of het zwembad van het hotel']::text[]
  where day_date = '2027-02-09';
update days set title = 'Naar Krabi', drive = '2,5 u', photo = null,
  items = array['Rustig ontbijt in de jungle','Rit naar Tubkaek','Avond: zonsondergang aan het strand']::text[]
  where day_date = '2027-02-10';
update days set title = 'Krabi', drive = null, photo = '11-railay-kliffen',
  items = array['Dragon Crest, vertrek vóór 7 uur','Longtailboot naar Railay: klimmen of deep water soloing']::text[]
  where day_date = '2027-02-11';
update days set title = 'Krabi', drive = null, photo = '10-railay',
  items = array['Ochtend: Hong-eilanden met een vroege longtailboot, vóór de tourboten','Middag: Khlong Rut, suppen of kajakken in helder water']::text[]
  where day_date = '2027-02-12';

-- Ritten
update legs set date_label = '4 feb' where sort = 1;
update legs set date_label = '6 feb' where sort = 2;
update legs set date_label = '8 feb' where sort = 3;
update legs set date_label = '10 feb' where sort = 4;

-- Reserveringen: alleen de datums in titel en toelichting vervangen.
-- Hotelnamen, eigen notities en vinkjes blijven staan.
update checklist set title = replace(title, '3–5 feb', '3–4 feb'), updated_at = now() where id = 'h1';
update checklist set title = replace(title, '5–7 feb', '4–6 feb'), updated_at = now() where id = 'h2';
update checklist set title = replace(title, '7–9 feb', '6–8 feb'), updated_at = now() where id = 'chp';
update checklist set title = replace(title, '9–11 feb', '8–10 feb'), updated_at = now() where id = 'h3';
update checklist set title = replace(title, '11–13 feb', '10–13 feb'), updated_at = now() where id = 'h4';
update checklist set title = replace(title, '6 feb', '5 feb'), updated_at = now() where id = 'kui';
update checklist set title = replace(title, '8 feb', '7 feb'), updated_at = now() where id = 'snork';
update checklist set title = replace(title, '12 feb', '11 feb'), updated_at = now() where id = 'climb';
update checklist set title = replace(title, '4 feb', '3 feb'), updated_at = now() where id = 'muay';
update checklist set note = replace(note, 'Ophalen 5 feb', 'Ophalen 4 feb'), updated_at = now() where id = 'car';
