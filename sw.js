var CACHE = "mb-v2";
self.addEventListener("install", function(e){
  e.waitUntil(caches.open(CACHE).then(function(c){ return c.addAll(["./","index.html","manifest.json","icone-192.png"]); }));
  self.skipWaiting();
});
self.addEventListener("activate", function(e){
  e.waitUntil(caches.keys().then(function(ks){ return Promise.all(ks.filter(function(k){return k!==CACHE;}).map(function(k){return caches.delete(k);})); }));
  self.clients.claim();
});
self.addEventListener("fetch", function(e){
  var url = new URL(e.request.url);
  if (url.pathname.endsWith("dados.enc.js")) {
    // dados: rede primeiro, cache como reserva offline
    e.respondWith(fetch(e.request).then(function(r){
      var cp = r.clone(); caches.open(CACHE).then(function(c){ c.put(e.request, cp); }); return r;
    }).catch(function(){ return caches.match(e.request); }));
  } else if (e.request.method === "GET") {
    e.respondWith(caches.match(e.request).then(function(r){
      return r || fetch(e.request).then(function(r2){
        var cp = r2.clone(); caches.open(CACHE).then(function(c){ c.put(e.request, cp); }); return r2;
      });
    }));
  }
});
