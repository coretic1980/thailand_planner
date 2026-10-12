-- Alle teksten die nog vast in de pagina stonden, gaan naar de database (tabel info).
-- Zo zijn ook de kop, vluchten, praktische info, noodnummers, Thaise woorden en fotocredits
-- via Aanpassen te wijzigen.

create table if not exists info (
  id      text primary key,
  sectie  text not null,
  sort    int  not null,
  label   text not null,
  waarde  text,
  tekst   text
);

insert into info (id, sectie, sort, label, waarde, tekst) values
  -- Kop van de pagina en de teller
  ('hero_label',  'algemeen', 1, 'Bovenregel',          'Gezinsreis · 3–17 februari 2027', null),
  ('hero_titel',  'algemeen', 2, 'Titel',               'Bangkok → Phuket', null),
  ('hero_tekst',  'algemeen', 3, 'Ondertitel',          'Roadtrip langs de Golf en de Andamanzee, maximaal ongeveer 4 uur rijden per dag.', null),
  ('hero_foto',   'algemeen', 4, 'Grote foto',          '13-samet-nangshe', 'Phang Nga Bay'),
  ('reis_start',  'algemeen', 5, 'Begin reis (landing)', '2027-02-03T06:35:00+07:00', null),
  ('reis_einde',  'algemeen', 6, 'Einde reis (vertrek)', '2027-02-17T08:45:00+07:00', null),
  ('reisdagen',   'algemeen', 7, 'Aantal dagen',        '15', null),
  ('afstand',     'algemeen', 8, 'Afstand in km',       '±1.100', null),
  ('fotos',       'algemeen', 9, 'Foto''s', null,
     'Alle foto''s komen van Unsplash. Met dank aan Anantachai Saothong, Vasant Jain, Udee Manmin, Jean Carlo Emer, allPhoto Bangkok, Audrey Langlois, Rock Vincent Guitard, Robin Noguier, Aleksandra B., Steven Watson, Simon Pallard, Martti Salmi, Sven, Dario Brönnimann, Jo Barnes en de fotografen van de foto''s van Chumphon en Khao Sok.'),
  -- Vluchten
  ('vlucht_heen',  'vlucht', 1, 'Heen · landing',  '06:35', E'Wo 3 feb · EY402 Etihad\nSuvarnabhumi, Bangkok'),
  ('vlucht_terug', 'vlucht', 2, 'Terug · vertrek', '08:45', E'Wo 17 feb · EY429 Etihad\nPhuket International (om 06:45 aanwezig)'),
  -- Praktisch
  ('rijbewijs', 'praktisch', 1, 'Rijbewijs', null, 'Internationaal rijbewijs (ANWB) plus je Nederlandse rijbewijs. Links rijden.'),
  ('huurauto',  'praktisch', 2, 'Huurauto', null, 'Ophalen 4 feb in Bangkok, inleveren op Phuket Airport op 17 feb vroeg in de ochtend (Nai Yang ligt op 10 minuten). Vraag naar de toeslag voor inleveren op een andere plek en of de balie rond 06:00 open is.'),
  ('nieuwjaar', 'praktisch', 3, 'Chinees Nieuwjaar', null, 'Za 6 feb 2027, de dag van de rit naar Chumphon. Reken op drukte langs de kust. Chumphon is geregeld bij Nana Beach Hotel.'),
  ('weer',      'praktisch', 4, 'Weer', null, 'Droog seizoen aan beide kusten, rond 32 °C overdag.'),
  ('parken',    'praktisch', 5, 'Nationale parken', null, 'Entree meestal contant betalen. Check openingsdata van de Surin-eilanden vlak voor vertrek.'),
  ('geld',      'praktisch', 6, 'Geld', null, 'Thaise baht. Veel stalletjes, parken en kleine hotels accepteren alleen contant geld.'),
  ('stroom',    'praktisch', 7, 'Stroom', null, '230 V. Nederlandse stekkers passen meestal, een wereldstekker is handig.'),
  -- Noodnummers
  ('nood_toeristenpolitie', 'nood', 1, 'Toeristenpolitie', '1155', 'Engelstalig'),
  ('nood_ambulance',        'nood', 2, 'Ambulance',        '1669', null),
  ('nood_politie',          'nood', 3, 'Politie',          '191',  null),
  ('nood_brandweer',        'nood', 4, 'Brandweer',        '199',  null),
  -- Thaise woorden
  ('woord_hallo',   'woorden', 1, 'Hallo / dank je',   null, 'sawasdee khrap (m) / kha (v) · khop khun khrap / kha'),
  ('woord_pittig',  'woorden', 2, 'Niet pittig',       null, 'mai phet'),
  ('woord_prijs',   'woorden', 3, 'Hoeveel kost het?', null, 'tao rai?'),
  ('woord_lekker',  'woorden', 4, 'Lekker!',           null, 'aroi!')
on conflict (id) do nothing;
