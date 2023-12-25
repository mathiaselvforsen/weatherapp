'use strict';
const MANIFEST = 'flutter-app-manifest';
const TEMP = 'flutter-temp-cache';
const CACHE_NAME = 'flutter-app-cache';

const RESOURCES = {"version.json": "e12d16673f638ed170a5f83edf27c036",
"index.html": "83b1d55f206b68a99123829806c6e83f",
"/": "83b1d55f206b68a99123829806c6e83f",
"main.dart.js": "58cb74a72b72517182f40bf245bf26be",
"flutter.js": "7d69e653079438abfbb24b82a655b0a4",
"favicon.png": "5dcef449791fa27946b3d35ad8803796",
"icons/Icon-192.png": "ac9a721a12bbc803b44f645561ecb1e1",
"icons/Icon-maskable-192.png": "c457ef57daa1d16f64b27b786ec2ea3c",
"icons/Icon-maskable-512.png": "301a7604d45b3e739efc881eb04896ea",
"icons/Icon-512.png": "96e752610906ba2a93c65f8abe1645f1",
"manifest.json": "e93baf6d4ec4769f8abb33f41321436c",
"assets/images/broken_clouds_night.png": "c06d02c9ad9889f8b092e241cae4a8e7",
"assets/images/me.JPG": "70596d4ad157f67a368cd152cf56a2b2",
"assets/images/scattered_clouds_night.png": "c06d02c9ad9889f8b092e241cae4a8e7",
"assets/images/broken_clouds.png": "4b57f7af7ff36c61c5d410cb9361f703",
"assets/images/thunderstorm.png": "5ec0fe6b9e077648b0ea545b4ca05f90",
"assets/images/clear_sky.png": "f8e104c1085df70b8bacc4ca84a1bfe8",
"assets/images/few_clouds.png": "23ecb9578cdaf02c6c43d61155da7c29",
"assets/images/snow_night.png": "1ae1273f6c491ebbfa5ff5fa88494797",
"assets/images/overcast_clouds.png": "6016554ab99540d0a65b4ae44d8184bc",
"assets/images/snow.png": "43ac663a3432b676d176a1b14f2e6b4d",
"assets/images/windy.png": "ebf63bd2688a1572280929f11c0a762f",
"assets/images/heavy_shower_rain.png": "c25e162bfdc3f2dacf06fb6837d3cf32",
"assets/images/moderate_rain.png": "c7bf8375543fcfe231498337ca197e76",
"assets/images/mist_night.png": "00404c429970000d35dc8a66be91ef19",
"assets/images/scattered_clouds.png": "87bee9c6efdef5a4a51f834e32e0541f",
"assets/images/shower_rain_night.png": "daac078a4194538adb1429a5008331d5",
"assets/images/light_rain.png": "c7bf8375543fcfe231498337ca197e76",
"assets/images/thunderstorm_night.png": "daa17c04c56d5f2849ae1d2c119e1dd2",
"assets/images/clear_sky_night.png": "71afb6cc5dffa635f05ee76e9b6eabef",
"assets/images/rain_night.png": "75db4dc5b1a285d9228770a1980a2529",
"assets/images/heavy_rain.png": "c25e162bfdc3f2dacf06fb6837d3cf32",
"assets/images/shower_rain.png": "c7bf8375543fcfe231498337ca197e76",
"assets/images/mist.png": "ebf63bd2688a1572280929f11c0a762f",
"assets/images/few_clouds_night.png": "67f24db649c3e1312b11246bd59c775e",
"assets/images/moderate_snow.png": "b3fe272cbf728aebbc5accb3a172f2bc",
"assets/images/rain.png": "be33d796656259def0aa09194e5f642b",
"assets/AssetManifest.json": "a8d0088bd2694863edd36e734f56a112",
"assets/NOTICES": "4754cf372f8a1cadf54043d0e4c94c74",
"assets/FontManifest.json": "dc3d03800ccca4601324923c0b1d6d57",
"assets/AssetManifest.bin.json": "75588b52a377f19043047e6a8691c3d3",
"assets/packages/cupertino_icons/assets/CupertinoIcons.ttf": "89ed8f4e49bcdfc0b5bfc9b24591e347",
"assets/shaders/ink_sparkle.frag": "4096b5150bac93c41cbc9b45276bd90f",
"assets/AssetManifest.bin": "53b62af6e8bb28d43abd07e2bbec0e73",
"assets/fonts/MaterialIcons-Regular.otf": "3d51b5f3d49c4e7bce2028b35e40f5a6",
"canvaskit/skwasm.js": "87063acf45c5e1ab9565dcf06b0c18b8",
"canvaskit/skwasm.wasm": "2fc47c0a0c3c7af8542b601634fe9674",
"canvaskit/chromium/canvaskit.js": "0ae8bbcc58155679458a0f7a00f66873",
"canvaskit/chromium/canvaskit.wasm": "143af6ff368f9cd21c863bfa4274c406",
"canvaskit/canvaskit.js": "eb8797020acdbdf96a12fb0405582c1b",
"canvaskit/canvaskit.wasm": "73584c1a3367e3eaf757647a8f5c5989",
"canvaskit/skwasm.worker.js": "bfb704a6c714a75da9ef320991e88b03"};
// The application shell files that are downloaded before a service worker can
// start.
const CORE = ["main.dart.js",
"index.html",
"assets/AssetManifest.json",
"assets/FontManifest.json"];

