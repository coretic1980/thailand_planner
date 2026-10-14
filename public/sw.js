// Service worker: houdt de app bruikbaar zonder internet (onderweg op de boot, in de jungle).
// - De pagina en de reisgegevens: eerst het netwerk, zonder bereik de laatst bewaarde versie.
// - Foto's en lettertypes: uit de cache als ze er al zijn.
const VERSIE = "reisapp-v2";

self.addEventListener("install", (e) => {
  e.waitUntil(caches.open(VERSIE).then((c) => c.addAll(["./"]).catch(() => {})).then(() => self.skipWaiting()));
});

self.addEventListener("activate", (e) => {
  e.waitUntil(
    caches.keys()
      .then((keys) => Promise.all(keys.filter((k) => k !== VERSIE).map((k) => caches.delete(k))))
      .then(() => self.clients.claim())
  );
});

async function eerstNetwerk(req, sleutel, magBewaren) {
  const cache = await caches.open(VERSIE);
  try {
    const res = await fetch(req);
    if (res.ok && magBewaren(res)) cache.put(sleutel, res.clone());
    return res;
  } catch (err) {
    const oud = await cache.match(sleutel);
    if (oud) return oud;
    throw err;
  }
}

async function eerstCache(req) {
  const cache = await caches.open(VERSIE);
  const oud = await cache.match(req);
  if (oud) return oud;
  const res = await fetch(req);
  if (res.ok || res.type === "opaque") cache.put(req, res.clone());
  return res;
}

self.addEventListener("fetch", (e) => {
  const req = e.request;
  if (req.method !== "GET") return;
  const url = new URL(req.url);
  const zelfde = url.origin === self.location.origin;

  // De pagina zelf (niet het inlogscherm: dat heeft no-store)
  if (req.mode === "navigate" && zelfde) {
    e.respondWith(eerstNetwerk(req, "./", (res) => !/no-store/.test(res.headers.get("cache-control") || "")));
    return;
  }
  // Reisgegevens per reis bewaren (de reis staat in ?reis=)
  if (zelfde && (url.pathname.endsWith("/api/trip") || url.pathname.endsWith("/api/me"))) {
    e.respondWith(eerstNetwerk(req, url.pathname + url.search, () => true));
    return;
  }
  if (zelfde && url.pathname.includes("/img/")) {
    e.respondWith(eerstCache(req));
    return;
  }
  // Lettertypes en de wereldkaart (kustlijnen) veranderen niet
  if (url.hostname.endsWith("fonts.googleapis.com") || url.hostname.endsWith("fonts.gstatic.com") || (url.hostname === "cdn.jsdelivr.net" && url.pathname.includes("/world-atlas@"))) {
    e.respondWith(eerstCache(req));
  }
});
