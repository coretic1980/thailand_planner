-- Muay Thai verhuist van Bangkok (3 feb, aankomstdag) naar Khao Lak (ma 15 feb, Beyond Boxing Stadium in Bang Niang)

update days set items = array_replace(items, 'Avond: Muay Thai in Rajadamnern en een rooftopbar', 'Avond: rooftopbar met uitzicht over de stad')
  where day_date = '2027-02-03';
update days set items = array_append(items, 'Avond 21:00: Muay Thai in het Beyond Boxing Stadium in Bang Niang, een paar minuten rijden (tot ca. 23:45)')
  where day_date = '2027-02-15' and not exists (select 1 from unnest(items) i where i ilike '%muay thai%');

update bases set todo = array_replace(todo, 'Muay Thai in Rajadamnern en een rooftopbar', 'Rooftopbar met uitzicht over de stad')
  where id = 'bkk';
update bases set todo = array_append(todo, 'Muay Thai in Bang Niang (ma 15 feb)')
  where id = 'kl' and not exists (select 1 from unnest(todo) t where t ilike '%muay thai%');

update checklist set
  title = 'Tickets Muay Thai, 15 feb',
  note = 'Beyond Boxing Stadium, Bang Niang (Khao Lak), 21:00. Stadion 1.200 baht, ring 1.500 baht p.p.',
  updated_at = now()
  where id = 'muay';
