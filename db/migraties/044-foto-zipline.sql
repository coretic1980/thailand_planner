-- Foto bij het ziplinen: in de galerij van Khao Lak en bij het dagprogramma van 15 feb
update bases set gallery = gallery || '[["28-zipline-jungle", "Ziplinen door de jungle"]]'::jsonb
 where reis_id = 'thailand-2027' and id = 'kl' and not gallery::text like '%28-zipline-jungle%';
update days set photo = '28-zipline-jungle'
 where reis_id = 'thailand-2027' and day_date = '2027-02-15' and photo is null;
