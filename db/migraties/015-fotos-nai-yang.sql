-- Foto's van Nai Yang (Unsplash: Cem Sagisman en set.sj)

update bases set
  photo = '21-nai-yang-zonsondergang',
  photo_caption = 'Zonsondergang aan het strand van Nai Yang',
  gallery = '[["22-nai-yang-wad","Bij eb aan de kust van Nai Yang"]]'::jsonb
  where id = 'hkt' and photo is null;

update days set photo = '21-nai-yang-zonsondergang' where day_date = '2027-02-16';

update info set tekst = replace(tekst, 'Jo Barnes en de fotografen', 'Jo Barnes, Cem Sagisman, set.sj en de fotografen')
  where id = 'fotos' and tekst not like '%Cem Sagisman%';
