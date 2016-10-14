/**
 * Copyright 2016 Google Inc. All rights reserved.
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
*/

// DO NOT EDIT THIS GENERATED OUTPUT DIRECTLY!
// This file should be overwritten as part of your build process.
// If you need to extend the behavior of the generated service worker, the best approach is to write
// additional code and include it using the importScripts option:
//   https://github.com/GoogleChrome/sw-precache#importscripts-arraystring
//
// Alternatively, it's possible to make changes to the underlying template file and then use that as the
// new base for generating output, via the templateFilePath option:
//   https://github.com/GoogleChrome/sw-precache#templatefilepath-string
//
// If you go that route, make sure that whenever you update your sw-precache dependency, you reconcile any
// changes made to this original template file with your modified copy.

// This generated service worker JavaScript will precache your site's resources.
// The code needs to be saved in a .js file at the top-level of your site, and registered
// from your pages in order to be used. See
// https://github.com/googlechrome/sw-precache/blob/master/demo/app/js/service-worker-registration.js
// for an example of how you can register this script and handle various service worker events.

/* eslint-env worker, serviceworker */
/* eslint-disable indent, no-unused-vars, no-multiple-empty-lines, max-nested-callbacks, space-before-function-paren, quotes, comma-spacing */
'use strict';

var precacheConfig = [["./build/bundle.js","86dbb57bd29bec5da913759f23e7bc93"],["./build/themes/elementary-dark.css","e02966a220dfadc16e977fd4ebdd3da0"],["./build/themes/elementary.css","dfd4786a7d7f01931bcfe2b7f74d4b4f"],["./build/themes/retro/amber.css","acd42f4a91d308ef153d658e3d7b62b5"],["./build/themes/retro/ambergine.css","d281d512db03252c46b3053cbc88e2ae"],["./build/themes/retro/aqua.css","3e7056d5f779c3a63e6df510fb1b5a5c"],["./build/themes/retro/green.css","ce21775919188712963966574da154cd"],["./images/wavey-logo-512.png","01adf80426236c4ac5440778ff34dde1"],["./images/wavey-logo.svg","680531792699b1f52cce7ba00ec909b3"],["./index.html","3747d94ae224e4f78afe90f97e7e41ab"],["./lib/export/mp3/lame-worker.js","08231ab678dc4bbaeacbbe61dc43197f"],["./lib/export/mp3/lame.min.js","924f0e7ba1ca6478bbeacc287703068b"],["./lib/export/wav/recorderWorker.js","683e70b4dafb88733419f051836be2f1"],["./lib/fontello/css/animation.css","5efb6f925470166045ba28c25131f79a"],["./lib/fontello/css/audio-codes.css","4acf1239c2302af73518698348c18e17"],["./lib/fontello/css/audio-embedded.css","16c41d8aeb250074ab1fc7811412007f"],["./lib/fontello/css/audio-ie7-codes.css","fec2a32ca109ff4ab63d6f5448bb4c1b"],["./lib/fontello/css/audio-ie7.css","226ff18c936582a82135e52b3e7c601c"],["./lib/fontello/css/audio.css","bc7889b30ffcb10e87e440cc157c3554"],["./lib/fontello/font/audio.eot","09d9da58f2d63eb61ffd09141c5409c5"],["./lib/fontello/font/audio.svg","646365a61b9bad40ea6b74c7a2861cca"],["./lib/fontello/font/audio.ttf","2044f03065c1db566c43b3076d0bb85f"],["./lib/fontello/font/audio.woff","024a0f88d4a0fca75666bbd33636ef4f"],["./lib/fontello/font/audio.woff2","c4e8707b1e19690c2b180cd6b029c8da"],["./lib/octicons/octicons-local.ttf","72e4167c13648cb89e9e96cdd212cb82"],["./lib/octicons/octicons.css","f1f217e5281c326fc32bd15626687fbe"],["./lib/octicons/octicons.eot","0a82c1edade24862533bbe96ebeaea47"],["./lib/octicons/octicons.svg","adc17600a2b7a648eba306c2e1426b85"],["./lib/octicons/octicons.ttf","103abd6cc0199e2519ef6f1aac4bb0e0"],["./lib/octicons/octicons.woff","be82065223a03ba577de159d97a5d63d"],["./lib/polyfill.js","58565bcf4bfa7938e0a47c839cc22674"],["./styles/app.css","c5c7ffaacee74ac0f0712664e1089233"],["./styles/base.css","b8e05283e2a8244efa48a26eb7a5adc3"],["./styles/layout.css","3907d903a44e2e724fa421e11e41e1db"],["./styles/themes/images/document-export.svg","7d46273fda7417464197a6e419cb9871"],["./styles/themes/images/document-import.svg","7c3a1d2d4a7cb7d5f09501d6b3a7e8d8"],["./styles/themes/images/gear.svg","bac794d35fa98b25542da5c5eaa4dd81"]];
var cacheName = 'sw-precache-v2--' + (self.registration ? self.registration.scope : '');


var ignoreUrlParametersMatching = [/./];



var addDirectoryIndex = function (originalUrl, index) {
    var url = new URL(originalUrl);
    if (url.pathname.slice(-1) === '/') {
      url.pathname += index;
    }
    return url.toString();
  };

