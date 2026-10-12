-- Activiteiten rond Baan Mahasamut (Pranburi / Sam Roi Yot), 4–6 feb

update bases set todo = array[
  'Phraya Nakhon-grot: licht op het paviljoen tussen 9 en 12 uur',
  'Boottocht door de mangroves van Khlong Khao Daeng (45 min, laat in de middag)',
  'Bueng Bua: vlonderpad over het grootste zoetwatermoeras van Thailand',
  'Safari met wilde olifanten in Kui Buri (laat in de middag)',
  'Pranburi Forest Park: vlonderpaden door de mangroves (gratis)',
  'Verse vis in het vissersdorp Pak Nam Pran',
  'Rustige stranden bij Khao Kalok en Dolphin Bay',
  'Vrijdagavond: Cicada Market in Hua Hin (16–23 uur)'
]::text[]
where id = 'pkk';

update days set title = 'Naar Pranburi', drive = '3,5 u',
  items = array[
    'Huurauto ophalen',
    'Maeklong-spoorwegmarkt (check de treintijden)',
    'Aankomst bij Baan Mahasamut, zwembad met uitzicht op de bergen',
    'Laat in de middag: boottocht door de mangroves van Khlong Khao Daeng (ca. 500 baht per boot)',
    'Avond: verse vis in het vissersdorp Pak Nam Pran'
  ]::text[]
where day_date = '2027-02-04';

update days set title = 'Sam Roi Yot en Kui Buri', drive = '2 u',
  items = array[
    'Ochtend: Phraya Nakhon-grot, licht tussen 9 en 12 uur (entree 200 baht p.p., stevige schoenen)',
    'Lunch en rust bij het zwembad',
    'Laat in de middag: safari met wilde olifanten in Kui Buri (ca. 1 uur rijden)',
    'Nog energie? Vrijdagavond Cicada Market in Hua Hin, 16–23 uur (ca. 40 min)'
  ]::text[]
where day_date = '2027-02-05';

update days set title = 'Naar Chumphon', drive = '4 u',
  items = array[
    'Chinees Nieuwjaar: reken op drukte langs de kust',
    'Vroeg: vlonderpad van Bueng Bua, op de route naar het zuiden (vogels in de ochtend)',
    'Onderweg: strand van Ao Manao en de apenberg in Prachuap Khiri Khan',
    'Onderweg: de tempel Wat Thang Sai bij Ban Krut',
    'Avond: zonsondergang en vis aan het strand van Thung Wua Laen'
  ]::text[]
where day_date = '2027-02-06';
