-- Geschatte kosten naast de boekingen: eten en drinken, uitstapjes, benzine
create table if not exists budget (
  id          text primary key,
  sort        int  not null default 1,
  label       text not null,
  bedrag      numeric(10,2),
  toelichting text
);

insert into budget (id, sort, label, bedrag, toelichting) values
 ('eten', 1, 'Eten en drinken', 1550,
  'Realistisch: mix van lokale tentjes en af en toe een restaurant of strandtent, ca. € 110 per dag voor het gezin (14 dagen). Bangkok, Pranburi en Koh Phayam zijn goedkoop; Railay en Khao Lak duidelijk duurder.'),
 ('uitstapjes', 2, 'Uitstapjes en entree', 1450,
  'Realistisch, voor het hele gezin: Muay Thai, Kui Buri, Khao Sok (tuben, nachtsafari), longtail en klimcursus op Railay, Phang Nga Bay en de dagtrip naar de Surin-eilanden, plus kleine dingen zoals tempels, kajakken en massages.'),
 ('benzine', 3, 'Benzine en tol', 120,
  'Schatting: ca. 1.100 km met de pick-up op diesel, plus wat tol rond Bangkok.')
on conflict (id) do nothing;
