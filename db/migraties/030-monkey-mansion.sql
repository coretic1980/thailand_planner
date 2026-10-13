-- Khao Sok 8–10 feb: Monkey Mansion – Jungalows & Tours, 1 familiebungalow + 1 bungalow met tuinzicht, € 176,85 via Booking.com
update bases set
  hotel = 'Monkey Mansion – Jungalows & Tours',
  alternative = null,
  why = '1 familiebungalow + 1 bungalow met tuinzicht, 2 nachten voor € 176,85 via Booking.com (betaling in baht). Eenvoudige houten jungalows met klamboe en veranda, vlak bij de ingang van het nationale park; restaurant en eigen tours. Geen zwembad; de douche is soms koud.',
  hotel_url = 'https://www.booking.com/hotel/th/monkey-mansion.nl.html?checkin=2027-02-08&checkout=2027-02-10&group_adults=3&group_children=1&age=15&no_rooms=2',
  hotel_foto = null,
  maps_query = 'Monkey Mansion Khao Sok',
  lat = 8.912, lon = 98.528,
  prijs = 176.85
  where id = 'ks';
update days set items = array_replace(items,
    'Middag: zwemmen in de rivier of het zwembad van het hotel',
    'Middag: zwemmen in de rivier (Monkey Mansion heeft geen zwembad) of een tour van het hotel')
  where day_date = '2027-02-09';
update checklist set title = 'Monkey Mansion, Khao Sok, 8–10 feb',
  note = '1 familiebungalow + 1 bungalow met tuinzicht, € 176,85 via Booking.com (je betaalt in baht, THB 6.642). Annuleer Khao Sok River & Jungle Resort', updated_at = now()
  where id = 'h3';
