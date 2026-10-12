-- Prijs per overnachtingsplek (totaal voor het hele verblijf, in euro). De app telt het totaal zelf op.
alter table bases add column if not exists prijs numeric(10,2);

update bases set prijs = 237.67 where id = 'bkk' and prijs is null and hotel = 'Amara Bangkok Hotel';
update bases set prijs = 195.13 where id = 'pkk' and prijs is null and hotel = 'Baan Mahasamut Pranburi';
update bases set prijs = 257.48 where id = 'chp' and prijs is null and hotel = 'Nana Beach Hotel';
update bases set prijs = 283.00 where id = 'ks'  and prijs is null and hotel = 'Khao Sok River & Jungle Resort';
update bases set prijs = 305.00 where id = 'kr'  and prijs is null and hotel like 'Railay Great View%';
update bases set prijs = 305.73 where id = 'kl'  and prijs is null and hotel = 'Khaolak Relax Resort';
update bases set prijs = 298.20 where id = 'hkt' and prijs is null and hotel = 'Naiyang Park Resort';

-- Aantal reizigers, voor de prijs per persoon
insert into info (id, sectie, sort, label, waarde, tekst)
  values ('reizigers', 'algemeen', 10, 'Aantal reizigers', '4', null)
  on conflict (id) do nothing;
