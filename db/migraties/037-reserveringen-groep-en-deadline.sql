-- Reserveringen in groepen (hotels, vervoer, activiteiten, voor vertrek) en met een datum waarvoor je iets moet doen
alter table checklist add column if not exists groep text;
alter table checklist add column if not exists deadline date;
alter table checklist add column if not exists deadline_label text;

update checklist set groep = 'hotels' where id in ('h1','h2','chp','h3','h4','h5','hkt') and groep is null;
update checklist set groep = 'vervoer' where id in ('car','snork','park') and groep is null;
update checklist set groep = 'activiteiten' where id in ('surin','kui','climb','muay') and groep is null;
update checklist set groep = 'vertrek' where id in ('idp','ins') and groep is null;

update checklist set deadline = '2027-01-29', deadline_label = 'Amara gratis annuleren tot 29 jan' where id = 'h1' and deadline is null;
update checklist set deadline = '2026-12-24', deadline_label = 'Betalen op 24 dec · gratis annuleren tot 27 dec' where id = 'h4' and deadline is null;
