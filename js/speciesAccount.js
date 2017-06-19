
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
var appendCountryLayerToMap, baseQuery, fetchIucnRange, gMapsConfig, initMap, worldPoliticalFusionTableId,
  indexOf = [].indexOf || function(item) { for (var i = 0, l = this.length; i < l; i++) { if (i in this && this[i] === item) return i; } return -1; };

gMapsConfig = {
  jsApiKey: "AIzaSyC_qZqVvNk6A6px4Q7BJQOOHqpnQNihSBA",
  jsApiSrc: "https://maps.googleapis.com/maps/api/js",
  jsApiInitCallbackFn: null,
  hasRunInitMap: false
};

if (!isNull(window.gMapsLocalKey)) {
  gMapsConfig.jsApiKey = window.gMapsLocalKey;
}

worldPoliticalFusionTableId = "1uKyspg-HkChMIntZ0N376lMpRzduIjr85UYPpQ";

baseQuery = {
  query: {
    select: "json_4326",
    from: worldPoliticalFusionTableId
  },
  styles: [
    {
      polygonOptions: {
        fillColor: "#rrggbb",
        strokeColor: "#rrggbb",
        strokeWeight: "int",
        fillOpacity: 0
      }
    }
  ]
};

appendCountryLayerToMap = function(queryObj, mapObj) {
  var build, col, fusionColumn, fusionQuery, i, j, layer, len, len1, query, subval, temp, val, where;
  if (queryObj == null) {
    queryObj = {
      "code": "US"
    };
  }
  if (mapObj == null) {
    mapObj = gMapsConfig.map;
  }

  /*
   *
   */
  if ((typeof google !== "undefined" && google !== null ? google.maps : void 0) == null) {
    initMap(function() {
      appendCountryLayerToMap(queryObj, mapObj);
      return false;
    });
    return false;
  }
  if (!(mapObj instanceof google.maps.Map)) {
    console.error("Invalid map object provided");
    return false;
  }
  fusionColumn = {
    code: "postal",
    postal: "postal",
    name: "name",
    country: "name"
  };
  fusionQuery = baseQuery;
  if (typeof queryObj === "object") {
    build = new Array();
    for (col in queryObj) {
      val = queryObj[col];
      if (indexOf.call(Object.keys(fusionColumn), col) >= 0) {
        if (isArray(val)) {
          for (i = 0, len = val.length; i < len; i++) {
            subval = val[i];
            build.push("'" + fusionColumn[col] + "' = '" + subval + "'");
          }
        } else {
          build.push("'" + fusionColumn[col] + "' = '" + val + "'");
        }
      }
    }
    for (j = 0, len1 = build.length; j < len1; j++) {
      where = build[j];
      temp = {
        where: where,
        polygonOptions: {
          fillOpacity: .5
        }
      };
      fusionQuery.styles.push(temp);
    }
  } else {
    query = queryObj;
    fusionQuery.query.where = query;
  }
  layer = new google.maps.FusionTablesLayer(fusionQuery);
  layer.setMap(mapObj);
  return {
    fusionQuery: fusionQuery,
    layer: layer,
    mapObj: mapObj
  };
};

initMap = function(callback, nextToSelector) {
  var canvasHtml, map, mapDefaults, mapDiv, mapPath, names, ref, ref1, ref2, ref3, ref4, selfName;
  if (nextToSelector == null) {
    nextToSelector = "#species-note";
  }

  /*
   *
   */
  if (gMapsConfig.hasRunInitMap === true) {
    console.debug("Map already initialized");
    if (typeof callback === "function") {
      callback();
    }
    return false;
  }
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
      initMap(callback, nextToSelector);
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
  gMapsConfig.hasRunInitMap = true;
  if (typeof callback === "function") {
    callback();
  }
  return map;
};

fetchIucnRange = function(taxon) {
  var args;
  if (taxon == null) {
    taxon = window._activeTaxon;
  }

  /*
   *
   */
  if (isNull(taxon.genus) || isNull(taxon.species)) {
    false;
  }
  args = {
    action: "iucn",
    taxon: (taxon.genus.toTitleCase()) + "%20" + taxon.species,
    iucn_endpoint: "species/countries/name/"
  };
  if (!isNull(taxon.subspecies)) {
    args.taxon += "%20" + taxon.subspecies;
  }
  $.get("api.php", buildQuery(args, "json")).done(function(result) {
    var countryList, countryObj, extantList, i, j, len, len1, populateQueryObj, ref, sourceList;
    console.log("Got", result);
    if (result.status !== true) {
      console.warn(uri.urlString + "api.php?" + (buildQuery(args)));
      return false;
    }
    countryList = new Array();
    if (((ref = result.response) != null ? ref.count : void 0) <= 0) {
      console.warn("No results found!");
      return false;
    } else {
      sourceList = Object.toArray(result.response.result);
      extantList = new Array();
      for (i = 0, len = sourceList.length; i < len; i++) {
        countryObj = sourceList[i];
        if (countryObj.presence.search(/extinct/i) === -1) {
          extantList.push(countryObj);
        }
      }
      if (extantList.length === 0) {
        console.warn("This taxon '" + result.response.name + "' is extinct :(");
        return false;
      }
      for (j = 0, len1 = extantList.length; j < len1; j++) {
        countryObj = extantList[j];
        countryList.push(countryObj.code);
      }
      populateQueryObj = {
        code: countryList
      };
      console.debug("Taxon exists in " + countryList.length + " countries...", countryList);
      initMap(function() {
        var appendResults;
        console.debug("Map initialized, populating...");
        appendResults = appendCountryLayerToMap(populateQueryObj);
        return console.debug("Country layers topped", appendResults);
      });
    }
    return false;
  }).fail(function(result, error) {
    return false;
  });
  return false;
};

$(function() {
  fetchIucnRange();
  return false;
});

//# sourceMappingURL=maps/speciesAccount.js.map
