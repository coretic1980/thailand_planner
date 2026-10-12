-- Foto's bij de uitstapjes op de kaart (bestaande foto's uit de app)
update kaart set tussenstops = (
  select jsonb_agg(case e->>'naam'
      when 'Maeklong' then e || '{"foto":"04-maeklong"}'
      when 'Prachuap Khiri Khan' then e || '{"foto":"06-prachuap"}'
      when 'Wat Thang Sai' then e || '{"foto":"18-tempel-ban-krut"}'
      when 'Phang Nga Bay' then e || '{"foto":"13-samet-nangshe"}'
      else e end order by o)
    from jsonb_array_elements(tussenstops) with ordinality t(e, o))
  where id = 'kaart' and jsonb_array_length(tussenstops) > 0;
update kaart set dagtrips = (
  select jsonb_agg(case e->>'naam'
      when 'Phraya Nakhon-grot' then e || '{"foto":"05-sam-roi-yot-grot"}'
      when 'Kui Buri NP' then e || '{"foto":"07-kui-buri-olifant"}'
      when 'Surin-eilanden' then e || '{"foto":"15-surin"}'
      else e end order by o)
    from jsonb_array_elements(dagtrips) with ordinality t(e, o))
  where id = 'kaart' and jsonb_array_length(dagtrips) > 0;
