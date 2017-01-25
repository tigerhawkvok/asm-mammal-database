
/*
 * HTML5 ServiceWorker
 * After
 * https://github.com/SSARHERPS/SSAR-species-database/issues/50
 *
 * Why are we here? Because this gives us some nice bonuses on mobile!
 */
var cacheName, urlsToCache;

cacheName = "ssar_cndb_cache";

urlsToCache = ["js/c.min.js", "css/main.min.css"];

self.addEventListener("install", function(event) {
  var cacheHandler;
  cacheHandler = function(cache) {
    console.log("Opened cache");
    return cache.addAll(urlsToCache);
  };
  event.waitUntil(caches.open(cacheName).then(cacheHandler(cache)));
  return false;
});

//# sourceMappingURL=maps/serviceWorker.js.map
