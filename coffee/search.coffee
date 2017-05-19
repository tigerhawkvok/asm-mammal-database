searchParams =
  lastSearch: "*"
  targetApi: "api.php"
  targetContainer: "#result_container"
searchParams.apiPath = uri.urlString + targetApi

window._asm = new Object()
# Base query URLs for out-of-site linkouts
_asm.affiliateQueryUrl =
  iucnRedlist: "http://apiv3.iucnredlist.org/api/v3/species/"
  iucnRedlistCN: "http://apiv3.iucnredlist.org/api/v3/species/common_names/"
  iNaturalist: "https://www.inaturalist.org/taxa/search"



fetchMajorMinorGroups = (scientific = null, callback) ->
  renderItemsList = ->
    $("#eutheria-extra").remove()
    # Change the item list
    menuItems = """
    <paper-item data-type="any" selected>All</paper-item>
    """
    for itemType, itemLabel of _asm.major
      menuItems += """
    <paper-item data-type="#{itemType}">#{itemLabel.toTitleCase()}</paper-item>
      """
    column = if scientific then "linnean_family" else "simple_linnean_subgroup"
    buttonHtml = """
            <paper-menu-button id="simple-linnean-groups" class="col-xs-6 col-md-4">
              <paper-button class="dropdown-trigger"><iron-icon icon="icons:filter-list"></iron-icon><span id="filter-what" class="dropdown-label"></span></paper-button>
              <paper-menu label="Group" data-column="simple_linnean_group" class="cndb-filter dropdown-content" id="linnean" name="type" attrForSelected="data-type" selected="0">
                #{menuItems}
              </paper-menu>
            </paper-menu-button>
    """
    if $("#simple-linnean-groups").exists()
      $("#simple-linnean-groups").replaceWith buttonHtml
      $("#simple-linnean-groups")
      .on "iron-select", ->
        type = $(p$("#simple-linnean-groups paper-menu").selectedItem).text()
        $("#simple-linnean-groups span.dropdown-label").text type
      try
        type = $(p$("#simple-linnean-groups paper-menu").selectedItem).text()
        $("#simple-linnean-groups span.dropdown-label").text type
    eutheriaFilterHelper(true)
    if $("#simple-linnean-groups").exists()
      console.log "Replaced menu items with", menuItems
    if typeof callback is "function"
      callback()
    false
  if typeof _asm.mammalGroupsBase is "object" and typeof _asm.major is "object"
    unless isArray _asm.mammalGroupsBase
      _asm.mammalGroupsBase = Object.toArray _asm.mammalGroupsBase
    renderItemsList()
    return true
  else
    # Hit the API
    unless isBool scientific
      try
        scientific = p$("#use-scientific").checked ? true
      catch
        scientific = true
    $.get searchParams.apiPath, "fetch-groups=true&scientific=#{scientific}"
    .done (result) ->
      # console.log "Group fetch for dropdown got", result
      if result.status isnt true
        return false
      _asm.mammalGroupsBase = Object.toArray result.minor
      _asm.major = result.major
      renderItemsList()
    .fail (result, error) ->
      console.error "Failed to hit API"
      console.warn result, error
      false
  false



eutheriaFilterHelper = (skipFetch = false) ->
  unless skipFetch
    fetchMajorMinorGroups.debounce(50)
    try
      $("#use-scientific")
      .on "iron-change", ->
        delete _asm.mammalGroupsBase
        fetchMajorMinorGroups.debounce(50)
  $("#linnean")
  .on "iron-select", ->
    if $(p$("#linnean").selectedItem).attr("data-type") is "eutheria"
      # Clean it up for the code
      mammalGroups = new Array()
      for humanGroup in _asm.mammalGroupsBase
        mammalGroups.push humanGroup.toLowerCase()
      mammalGroups.sort()
      mammalItems = ""
      for group in mammalGroups
        html = """
        <paper-item data-type="#{group}">
          #{group.toTitleCase()}
        </paper-item>
        """
        mammalItems += html
      unless isBool scientific
        try
          scientific = p$("#use-scientific").checked ? true
        catch
          scientific = true
      column = if scientific then "linnean_order" else "simple_linnean_subgroup"
      html = """
        <div id="eutheria-extra"  class="col-xs-6 col-md-4">
            <label for="type" class="sr-only">Eutheria Filter</label>
            <div class="row">
            <paper-menu-button class="col-xs-12" id="eutheria-subfilter">
              <paper-button class="dropdown-trigger"><iron-icon icon="icons:filter-list"></iron-icon><span id="filter-what" class="dropdown-label"></span></paper-button>
              <paper-menu label="Group" data-column="#{column}" class="cndb-filter dropdown-content" id="linnean-eutheria" name="type" attrForSelected="data-type" selected="0">
                <paper-item data-type="any" selected>All</paper-item>
                #{mammalItems}
                <!-- As per flag 4 in readme -->
              </paper-menu>
            </paper-menu-button>
            </div>
          </div>
      """
      $("#simple-linnean-groups").after html
      $("#eutheria-subfilter")
      .on "iron-select", ->
        type = $(p$("#eutheria-subfilter paper-menu").selectedItem).attr "data-type"
        $("#eutheria-subfilter span.dropdown-label").text type
      type = $(p$("#eutheria-subfilter paper-menu").selectedItem).attr "data-type"
      $("#eutheria-subfilter span.dropdown-label").text type
    else
      $("#eutheria-extra").remove()
  try
    doLazily()
  false



checkLaggedUpdate = (result) ->
  iucnCanProvide = [
    "common_name"
    "species_authority"
    ]
  start = Date.now()
  if result.do_client_update is true
    # console.info "About to trigger client update process"
    k = j = 0
    finishedLoop = false
    try
      for i, taxon of result.result
        shouldSkip = true
        for key in iucnCanProvide
          unless isNull taxon[key]
            continue
          else
            # console.debug "Missing key '#{key}' in ", taxon
            shouldSkip = false
            break
        if shouldSkip
          continue
        ++k
        args = "missing=true&genus=#{taxon.genus}&species=#{taxon.species}"
        #console.log "About to ping missing update url", "#{searchParams.targetApi}?#{args}"
        $.get searchParams.targetApi, args, "json"
        .done (subResult) ->
          ++j
          unless subResult.did_update
            return false
          console.log "Update for #{subResult.canonical_sciname}", subResult
          row = $(".cndb-result-entry[data-taxon='#{subResult.genus}+#{subResult.species}']")
          for col, val of subResult
            if $(row).find(".#{col}").exists() and not isNull val
              if isNull $(row).find(".#{col}").text()
                console.log "Set #{col} text of #{subResult.canonical_sciname} to #{val}"
                $(row).find(".#{col}").text val
            else if $(row).find(".#{col}").exists() and isNull val
              console.warn "Couldn't update #{col} - got an empty IUCN result"
          false
        .fail (subResult, status) ->
          console.warn "Couldn't update #{taxon.canonical_sciname}", subResult, status
          console.warn "#{searchParams.targetApi}?#{args}"
          false
        .always ->
          if j is k and finishedLoop
            elapsed = Date.now() - start
            console.log "Finished async IUCN taxa check in #{elapsed}ms"
      finishedLoop = true
    catch e
      console.warn "Couldn't do client update -- #{e.message}"
      console.warn e.stack
  false



