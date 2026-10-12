-- Duidelijke stappen voor auto en boot rond Railay (10 en 13 feb)

update days set title = 'Naar Krabi (Railay)', drive = '2,5 u',
  items = array[
    'Ontbijt in de jungle en uitchecken',
    'Rit van Khao Sok naar de pier van Ao Nam Mao (ca. 2,5 uur)',
    'Auto parkeren bij Ao Nam Mao; hij blijft daar 3 nachten staan (vraag het resort vooraf waar dat veilig kan)',
    'Bagage mee in de longtail naar de eigen pier van het resort op Railay East (ca. 15 min; het resort regelt de boot)',
    'Avond: zonsondergang op Railay West'
  ]::text[]
  where day_date = '2027-02-10';

update days set title = 'Via Phang Nga naar Khao Lak', drive = '3–3,5 u',
  items = array[
    '08:00 Uitchecken; longtail van het resort naar de pier van Ao Nam Mao (ca. 15 min). Vraag het resort de dag ervoor om deze boot',
    '08:30 Auto ophalen bij Ao Nam Mao en de bagage in de kofferbak',
    'Rijden naar de pier in Phang Nga via Ao Luek (ca. 1,5 uur)',
    '10:15 Longtail naar Koh Panyee en kajakken door de grotten; lunch op het dorp op palen',
    'Auto blijft op slot bij de pier; paspoorten en waardevolle spullen gaan mee',
    '13:30 Uitzichtpunt Samet Nangshe (ca. 30 min rijden)',
    '14:15 Door naar Khao Lak (ca. 1 tot 1,5 uur)',
    'Ca. 15:30 Inchecken in het Khaolak Relax Resort'
  ]::text[]
  where day_date = '2027-02-13';
