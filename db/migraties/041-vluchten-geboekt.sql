-- Geboekte kosten die geen hotel of auto zijn (zoals de vluchten) staan ook in budget, met geboekt = true
alter table budget add column if not exists geboekt boolean not null default false;

insert into budget (id, sort, label, bedrag, toelichting, geboekt)
values ('vluchten', 0, 'Vluchten', 2625.14, 'Etihad, geboekt: EY402 naar Bangkok (aankomst wo 3 feb 06:35) en EY429 vanaf Phuket (wo 17 feb 08:45)', true)
on conflict (id) do nothing;
