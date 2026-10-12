-- Bestaande foto's hergebruiken voor Khlong Khao Daeng (mangroves) en de Hong-eilanden (longtailboten bij Railay)
update kaart set dagtrips = (
  select jsonb_agg(case
      when e->>'naam' = 'Khlong Khao Daeng' and not e ? 'foto' then e || '{"foto":"12-phang-nga-mangrove"}'
      when e->>'naam' = 'Hong-eilanden' and not e ? 'foto' then e || '{"foto":"10-railay"}'
      else e end order by o)
    from jsonb_array_elements(dagtrips) with ordinality t(e, o))
  where id = 'kaart' and jsonb_array_length(dagtrips) > 0;
