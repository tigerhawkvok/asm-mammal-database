###
# Highlight countries on a Google Map
#
# Use a Fusion Table later
#
# Fusion Tables:
#   - https://developers.google.com/maps/documentation/javascript/fusiontableslayer#constructing_a_fusiontables_layer
#   - https://fusiontables.google.com/DataSource?dsrcid=424206#rows:id=1
#   - Fusion ID: 1uKyspg-HkChMIntZ0N376lMpRzduIjr85UYPpQ
#   -
#
###

gMapsConfig =
  jsApiKey: "AIzaSyC_qZqVvNk6A6px4Q7BJQOOHqpnQNihSBA"
  jsApiSrc: "https://maps.googleapis.com/maps/api/js"
  jsApiInitCallbackFn: null
  hasRunInitMap: false

unless isNull window.gMapsLocalKey
  gMapsConfig.jsApiKey = window.gMapsLocalKey


worldPoliticalFusionTableId = "1uKyspg-HkChMIntZ0N376lMpRzduIjr85UYPpQ"

baseQuery =
  query:
    select: "json_4326" # GeoJson coords: http://blog.mastermaps.com/2011/02/natural-earth-vectors-in-cloud.html
    from: worldPoliticalFusionTableId
  styles: [
    polygonOptions:
      fillColor: "#22dd55",
      strokeColor: "#22dd55",
      strokeWeight: 1
      fillOpacity: .5
    ]


appendCountryLayerToMap = (queryObj = {"code":"US"},  mapObj = gMapsConfig.map) ->
  ###
  #
  ###
  unless google?.maps?
    initMap ->
      appendCountryLayerToMap queryObj, mapObj
      false
    return false
  # Verify the map object is really a map object
  unless mapObj instanceof google.maps.Map
    console.error "Invalid map object provided"
    return false
  # Create a map of plausible query specifications to fusion table
  # lookups
  # Primarily based on IUCNv3 API codes
  # Ex: http://apiv3.iucnredlist.org/api/v3/species/countries/name/Loxodonta%20africana?token=9bb4facb6d23f48efbf424bb05c0c1ef1cf6f468393bc745d42179ac4aca5fee
  fusionColumn =
    code: "postal"
    postal: "postal"
    name: "name"
    country: "name"
  layers = new Array()
  fusionQuery = $.extend {}, baseQuery
  fusionQueries = new Array()
  if typeof queryObj is "object"
    build = new Array()
    for col, val of queryObj
      if col in Object.keys fusionColumn
        if isArray val
          for subval in val
            build.push "'#{fusionColumn[col]}' = '#{subval}'"
        else
          build.push "'#{fusionColumn[col]}' = '#{val}'"
    for where in build
      # We need to redeclare it, because object copies suck.
      tmp =
        query:
          select: "json_4326" # GeoJson coords: http://blog.mastermaps.com/2011/02/natural-earth-vectors-in-cloud.html
          from: worldPoliticalFusionTableId
          where: where
        styles: [
          polygonOptions:
            fillColor: "#22dd55",
            strokeColor: "#22dd55",
            strokeWeight: 1
            fillOpacity: .5
          ]
      fusionQueries.push tmp
      layers.push setMapHelper new google.maps.FusionTablesLayer(tmp), mapObj
  else
    fusionQuery.query.where = queryObj
    fusionQueries.push fusionQuery
    layers.push setMapHelper new google.maps.FusionTablesLayer(fusionQuery), mapObj
  {fusionQueries, layers, mapObj}

setMapHelper = (layer, mapObj = gMapsConfig.map) ->
  layer.setMap mapObj
  layer


initMap = (callback, nextToSelector = "#species-note") ->
  ###
  #
  ###
  if gMapsConfig.hasRunInitMap is true
    console.debug "Map already initialized"
    if typeof callback is "function"
      callback()
    return false
  unless google?.maps?
    console.debug "Loading Google Maps first ..."
    mapPath = "#{gMapsConfig.jsApiSrc}?key=#{gMapsConfig.jsApiKey}"
    if typeof gMapsConfig.jsApiInitCallbackFn is "function"
      selfName = @getName()
      names = [
        selfName
        "initMap"
        ]
      unless gMapsConfig.jsApiInitCallbackFn.getName() in names
        mapPath += "&callback=#{gMapsConfig.jsApiInitCallbackFn.getName()}"
    loadJS mapPath, ->
      initMap callback, nextToSelector
      false
    return false
  unless $(nextToSelector).exists()
    console.error "Invalid page layout to init map"
    return false
  $(nextToSelector)
  .removeClass "col-xs-12"
  .addClass "col-xs-6"
  canvasHtml = """
  <div id="taxon-range-map-container" class="col-xs-6 map-container google-map-container">
    <div id="taxon-range-map" class="map google-map">
    </div>
  </div>
  """
  $(nextToSelector).after canvasHtml
  mapDefaults =
    center:
      lat: window.locationData?.lat ? 0
      lng: window.locationData?.lng ? 0
    zoom: 2
  mapDiv = $("#taxon-range-map").get(0)
  map = new google.maps.Map mapDiv, mapDefaults
  gMapsConfig.map = map
  gMapsConfig.hasRunInitMap = true
  if typeof callback is "function"
    callback()
  map



fetchIucnRange = (taxon = window._activeTaxon) ->
  ###
  #
  ###
  if isNull(taxon.genus) or isNull taxon.species
    # we have to infer the taxon
    false
  args =
    action: "iucn"
    taxon: "#{taxon.genus.toTitleCase()}%20#{taxon.species}"
    iucn_endpoint: "species/countries/name/"
  unless isNull taxon.subspecies
    args.taxon += "%20#{taxon.subspecies}"
  $.get "api.php", buildQuery args, "json"
  .done (result) ->
    console.log "Got", result
    if result.status isnt true
      console.warn "#{uri.urlString}api.php?#{buildQuery args}"
      return false
    countryList = new Array()
    if result.response?.count <= 0
      console.warn "No results found!"
      return false
    else
      sourceList = Object.toArray result.response.result
      extantList = new Array()
      for countryObj in sourceList
        if countryObj.presence.search(/extinct/i) is -1
          extantList.push countryObj
      if extantList.length is 0
        console.warn "This taxon '#{result.response.name}' is extinct :("
        return false
      for countryObj in extantList
        countryList.push countryObj.code
      populateQueryObj =
        code: countryList
      console.debug "Taxon exists in #{countryList.length} countries...", countryList
      initMap ->
        console.debug "Map initialized, populating..."
        appendResults = appendCountryLayerToMap populateQueryObj
        console.debug "Country layers topped", appendResults
    false
  .fail (result, error) ->
    false
  false



$ ->
  fetchIucnRange()
  false