// During install, the TEMP cache is populated with the application shell files.
self.addEventListener("install", (event) => {
  self.skipWaiting();
  return event.waitUntil(
    caches.open(TEMP).then((cache) => {
      return cache.addAll(
        CORE.map((value) => new Request(value, {'cache': 'reload'})));
    })
  );
});
// During activate, the cache is populated with the temp files downloaded in
// install. If this service worker is upgrading from one with a saved
// MANIFEST, then use this to retain unchanged resource files.
self.addEventListener("activate", function(event) {
  return event.waitUntil(async function() {
    try {
      var contentCache = await caches.open(CACHE_NAME);
      var tempCache = await caches.open(TEMP);
      var manifestCache = await caches.open(MANIFEST);
      var manifest = await manifestCache.match('manifest');
      // When there is no prior manifest, clear the entire cache.
      if (!manifest) {
        await caches.delete(CACHE_NAME);
        contentCache = await caches.open(CACHE_NAME);
        for (var request of await tempCache.keys()) {
          var response = await tempCache.match(request);
          await contentCache.put(request, response);
        }
        await caches.delete(TEMP);
        // Save the manifest to make future upgrades efficient.
        await manifestCache.put('manifest', new Response(JSON.stringify(RESOURCES)));
        // Claim client to enable caching on first launch
        self.clients.claim();
        return;
      }
      var oldManifest = await manifest.json();
      var origin = self.location.origin;
      for (var request of await contentCache.keys()) {
        var key = request.url.substring(origin.length + 1);
        if (key == "") {
          key = "/";
        }
        // If a resource from the old manifest is not in the new cache, or if
        // the MD5 sum has changed, delete it. Otherwise the resource is left
        // in the cache and can be reused by the new service worker.
        if (!RESOURCES[key] || RESOURCES[key] != oldManifest[key]) {
          await contentCache.delete(request);
        }
      }
      // Populate the cache with the app shell TEMP files, potentially overwriting
      // cache files preserved above.
      for (var request of await tempCache.keys()) {
        var response = await tempCache.match(request);
        await contentCache.put(request, response);
      }
      await caches.delete(TEMP);
      // Save the manifest to make future upgrades efficient.
      await manifestCache.put('manifest', new Response(JSON.stringify(RESOURCES)));
      // Claim client to enable caching on first launch
      self.clients.claim();
      return;
    } catch (err) {
      // On an unhandled exception the state of the cache cannot be guaranteed.
      console.error('Failed to upgrade service worker: ' + err);
      await caches.delete(CACHE_NAME);
      await caches.delete(TEMP);
      await caches.delete(MANIFEST);
    }
  }());
});
// The fetch handler redirects requests for RESOURCE files to the service
// worker cache.
self.addEventListener("fetch", (event) => {
  if (event.request.method !== 'GET') {
    return;
  }
  var origin = self.location.origin;
  var key = event.request.url.substring(origin.length + 1);
  // Redirect URLs to the index.html
  if (key.indexOf('?v=') != -1) {
    key = key.split('?v=')[0];
  }
  if (event.request.url == origin || event.request.url.startsWith(origin + '/#') || key == '') {
    key = '/';
  }
  // If the URL is not the RESOURCE list then return to signal that the
  // browser should take over.
  if (!RESOURCES[key]) {
    return;
  }
  // If the URL is the index.html, perform an online-first request.
  if (key == '/') {
    return onlineFirst(event);
  }
  event.respondWith(caches.open(CACHE_NAME)
    .then((cache) =>  {
      return cache.match(event.request).then((response) => {
        // Either respond with the cached resource, or perform a fetch and
        // lazily populate the cache only if the resource was successfully fetched.
        return response || fetch(event.request).then((response) => {
          if (response && Boolean(response.ok)) {
            cache.put(event.request, response.clone());
          }
          return response;
        });
      })
    })
  );
});
self.addEventListener('message', (event) => {
  // SkipWaiting can be used to immediately activate a waiting service worker.
  // This will also require a page refresh triggered by the main worker.
  if (event.data === 'skipWaiting') {
    self.skipWaiting();
    return;
  }
  if (event.data === 'downloadOffline') {
    downloadOffline();
    return;
  }
});
// Download offline will check the RESOURCES for all files not in the cache
// and populate them.
async function downloadOffline() {
  var resources = [];
  var contentCache = await caches.open(CACHE_NAME);
  var currentContent = {};
  for (var request of await contentCache.keys()) {
    var key = request.url.substring(origin.length + 1);
    if (key == "") {
      key = "/";
    }
    currentContent[key] = true;
  }
  for (var resourceKey of Object.keys(RESOURCES)) {
    if (!currentContent[resourceKey]) {
      resources.push(resourceKey);
    }
  }
  return contentCache.addAll(resources);
}
// Attempt to download the resource online before falling back to
// the offline cache.
function onlineFirst(event) {
  return event.respondWith(
    fetch(event.request).then((response) => {
      return caches.open(CACHE_NAME).then((cache) => {
        cache.put(event.request, response.clone());
        return response;
      });
    }).catch((error) => {
      return caches.open(CACHE_NAME).then((cache) => {
        return cache.match(event.request).then((response) => {
          if (response != null) {
            return response;
          }
          throw error;
        });
      });
    })
  );
}
