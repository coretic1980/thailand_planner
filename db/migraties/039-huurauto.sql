-- Huurauto als eigen reservering met alle details, en meegeteld in de reiskosten
create table if not exists autohuur (
  id                text primary key,
  sort              int  not null default 1,
  verhuurder        text not null,
  auto              text not null,
  reservering       text,
  status            text,
  ophalen           text not null,
  ophalen_plek      text,
  inleveren         text not null,
  inleveren_plek    text,
  prijs             numeric(10,2),
  ter_plaatse       numeric(10,2),
  ter_plaatse_tekst text,
  borg              text,
  details           text[] not null default '{}',
  url               text,
  notitie           text
);

insert into autohuur (id, sort, verhuurder, auto, reservering, status, ophalen, ophalen_plek, inleveren, inleveren_plek,
                      prijs, ter_plaatse, ter_plaatse_tekst, borg, details, url, notitie)
values ('sunny', 1, 'Sunny Cars', 'Nissan Navara pick-up of vergelijkbaar (Standard - Pickup)', '16350284', 'Op aanvraag',
        'do 4 feb 2027, 08:30', 'Afgeleverd bij Hotel Once Bangkok',
        'di 16 feb 2027, 17:00', 'Kantoor op Phuket International Airport',
        743.40, 195.10, 'THB 7.221,43: afleveren bij het hotel THB 801,43 en one-way THB 6.420',
        'THB 20.000 (ca. € 540) op de creditcard van de hoofdbestuurder (Dave)',
        '{"Automaat","Airco","4 personen","4 koffers","Extra bestuurder inbegrepen","Online inchecken","All-in, gratis annuleren"}',
        null,
        'Op aanvraag: wacht op de bevestiging van Sunny Cars. Gegevens van de lokale verhuurder staan op de voucher zodra die klaar is.')
on conflict (id) do nothing;

-- De reservering in Regelen
update checklist
   set title = 'Huurauto Sunny Cars, 4–16 feb',
       note  = 'Reservering 16350284, op aanvraag. € 743,40 vooraf, ter plaatse ca. € 195,10. Afgeleverd bij Hotel Once op 4 feb 08:30, inleveren op Phuket Airport op 16 feb 17:00',
       groep = 'vervoer', updated_at = now()
 where id = 'car';

insert into checklist (id, sort, title, note, done, groep)
values ('taxi', 17, 'Vervoer naar Phuket Airport, 17 feb 06:15',
        'De auto is dan al ingeleverd. Vraag de receptie van Naiyang Park om een taxi of shuttle (5 minuten)', false, 'vervoer')
on conflict (id) do nothing;

-- Dagprogramma: ophalen bij het hotel, inleveren op 16 feb
update days set items = array_replace(items, 'Huurauto ophalen',
  '08:30: de huurauto (Nissan Navara pick-up) wordt bij Hotel Once afgeleverd; neem de creditcard van Dave mee voor de borg')
 where day_date = '2027-02-04';

update days set items = '{"Laatste ochtend aan het strand in Khao Lak","Uitchecken en rit naar Nai Yang (ca. 1,5 uur); inchecken bij Naiyang Park Resort vanaf 14:00","Vóór 17:00: auto tanken en inleveren bij het kantoor op Phuket Airport (5 minuten van het resort), terug met een taxi","Avond: zonsondergang en eten aan het strand van Nai Yang"}'
 where day_date = '2027-02-16';

update days set items = '{"Rond 06:15 uitchecken (receptie is 24 uur open) en met een taxi of de shuttle in 5 minuten naar Phuket Airport, om 06:45 aanwezig","Vlucht EY429 om 08:45"}'
 where day_date = '2027-02-17';

update legs set route = 'Khao Lak → Nai Yang, auto inleveren op Phuket Airport' where sort = 6;
update legs set route = 'Nai Yang → Phuket Airport (taxi)' where sort = 7;

update info set tekst = 'Sunny Cars, Nissan Navara pick-up (automaat). Wordt do 4 feb om 08:30 bij Hotel Once afgeleverd; inleveren di 16 feb om 17:00 bij het kantoor op Phuket Airport. Borg THB 20.000 op de creditcard van de hoofdbestuurder.'
 where id = 'huurauto';
