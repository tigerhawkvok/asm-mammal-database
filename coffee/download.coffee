

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
        "common_name"
        "image"
        "image_credit"
        "image_license"
        "major_type"
        "major_common_type"
        "major_subtype"
        "minor_type"
        "linnean_order"
        "genus_authority"
        "species_authority"
        "deprecated_scientific"
        "notes"
        "taxon_credit"
        "taxon_credit_date"
        ]
      makeTitleCase = [
        "genus"
        "common_name"
        "taxon_author"
        "major_subtype"
        "linnean_order"
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
          colData = dirtyColData.replace(/"/g,'\"\"').replace(/&#39;/g,"'")
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
                authorityYears = JSON.parse(row.authority_year)
                genusYear = ""
                speciesYear = ""
                for k,v of authorityYears
                  genusYear = k.replace(/"/g,'\"\"').replace(/&#39;/g,"'")
                  speciesYear = v.replace(/"/g,'\"\"').replace(/&#39;/g,"'")
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
              colData = "http://mammaldiversity.org/cndb/#{colData}"
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
      html = """
      <paper-dialog class="download-file" id="download-csv-file" modal>
        <h2>Your file is ready</h2>
        <paper-dialog-scrollable class="dialog-content">
          <p>
            Please note that some special characters in names may be decoded incorrectly by Microsoft Excel. If this is a problem, following the steps in <a href="https://github.com/SSARHERPS/SSAR-species-database/blob/master/meta/excel_unicode_readme.md"  onclick='window.open(this.href); return false;' onkeypress='window.open(this.href); return false;'>this README <iron-icon icon="launch"></iron-icon></a> to force Excel to format it correctly.
          </p>
          <p class="text-center">
            <a href="#{downloadable}" download="asm-common-names-#{dateString}.csv" class="btn btn-default"><iron-icon icon="file-download"></iron-icon> Download Now</a>
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
      $("#download-chooser").get(0).close()
      safariDialogHelper("#download-csv-file")
    catch e
      stopLoadError("There was a problem creating the CSV file. Please try again later.")
      console.error("Exception in downloadCSVList() - #{e.message}")
      console.warn("Got",result,"from","#{searchParams.apiPath}?#{args}", result.status)
  .fail ->
    stopLoadError("There was a problem communicating with the server. Please try again later.")
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
      worker = new Worker "js/serviceWorker.js"
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
          stopLoadError "Failed to create file"
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
        # Now try to fetch the PDF file
        toastStatusMessage "Please wait while we prepare your PDF file...", "", 7000
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
            $("#download-html-file paper-dialog-scrollable p.text-center a").after pdfDownload
          else
            console.error "Couldn't make PDF file"
        .error (result, status) ->
          console.error "Wasn't able to fetch PDF"
        .always ->
          safariDialogHelper("#download-html-file")
          stopLoad()
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
      <paper-button dialog-confirm id="initiate-csv-download">CSV</paper-button>
      <paper-button dialog-confirm id="initiate-html-download">HTML/PDF</paper-button>
    </div>
  </paper-dialog>
  """
  unless $("#download-chooser").exists()
    $("body").append(html)
  $("#initiate-csv-download").click ->
    downloadCSVList()
  $("#initiate-html-download").click ->
    downloadHTMLList()
  safariDialogHelper("#download-chooser")
  false
