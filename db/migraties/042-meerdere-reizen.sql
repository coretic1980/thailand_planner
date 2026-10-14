-- Meerdere reizen in één app: elke rij hoort bij een reis.
-- Thailand (feb 2027) wordt de eerste reis; alle bestaande gegevens horen daarbij.
create table if not exists reizen (
  id          text primary key,
  naam        text not null,
  land        text,
  start_datum date not null,
  eind_datum  date not null,
  tijdzone    text not null default 'Europe/Amsterdam',
  kaart       jsonb not null default '{}',
  notities    text,
  sort        int  not null default 1,
  created_at  timestamptz not null default now()
);

insert into reizen (id, naam, land, start_datum, eind_datum, tijdzone, kaart, notities, sort)
values ('thailand-2027', 'Thailand · februari 2027', 'Thailand', '2027-02-03', '2027-02-17', 'Asia/Bangkok',
        '{"lonMin":97.5,"lonMax":101.2,"latMin":7.5,"latMax":14.2,"schaal":100,"cos":1,"vb":[-24,0,394,670],"land":[[[98.2,14.2],[101.2,14.2],[101.2,12.7],[100.95,12.65],[100.9,12.95],[100.95,13.35],[100.6,13.5],[100.3,13.48],[100,13.35],[99.98,12.8],[99.97,12.55],[100,12.2],[99.82,11.8],[99.55,11.2],[99.25,10.5],[99.15,9.95],[99.25,9.4],[99.35,9.15],[99.85,9.25],[100.05,8.4],[100.35,7.75],[100.45,7.5],[99.55,7.5],[99.1,7.8],[98.9,8.05],[98.75,8],[98.6,8.3],[98.45,8.25],[98.3,8.2],[98.27,8.65],[98.32,9.2],[98.5,9.7],[98.62,10],[98.55,10.8],[98.6,11.5],[98.6,12.4],[98.4,13.2]],[[98.28,8.2],[98.4,8.15],[98.42,7.9],[98.35,7.75],[98.28,7.8],[98.27,8]]],"labels":[{"naam":"Golf van Thailand","lon":100,"lat":8.6},{"naam":"Andamanzee","lon":97.64,"lat":9.35}],"gebied":"Zuid-Thailand"}'::jsonb,
        '- Chinees Nieuwjaar valt op za 6 feb 2027: houd in de info (sectie praktisch, "nieuwjaar") bij welke rit dan valt en of dat hotel geregeld is. De maximale rijtijd per dag staat in hero_tekst.', 1)
on conflict (id) do nothing;

-- reis_id op alle tabellen met reisgegevens, en de sleutel wordt (reis_id, ...)
do $$
declare t text;
begin
  foreach t in array array['bases','days','legs','kaart','checklist','info','autohuur','budget'] loop
    execute format('alter table %I add column if not exists reis_id text not null default %L references reizen(id) on delete cascade', t, 'thailand-2027');
    execute format('alter table %I alter column reis_id drop default', t);
    execute format('alter table %I drop constraint if exists %I', t, t || '_pkey');
  end loop;
end $$;
alter table bases     add primary key (reis_id, id);
alter table days      add primary key (reis_id, day_date);
alter table legs      add primary key (reis_id, sort);
alter table kaart     add primary key (reis_id, id);
alter table checklist add primary key (reis_id, id);
alter table info      add primary key (reis_id, id);
alter table autohuur  add primary key (reis_id, id);
alter table budget    add primary key (reis_id, id);

-- Geschiedenis en voorstellen per reis
alter table change_log  add column if not exists reis_id text references reizen(id) on delete cascade;
alter table voorstellen add column if not exists reis_id text references reizen(id) on delete cascade;
update change_log  set reis_id = 'thailand-2027' where reis_id is null;
update voorstellen set reis_id = 'thailand-2027' where reis_id is null;
alter table change_log  alter column reis_id set not null;
alter table voorstellen alter column reis_id set not null;
