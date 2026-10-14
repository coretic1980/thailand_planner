-- Schema voor de Thailand-reisapp (Postgres / Neon)

create table if not exists bases (
  id              text primary key,
  nr              int  not null,
  name            text not null,
  dates           text not null,
  nights          text not null,
  lat             numeric(8,4) not null,
  lon             numeric(8,4) not null,
  hotel           text not null,
  alternative     text,
  why             text,
  todo            text[] not null default '{}',
  unsplash_query  text,
  maps_query      text,
  photo           text,
  photo_caption   text,
  gallery         jsonb not null default '[]'
);

-- Label links van de pin tonen (als het rechts botst met iets anders)
alter table bases add column if not exists links boolean not null default false;

-- De kaart: routelijn, tussenstops en dagtrips (één rij met id 'kaart')
-- Elk punt: {"naam": "...", "lat": 0.0, "lon": 0.0, "links": false}
create table if not exists kaart (
  id           text primary key,
  route        jsonb not null default '[]',
  tussenstops  jsonb not null default '[]',
  dagtrips     jsonb not null default '[]'
);

create table if not exists days (
  day_date  date primary key,
  title     text not null,
  drive     text,
  items     text[] not null default '{}',
  photo     text
);

create table if not exists legs (
  sort        int primary key,
  date_label  text not null,
  route       text not null,
  duration    text not null
);

create table if not exists change_log (
  id          serial primary key,
  prompt      text not null,
  summary     text,
  changes     jsonb not null,
  created_at  timestamptz not null default now(),
  undone_at   timestamptz
);

create table if not exists checklist (
  id          text primary key,
  sort        int  not null,
  title       text not null,
  note        text,
  done        boolean not null default false,
  updated_at  timestamptz not null default now(),
  groep       text,
  deadline    date,
  deadline_label text
);

-- Voorstellen uit het tabblad Aanpassen (ook als ze nog niet zijn toegepast)
-- status: open, toegepast, geannuleerd, vervangen (door een nieuwer voorstel), uitleg (Claude stelde niets voor)
create table if not exists voorstellen (
  id             serial primary key,
  prompt         text not null,
  samenvatting   text,
  wijzigingen    jsonb not null default '[]',
  beschrijving   jsonb not null default '[]',
  status         text not null default 'open',
  change_log_id  int,
  created_at     timestamptz not null default now(),
  decided_at     timestamptz
);

-- Vaste teksten: kop van de pagina, vluchten, praktische info, noodnummers, Thaise woorden, fotocredits
-- sectie: algemeen, vlucht, praktisch, nood, woorden
create table if not exists info (
  id      text primary key,
  sectie  text not null,
  sort    int  not null,
  label   text not null,
  waarde  text,
  tekst   text
);
-- Huurauto als eigen reservering met alle details, en meegeteld in de reiskosten
create table if not exists autohuur (
  id                text primary key,
  sort              int  not null default 1,
  verhuurder        text not null,
  auto              text not null,
  reservering       text,
  status            text,
  ophalen           text not null,
  ophalen_plek      text,
  inleveren         text not null,
  inleveren_plek    text,
  prijs             numeric(10,2),
  ter_plaatse       numeric(10,2),
  ter_plaatse_tekst text,
  borg              text,
  details           text[] not null default '{}',
  url               text,
  notitie           text
);
-- Geschatte kosten naast de boekingen: eten en drinken, uitstapjes, benzine
create table if not exists budget (
  id          text primary key,
  sort        int  not null default 1,
  label       text not null,
  bedrag      numeric(10,2),
  toelichting text
);
