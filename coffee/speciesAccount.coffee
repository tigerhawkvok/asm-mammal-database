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


worldPoliticalFusionTableId = "1uKyspg-HkChMIntZ0N376lMpRzduIjr85UYPpQ"

baseQuery =
  query:
    select: "json_4326" # GeoJson coords: http://blog.mastermaps.com/2011/02/natural-earth-vectors-in-cloud.html
    from: worldPoliticalFusionTableId
  styles: [
    polygonOptions:
      fillColor: "#dd2255",
      strokeColor: "#000",
      strokeWeight: .05
      fillOpacity: .05
    ]
  suppressInfoWindows: true

if typeof _asm is "object"
  _asm.baseQuery = $.extend {}, baseQuery

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
  console.debug "Got query obj", queryObj
  fusionQuery = $.extend {}, _asm.baseQuery
  #fusionQuery = baseQuery ? _asm.baseQuery
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
        where: where
        polygonOptions:
          fillColor: "#22dd55",
          strokeColor: "#22dd55",
          strokeWeight: 1
          fillOpacity: .5
      fusionQuery.styles.push tmp
    fusionQueries.push fusionQuery
    layers.push setMapHelper new google.maps.FusionTablesLayer(fusionQuery), mapObj
  else
    fusionQuery.query.where = queryObj
    fusionQuery.styles[0] =
      polygonOptions:
        fillColor: "#22dd55",
        strokeColor: "#22dd55",
        strokeWeight: 1
        fillOpacity: .5
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
  onFail = ->
    fetchMOLRange(taxon, undefined, true)
    false
  $.get "api.php", buildQuery args, "json"
  .done (result) ->
    console.log "Got", result
    if result.status isnt true
      console.warn "#{uri.urlString}api.php?#{buildQuery args}"
      try
        onFail()
      return false
    countryList = new Array()
    if result.response?.count <= 0
      console.warn "No results found!"
      try
        onFail()
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
      shuffle countryList
      populateQueryObj =
        code: countryList
      console.debug "Taxon exists in #{countryList.length} countries...", countryList
      initMap ->
        console.debug "Map initialized, populating..."
        appendResults = appendCountryLayerToMap populateQueryObj
        console.debug "Country layers topped", appendResults
    false
  .fail (result, error) ->
    console.error "Couldn't load range map"
    console.warn result, error
    try
      onFail()
    false
  false



fetchMOLRange = (taxon = window._activeTaxon, kml, dontExecuteFallback = false, nextToSelector = "#species-note") ->
  ###
  # Embed an iFrame for Map of Life.
  ###
  unless typeof taxon is "object"
    console.error "No taxon object specified"
    return false
  el = taxon
  if isNull(taxon.genus) or isNull(taxon.species)
    # Check if the object is actually an element
    try
      genus = $(taxon).attr "data-genus"
      species = $(taxon).attr "data-species"
      if isNull kml
        kml = $(taxon).attr "data-kml"
      taxon = {genus, species}
  if isNull(taxon.genus) or isNull(taxon.species)
    toastStatusMessage "Unable to show range map"
    return false
  if isNull kml
    try
      kml = $(el).attr "data-kml"
    if isNull kml
      console.warn "Unable to read KML attr and none passed"
  endpoint = "https://mol.org/species/map/"
  args =
    embed: "true"
  window._iframeRangeFail = ->
    unless dontExecuteFallback
      console.warn "We failed to load the MOL range map, doing a fall back to the IUCN/FusionTable map"
      $("#taxon-range-map-container.mol-map-container").remove()
      fetchIucnRange(taxon)
    else
      console.debug "Not falling back -- `dontExecuteFallback` set"
    false
  html = """
  <div id="taxon-range-map-container" class="col-xs-6 map-container mol-map-container">
    <iframe class="mol-embed mol-account map" id="species-range-map" src="#{endpoint}#{taxon.genus.toTitleCase()}_#{taxon.species}?#{buildQuery args}"  data-taxon-genus="#{taxon.genus}" data-taxon-species="#{taxon.species}" onerror="_iframeRangeFail()"></iframe>
  </div>
  """
  $("#taxon-range-map-container").remove()
  $(nextToSelector)
  .removeClass "col-xs-12"
  .addClass "col-xs-6"
  .after html
  doIucnLoad = delay 7500, -> _iframeRangeFail()
  $("#species-range-map").on "load", ->
    clearTimeout doIucnLoad
    false
  true



getSpeciesAccountLinkout = (taxon =  window._activeTaxon, endpoint = "api.php", domSelector = "ol a[href^='pdf']") ->
  ###
  # Check open-access account lists to find if there are any accounts
  # available to ping and link out to
  #
  # See
  # https://github.com/tigerhawkvok/asm-mammal-database/issues/86
  ###
  $.get endpoint, "action=get-account"
  .done (result) ->
    console.debug "Got response", result
    if result.status isnt true
      console.error "There was a problem fetching the endpoint content"
      console.warn result
      return false
    resultHtml = decode64 result.body_content
    relativeParts = result.endpoint.split "/"
    listPage = relativeParts.pop()
    relativeBase = relativeParts.join "/"
    console.debug "Got result!"
    fullDom = $(resultHtml)
    console.debug "Got full dom"
    foundMatch = false
    anchorList = fullDom.find domSelector
    console.debug "Anchor list is #{anchorList.length} elements long"
    _asm.availableTaxaAccounts = new Array()
    for anchor in anchorList
      anchorText = $(anchor).text()
      taxonName = anchorText.replace(/^(.*?)\s+\(([\w ]+)\)\s*$/img, "$2").split " "
      taxonSample =
        genus: taxonName[0].toLowerCase()
        species: taxonName[1].toLowerCase()
      _asm.availableTaxaAccounts.push taxonSample
      if taxonName[0].toLowerCase() is taxon.genus.toLowerCase() and taxonName[1].toLowerCase() is taxon.species.toLowerCase()
        pdfLocation = relativeBase + "/" + $(anchor).attr "href"        
        console.log "Found a match: ", pdfLocation
        foundMatch = true
        html = """
        <paper-icon-button
          icon="icons:description"
          data-href="#{pdfLocation}"
          class="click"
          data-newtab="true"
          id="external-species-account"
          title="View Species Account PDF (Open Access)"
          data-toggle="tooltip"
          >
        </paper-icon-button>
        """
        $("#species-account h3").after html
        bindClicks("#external-species-account")
        break
    if foundMatch isnt true
      console.warn "Found no matching taxon from open-access accounts"
    false
  .fail (result, status) ->
    console.error "Unable to hit target '#{endpoint}'"
    false
  false


_asm.getSpeciesAccountLinkout = getSpeciesAccountLinkout

$ ->
  unless isNull window.gMapsLocalKey
    console.log "Using local unrestricted key"
    gMapsConfig.jsApiKey = window.gMapsLocalKey
  fetchMOLRange()
  getSpeciesAccountLinkout()
  false