var createCacheKey = function (originalUrl, paramName, paramValue,
                           dontCacheBustUrlsMatching) {
    // Create a new URL object to avoid modifying originalUrl.
    var url = new URL(originalUrl);

    // If dontCacheBustUrlsMatching is not set, or if we don't have a match,
    // then add in the extra cache-busting URL parameter.
    if (!dontCacheBustUrlsMatching ||
        !(url.toString().match(dontCacheBustUrlsMatching))) {
      url.search += (url.search ? '&' : '') +
        encodeURIComponent(paramName) + '=' + encodeURIComponent(paramValue);
    }

    return url.toString();
  };

var isPathWhitelisted = function (whitelist, absoluteUrlString) {
    // If the whitelist is empty, then consider all URLs to be whitelisted.
    if (whitelist.length === 0) {
      return true;
    }

    // Otherwise compare each path regex to the path of the URL passed in.
    var path = (new URL(absoluteUrlString)).pathname;
    return whitelist.some(function(whitelistedPathRegex) {
      return path.match(whitelistedPathRegex);
    });
  };

var stripIgnoredUrlParameters = function (originalUrl,
    ignoreUrlParametersMatching) {
    var url = new URL(originalUrl);

    url.search = url.search.slice(1) // Exclude initial '?'
      .split('&') // Split into an array of 'key=value' strings
      .map(function(kv) {
        return kv.split('='); // Split each 'key=value' string into a [key, value] array
      })
      .filter(function(kv) {
        return ignoreUrlParametersMatching.every(function(ignoredRegex) {
          return !ignoredRegex.test(kv[0]); // Return true iff the key doesn't match any of the regexes.
        });
      })
      .map(function(kv) {
        return kv.join('='); // Join each [key, value] array into a 'key=value' string
      })
      .join('&'); // Join the array of 'key=value' strings into a string with '&' in between each

    return url.toString();
  };


var hashParamName = '_sw-precache';
var urlsToCacheKeys = new Map(
  precacheConfig.map(function(item) {
    var relativeUrl = item[0];
    var hash = item[1];
    var absoluteUrl = new URL(relativeUrl, self.location);
    var cacheKey = createCacheKey(absoluteUrl, hashParamName, hash, false);
    return [absoluteUrl.toString(), cacheKey];
  })
);

function setOfCachedUrls(cache) {
  return cache.keys().then(function(requests) {
    return requests.map(function(request) {
      return request.url;
    });
  }).then(function(urls) {
    return new Set(urls);
  });
}

self.addEventListener('install', function(event) {
  event.waitUntil(
    caches.open(cacheName).then(function(cache) {
      return setOfCachedUrls(cache).then(function(cachedUrls) {
        return Promise.all(
          Array.from(urlsToCacheKeys.values()).map(function(cacheKey) {
            // If we don't have a key matching url in the cache already, add it.
            if (!cachedUrls.has(cacheKey)) {
              return cache.add(new Request(cacheKey, {credentials: 'same-origin'}));
            }
          })
        );
      });
    }).then(function() {
      
      // Force the SW to transition from installing -> active state
      return self.skipWaiting();
      
    })
  );
});

self.addEventListener('activate', function(event) {
  var setOfExpectedUrls = new Set(urlsToCacheKeys.values());

  event.waitUntil(
    caches.open(cacheName).then(function(cache) {
      return cache.keys().then(function(existingRequests) {
        return Promise.all(
          existingRequests.map(function(existingRequest) {
            if (!setOfExpectedUrls.has(existingRequest.url)) {
              return cache.delete(existingRequest);
            }
          })
        );
      });
    }).then(function() {
      
      return self.clients.claim();
      
    })
  );
});


self.addEventListener('fetch', function(event) {
  if (event.request.method === 'GET') {
    // Should we call event.respondWith() inside this fetch event handler?
    // This needs to be determined synchronously, which will give other fetch
    // handlers a chance to handle the request if need be.
    var shouldRespond;

    // First, remove all the ignored parameter and see if we have that URL
    // in our cache. If so, great! shouldRespond will be true.
    var url = stripIgnoredUrlParameters(event.request.url, ignoreUrlParametersMatching);
    shouldRespond = urlsToCacheKeys.has(url);

    // If shouldRespond is false, check again, this time with 'index.html'
    // (or whatever the directoryIndex option is set to) at the end.
    var directoryIndex = 'index.html';
    if (!shouldRespond && directoryIndex) {
      url = addDirectoryIndex(url, directoryIndex);
      shouldRespond = urlsToCacheKeys.has(url);
    }

    // If shouldRespond is still false, check to see if this is a navigation
    // request, and if so, whether the URL matches navigateFallbackWhitelist.
    var navigateFallback = '';
    if (!shouldRespond &&
        navigateFallback &&
        (event.request.mode === 'navigate') &&
        isPathWhitelisted([], event.request.url)) {
      url = new URL(navigateFallback, self.location).toString();
      shouldRespond = urlsToCacheKeys.has(url);
    }

    // If shouldRespond was set to true at any point, then call
    // event.respondWith(), using the appropriate cache key.
    if (shouldRespond) {
      event.respondWith(
        caches.open(cacheName).then(function(cache) {
          return cache.match(urlsToCacheKeys.get(url)).then(function(response) {
            if (response) {
              return response;
            }
            throw Error('The cached response that was expected is missing.');
          });
        }).catch(function(e) {
          // Fall back to just fetch()ing the request if some unexpected error
          // prevented the cached response from being valid.
          console.warn('Couldn\'t serve response for "%s" from cache: %O', event.request.url, e);
          return fetch(event.request);
        })
      );
    }
  }
});







