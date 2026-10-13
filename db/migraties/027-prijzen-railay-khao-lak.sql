-- Prijzen zoals ingevuld in de testversie: Railay € 1.100,00; Khao Lak € 350 (ingevuld toen het 2 nachten waren)
update bases set prijs = 1100.00, why = replace(why, '€ 305 via', '€ 1.100,00 via') where id = 'kr' and prijs = 305.00;
update checklist set note = replace(note, '€ 305 via', '€ 1.100,00 via'), updated_at = now()
  where id = 'h4' and note like '%€ 305 via%' and exists (select 1 from bases where id = 'kr' and prijs = 1100.00);
update bases set prijs = 350.00,
  why = '2 kamers × 3 nachten via Booking.com (geboekt 13–16 feb). Rustig eco-resort met tuin en zwembad, ca. 20 minuten van het strand.'
  where id = 'kl' and prijs = 305.73;
update checklist set note = '2 kamers, 13–16 feb via Booking.com. Controleer de prijs: in de app staat € 350, ingevuld toen het nog 2 nachten waren', updated_at = now()
  where id = 'h5' and exists (select 1 from bases where id = 'kl' and prijs = 350.00);
