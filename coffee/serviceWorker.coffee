###
# HTML5 ServiceWorker
# After
# https://github.com/SSARHERPS/SSAR-species-database/issues/50
#
# Why are we here? Because this gives us some nice bonuses on mobile!
###

cacheName = "asm_cndb_cache"

urlsToCache = [
  "js/c.min.js"
  "css/main.min.css"
  ]

self.addEventListener "install", (event) ->
  # Do the install
  cacheHandler = (cache) ->
    console.log("Opened cache")
    cache.addAll(urlsToCache)
  event.waitUntil caches.open(cacheName).then(cacheHandler(cache))
  false

