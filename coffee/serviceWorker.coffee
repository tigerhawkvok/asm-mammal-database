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
    when "render-html"
      console.log "Got info from file on thread", e.data
      createHtmlFile e.data.data, e.data.htmlHeader


# Import Markdown
#
# https://developer.mozilla.org/en-US/docs/Web/API/WorkerGlobalScope/importScripts
window = new Object()
self.importScripts "markdown.min.js"
self.importScripts "markdown.min.js"
markdown = window.markdown


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



createHtmlFile = (result, htmlBody) ->
  ###
  # The off-thread component to download.coffee->downloadHTMLList()
  #
  # Requires the JSOn result from the main function.
  ###
  startTime = Date.now()
  console.debug "Got", result
  console.debug "Got body provided?", not isNull htmlBody
  total = result.count
  try
    unless result.status is true
      throw Error("Invalid Result")
    ###
    # Let's work with each result
    #
    # We're going to construct an entry for each, then go through
    # and append that to to the text blobb htmlBody
    ###
    hasReadGenus = new Array()
    hasReadClade = new Array()
    hasReadSubClade = new Array()
    for k, row of result.result
      try
        if k %% 100 is 0
          console.log "Parsing row #{k} of #{total}"
          if k %% 500 is 0 and k > 0
            message =
              status: true
              done: false
              updateUser: "Parsing #{k} of #{total}, please wait"
            self.postMessage message
          #   startLoad()
          #   toastStatusMessage "Parsing #{k} of #{total}, please wait"
      if isNull(row.genus) or isNull(row.species)
        # Skip this clearly unfinished entry
        continue
      # Prep the authorities
      try
        unless typeof row.authority_year is "object"
          authorityYears = new Object()
          try
            # Try to deal with the singlet
            if isNumber row.authority_year
              authorityYears[row.authority_year] = row.authority_year
            else if isNull row.authority_year
              # Check if this is an IUCN style species authority
              if /^\(? *((['"])? *([\w\.\-\&; \[\]]+(,|&|&amp;|&amp;amp;)?)+ *\2) *, *([0-9]{4}) *\)?/i.test(row.species_authority)
                year = row.species_authority.replace /^\(? *((['"])? *([\w\.\-\&; \[\]]+(,|&|&amp;|&amp;amp;)?)+ *\2) *, *([0-9]{4}) *\)?/ig, "$3"
                row.species_authority = row.species_authority.replace /^\(? *((['"])? *([\w\.\-\&; \[\]]+(,|&|&amp;|&amp;amp;)?)+ *\2) *, *([0-9]{4}) *\)?/ig, "$1"
                authorityYears[year] = year
              else
                authorityYears["No Year"] = "No Year"
            else
              authorityYears = JSON.parse row.authority_year
          catch e
            # Try to fix a bad JSON
            console.debug "authority isnt number, null, or object, with bad species_authority '#{row.authority_year}'"
            split = row.authority_year.split(":")
            if split.length > 1
              year = split[1].slice(split[1].search("\"")+1,-2)
              # console.log("Examining #{year}")
              year = year.replace(/"/g,"'")
              split[1] = "\"#{year}\"}"
              authorityYears = JSON.parse split.join(":")
            else
              console.warn "Unable to figure out the type of data for `authority_year`: #{e.message}", JSON.stringify row
              console.warn e.stack
        else
          authorityYears = row.authority_year
        try
          genusYear = Object.keys(authorityYears)[0]
          speciesYear = authorityYears[genusYear]
          genusYear = genusYear.replace(/&#39;/g,"'")
          speciesYear = speciesYear.replace(/&#39;/g,"'")
        catch
          for c,v of authorityYears
            genusYear = c.replace(/&#39;/g,"'")
            speciesYear = v.replace(/&#39;/g,"'")
        if isNull row.genus_authority
          row.genus_authority = row.species_authority
        else if isNull row.species_authority
          row.species_authority = row.genus_authority
        genusAuth = "#{row.genus_authority.toTitleCase()} #{genusYear}"
        if toInt(row.parens_auth_genus).toBool()
          genusAuth = "(#{genusAuth})"
        speciesAuth = "#{row.species_authority.toTitleCase()} #{speciesYear}"
        if toInt(row.parens_auth_species).toBool()
          speciesAuth = "(#{speciesAuth})"
      catch e
        # There was a data problem for the authority year!
        # However, we want it to be non-fatal.
        console.warn "There was a problem parsing the authority information for _#{row.genus} #{row.species} #{row.subspecies}_ - #{e.message}"
        console.warn e.stack
        console.warn "Bad parse for authority year -- tried to fix >>#{row.authority_year}<<", authorityYears, row.authority_year
        console.warn "We were working with",authorityYears,genusYear,genusAuth,speciesYear, speciesAuth
      # Handle the entry. Taxon notes (row.notes) are ignored.
      unless isNull row.entry
        try
          htmlNotes = markdown.toHTML row.entry
        catch e
          console.warn("Unable to parse Markdown for _#{row.genus} #{row.species} #{row.subspecies}_")
          htmlNotes = row.entry
      else
        htmlNotes = ""
      htmlCredit = ""
      unless isNull(htmlNotes) or isNull(row.taxon_credit)
        taxonCreditDate = ""
        unless isNull(row.taxon_credit_date)
          taxonCreditDate = ", #{row.taxon_credit_date}"
        htmlCredit = """
          <p class="text-right small text-muted">
            <cite>
              #{row.taxon_credit}#{taxonCreditDate}
            </cite>
          </p>
        """
      # Now for each result, we want to create a text blob
      oneOffHtml = ""
      unless row.linnean_order.trim() in hasReadClade
        oneOffHtml += """
        <h2 class="clade-declaration text-capitalize text-center">#{row.linnean_order}</h2>
        """
        hasReadClade.push row.linnean_order.trim()
      unless row.linnean_family.trim() in hasReadSubClade
        oneOffHtml += """
        <h3 class="subclade-declaration text-capitalize text-center">#{row.linnean_family}</h3>
        """
        hasReadSubClade.push row.linnean_family.trim()
      unless row.genus in hasReadGenus
        # Show the genus header
        oneOffHtml += """
        <aside class="genus-declaration lead">
          <span class="entry-sciname text-capitalize">#{row.genus}</span>
          <span class="entry-authority">#{genusAuth.unescape()}</span>
        </aside>
        """
        hasReadGenus.push row.genus
      shortGenus = "#{row.genus.slice(0,1)}. "
      entryHtml = """
      <section class="species-entry">
        #{oneOffHtml}
        <p class="h4 entry-header">
          <span class="entry-sciname">
            <span class="text-capitalize">#{shortGenus}</span> #{row.species} #{row.subspecies}
          </span>
          <span class="entry-authority">
            #{speciesAuth.unescape()}
          </span>
          &#8212;
          <span class="common_name no-cap">
            #{smartUpperCasing row.common_name}
          </span>
        </p>
        <div class="entry-content">
          #{htmlNotes}
          #{htmlCredit}
        </div>
      </section>
      """
      # Append it to htmlBody
      htmlBody += entryHtml
      ## End for loop
    # Now let's close up that HTML file
    htmlBody += """
    </article>
    </div>
    </body>
    </html>
    """
    duration = Date.now() - startTime
    console.log "HTML file prepped in #{duration}ms off-thread"
    message =
      html: htmlBody
      status: true
      done: true
    self.postMessage message
    self.close()
  catch e
    console.error "There was a problem creating your file. Please try again later."
    console.error("Exception in createHtmlFile() - #{e.message}")
    console.warn(e.stack)
    message =
      status: false
      done: true
    self.postMessage message
    self.close()
