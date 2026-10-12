-- Foto's van Unsplash bij de uitstapjes: Bueng Bua (Tomáš Malík), Mu Ko Chumphon (Thitipark Sodchuen),
-- Similan-eilanden (Stella Weis), waterval bij Khao Lak (Jens De Decker)
update kaart set dagtrips = (
  select jsonb_agg(case e->>'naam'
      when 'Bueng Bua' then e || '{"foto":"27-bueng-bua-paviljoen"}'
      when 'Mu Ko Chumphon' then e || '{"foto":"25-chumphon-zee"}'
      when 'Similan-eilanden' then e || '{"foto":"23-similan"}'
      when 'Lam Ru' then e || '{"foto":"26-waterval-khao-lak"}'
      else e end order by o)
    from jsonb_array_elements(dagtrips) with ordinality t(e, o))
  where id = 'kaart' and jsonb_array_length(dagtrips) > 0;

update bases set gallery = gallery || '[["24-bueng-bua","Vlonderpad van Bueng Bua"]]'::jsonb
  where id = 'pkk' and not gallery @> '[["24-bueng-bua","Vlonderpad van Bueng Bua"]]'::jsonb;

update info set tekst = replace(tekst, 'Cem Sagisman, set.sj en de fotografen', 'Cem Sagisman, set.sj, Tomáš Malík, Stella Weis, Thitipark Sodchuen, Jens De Decker en de fotografen')
  where id = 'fotos' and tekst not like '%Tomáš Malík%';
