-- Hotel Bangkok geboekt: Amara Bangkok Hotel, 1 nacht (3–4 feb).

update bases set hotel = 'Amara Bangkok Hotel',
  why = '1 nacht voor 237,67. Gratis annuleren vóór 29 januari 2027.',
  maps_query = 'Amara Bangkok Hotel'
  where id = 'bkk';

update checklist set title = 'Amara Bangkok Hotel, Bangkok, 3–4 feb',
  note = '1 nacht voor 237,67. Gratis annuleren vóór 29 januari 2027',
  updated_at = now()
  where id = 'h1';
