var CACHE = "mb-v4";
var BASE = ["./", "index.html", "manifest.json", "icone-192.png"];
self.addEventListener("install", function (e) {
  e.waitUntil(caches.open(CACHE).then(function (c) { return c.addAll(BASE); }));
  self.skipWaiting();
});
self.addEventListener("activate", function (e) {
  e.waitUntil(caches.keys().then(function (ks) {
    return Promise.all(ks.filter(function (k) { return k !== CACHE; }).map(function (k) { return caches.delete(k); }));
  }));
  self.clients.claim();
});
self.addEventListener("fetch", function (e) {
  var req = e.request;
  if (req.method !== "GET" || new URL(req.url).origin !== location.origin) return;
  // Rede primeiro (dados e app mudam com frequência); o cache serve só de reserva offline.
  e.respondWith(
    fetch(req, { cache: "no-store" }).then(function (r) {
      if (r.ok) { var cp = r.clone(); caches.open(CACHE).then(function (c) { c.put(req, cp); }); }
      return r;
    }).catch(function () { return caches.match(req, { ignoreSearch: true }); })
  );
});
