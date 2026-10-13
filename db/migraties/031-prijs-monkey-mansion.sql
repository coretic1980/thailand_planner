-- Monkey Mansion: nieuwe prijs € 187,39 (THB 7.038)
update bases set prijs = 187.39, why = replace(why, '€ 176,85', '€ 187,39') where id = 'ks' and prijs = 176.85;
update checklist set note = replace(replace(note, '€ 176,85', '€ 187,39'), 'THB 6.642', 'THB 7.038'), updated_at = now() where id = 'h3';
