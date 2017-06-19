
/*
 * Highlight countries on a Google Map
 *
 * Use a Fusion Table later
 *
 * Fusion Tables:
 *   - https://developers.google.com/maps/documentation/javascript/fusiontableslayer#constructing_a_fusiontables_layer
 *   - https://fusiontables.google.com/DataSource?dsrcid=424206#rows:id=1
 *   - Fusion ID: 1uKyspg-HkChMIntZ0N376lMpRzduIjr85UYPpQ
 *   -
 *
 */
var appendCountryLayerToMap, baseQuery, gMapsConfig, initMap, worldPoliticalFusionTableId,
  indexOf = [].indexOf || function(item) { for (var i = 0, l = this.length; i < l; i++) { if (i in this && this[i] === item) return i; } return -1; };

gMapsConfig = {
  jsApiKey: "AIzaSyC_qZqVvNk6A6px4Q7BJQOOHqpnQNihSBA",
  jsApiSrc: "https://maps.googleapis.com/maps/api/js",
  jsApiInitCallbackFn: null
};

if (!isNull(window.gMapsLocalKey)) {
  gMapsConfig.jsApiKey = window.gMapsLocalKey;
}

worldPoliticalFusionTableId = "1uKyspg-HkChMIntZ0N376lMpRzduIjr85UYPpQ";

baseQuery = {
  select: "json_4326",
  from: worldPoliticalFusionTableId
};

appendCountryLayerToMap = function(queryObj, mapObj) {
  var build, col, fusionColumn, fusionQuery, mapPath, query, val;
  if (mapObj == null) {
    mapObj = gMapsConfig.map;
  }

  /*
   *
   */
  if ((typeof google !== "undefined" && google !== null ? google.maps : void 0) == null) {
    console.debug("Loading Google Maps first ...");
    mapPath = gMapsConfig.jsApiSrc + "?key=" + gMapsConfig.jsApiKey;
    if (typeof gMapsConfig.jsApiInitCallbackFn === "function") {
      mapPath += "&callback=" + gMapsConfig.jsApiInitCallbackFn.name;
    }
    loadJS(mapPath, function() {
      appendCountryLayerToMap(queryObj, mapObj);
      return false;
    });
    return false;
  }
  if (!mapObj(instanceOf(google.map.Map))) {
    console.error("Invalid map object provided");
    return false;
  }
  fusionColumn = {
    code: "postal",
    postal: "postal",
    name: "name",
    country: "name"
  };
  if (typeof queryObj === "object") {
    build = new Array();
    for (col in queryObj) {
      val = queryObj[col];
      if (indexOf.call(Object.keys(fusionColumn), col) >= 0) {
        build.push("`" + fusionColumn[col] + "` = '" + val + "'");
      }
    }
    query = build.join(" OR ");
  } else {
    query = queryObj;
  }
  fusionQuery = baseQuery;
  fusionQuery.where = query;
  return false;
};

initMap = function(nextToSelector) {
  var canvasHtml, map, mapDefaults, mapDiv, mapPath, names, ref, ref1, ref2, ref3, ref4, selfName;
  if (nextToSelector == null) {
    nextToSelector = "#species-note";
  }

  /*
   *
   */
  if ((typeof google !== "undefined" && google !== null ? google.maps : void 0) == null) {
    console.debug("Loading Google Maps first ...");
    mapPath = gMapsConfig.jsApiSrc + "?key=" + gMapsConfig.jsApiKey;
    if (typeof gMapsConfig.jsApiInitCallbackFn === "function") {
      selfName = this.getName();
      names = [selfName, "initMap"];
      if (ref = gMapsConfig.jsApiInitCallbackFn.getName(), indexOf.call(names, ref) < 0) {
        mapPath += "&callback=" + (gMapsConfig.jsApiInitCallbackFn.getName());
      }
    }
    loadJS(mapPath, function() {
      initMap(nextToSelector);
      return false;
    });
    return false;
  }
  if (!$(nextToSelector).exists()) {
    console.error("Invalid page layout to init map");
    return false;
  }
  $(nextToSelector).removeClass("col-xs-12").addClass("col-xs-6");
  canvasHtml = "<div id=\"taxon-range-map-container\" class=\"col-xs-6 map-container google-map-container\">\n  <div id=\"taxon-range-map\" class=\"map google-map\">\n  </div>\n</div>";
  $(nextToSelector).after(canvasHtml);
  mapDefaults = {
    center: {
      lat: (ref1 = (ref2 = window.locationData) != null ? ref2.lat : void 0) != null ? ref1 : 0,
      lng: (ref3 = (ref4 = window.locationData) != null ? ref4.lng : void 0) != null ? ref3 : 0
    },
    zoom: 2
  };
  mapDiv = $("#taxon-range-map").get(0);
  map = new google.maps.Map(mapDiv, mapDefaults);
  gMapsConfig.map = map;
  return map;
};

$(function() {
  return false;
});

//# sourceMappingURL=maps/speciesAccount.js.map