performSearch = (stateArgs = undefined) ->
  ###
  # Check the fields and filters and do the async search
  ###
  if not stateArgs?
    # No arguments have been passed in
    s = $("#search").val()
    # Store a version before we do any search modifiers
    sOrig = s
    s = s.toLowerCase()
    filters = getFilters()
    if (isNull(s) or not s?) and isNull(filters)
      $("#search-status").attr("text","Please enter a search term.")
      $("#search-status")[0].show()
      return false
    $("#search").blur()
    # Remove periods from the search
    s = s.replace(/\./g,"")
    s = prepURI(s)
    if $("#loose").polymerChecked()
      s = "#{s}&loose=true"
    if $("#fuzzy").polymerChecked()
      s = "#{s}&fuzzy=true"
    # Add on the filters
    unless isNull(filters)
      # console.log("Got filters - #{filters}")
      s = "#{s}&filter=#{filters}"
    args = "q=#{s}"
  else
    # An argument has been passed in
    if stateArgs is true
      # Special case -- do a search on everything
      args = "q="
      sOrig = "(all items)"
    else
      # Do the search exactly as passed. The fragment should ALREADY
      # be decoded at this point.
      args = "q=#{stateArgs}"
      sOrig = stateArgs.split("&")[0]
    #console.log("Searching on #{stateArgs}")
  if s is "#" or (isNull(s) and isNull(args)) or (args is "q=" and stateArgs isnt true)
    return false
  animateLoad()
  console.log("Got search value #{s}, hitting","#{searchParams.apiPath}?#{args}")
  searchParams.lastSearch = s
  $.get(searchParams.targetApi,args,"json")
  .done (result) ->
    # Populate the result container
    # console.log("Search executed by #{result.method} with #{result.count} results.")
    if toInt(result.count) is 0
      console.error "No search results: Got search value #{s}, from hitting","#{searchParams.apiPath}?#{args}"
      showBadSearchErrorMessage.debounce null, null, null, result
      clearSearch(true)
      return false
    if result.status is true
      console.log "Server response:", result
      # May be worth moving this part to a service worker
      formatSearchResults result, undefined, ->
        checkLaggedUpdate result
      return false
    clearSearch(true)
    $("#search-status").attr("text",result.human_error)
    $("#search-status")[0].show()
    console.error(result.error)
    console.warn(result)
    stopLoadError()
  .fail (result,error) ->
    console.error("There was an error performing the search")
    console.warn(result,error,result.statusText)
    error = "#{result.status} - #{result.statusText}"
    # It probably doesn't make sense to clear the search on a bad
    # server call ...
    # clearSearch(true)
    $("#search-status").attr("text","Couldn't execute the search - #{error}")
    $("#search-status")[0].show()
    stopLoadError()
  .always ->
    # Anything we always want done
    b64s = Base64.encodeURI s
    if s? then setHistory "#{uri.urlString}##{b64s}"
    false

getFilters = (selector = ".cndb-filter", booleanType = "AND") ->
  ###
  # Look at $(selector) and apply the filters as per
  # https://github.com/tigerhawkvok/SSAR-species-database#search-flags
  # It's meant to work with Polymer dropdowns, but it'll fall back to <select><option>
  ###
  filterList = new Object()
  $(selector).each ->
    col = $(this).attr("data-column")
    if not col?
      # Skip this iteration
      return true
    try
      val = $(this).polymerSelected()
    catch
      return true
    if val is "any" or val is "all" or val is "*"
      # Wildcard filter -- just don't give anything
      # Go to the next iteration
      return true
    if isNull(val) or val is false
      val = $(this).val()
      if isNull(val)
        # Skip this iteration
        return true
      else
    filterList[col] = val.toLowerCase()
  if Object.size(filterList) is 0
    # Pass back an empty string
    # console.log("Got back an empty filter list.")
    return ""
  try
    filterList["BOOLEAN_TYPE"] = booleanType
    jsonString = JSON.stringify(filterList)
    encodedFilter = Base64.encodeURI(jsonString)
    # console.log("Returning #{encodedFilter} from",filterList)
    return encodedFilter
  catch e
    return false


