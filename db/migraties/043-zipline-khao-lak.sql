-- Zipline bij Khao Lak (Sky Rock Khaolak), op ma 15 feb. Voegt toe; bestaande tekst blijft staan.
update bases set todo = array_append(todo, 'Ziplinen in de jungle bij Sky Rock Khaolak (ophalen bij het hotel)')
 where reis_id = 'thailand-2027' and id = 'kl' and not ('Ziplinen in de jungle bij Sky Rock Khaolak (ophalen bij het hotel)' = any(todo));

update days set items = array_prepend('Ochtend: ziplinen in de jungle bij Sky Rock Khaolak (1,5 à 2 uur, ophalen bij het hotel)', items)
 where reis_id = 'thailand-2027' and day_date = '2027-02-15' and not (items::text like '%Sky Rock%');

insert into checklist (reis_id, id, sort, title, note, done, groep)
values ('thailand-2027', 'zipline', (select coalesce(max(sort),0)+1 from checklist where reis_id = 'thailand-2027'),
        'Zipline Sky Rock Khaolak, 15 feb',
        'Kies Rock 1 (ca. 2 uur, 9 ziplines en 3 hangbruggen) of Rock 2 (ca. 1,5 uur). Ophalen en terugbrengen bij het hotel in Khao Lak. Ca. € 50–85 p.p., vanaf 4 jaar',
        false, 'activiteiten')
on conflict (reis_id, id) do nothing;
