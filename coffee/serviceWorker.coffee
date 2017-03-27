###
# Service worker!
###
unless typeof uri is "object"
  uri =
    urlString: ""

unless typeof _asm is "object"
  _asm =
    affiliateQueryUrl:
      iucnRedlist: "http://apiv3.iucnredlist.org/api/v3/species/common_names/"

self.addEventListener "message", (e) ->
  switch e.data.action
    when "render-row"
      data = e.data.data
      chunkSize = if isNumber e.data.chunk then toInt(e.data.chunk) else 100
      firstIteration = e.data.firstIteration.toBool() ? false
      # Posts its own message
      renderDataArray data, firstIteration, chunkSize



renderDataArray = (data = dataArray, firstIteration = true, renderChunk = 100) ->
  html = ""
  headers = new Array()
  tableId = "cndb-result-list"
  htmlHead = "<table id='#{tableId}' class='table table-striped table-hover col-md-12'>\n\t<tr class='cndb-row-headers'>"
  htmlClose = "</table>"
  bootstrapColCount = 0
  unless isNumber renderChunk
    renderChunk = 100
  finalIteration = if data.length <= renderChunk then true else false
  i = 0
  console.log "Starting loop with i = #{i}, renderChunk = #{renderChunk}, data length = #{data.length}", firstIteration, finalIteration
  for row in data
    externalCounter = i
    if toInt(i) is 0 and firstIteration
      j = 0
      htmlHead += "\n<!-- Table Headers - #{Object.size(row)} entries -->"
      for k, v of row
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
      html = htmlHead
    # End header construction
    # Start building the data rows
    taxonQuery = "#{row.genus}+#{row.species}"
    if not isNull(row.subspecies)
      taxonQuery = "#{taxonQuery}+#{row.subspecies}"
    rowId = "msadb-row#{i}"
    htmlRow = """\n\t<tr id='#{rowId}' class='cndb-result-entry' data-taxon="#{taxonQuery}" data-genus="#{row.genus}" data-species="#{row.species}">"""
    for k, col of row
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
  # End data loop
  if firstIteration
    html += htmlClose
  message =
    html: html
    nextChunk: data.slice i
    renderChunk: renderChunk
    loops: i
  self.postMessage message
  self.close()
