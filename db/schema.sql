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
  updated_at  timestamptz not null default now()
);