formatSearchResults = (result, container = searchParams.targetContainer, callback) ->
  ###
  # Take a result object from the server's lookup, and format it to
  # display search results.
  #
  # By default, this will try to render the results off-thread with a
  # service worker for the best client performance, but it will fall
  # back on to an on-thread renderer if no service worker exists.
  #
  # See
  #
  # http://mammaldiversity.org/api.php?q=ursus+arctos&loose=true
  #
  # for a sample search result return.
  ###
  start = Date.now()
  elapsed = 0
  $("#result-header-container").removeAttr "hidden"
  data = result.result
  searchParams.result = data
  headers = new Array()
  tableId = "cndb-result-list"
  htmlHead = "<table id='#{tableId}' class='table table-striped table-hover col-md-12'>\n\t<tr class='cndb-row-headers'>"
  htmlClose = "</table>"
  # We start at 0, so we want to count one below
  targetCount = result.count
  if targetCount > 150
    toastStatusMessage "We found #{result.count} results, please hang on a moment while we render them...", "", 5000
  else
    console.log "Not notifying of render delay, only showing #{targetCount} items"
  colClass = null
  bootstrapColCount = 0
  dontShowColumns = [
    "id"
    "minor_type"
    "notes"
    "major_type"
    "taxon_author"
    "taxon_credit"
    "image_license"
    "image_credit"
    "taxon_credit_date"
    "parens_auth_genus"
    "parens_auth_species"
    "is_alien"
    "internal_id"
    "source"
    "deprecated_scientific"
    # "species_authority"
    # "genus_authority"
    # "authority_year"
    "canonical_sciname"
    "simple_linnean_group"
    "iucn"
    "dwc"
    "entry"
    "common_name_source"
    "image_caption"
    ]
  externalCounter = 0
  renderTimeout = delay 7500, ->
    stopLoadError "There was a problem parsing the search results."
    console.error "Couldn't finish parsing the results! Expecting #{targetCount} elements, timed out on #{externalCounter}."
    console.warn data
    return false
  requiredKeyOrder = [
    "common_name"
    "genus"
    "species"
    ]
  delay 5, ->
    # Remove data-less columns
    colHasData = new Array()
    for i, row of data
      allColsHaveData = true
      for k, v of row
        if k in colHasData
          continue
        if isNull v
          allColsHaveData = false
        else
          # console.log "Col '#{k}' has non-empty value '#{v}' at row #{i}", row
          colHasData.push k
      if allColsHaveData
        break
    if "subspecies" in colHasData
      requiredKeyOrder.push "subspecies"
    # Get all the rows in order
    for k, v of data[0]
      # Don't double-count a column
      unless k in requiredKeyOrder
        # Don't render columns that we shouldn't show, duh
        unless k in dontShowColumns
          # Only render columns that have data
          if k in colHasData
            requiredKeyOrder.push k
    # elapsed = Date.now() - start
    # console.debug "Took #{elapsed}ms to finish sorting keys"
    # Re-sort the data
    origData = data
    data = new Object()
    for i, row of origData
      data[i] = new Object()
      for key in requiredKeyOrder
        data[i][key] = row[key]
    # elapsedBetween = Date.now() - start - elapsed
    # elapsed = Date.now() - start
    # console.debug "Took #{elapsedBetween}ms to re-order data (total time: #{elapsed}ms)"
    # The real render loop
    totalLoops = 0
    dataArray = Object.toArray data
    do renderDataArray = (data = dataArray, firstIteration = true, renderChunk = 100) ->
      html = ""
      i = 0
      nextIterationData = null
      wasOffThread = false
      unless isNumber renderChunk
        renderChunk = 100
      finalIteration = if data.length <= renderChunk then true else false
      try
        postMessageContent =
          action: "render-row"
          data: data
          chunk: renderChunk
          firstIteration: firstIteration
        worker = new Worker "js/serviceWorker.js"
        console.info "Rendering list off-thread"
        worker.addEventListener "message", (e) ->
          console.info "Got message back from service worker", e.data
          wasOffThread = true
          html = e.data.html
          nextIterationData = e.data.nextChunk
          usedRenderChunk = e.data.renderChunk
          i = e.data.loops
          loopCleanup()
        worker.postMessage postMessageContent
      catch
        ###############################
        # No web worker! Fallback
        ###############################
        console.log "Starting loop with i = #{i}, renderChunk = #{renderChunk}, data length = #{data.length}", firstIteration, finalIteration
        for row in data
          ++totalLoops
          externalCounter = i
          if toInt(i) is 0 and firstIteration
            j = 0
            htmlHead += "\n<!-- Table Headers - #{Object.size(row)} entries -->"
            for k, v of row
              ++totalLoops
              niceKey = k.replace(/_/g," ")
              # Remap names to pretty names
              niceKey = switch niceKey
                when "simple linnean subgroup" then "Group"
                when "major subtype" then "Clade"
                else niceKey
              htmlHead += "\n\t\t<th class='text-center'>#{niceKey}</th>"
              bootstrapColCount++
              j++
            # End header build loop
            htmlHead += "\n\t</tr>"
            htmlHead += "\n<!-- End Table Headers -->"
            console.log("Got #{bootstrapColCount} display columns.")
            bootstrapColSize = roundNumber(12/bootstrapColCount,0)
            colClass = "col-md-#{bootstrapColSize}"
            # elapsedBetween = Date.now() - start - elapsed
            # elapsed = Date.now() - start
            # console.debug "Took #{elapsedBetween}ms to build headers (total time: #{elapsed}ms)"
            frameHtml = htmlHead + htmlClose
            html = htmlHead
            $(container).html frameHtml
          # End header construction
          # Start building the data rows
          taxonQuery = "#{row.genus}+#{row.species}"
          if not isNull(row.subspecies)
            taxonQuery = "#{taxonQuery}+#{row.subspecies}"
          rowId = "msadb-row#{i}"
          htmlRow = """\n\t<tr id='#{rowId}' class='cndb-result-entry' data-taxon="#{taxonQuery}" data-genus="#{row.genus}" data-species="#{row.species}">"""
          for k, col of row
            ++totalLoops
            if k is "authority_year"
              unless isNull col
                try
                  d = JSON.parse(col)
                catch e
                  # attempt to fix it
                  try
                    console.warn("There was an error parsing authority_year='#{col}', attempting to fix - ",e.message)
                    split = col.split(":")
                    year = split[1].slice(split[1].search("\"")+1,-2)
                    # console.log("Examining #{year}")
                    year = year.replace(/"/g,"'")
                    split[1] = "\"#{year}\"}"
                    col = split.join(":")
                    # console.log("Reconstructed #{col}")
                    d = JSON.parse(col)
                  catch e
                    # Render as-is
                    console.error("There was an error parsing '#{col}'",e.message)
                    d = col
                try
                  genus = Object.keys(d)[0]
                  species = d[genus]
                  if toInt(row.parens_auth_genus).toBool()
                    genus = "(#{genus})"
                  if toInt(row.parens_auth_species).toBool()
                    species = "(#{species})"
                  col = "G: #{genus}<br/>S: #{species}"
              else
                d = col
            if k is "image"
              # Set up the images
              if isNull col
                # Link out to mammal photos database
                col = "<paper-icon-button icon='launch' data-href='#{_asm.affiliateQueryUrl.mammalPhotos}?rel-taxon=contains&where-taxon=#{taxonQuery}' class='newwindow calphoto click' data-taxon=\"#{taxonQuery}\"></paper-icon-button>"
              else
                col = "<paper-icon-button icon='image:image' data-lightbox='#{uri.urlString}#{col}' class='lightboximage'></paper-icon-button>"
            ###
            # Assign classes to the rows
            ###
            # What should be centered, and what should be left-aligned?
            if k isnt "genus" and k isnt "species" and k isnt "subspecies"
              kClass = "#{k} text-center"
            else
              # Left-aligned
              kClass = k
            if k is "genus_authority" or k is "species_authority"
              kClass += " authority"
            else if k is "common_name"
              col = smartUpperCasing col
              kClass += " no-cap"
            # Append the completed column to the row
            htmlRow += "\n\t\t<td id='#{k}-#{i}' class='#{kClass} #{colClass}'>#{col}</td>"
          # Finish building the row
          htmlRow += "\n\t</tr>"
          html += htmlRow
          # Render the rows one at a time
          # $("table##{tableId} tbody").append htmlRow
          # $("##{rowId}").click ->
          #   accountArgs = "genus=#{$(this).attr("data-genus")}&species=#{$(this).attr("data-species")}"
          #   goTo "species-account.php?#{accountArgs}"
          # Debug timing per-row
          # if toInt(i) %% 50 is 0
          #   elapsedBetween = Date.now() - start - elapsed
          #   elapsed = Date.now() - start
          #   console.debug "Took #{elapsedBetween}ms to build 50 rows through #{i} (total time: #{elapsed}ms)"
          i++
          if i >= renderChunk
            break
        console.log "Ended data loop with i = #{i}, renderChunk = #{renderChunk}"
        loopCleanup()
        # End data loop
      loopCleanup = ->
        if firstIteration
          html += htmlClose
          $(container).html html
          $("#result-count").text(" - #{result.count} entries")
          if result.method is "space_common_fallback" and not $("#space-fallback-info").exists()
            noticeHtml = """
            <div id="space-fallback-info" class="alert alert-info alert-dismissible center-block fade in" role="alert">
              <button type="button" class="close" data-dismiss="alert" aria-label="Close"><span aria-hidden="true">&times;</span></button>
              <strong>Don't see what you want?</strong> We might use a slightly different name. Try <a href="" class="alert-link" id="do-instant-fuzzy">checking the "fuzzy" toggle and searching again</a>, or use a shorter search term.
            </div>
            """
            $("#result_container").before(noticeHtml)
            $("#do-instant-fuzzy").click (e) ->
              e.preventDefault()
              doBatch = ->
                $("#fuzzy").get(0).checked = true
                performSearch()
              doBatch.debounce()
          else if $("#space-fallback-info").exists()
            # We only want to show it once, so we'll hide it now
            $("#space-fallback-info").prop("hidden",true)
            #$("#space-fallback-info").remove()
        else
          # Just add the new rows
          $("table##{tableId} tbody").append html
        unless finalIteration
          elapsed = Date.now() - start
          nextIterationData ?= data.slice i
          console.log "Chunk rendered at #{elapsed}ms, next bit with slice @ #{i}:", nextIterationData
          unless nextIterationData.length is 0
            delayInterval = if wasOffThread then 25 else 250
            delay delayInterval, ->
              renderDataArray nextIterationData, false, renderChunk
          else
            finalIteration = true
        if finalIteration
          elapsed = Date.now() - start
          console.log "Finished rendering list in #{elapsed}ms"
          console.debug "Executed #{totalLoops} loops"
          if elapsed > 3000 and not wasOffThread
            console.warn "Warning: Took greater than 3 seconds to render!"
          stopLoad()
          delay 250, ->
            stopLoad()
          if typeof callback is "function"
            try
              callback()
        clearTimeout renderTimeout
        mapNewWindows()
        lightboxImages()
        # modalTaxon()
        $(".cndb-result-entry")
        .unbind()
        .click ->
          accountArgs = "genus=#{$(this).attr("data-genus")}&species=#{$(this).attr("data-species")}"
          goTo "species-account.php?#{accountArgs}"
        doFontExceptions()
  false


parseTaxonYear = (taxonYearString, strict = true) ->
  ###
  # Take the (theoretically nicely JSON-encoded) taxon year/authority
  # string and turn it into a canonical object for the modal dialog to use
  ###
  try
    d = JSON.parse(taxonYearString)
  catch e
    # attempt to fix it
    console.warn("There was an error parsing '#{taxonYearString}', attempting to fix - ",e.message)
    try
      split = taxonYearString.split(":")
      year = split[1].slice(split[1].search('"')+1,-2)
      # console.log("Examining #{year}")
      year = year.replace(/"/g,"'")
      split[1] = "\"#{year}\"}"
      taxonYearString = split.join(":")
      # console.log("Reconstructed #{taxonYearString}")
      try
        d = JSON.parse(taxonYearString)
      catch e
        if strict
          return false
        else
          return taxonYearString
    catch e
      if strict
        return false
      else
        return taxonYearString
  genus = Object.keys(d)[0]
  species = d[genus]
  year = new Object()
  year.genus = genus
  year.species = species
  return year


checkTaxonNear = (taxonQuery = undefined, callback = undefined, selector = "#near-me-container") ->
  ###
  # Check the iNaturalist API to see if the taxon is in your county
  # See https://github.com/tigerhawkvok/SSAR-species-database/issues/7
  ###
  if not taxonQuery?
    console.warn("Please specify a taxon.")
    return false;
  if not locationData.last?
    getLocation()
  elapsed = (Date.now() - locationData.last)/1000
  if elapsed > 15*60 # 15 minutes
    getLocation()
  # Now actually check
  apiUrl = "https://www.inaturalist.org/places.json"
  args = "taxon=#{taxonQuery}&latitude=#{locationData.lat}&longitude=#{locationData.lng}&place_type=county"
  geoIcon = ""
  cssClass = ""
  tooltipHint = ""
  $.get(apiUrl,args,"json")
  .done (result) ->
    if Object.size(result) > 0
      geoIcon = "communication:location-on"
      cssClass = "good-location"
      tooltipHint = "This species occurs in your county"
    else
      geoIcon = "communication:location-off"
      cssClass = "bad-location"
      tooltipHint = "This species does not occur in your county"
  .fail (result,status) ->
    cssClass = "bad-location"
    geoIcon = "warning"
    tooltipHint = "We couldn't determine your location"
  .always ->
    tooltipHtml = """
    <div class="tooltip fade top in right manual-placement-tooltip" role="tooltip" style="top: 6.5em; left: 4em; right:initial; display:none" id="manual-location-tooltip">
      <div class="tooltip-arrow" style="top:50%;left:5px"></div>
      <div class="tooltip-inner">#{tooltipHint}</div>
    </div>
    """
    # Append it all
    d$(selector).html("<iron-icon icon='#{geoIcon}' class='small-icon #{cssClass} near-me' data-toggle='tooltip' id='near-me-icon'></iron-icon>")
    $(selector)
    .after(tooltipHtml)
    .mouseenter ->
      d$("#manual-location-tooltip").css("display","block")
      false
    .mouseleave ->
      d$("#manual-location-tooltip").css("display","none")
      false
    if callback?
      callback()
  false



insertModalImage = (imageObject = _asm.taxonImage, taxon = _asm.activeTaxon, callback = undefined) ->
  ###
  # Insert into the taxon modal a lightboxable photo. If none exists,
  # load from CalPhotos
  #
  # CalPhotos functionality blocked on
  # https://github.com/tigerhawkvok/SSAR-species-database/issues/30
  ###
  # Is the modal dialog open?
  unless taxon?
    console.error("Tried to insert a modal image, but no taxon was provided!")
    return false
  unless typeof taxon is "object"
    console.error("Invalid taxon data type (expecting object), got #{typeof taxon}")
    warnArgs =
      taxon: taxon
      imageUrl: imageUrl
      defaultTaxon: _asm.activeTaxon
      defaultImage: _asm.taxonImage
    console.warn(warnArgs)
    return false
  # Image insertion helper
  insertImage = (image, taxonQueryString, classPrefix = "calphoto") ->
    ###
    # Insert a lightboxed image into the modal taxon dialog. This must
    # be shadow-piercing, since the modal dialog is a
    # paper-dialog.
    #
    # @param image an object with parameters [thumbUri, imageUri,
    #   imageLicense, imageCredit], and optionally imageLinkUri
    ###
    # Build individual args from object
    thumbnail = image.thumbUri
    largeImg = image.imageUri
    largeImgLink = image.imageLinkUri? image.imageUri
    imgLicense = image.imageLicense
    imgCredit = image.imageCredit
    html = """
    <div class="modal-img-container">
      <a href="#{largeImg}" class="#{classPrefix}-img-anchor center-block text-center">
        <img src="#{thumbnail}"
          data-href="#{largeImgLink}"
          class="#{classPrefix}-img-thumb"
          data-taxon="#{taxonQueryString}" />
      </a>
      <p class="small text-muted text-center">
        Image by #{imgCredit} under #{imgLicense}
      </p>
    </div>
    """
    d$("#meta-taxon-info").before(html)
    do smartFit = (iteration = 0) ->
      try
        d$("#modal-taxon").get(0).fit()
        delay 250, ->
          d$("#modal-taxon").get(0).fit()
          delay 750, ->
            d$("#modal-taxon").get(0).fit()
      catch e
        if iteration < 10
          iteration++
          delay 100, ->
            smartFit(iteration)
        else
          console.warn("Couldn't execute fit!")
    try
      # Call lightboxImages with the second argument "true" to do a
      # shadow-piercing lookup
      lightboxImages(".#{classPrefix}-img-anchor", true)
    catch e
      console.error("Error lightboxing images")
    if typeof callback is "function"
      callback()
    false
  # Now that that's out of the way, we actually check the information
  # and process it
  taxonArray = [taxon.genus,taxon.species]
  if taxon.subspecies?
    taxonArray.push(taxon.subspecies)
  taxonString = taxonArray.join("+")

  if imageObject.imageUri?
    # The image URI is valid, so insert it
    if typeof imageObject is "string"
      # Make it conform to expectations
      imageUrl = imageObject
      imageObject = new Object()
      imageObject.imageUri = imageUrl
    # Construct the thumb URI from the provided full-sized path
    imgArray = imageObject.imageUri.split(".")
    extension = imgArray.pop()
    # In case the uploaded file has "." in it's name, we want to re-join
    imgPath = imgArray.join(".")
    imageObject.thumbUri = "#{uri.urlString}#{imgPath}-thumb.#{extension}"
    imageObject.imageUri = "#{uri.urlString}#{imgPath}.#{extension}"
    # And finally, call our helper function
    insertImage(imageObject, taxonString, "asmimg")
    return false

  ###
  # OK, we don't have it, do CalPhotos
  #
  # Hit targets of form
  # http://calphotos.berkeley.edu/cgi-bin/img_query?getthumbinfo=1&num=all&taxon=Acris+crepitans&format=xml
  #
  # See
  # http://calphotos.berkeley.edu/thumblink.html
  # for API reference.
  ###

  args = "getthumbinfo=1&num=all&cconly=1&taxon=#{taxonString}&format=xml"
  # console.log("Looking at","#{_asm.affiliateQueryUrl.calPhotos}?#{args}")
  ## CalPhotos doesn't have good headers set up. Try a CORS request.
  # CORS success callback
  doneCORS = (resultXml) ->
    result = xmlToJSON.parseString(resultXml)
    window.testData = result
    try
      data = result.calphotos[0]
    catch e
      data = undefined
    unless data?
      # console.warn("CalPhotos didn't return any valid images for this search! Looked for #{taxonString}")
      return false
    imageObject = new Object()
    try
      imageObject.thumbUri = data.thumb_url[0]["_text"]
      unless imageObject.thumbUri?
        console.warn("CalPhotos didn't return any valid images for this search!")
        return false
      imageObject.imageUri = data.enlarge_jpeg_url[0]["_text"]
      imageObject.imageLinkUri = data.enlarge_url[0]["_text"]
      imageObject.imageLicense = data.license[0]["_text"]
      imageObject.imageCredit = "#{data.copyright[0]["_text"]} (via CalPhotos)"
    catch e
      console.warn("CalPhotos didn't return any valid images for this search!","#{_asm.affiliateQueryUrl.calPhotos}?#{args}")
      return false
    # Do the image insertion via our helper function
    insertImage(imageObject,taxonString)
    false
  # CORS failure callback
  failCORS = (result,status) ->
    insertCORSWorkaround()
    console.error("Couldn't load a CalPhotos image to insert!")
    false
  # The actual call attempts.
  try
    doCORSget(_asm.affiliateQueryUrl.calPhotos, args, doneCORS, failCORS)
  catch e
    console.error(e.message)
  false





modalTaxon = (taxon = undefined) ->
  ###
  # Pop up the modal taxon dialog for a given species
  ###
  if not taxon?
    # If we have no taxon defined at all, bind all the result entries
    # from a search into popping one of these up
    $(".cndb-result-entry").click ->
      modalTaxon($(this).attr("data-taxon"))
    return false
  # Pop open a paper action dialog ...
  # https://elements.polymer-project.org/elements/paper-dialog
  animateLoad()
  if not $("#modal-taxon").exists()
    # On very small devices, for both real-estate and
    # optimization-related reasons, we'll hide calphotos and the alternate
    html = """
    <paper-dialog modal id='modal-taxon' entry-animation="scale-up-animation" exit-animation="scale-down-animation">
      <h2 id="modal-heading"></h2>
      <paper-dialog-scrollable id='modal-taxon-content'></paper-dialog-scrollable>
      <div class="buttons">
        <paper-button id='modal-inat-linkout'>iNaturalist</paper-button>
        <paper-button id='modal-calphotos-linkout' class="hidden-xs">CalPhotos</paper-button>
        <paper-button id='modal-alt-linkout' class="hidden-xs"></paper-button>
        <paper-button dialog-dismiss autofocus>Close</paper-button>
      </div>
    </paper-dialog>
    """
    $("body").append(html)
  $.get(searchParams.targetApi,"q=#{taxon}","json")
  .done (result) ->
    data = result.result[0]
    unless data?
      toastStatusMessage("There was an error fetching the entry details. Please try again later.")
      stopLoadError()
      return false
    # console.log("Got",data)
    year = parseTaxonYear(data.authority_year)
    yearHtml = ""
    if year isnt false
      genusAuthBlock = """
      <span class='genus_authority authority'>#{data.genus_authority}</span> #{year.genus}
      """
      speciesAuthBlock = """
      <span class='species_authority authority'>#{data.species_authority}</span> #{year.species}
      """
      if toInt(data.parens_auth_genus).toBool()
        genusAuthBlock = "(#{genusAuthBlock})"
      if toInt(data.parens_auth_species).toBool()
        speciesAuthBlock = "(#{speciesAuthBlock})"
      yearHtml = """
      <div id="is-alien-container" class="tooltip-container"></div>
      <div id='near-me-container' data-toggle='tooltip' data-placement='top' title='' class='near-me tooltip-container'></div>
      <p>
        <span class='genus'>#{data.genus}</span>,
        #{genusAuthBlock};
        <span class='species'>#{data.species}</span>,
        #{speciesAuthBlock}
      </p>
      """
    deprecatedHtml = ""
    if not isNull(data.deprecated_scientific)
      deprecatedHtml = "<p>Deprecated names: "
      try
        sn = JSON.parse(data.deprecated_scientific)
        i = 0
        $.each sn, (scientific,authority) ->
          i++
          if i isnt 1
            deprecatedHtml += "; "
          deprecatedHtml += "<span class='sciname'>#{scientific}</span>, #{authority}"
          if i is Object.size(sn)
            deprecatedHtml += "</p>"
      catch e
        # skip it
        deprecatedHtml = ""
        console.error("There were deprecated scientific names, but the JSON was malformed.")
    minorTypeHtml = ""
    if not isNull(data.minor_type)
      minorTypeHtml = " <iron-icon icon='arrow-forward'></iron-icon> <span id='taxon-minor-type'>#{data.minor_type}</span>"
    # Populate the taxon
    if isNull(data.notes)
      data.notes = "Sorry, we have no notes on this taxon yet."
      data.taxon_credit = ""
    else
      if isNull(data.taxon_credit) or data.taxon_credit is "null"
        data.taxon_credit = "This taxon information is uncredited."
      else
        taxonCreditDate = if isNull(data.taxon_credit_date) or data.taxon_credit_date is "null" then "" else " (#{data.taxon_credit_date})"
        data.taxon_credit = "Taxon information by #{data.taxon_credit}.#{taxonCreditDate}"
    try
      notes = markdown.toHTML(data.notes)
    catch e
      notes = data.notes
      console.warn("Couldn't parse markdown!! #{e.message}")
    # For the notes, we want to fix any badly-encoded html with real
    # encodings
    notes = notes.replace(/\&amp;(([a-z]+|[0-9]+);)/mg, "&$1")
    commonType = unless isNull(data.major_common_type) then " (<span id='taxon-common-type'>#{data.major_common_type}</span>) " else ""
    html = """
    <div id='meta-taxon-info'>
      #{yearHtml}
      <p>
        English name: <span id='taxon-common-name' class='common_name no-cap'>#{smartUpperCasing data.common_name}</span>
      </p>
      <p>
        Type: <span id='taxon-type' class="major_type">#{data.major_type}</span>
        #{commonType}
        <iron-icon icon='arrow-forward'></iron-icon>
        <span id='taxon-subtype' class="major_subtype">#{data.major_subtype}</span>#{minorTypeHtml}
      </p>
      #{deprecatedHtml}
    </div>
    <h3>Taxon Notes</h3>
    <p id='taxon-notes'>#{notes}</p>
    <p class="text-right small text-muted">#{data.taxon_credit}</p>
    """
    $("#modal-taxon-content").html(html)
    ## Bind the dismissive buttons
    # iNaturalist
    $("#modal-inat-linkout")
    .unbind()
    .click ->
      openTab("#{_asm.affiliateQueryUrl.iNaturalist}?q=#{taxon}")
    # CalPhotos
    $("#modal-calphotos-linkout")
    .unbind()
    .click ->
      openTab("#{_asm.affiliateQueryUrl.calPhotos}?rel-taxon=contains&where-taxon=#{taxon}")
    # AmphibiaWeb or Reptile Database
    # See
    # https://github.com/tigerhawkvok/SSAR-species-database/issues/35
    outboundLink = null
    buttonText = null
    taxonArray = taxon.split("+")
    _asm.activeTaxon =
      genus: taxonArray[0]
      species: taxonArray[1]
      subspecies: taxonArray[2]
    if outboundLink?
      # First, un-hide it in case it was hidden
      $("#modal-alt-linkout")
      .replaceWith(button)
      $("#modal-alt-linkout")
      .click ->
        # console.log "Should outbound to", outboundLink
        openTab(outboundLink)
    else
      # Well, wasn't expecting this! But we'll handle it anyway.
      # Hide the link
      $("#modal-alt-linkout")
      .addClass("hidden")
      .unbind()
    formatScientificNames()
    doFontExceptions()
    # Set the heading
    humanTaxon = taxon.charAt(0).toUpperCase()+taxon[1...]
    humanTaxon = humanTaxon.replace(/\+/g," ")
    d$("#modal-heading").text(humanTaxon)
    # Open it
    if isNull(data.image) then data.image = undefined
    _asm.taxonImage =
      imageUri: data.image
      imageCredit: data.image_credit
      imageLicense: data.image_license
    # Insert the image
    try
      insertModalImage()
    catch e
      console.info("Unable to insert modal image! ")
    checkTaxonNear taxon, ->
      stopLoad()
      modalElement = d$("#modal-taxon")[0]
      d$("#modal-taxon").on "iron-overlay-opened", ->
        modalElement.fit()
        modalElement.scrollTop = 0
        if toFloat($(modalElement).css("top").slice(0,-2)) > $(window).height()
          # Firefox is weird about this sometimes ...
          # Let's add a catch-all 'top' adjustment
          $(modalElement).css("top","12.5vh")
        delay 250, ->
          modalElement.fit()
      modalElement.sizingTarget = d$("#modal-taxon-content")[0]
      safariDialogHelper("#modal-taxon")
    bindDismissalRemoval()
  .fail (result,status) ->
    stopLoadError()
  false


bindDismissalRemoval = ->
  $("[dialog-dismiss]")
  .unbind()
  .click ->
    $(this).parents("paper-dialog").remove()


doFontExceptions = ->
  ###
  # Look for certain keywords to force into capitalized, or force
  # uncapitalized, overriding display CSS rules
  ###
  alwaysLowerCase = [
    "de"
    "and"
    ]

  forceSpecialToLower = (authorityText) ->
    # Returns HTML
    $.each alwaysLowerCase, (i,word) ->
      # Do this to each
      #console.log("Checking #{authorityText} for #{word}")
      search = " #{word} "
      if authorityText?
        authorityText = authorityText.replace(search, " <span class='force-lower'>#{word}</span> ")
    return authorityText

  d$(".authority").each ->
    authorityText = $(this).text()
    unless isNull(authorityText)
      #console.log("Forcing format of #{authorityText}")
      $(this).html(forceSpecialToLower(authorityText))
  false



sortResults = (by_column) ->
  # Somethign clever -- look at each of the by_column points, then
  # throw those into an array and sort those, using their index as a
  # map to data and re-mapping data by those orders. May need to use
  # the index of a duplicated array as the reference - walk through
  # sorted and lookup position in reference, then data[index] = data[ref_pos]
  data = searchParams.result

setHistory = (url = "#",state = null, title = null) ->
  ###
  # Set up the history to provide something linkable
  ###
  history.pushState(state,title,url)
  # Rewrite the query URL
  uri.query = $.url(url).attr("fragment")
  false

clearSearch = (partialReset = false) ->
  ###
  # Clear out the search and reset it to a "fresh" state.
  ###
  $("#result-count").text("")
  calloutHtml = """
  <div class="bs-callout bs-callout-info center-block col-xs-12 col-sm-8 col-md-5">
    Search for a common or scientific name above to begin, eg, "Brown Bear" or "<span class="sciname">Ursus arctos</span>"
  </div>
  """
  $("#result_container").html(calloutHtml)
  $("#result-header-container").attr "hidden", "hidden"
  if partialReset is true then return false
  # Do a history breakpoint
  setHistory()
  # Reset the fields
  $(".cndb-filter").attr("value","")
  $("#collapse-advanced").collapse('hide')
  $("#search").attr("value","")
  $("#linnean").polymerSelected("any")
  formatScientificNames()
  false



safariDialogHelper = (selector = "#download-chooser", counter = 0, callback) ->
  ###
  # Help Safari display paper-dialogs
  ###
  unless typeof callback is "function"
    callback = ->
      bindDismissalRemoval()
  if counter < 10
    try
      # Safari is stupid and like to throw an error. Presumably
      # it's VERY slow about creating the element.
      try
        p$(selector).open()
      catch
        d$(selector).get(0).open()
      if typeof callback is "function"
        callback()
      stopLoad()
    catch e
      # Ah, Safari threw an error. Let's delay and try up to
      # 10x.
      newCount = counter + 1
      delayTimer = 250
      delay delayTimer, ->
        console.warn "Trying again to display dialog after #{newCount * delayTimer}ms"
        console.debug "Error caught: #{e.message}"
        console.debug e.stack
        safariDialogHelper(selector, newCount, callback)
  else
    stopLoadError("Unable to show dialog. Please try again.")


safariSearchArgHelper = (value, didLateRecheck = false) ->
  ###
  # If the search argument has a "+" in it, remove it
  # Then write the arg to search.
  #
  # Since Safari doesn't "take" it all the time, keep trying till it does.
  ###
  if value?
    searchArg = value
  else
    searchArg = $("#search").val()
  trimmed = false
  if searchArg.search(/\+/) isnt -1
    trimmed = true
    searchArg = searchArg.replace(/\+/g," ").trim()
    # console.log("Trimmed a plus")
    delay 100, ->
      safariSearchArgHelper()
  if trimmed or value?
    $("#search").attr("value",searchArg)
    # console.log("Updated the search args")
    unless didLateRecheck
      delay 5000, ->
        # What? Safari is VERY slow on older devices,
        # and this check will fix them.
        safariSearchArgHelper(undefined, true)
  false


insertCORSWorkaround = ->
  unless _asm.hasShownWorkaround?
    _asm.hasShownWorkaround = false
  if _asm.hasShownWorkaround
    return false
  try
    browsers = new WhichBrowser()
  catch e
    # Defer it till next time
    return false
  if browsers.isType("mobile")
    # We don't need to show this at all -- no extensions!
    _asm.hasShownWorkaround = true
    return false
  browserExtensionLink = switch browsers.browser.name
    when "Chrome"
      """
      Install the extension "<a class='alert-link' href='https://chrome.google.com/webstore/detail/allow-control-allow-origi/nlfbmbojpeacfghkpbjhddihlkkiljbi?utm_source=chrome-app-launcher-info-dialog'>Allow-Control-Allow-Origin: *</a>", activate it on this domain, and you'll see them in your popups!
      """
    when "Firefox"
      """
      Follow the instructions <a class='alert-link' href='http://www-jo.se/f.pfleger/forcecors-workaround'>for this ForceCORS add-on</a>, or try Chrome for a simpler extension. Once you've done so, you'll see photos in your popups!
      """
    when "Internet Explorer"
      """
      Follow these <a class='alert-link' href='http://stackoverflow.com/a/20947828'>StackOverflow instructions</a> while on this site, and you'll see them in your popups!
      """
    else ""
  html = """
  <div class="alert alert-info alert-dismissible center-block fade in" role="alert">
    <button type="button" class="close" data-dismiss="alert" aria-label="Close"><span aria-hidden="true">&times;</span></button>
    <strong>Want CalPhotos images in your species dialogs?</strong> #{browserExtensionLink}
    We're working with CalPhotos to enable this natively, but it's a server change on their side.
  </div>
  """
  $("#result_container").before(html)
  $(".alert").alert()
  _asm.hasShownWorkaround = true
  false


showBadSearchErrorMessage = (result) ->
  try
    sOrig = result.query.replace(/\+/g," ")
  catch
    sOrig = $("#search").val()
  try
    if result.status is true
      if result.query_params.filter.had_filter is true
        filterText = ""
        i = 0
        $.each result.query_params.filter.filter_params, (col,val) ->
          if col isnt "BOOLEAN_TYPE"
            if i isnt 0
              filterText = "#{filter_text} #{result.filter.filter_params.BOOLEAN_TYPE}"
            if isNumber(toInt(val,true))
              val = if toInt(val) is 1 then "true" else "false"
            filterText = "#{filterText} #{col.replace(/_/g," ")} is #{val}"
        text = "\"#{sOrig}\" where #{filterText} returned no results."
      else
        text = "\"#{sOrig}\" returned no results."
    else
      text = result.human_error
  catch
    text = "Sorry, there was a problem with your search"
  stopLoadError(text)




bindPaperMenuButton = (selector = "paper-menu-button", unbindTargets = true) ->
  ###
  # Use a paper-menu-button and make the
  # .dropdown-label gain the selected value
  #
  # Reference:
  # https://github.com/polymerelements/paper-menu-button
  # https://elements.polymer-project.org/elements/paper-menu-button
  ###
  return false
  for dropdown in $(selector)
    menu = $(dropdown).find("paper-menu")
    if unbindTargets
      $(menu).unbind()
    do relabelSelectedItem = (target = menu, activeDropdown = dropdown) ->
      # A menu item has been selected!
      selectText = $(target).polymerSelected(null, true)
      # console.log("iron-select fired! We fetched '#{selectText}'")
      labelSpan = $(activeDropdown).find(".dropdown-label")
      $(labelSpan).text(selectText)
      $(target).polymerSelected()
    $(menu).on "iron-select", ->
      relabelSelectedItem this, dropdown
  false



getRandomEntry = ->
  ###
  # Get a random taxon, and go to that page
  ###
  startLoad()
  args =
    random: true
  $.get searchParams.apiPath, buildQuery args, "json"
  .done (result) ->
    if isNull(result.genus) or isNull result.species
      stopLoadError "Unable to fetch random entry"
    accountQuery =
      genus: result.genus
      species: result.species
    unless isNull result.subspecies
      accountQuery.subspecies = result.subspecies
    dest = "#{uri.urlString}species-account.php?#{buildQuery accountQuery}"
    console.log "About to go to", dest
    goTo dest
    stopLoad() # Just in case
  .fail ->
    stopLoadError "Unable to fetch random entry"
  false


window.getRandomEntry = getRandomEntry



doLazily = ->
  ###
  # Load these assets lazily, but only once
  ###
  unless _asm?.hasDoneLazily is true
    unless typeof _asm is "object"
      window._asm = new Object()
    _asm.hasDoneLazily = true
    loadJS "#{uri.urlString}js/download.min.js", ->
      # Insert an icon into the footer to trigger the download
      # (eg, invoke showDownloadChooser())
      html = """
      <paper-icon-button
        icon="icons:cloud-download"
        class="click"
        data-fn="showDownloadChooser"
        title="Download Copy"
        data-toggle="tooltip"
        >
      </paper-icon-button>
      """
      $("#git-footer").prepend html
      bindClicks()
      false
  false



$ ->
  devHello = """
  ****************************************************************************
  Hello developer!
  If you're looking for hints on our API information, this site is open-source
  and released under the GPL. Just click on the GitHub link on the bottom of
  the page, or check out LINK_TO_ORG_REPO
  ****************************************************************************
  """
  console.log(devHello)
  _asm.polymerReady = false
  ignorePages = [
    "admin-login.php"
    "admin-page.html"
    "admin-page.php"
    ]
  if uri.o.attr("file") in ignorePages
    try
      do setupPolymerReady = ->
        try
          if Polymer?.Base?.$$?
            Polymer.Base.ready ->
              _asm.polymerReady = true
            delay 250, ->
              _asm.polymerReady = true
          else
            throw {message:"POLYMER_NOT_READY"}
        catch
          delay 100, ->
            setupPolymerReady
    return false
  # Do bindings
  # console.log("Doing onloads ...")
  animateLoad()
  # Set up popstate
  window.addEventListener "popstate", (e) ->
    uri.query = $.url().attr("fragment")
    try
      loadArgs = Base64.decode(uri.query)
    catch e
      loadArgs = ""
    #console.log("Popping state to #{loadArgs}")
    performSearch.debounce 50, null, null, loadArgs
    temp = loadArgs.split("&")[0]
    $("#search").attr("value",temp)
  ## Set events
  $("#do-reset-search").click ->
    clearSearch()
  $("#search_form").submit (e) ->
    e.preventDefault()
    performSearch.debounce 50
  $("#collapse-advanced").on "shown.bs.collapse", ->
    $("#collapse-icon").attr("icon","icons:unfold-less")
  $("#collapse-advanced").on "hidden.bs.collapse", ->
    $("#collapse-icon").attr("icon","icons:unfold-more")
  # Bind enter keydown
  $("#search_form").keypress (e) ->
    if e.which is 13 then performSearch.debounce 50
  # Bind clicks
  $("#do-search").click ->
    performSearch.debounce 50
  $("#do-search-all").click ->
    performSearch.debounce 50, null, null, true
  $("#linnean").on "iron-select", ->
    # We do want to auto-trigger this when there's a search value,
    # but not when it's empty (even though this is valid)
    if not isNull($("#search").val()) then performSearch.debounce()
  eutheriaFilterHelper()
  bindPaperMenuButton()
  # Do a fill of the result container
  if isNull uri.query
    loadArgs = ""
    try
      do setupPolymerReady = ->
        try
          if Polymer?.Base?.$$?
            Polymer.Base.ready ->
              _asm.polymerReady = true
            delay 250, ->
              _asm.polymerReady = true
          else
            throw {message:"POLYMER_NOT_READY"}
        catch
          delay 100, ->
            setupPolymerReady
  else
    try
      loadArgs = Base64.decode(uri.query)
      queryUrl = $.url("#{searchParams.apiPath}?q=#{loadArgs}")
      try
        looseState = queryUrl.param("loose").toBool()
      catch e
        looseState = false
      try
        fuzzyState = queryUrl.param("fuzzy").toBool()
      catch e
        fuzzyState = false
      temp = loadArgs.split("&")[0]
      # Remove any plus signs in the query
      safariSearchArgHelper(temp)
      # Delay these for polyfilled element registration
      # See
      # https://github.com/PolymerElements/paper-toggle-button/issues/29
      do fixState = ->
        if Polymer?.Base?.$$?
          unless isNull Polymer.Base.$$("#loose")
            _asm.polymerReady = true
            delay 250, ->
              if looseState
                d$("#loose").attr("checked", "checked")
              if fuzzyState
                d$("#fuzzy").attr("checked", "checked")
            return false
        unless _asm.stateIter?
          _asm.stateIter = 0
        ++_asm.stateIter
        if _asm.stateIter > 30
          console.warn("Couldn't attach Polymer.Base.ready")
          return false
        try
          Polymer.Base.ready ->
            # The whenReady makes the toggle work, but it won't toggle
            # without this "real" delay
            _asm.polymerReady = true
            delay 250, ->
              console.info "Doing a late Polymer.Base.ready call"
              if looseState
                d$("#loose").attr("checked", "checked")
              if fuzzyState
                d$("#fuzzy").attr("checked", "checked")
              safariSearchArgHelper()
              eutheriaFilterHelper()
        catch
          delay 250, ->
            fixState()
      # Filters
      try
        f64 = queryUrl.param("filter")
        filterObj = JSON.parse(Base64.decode(f64))
        openFilters = false
        simpleAllowedFilters = [
          "simple-linnean-group"
          "simple-linnean-subgroup"
          "linnean-family"
          "type"
          "BOOLEAN-TYPE"
          ]
        for col, val of filterObj
          col = col.replace(/_/g,"-")
          #selector = "##{col}-filter"
          selector = ".cndb-filter[data-column='#{col}']"
          unless col in simpleAllowedFilters
            console.debug "Col '#{col}' is not a simple filter"
            $(selector).attr("value",val)
            openFilters = true
          else
            $(".cndb-filter[data-column='#{col}']").polymerSelected(val)
        if openFilters
          # Open up #collapse-advanced
          $("#collapse-advanced").collapse("show")
      catch e
        # Do nothing
        f64 = false
    catch e
      console.error("Bad argument #{uri.query} => #{loadArgs}, looseState, fuzzyState",looseState,fuzzyState,"#{searchParams.apiPath}?q=#{loadArgs}")
      console.warn(e.message)
      loadArgs = ""
  # Perform the initial search
  if not isNull(loadArgs) and loadArgs isnt "#"
    # console.log("Doing initial search with '#{loadArgs}', hitting","#{searchParams.apiPath}?q=#{loadArgs}")
    $.get searchParams.targetApi,"q=#{loadArgs}","json"
    .done (result) ->
      # Populate the result container
      _asm.polymerReady = true
      console.debug "Server query got", result
      if result.status is true and result.count > 0
        console.log "Got a valid result, formatting #{result.count} results."
        formatSearchResults result, undefined, ->
          console.log "Format results finished, checking lagged update"
          checkLaggedUpdate result
        return false
      console.warn "Bad initial search"
      showBadSearchErrorMessage.debounce null, null, null, result
      console.error result.error
      console.warn result
    .fail (result,error) ->
      console.error("There was an error loading the generic table")
      console.warn(result,error,result.statusText)
      error = "#{result.status} - #{result.statusText}"
      $("#search-status").attr("text","Couldn't load table - #{error}")
      $("#search-status")[0].show()
      stopLoadError()
    .always ->
      # Anything we always want done
      $("#search").attr("disabled",false)
      false
  else
    stopLoad()
    $("#search").attr("disabled",false)
    # Delay this for polyfilled element registration
    # See
    # https://github.com/PolymerElements/paper-toggle-button/issues/29
    do fixState = ->
      if Polymer?.Base?.$$?
        unless isNull Polymer.Base.$$("#loose")
          _asm.polymerReady = true
          delay 250, ->
            d$("#loose").attr("checked", "checked")
            eutheriaFilterHelper()
          return false
      unless _asm.stateIter?
        _asm.stateIter = 0
      ++_asm.stateIter
      if _asm.stateIter > 30
        console.warn("Couldn't attach Polymer.Base.ready")
        return false
      try
        Polymer.Base.ready ->
          # The whenReady makes the toggle work, but it won't toggle
          # without this "real" delay
          _asm.polymerReady = true
          delay 250, ->
            d$("#loose").attr("checked", "checked")
            eutheriaFilterHelper()
      catch
        delay 250, ->
          fixState()
