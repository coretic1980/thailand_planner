-- Uitstapjes op de kaart: elk punt krijgt een dag en een korte beschrijving, zodat je erop kunt klikken.

update kaart set tussenstops = '[
  {"naam":"Maeklong","lat":13.4075,"lon":100.0003,"dag":"2027-02-04","tekst":"Spoorwegmarkt: de trein rijdt dwars door de kraampjes (rond 08:30, 11:10, 14:30 en 17:40). Onderweg naar Pranburi."},
  {"naam":"Prachuap Khiri Khan","lat":11.745,"lon":99.79,"dag":"2027-02-06","tekst":"Strand van Ao Manao en de apenberg Khao Chong Krachok. Onderweg naar Chumphon."},
  {"naam":"Wat Thang Sai","lat":11.376,"lon":99.596,"dag":"2027-02-06","tekst":"Tempel op een heuvel boven de baai van Ban Krut, met uitzicht over zee. Onderweg naar Chumphon."},
  {"naam":"Phang Nga Bay","lat":8.3,"lon":98.5,"dag":"2027-02-13","tekst":"Longtail naar het dorp op palen Koh Panyee en kajakken door de grotten; daarna het uitzichtpunt Samet Nangshe. Onderweg naar Khao Lak."}
]'::jsonb
where id = 'kaart'
  and (select array_agg(e->>'naam' order by e->>'naam') from jsonb_array_elements(tussenstops) e)
      = array['Maeklong','Phang Nga Bay','Phuket Airport','Prachuap Khiri Khan'];

update kaart set dagtrips = '[
  {"naam":"Khlong Khao Daeng","lat":12.155,"lon":99.975,"dag":"2027-02-04","tekst":"Boottocht door de mangroves laat in de middag (45 min, ca. 500 baht per boot)."},
  {"naam":"Phraya Nakhon-grot","lat":12.205,"lon":100.01,"dag":"2027-02-05","tekst":"Grot met een paviljoen in het zonlicht, mooiste licht tussen 9 en 12 uur. Steile wandeling, entree 200 baht p.p."},
  {"naam":"Kui Buri NP","lat":12.05,"lon":99.62,"links":true,"dag":"2027-02-05","tekst":"Safari met wilde olifanten, laat in de middag (ca. 1 uur rijden vanaf Pranburi)."},
  {"naam":"Bueng Bua","lat":12.26,"lon":99.93,"links":true,"dag":"2027-02-06","tekst":"Vlonderpad over het grootste zoetwatermoeras van Thailand; vroeg in de ochtend veel vogels. Op de route naar het zuiden."},
  {"naam":"Mu Ko Chumphon","lat":10.5,"lon":99.42,"dag":"2027-02-07","tekst":"Snorkeltrip naar de eilanden van het zeepark, te regelen via het hotel."},
  {"naam":"Hong-eilanden","lat":8.077,"lon":98.676,"links":true,"dag":"2027-02-12","tekst":"Vroeg met de longtail vanaf Railay naar de lagune van Koh Hong, vóór de tourboten."},
  {"naam":"Surin-eilanden","lat":9.43,"lon":97.87,"dag":"2027-02-14","tekst":"Dagtrip met de speedboot, ophalen bij het hotel: snorkelen en het dorp van de Moken."},
  {"naam":"Similan-eilanden","lat":8.52,"lon":97.645,"dag":"2027-02-15","tekst":"Optie: dagtrip met de speedboot naar de Similan-eilanden. Of een rustdag."},
  {"naam":"Lam Ru","lat":8.72,"lon":98.36,"dag":"2027-02-15","tekst":"Waterval in het nationale park Lam Ru, op korte afstand van Khao Lak."}
]'::jsonb
where id = 'kaart'
  and (select array_agg(e->>'naam' order by e->>'naam') from jsonb_array_elements(dagtrips) e)
      = array['Kui Buri NP','Sam Roi Yot','Surin-eilanden'];

-- Label van Nai Yang links van de pin (rechts botst het met Krabi); het vliegveld heeft geen apart label meer nodig
update bases set links = true where id = 'hkt';
