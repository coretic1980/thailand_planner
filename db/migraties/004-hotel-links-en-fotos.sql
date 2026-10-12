-- Per overnachting: link naar de website van het hotel en een eigen hotelfoto.
alter table bases add column if not exists hotel_url text;
alter table bases add column if not exists hotel_foto text;

update bases set hotel_url = 'https://bangkok.amarahotels.com/' where id = 'bkk' and hotel = 'Amara Bangkok Hotel';
update bases set hotel_url = 'https://www.hotelkhaosok.com/' where id = 'ks' and hotel = 'Hotel Khao Sok & Spa';
update bases set hotel_url = 'https://www.tubkaakresort.com/' where id = 'kr' and hotel like 'The Tubkaak%';
update bases set hotel_url = 'https://www.thesandskhaolak.com/' where id = 'kl' and hotel like 'The Sands%';
-- Baan Mahasamut (Pranburi) en Moonrise Villa (Chumphon) hebben geen eigen website: daar toont de app de Google Maps-link.
