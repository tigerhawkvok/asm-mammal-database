# Handle all the downloads
# Depends on the service worker to do some of the load off-thread
# See ./serviceWorker.coffee

downloadCSVList = ->
  ###
  # Download a CSV file list
  #
  # See
  # https://github.com/tigerhawkvok/SSAR-species-database/issues/39
  ###
  animateLoad()
  #filterArg = "eyJpc19hbGllbiI6MCwiYm9vbGVhbl90eXBlIjoib3IifQ"
  #args = "filter=#{filterArg}"
  args = "q=*"
  d = new Date()
  adjMonth = d.getMonth() + 1
  month = if adjMonth.toString().length is 1 then "0#{adjMonth}" else adjMonth
  day = if d.getDate().toString().length is 1 then "0#{d.getDate().toString()}" else d.getDate()
  dateString = "#{d.getUTCFullYear()}-#{month}-#{day}"
  $.get "#{searchParams.apiPath}", args, "json"
  .done (result) ->
    try
      unless result.status is true
        throw Error("Invalid Result")
      # Parse it all out
      csvBody = """
      """
      csvHeader = new Array()
      showColumn = [
        "genus"
        "species"
        "subspecies"
        "canonical_sciname"
        "common_name"
        "common_name_source"
        "image"
        "image_caption"
        "image_credit"
        "image_license"
        "major_type"
        "major_subtype"
        "simple_linnean_group"
        "simple_linnean_subgroup"
        "linnean_order"
        "linnean_family"
        "genus_authority"
        "parens_auth_genus"
        "species_authority"
        "parens_auth_species"
        "authority_year"
        "deprecated_scientific"
        "notes"
        "entry"
        "taxon_credit"
        "taxon_credit_date"
        "taxon_author"
        "citation"
        "source"
        "internal_id"
        ]
      makeTitleCase = [
        "genus"
        "common_name"
        "taxon_credit"
        "linnean_order"
        "linnean_family"
        "genus_authority"
        "species_authority"
        ]
      i = 0
      for k, row of result.result
        # Line by line ... do each result
        csvRow = new Array()
        if isNull(row.genus) then continue
        for dirtyCol, dirtyColData of row
          # Escape as per RFC4180
          # https://tools.ietf.org/html/rfc4180#page-2
          col = dirtyCol.replace(/"/g,'\"\"')
          try
            colData = dirtyColData.replace(/"/g,'\"\"').replace(/&#39;/g,"'")
          catch
            colData = ""
          if i is 0
            # Do the headers
            if col in showColumn
              csvHeader.push col.replace(/_/g," ").toTitleCase()
          # Sitch together the row
          if col in showColumn
            # You'd want to naively push, but we can't
            # There are formatting rules to observe
            # Deal with authorities
            if /[a-z]+_authority/.test(col)
              try
                unless typeof row.authority_year is "object"
                  authorityYears = new Object()
                  try
                    # Try to deal with the singlet
                    if isNumber row.authority_year
                      authorityYears[row.authority_year] = row.authority_year
                    else if isNull row.authority_year
                      # Check if this is an IUCN style species authority
                      # Strip HTML
                      row.species_authority = row.species_authority.replace /(<\/|<|&lt;|&lt;\/).*?(>|&gt;)/img, ""
                      if /^\(? *((['"])? *([\w\u00C0-\u017F\. \-\&;\[\]]+(,|&|&amp;|&amp;amp;|&#[\w0-9]+;)?)+ *\2) *, *([0-9]{4}) *\)?/im.test(row.species_authority)
                        year = row.species_authority.replace /^\(? *((['"])? *([\w\u00C0-\u017F\.\-\&; \[\]]+(,|&|&amp;|&amp;amp;|&#[\w0-9]+;)?)+ *\2) *, *([0-9]{4}) *\)?/ig, "$5"
                        row.species_authority = row.species_authority.replace /^\(? *((['"])? *([\w\u00C0-\u017F\.\-\&; \[\]]+(,|&|&amp;|&amp;amp;|&#[\w0-9]+;)?)+ *\2) *, *([0-9]{4}) *\)?/ig, "$1"
                        authorityYears[year] = year
                        row.authority_year = authorityYears
                      else
                        unless isNull row.species_authority
                          console.warn "Failed a match on authority '#{row.species_authority}'"
                        authorityYears["Unknown"] = "Unknown"
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
                switch col.split("_")[0]
                  when "genus"
                    tempCol = "#{colData.toTitleCase()} #{genusYear}"
                    if toInt(row.parens_auth_genus).toBool()
                      tempCol = "(#{tempCol})"
                  when "species"
                    tempCol = "#{colData.toTitleCase()} #{speciesYear}"
                    if toInt(row.parens_auth_species).toBool()
                      tempCol = "(#{tempCol})"
                colData = tempCol
                # if "\"Plestiodon\"" in csvRow and "\"egregius\"" in csvRow
                #   console.log("Plestiodon: Working with",csvRow,"inserting",tempCol)
              catch e
                # Bad authority year, just don't use it
            if col in makeTitleCase
              colData = colData.toTitleCase()
            if col is "image" and not isNull(colData)
              colData = "#{uri.urlString}#{colData}"
            # Done with formatting, push it
            csvRow.push "\"#{colData}\""
        # Increment the row counter
        i++
        csvLiteralRow = csvRow.join(",")
        # if "\"Plestiodon\"" in csvRow and "\"egregius\"" in csvRow
        #   console.log("Plestiodon: Working with",csvRow,csvLiteralRow)
        csvBody +="""

        #{csvLiteralRow}
        """
      csv = """
      #{csvHeader.join(",")}
      #{csvBody}
      """
      # OK, it's all been created. Download it.
      downloadable = "data:text/csv;charset=utf-8," + encodeURIComponent(csv)
      try
        fileSizeMiB = downloadable.length / 1024 / 1024
      catch
        fileSizeMiB = 0
      console.log "Downloadable size: #{fileSizeMiB} MiB"
      html = """
      <paper-dialog class="download-file" id="download-csv-file" modal>
        <h2>Your files are ready</h2>
        <paper-dialog-scrollable class="dialog-content">
          <h3>Need data analysis?</h3>
          <p>
            api explanation link blurb
          </p>
          <h3>Which file type do I want?</h3>
          <p>
            A CSV file is readily opened by consumer-grade programs, such as Microsoft Excel or Google Spreadsheets.
            However, if you wish to replicate the whole database and perform queries, the SQL file is machine-readable,
            ready for import into a MySQL or MariaDB database by running the <code>source asm-species-#{dateString}.sql;</code> in their
            interactive shell prompts when run from your download directory.
          </p>
          <h3>Excel Important Note</h3>
          <p>
            Please note that some special characters in names may be decoded incorrectly by Microsoft Excel. If this is a problem, following the steps in <a href="https://github.com/SSARHERPS/SSAR-species-database/blob/master/meta/excel_unicode_readme.md"  onclick='window.open(this.href); return false;' onkeypress='window.open(this.href); return false;'>this README <iron-icon icon="launch"></iron-icon></a> to force Excel to format it correctly.
          </p>
          <p class="text-center">
            <a href="#{downloadable}" download="asm-species-#{dateString}.csv" class="btn btn-default" id="download-csv-summary"><iron-icon icon="file-download"></iron-icon> Download CSV</a>
            <a href="#" download="asm-species-#{dateString}.sql" class="btn btn-default" id="download-sql-summary" disabled><iron-icon icon="file-download"></iron-icon> Download SQL</a>
          </p>
        </paper-dialog-scrollable>
        <div class="buttons">
          <paper-button dialog-dismiss>Close</paper-button>
        </div>
      </paper-dialog>
      """
      unless $("#download-csv-file").exists()
        $("body").append(html)
      else
        $("#download-csv-file").replaceWith(html)
      p$("#download-chooser").close()
      if fileSizeMiB >= 2
        # Chrome doesn't support a data URI this big
        console.debug "Large file size triggering blob creation"
        downloadDataUriAsBlob "#download-csv-summary"
      else
        console.debug "File size is small enough to use a data-uri"
      safariDialogHelper("#download-csv-file")
      stopLoad()
    catch e
      stopLoadError "There was a problem creating the CSV file. Please try again later."
      console.error "Exception in downloadCSVList ) - #{e.message}"
      console.warn e.stack
      console.warn "Got",result,"from","#{searchParams.apiPath}?#{args}", result.status
  .fail ->
    stopLoadError "There was a problem communicating with the server. Please try again later."
  false




downloadHTMLList = ->
  ###
  # Download a HTML file list
  #
  # We want to set this up to look similar to the published list
  # http://mammaldiversity.org/wp-content/uploads/2014/07/HC_39_7thEd.pdf
  # Starting with page 11
  #
  # Configured Bootstrap:
  # https://gist.github.com/e14c62a4d4eee8f40b6b
  #
  # Bootstrap Config Link:
  # http://getbootstrap.com/customize/?id=e14c62a4d4eee8f40b6b
  #
  # See
  # https://github.com/tigerhawkvok/SSAR-species-database/issues/40
  ###
  startLoad()
  $.get "#{uri.urlString}css/download-inline-bootstrap.css"
  .done (importedCSS) ->
    d = new Date()
    adjMonth = d.getMonth() + 1
    month = if adjMonth.toString().length is 1 then "0#{adjMonth}" else adjMonth
    day = if d.getDate().toString().length is 1 then "0#{d.getDate().toString()}" else d.getDate()
    dateString = "#{d.getUTCFullYear()}-#{month}-#{day}"
    htmlBody = """
        <!doctype html>
        <html lang="en">
          <head>
            <title>ASM Species Checklist ver. #{dateString}</title>
            <meta http-equiv="X-UA-Compatible" content="IE=edge">
            <meta charset="UTF-8"/>
            <meta name="theme-color" content="#445e14"/>
            <meta name="viewport" content="width=device-width, initial-scale=1" />
            <link href='http://fonts.googleapis.com/css?family=Droid+Serif:400,700,700italic,400italic|Roboto+Slab:400,700' rel='stylesheet' type='text/css' />
            <style type="text/css" id="asm-checklist-inline-stylesheet">
              #{importedCSS}
            </style>
          </head>
          <body>
            <div class="container-fluid">
              <article>
                <h1 class="text-center">ASM Species Checklist ver. #{dateString}</h1>
    """
    args = "q=*&order=linnean_order,linnean_family,genus,species,subspecies"
    $.get "#{searchParams.apiPath}", args, "json"
    .done (result) ->
      startLoad()
      toastStatusMessage "Please be patient while we create the file for you"
      postMessageContent =
        action: "render-html"
        data: result
        htmlHeader: htmlBody
      worker = new Worker "js/serviceWorker.min.js"
      console.info "Rendering list off-thread"
      worker.addEventListener "message", (e) ->
        ###
        # Service worker callback
        ###
        console.info "Got message back from service worker", e.data
        if e.data.done isnt true
          console.log "Just an update"
          unless isNull e.data.updateUser
            toastStatusMessage e.data.updateUser
          return false
        if e.data.status isnt true
          console.warn "Got an error!"
          message = unless isNull e.data.updateUser then e.data.updateUser else "Failed to create file"
          stopLoadError message, "", 10000
          return false
        htmlBody = e.data.html
        downloadable = "data:text/html;charset=utf-8,#{encodeURIComponent(htmlBody)}"
        try
          fileSizeMiB = downloadable.length / 1024 / 1024
        catch
          fileSizeMiB = 0
        console.log "Downloadable size: #{fileSizeMiB} MiB"
        dialogHtml = """
        <paper-dialog  modal class="download-file" id="download-html-file">
          <h2>Your file is ready</h2>
          <paper-dialog-scrollable class="dialog-content">
            <p class="text-center">
              <a href="#{downloadable}" download="asm-species-#{dateString}.html" class="btn btn-default" id="download-html-summary"><iron-icon icon="file-download"></iron-icon> Download HTML</a>
              <div id="pdf-download-placeholder">
                <paper-spinner active></paper-spinner> Please wait while your PDF creation finishes ...
              </div>
            </p>
          </paper-dialog-scrollable>
          <div class="buttons">
            <paper-button dialog-dismiss>Close</paper-button>
          </div>
        </paper-dialog>
        """
        unless $("#download-html-file").exists()
          $("body").append(dialogHtml)
        else
          $("#download-html-file").replaceWith(dialogHtml)
        try
          p$("#download-chooser").close()
        if fileSizeMiB >= 2
          # Chrome doesn't support a data URI this big
          console.debug "Large file size triggering blob creation"
          downloadDataUriAsBlob "#download-html-summary"
        else
          console.debug "File size is small enough to use a data-uri"
        safariDialogHelper("#download-html-file")
        stopLoad()
        # Now try to fetch the PDF file
        toastStatusMessage "Please wait while we prepare your PDF file...", "", 7000
        pdfError = """
        <a href="#" disabled class="btn btn-default" id="download-pdf-summary">PDF Creation Failed</a>
        """
        console.debug "Posting for PDF"
        $.post "#{uri.urlString}pdf/pdfwrapper.php", "html=#{encodeURIComponent(htmlBody)}", "json"
        .done (result) ->
          console.debug "PDF result", result
          if result.status
            pdfDownloadPath = "#{uri.urlString}#{result.file}"
            console.debug pdfDownloadPath
            pdfDownload = """
              <a href="#{pdfDownloadPath}" download="asm-species-#{dateString}.pdf" class="btn btn-default" id="download-pdf-summary"><iron-icon icon="file-download"></iron-icon> Download PDF</a>
            """
            $("#download-html-file #download-html-summary").after pdfDownload
          else
            console.error "Couldn't make PDF file"
            $("#download-html-file #download-html-summary").after pdfError
        .error (result, status) ->
          console.error "Wasn't able to fetch PDF"
          $("#download-html-file #download-html-summary").after pdfError
        .always ->
          try
            $("#download-html-file #pdf-download-placeholder").remove()
      worker.postMessage postMessageContent
    .fail  ->
      stopLoadError("There was a problem communicating with the server. Please try again later.")
  .fail ->
    stopLoadError "Unable to fetch styles for printout"
    false
  false

showDownloadChooser = ->
  html = """
  <paper-dialog id="download-chooser" modal>
    <h2>Select Download Type</h2>
    <paper-dialog-scrollable class="dialog-content">
      <p>
        Once you select a file type, it will take a moment to prepare your download. Please be patient.
      </p>
    </paper-dialog-scrollable>
    <div class="buttons">
      <paper-button dialog-dismiss>Cancel</paper-button>
      <paper-button dialog-confirm id="initiate-csv-download">CSV/SQL</paper-button>
      <paper-button dialog-confirm id="initiate-html-download">HTML/PDF</paper-button>
    </div>
  </paper-dialog>
  """
  unless $("#download-chooser").exists()
    $("body").append(html)
  $("#initiate-csv-download").click ->
    # Show a notice to docs for direct queries
    downloadCSVList()
  $("#initiate-html-download").click ->
    downloadHTMLList()
  safariDialogHelper("#download-chooser")
  false
