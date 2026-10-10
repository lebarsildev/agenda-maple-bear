var CACHE = "mb-v3";
self.addEventListener("install", function(e){
  e.waitUntil(caches.open(CACHE).then(function(c){ return c.addAll(["./","index.html","manifest.json","icone-192.png"]); }));
  self.skipWaiting();
});
self.addEventListener("activate", function(e){
  e.waitUntil(caches.keys().then(function(ks){ return Promise.all(ks.filter(function(k){return k!==CACHE;}).map(function(k){return caches.delete(k);})); }));
  self.clients.claim();
});
self.addEventListener("fetch", function(e){
  if (e.request.method !== "GET") return;
  // rede primeiro sempre (o app muda com frequência); cache só como reserva offline.
  // Evita o app ficar "preso" numa versão antiga do index.html em quem já visitou antes.
  e.respondWith(fetch(e.request).then(function(r){
    var cp = r.clone(); caches.open(CACHE).then(function(c){ c.put(e.request, cp); }); return r;
  }).catch(function(){ return caches.match(e.request); }));
});
