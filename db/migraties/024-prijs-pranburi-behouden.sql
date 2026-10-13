-- Als de prijs van Pranburi intussen in de app is aangepast, die prijs ook in de teksten van migratie 023 gebruiken
update bases set why = replace(why, '€ 195,13', '€ ' || replace(to_char(prijs, 'FM9990.00'), '.', ','))
  where id = 'pkk' and prijs is not null and prijs <> 195.13;
update checklist set note = replace(note, '€ 195,13', '€ ' || (select replace(to_char(prijs, 'FM9990.00'), '.', ',') from bases where id = 'pkk'))
  where id = 'h2' and exists (select 1 from bases where id = 'pkk' and prijs is not null and prijs <> 195.13);
