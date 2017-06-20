# Handle all the downloads
# Depends on the service worker to do some of the load off-thread
# See ./serviceWorker.coffee

reEnableClosure = ->
  $("#download-chooser").find(".buttons paper-button")
  .removeAttr "disabled"
  false


getLastSearch = ->
  # Are we on a taxon page?
  if uri.o.attr("path")?.search(/species\-account/i) >=0
    # Get the taxon
    unless isNull window._activeTaxon
      canonicalTaxon = "#{_activeTaxon.genus} #{_activeTaxon.species}"
      unless isNull _activeTaxon.subspecies
        canonicalTaxon += " #{_activeTaxon.subspecies}"
      return canonicalTaxon
    else
      console.warn "Couldn't identify the active taxon"
  # OTherwise ...
  if searchParams?.lastSearch
    return searchParams.lastSearch
  else
    return "*"
  false


downloadCSVList = (useLastSearch = false) ->
  ###
  # Download a CSV file list
  #
  # See
  # https://github.com/tigerhawkvok/SSAR-species-database/issues/39
  ###
  animateLoad()
  startTime = Date.now()
  _asm.progressTracking =
    estimate: new Array()
  try
    searchString = if useLastSearch then getLastSearch() else "*"
    if isNull searchString
      searchString = "*"
  catch
    searchString = "*"
  try
    for button in $("#download-chooser .buttons paper-button")
      p$(button).disabled = true
  #filterArg = "eyJpc19hbGllbiI6MCwiYm9vbGVhbl90eXBlIjoib3IifQ"
  #args = "filter=#{filterArg}"
  args =
    q: encodeURIComponent searchString
  d = new Date()
  adjMonth = d.getMonth() + 1
  month = if adjMonth.toString().length is 1 then "0#{adjMonth}" else adjMonth
  day = if d.getDate().toString().length is 1 then "0#{d.getDate().toString()}" else d.getDate()
  dateString = "#{d.getUTCFullYear()}-#{month}-#{day}"
  $.get "#{searchParams.apiPath}", buildQuery args, "json"
  .done (result) ->
    try
      unless result.status is true
        throw Error("Invalid Result")
      startLoad()
      toastStatusMessage "Please be patient while we create the file for you"
      postMessageContent =
        action: "render-csv"
        data: result
      worker = new Worker "js/serviceWorker.min.js"
      console.info "Rendering list off-thread"
      worker.addEventListener "message", (e) ->
        ###
        # Service worker callback
        ###
        if e.data.status isnt true
          console.warn "Got an error!"
          message = unless isNull e.data.updateUser then e.data.updateUser else "Failed to create file"
          stopLoadError message, undefined, 10000
          reEnableClosure()
          return false
        if e.data.done isnt true
          unless isNull e.data.updateUser
            console.log "Toasting: #{e.data.updateUser}"
            toastStatusMessage e.data.updateUser, 1000
          else if isNumber e.data.progress
            unless $("#download-progress-indicator").exists()
              html = """
              <paper-progress
                class="transiting"
                id="download-progress-indicator"
                value="0"
                max="1000">
              </paper-progress>
              <p>
                <span class="bold">Estimated Time Remaining:</span> <span id="estimated-remaining-time">&#8734;</span>s
              </p>
              """
              $("#download-chooser .dialog-content .scrollable").append html
            p$("#download-progress-indicator").value = e.data.progress
            timeElapsed = Date.now() - startTime
            fractionalProgress = toFloat(e.data.progress) / 1000.0
            totalTimeEstimate = timeElapsed / fractionalProgress
            _asm.progressTracking.estimate.push totalTimeEstimate
            #console.log "Total time estimate:", totalTimeEstimate
            avgTotalTimeEstimate = _asm.progressTracking.estimate.mean()
            #console.log "Average time estimate:", avgTotalTimeEstimate
            estimatedTimeRemaining = avgTotalTimeEstimate - timeElapsed
            #console.log "Estimated time remaining:", estimatedTimeRemaining
            $("#estimated-remaining-time").text toInt estimatedTimeRemaining / 1000
          else
            console.log "Just an update", e.data
          return false
        # The CSV
        downloadable = e.data.csv
        try
          fileSizeMiB = downloadable.length / 1024 / 1024
        catch
          fileSizeMiB = 0
        console.log "Downloadable size: #{fileSizeMiB} MiB"
        if _asm.sqlDumpLocation is null
          # We're still waiting
          sqlButton = """
          <div id="download-sql-summary" class="data-download-button">
            <paper-spinner active></paper-spinner> Please wait while your SQL creation finishes ...
          </div>
          """
          do delayCheckSqlButton = ->
            if _asm.sqlDumpLocation is null
              delay 250, ->
                delayCheckSqlButton()
            else
              if _asm.sqlDumpLocation is false
                # The async check completed and failed
                sqlButton = """
                <a href="#" class="btn btn-danger data-download-button" id="download-sql-summary" disabled><iron-icon icon="icons:error"></iron-icon> SQL Creation Failed</a>
                """
              else
                # The async check completed
                sqlButton = """
                <a href="#{_asm.sqlDumpLocation}" download="asm-species-#{dateString}.sql" class="btn btn-default data-download-button" id="download-sql-summary"><iron-icon icon="icons:file-download"></iron-icon> Download SQL</a>
                """
              $("#download-sql-summary").replaceWith sqlButton
            false
        else if _asm.sqlDumpLocation is false
          # The async check completed and failed
          sqlButton = """
          <a href="#" class="btn btn-danger data-download-button" id="download-sql-summary" disabled><iron-icon icon="icons:error"></iron-icon> SQL Creation Failed</a>
          """
        else
          # The async check completed
          sqlButton = """
          <a href="#{_asm.sqlDumpLocation}" download="asm-species-#{dateString}.sql" class="btn btn-default data-download-button" id="download-sql-summary"><iron-icon icon="icons:file-download"></iron-icon> Download SQL</a>
          """
        # Build the dialog
        html = """
        <paper-dialog class="download-file" id="download-csv-file" modal>
          <h2>Your files are ready</h2>
          <paper-dialog-scrollable class="dialog-content">
            <h3>Want to do data analysis?</h3>
            <p>
              We have an open API! Read all of our parameters here:
              <a href="https://github.com/tigerhawkvok/asm-mammal-database/blob/master/README.md#api"  onclick='window.open(this.href); return false;' onkeypress='window.open(this.href); return false;'>README API Documentation <iron-icon icon="launch"></iron-icon></a>
              <br/><br/>
              We also have a UI to perform permission-restricted SQL queries on the database. You can launch this by clicking the <iron-icon icon="icons:code"></iron-icon> icon in the footer.
            </p>
            <h3>Which file type do I want?</h3>
            <p>
              A CSV file is readily opened by consumer-grade programs, such as Microsoft Excel or Google Spreadsheets.
              It has some transformations done to the raw data to make it more readable.
              <br/><br/>
              However, if you wish to replicate the whole database and perform queries, the SQL file is machine-readable,
              ready for import into a MySQL or MariaDB database by running the <code>source asm-species-#{dateString}.sql;</code> in their
              interactive shell prompts when run from your download directory. This file has not been transformed in any way.
            </p>
            <h3>Excel Important Note</h3>
            <p>
              Please note that some special characters in names may be decoded incorrectly by Microsoft Excel. If this is a problem, following the steps in <a href="https://github.com/tigerhawkvok/asm-mammal-database/blob/master/meta/excel_unicode_readme.md"  onclick='window.open(this.href); return false;' onkeypress='window.open(this.href); return false;'>this README <iron-icon icon="icons:launch"></iron-icon></a> to force Excel to format it correctly.
            </p>
            <p class="text-center">
              <a href="#{downloadable}" download="asm-species-#{dateString}.csv" class="btn btn-default data-download-button" id="download-csv-summary"><iron-icon icon="icons:file-download"></iron-icon> Download CSV</a>
              #{sqlButton}
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
        delay 250, ->
          safariDialogHelper("#download-csv-file")
        stopLoad()
        duration = Date.now() - startTime
        console.debug "CSV time elapsed: #{duration}ms"
        false
      worker.postMessage postMessageContent
      false
    catch e
      stopLoadError "There was a problem creating the CSV file. Please try again later."
      console.error "Exception in downloadCSVList ) - #{e.message}"
      console.warn e.stack
      console.warn "Got",result,"from","#{searchParams.apiPath}?#{args}", result.status
  .fail ->
    stopLoadError "There was a problem communicating with the server. Please try again later."
    reEnableClosure()
  # Get the SQL dump location
  _asm.sqlDumpLocation = null
  $.get "#{uri.urlString}meta.php", "action=get_db_dump", "json"
  .done (result) ->
    if result.status is true
      _asm.sqlDumpLocation = result.download_path
    else
      _asm.sqlDumpLocation = false
    false
  .fail (result, status) ->
    reEnableClosure()
    false
  false




downloadHTMLList = (useLastSearch = false) ->
  ###
  # Download a HTML file list
  #
  # We want to set this up to look similar to the published list
  # https://mammaldiversity.org/wp-content/uploads/2014/07/HC_39_7thEd.pdf
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
  startTime = Date.now()
  _asm.progressTracking =
    estimate: new Array()
  try
    searchString = if useLastSearch then getLastSearch() else "*"
    if isNull searchString
      searchString = "*"
  catch
    searchString = "*"
  try
    for button in $("#download-chooser .buttons paper-button")
      p$(button).disabled = true
  console.debug "Getting CSS..."
  $.get "#{uri.urlString}css/download-inline-bootstrap.css"
  .done (importedCSS) ->
    startLoad()
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
    console.debug "CSS loaded, starting main ..."
    args =
      q: encodeURIComponent searchString
      order: "linnean_order,linnean_family,genus,species,subspecies"
    #args = "q=#{searchString}&order=linnean_order,linnean_family,genus,species,subspecies"
    $.get "#{searchParams.apiPath}", buildQuery args, "json"
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
        # console.info "Got message back from service worker", e.data
        if e.data.status isnt true
          console.warn "Got an error!"
          message = unless isNull e.data.updateUser then e.data.updateUser else "Failed to create file"
          stopLoadError message, undefined, 10000
          reEnableClosure()
          return false
        if e.data.done isnt true
          unless isNull e.data.updateUser
            console.log "Toasting: #{e.data.updateUser}"
            toastStatusMessage e.data.updateUser, 1000
          else if isNumber e.data.progress
            unless $("#download-progress-indicator").exists()
              html = """
              <paper-progress
                class="transiting"
                id="download-progress-indicator"
                value="0"
                max="1000">
              </paper-progress>
              <p>
                <span class="bold">Estimated Time Remaining:</span> <span id="estimated-remaining-time">&#8734;</span>s
              </p>
              """
              $("#download-chooser .dialog-content .scrollable").append html
            try
              p$("#download-progress-indicator").value = e.data.progress
            timeElapsed = Date.now() - startTime
            fractionalProgress = toFloat(e.data.progress) / 1000.0
            totalTimeEstimate = timeElapsed / fractionalProgress
            _asm.progressTracking.estimate.push totalTimeEstimate
            #console.log "Total time estimate:", totalTimeEstimate
            avgTotalTimeEstimate = _asm.progressTracking.estimate.mean()
            #console.log "Average time estimate:", avgTotalTimeEstimate
            estimatedTimeRemaining = avgTotalTimeEstimate - timeElapsed
            #console.log "Estimated time remaining:", estimatedTimeRemaining
            $("#estimated-remaining-time").text toInt estimatedTimeRemaining / 1000
          else
            console.log "Just an update", e.data
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
            <p>
              Please note that some taxa may have had incomplete data. Please download a CSV or SQL file for the uncombined taxon data.
            </p>
            <p class="text-center">
              <a href="#{downloadable}" download="asm-species-#{dateString}.html" class="btn btn-default data-download-button" id="download-html-summary"><iron-icon icon="icons:file-download"></iron-icon> Download HTML</a>
              <div id="pdf-download-placeholder" class="data-download-button">
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
        # When we close it, we want to remove it to reset the
        # progress bar and the disabled's, etc.
        $("#download-chooser").on "iron-overlay-closed", ->
          delay 100, ->
            $(this).remove()
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
        <a href="#" disabled class="btn btn-danger" id="download-pdf-summary"><iron-icon icon="icons:error"></iron-icon> PDF Creation Failed</a>
        """
        console.debug "Posting for PDF"
        $.post "#{uri.urlString}pdf/pdfwrapper.php", "html=#{encodeURIComponent(htmlBody)}", "json"
        .done (result) ->
          console.debug "PDF result", result
          if result.status
            pdfDownloadPath = "#{uri.urlString}#{result.file}"
            console.debug pdfDownloadPath
            pdfDownload = """
              <a href="#{pdfDownloadPath}" download="asm-species-#{dateString}.pdf" class="btn btn-default data-download-button" id="download-pdf-summary"><iron-icon icon="file-download"></iron-icon> Download PDF</a>
            """
            $("#download-html-file #download-html-summary").after pdfDownload
          else
            stopLoadError "Couldn't make PDF file"
            $("#download-html-file #download-html-summary").after pdfError
        .error (result, status) ->
          stopLoadError "Wasn't able to fetch PDF"
          $("#download-html-file #download-html-summary").after pdfError
        .always ->
          try
            $("#download-html-file #pdf-download-placeholder").remove()
          duration = Date.now() - startTime
          console.debug "HTML+PDF time elapsed: #{duration}ms"
        false
      worker.postMessage postMessageContent
      false
    .fail  ->
      stopLoadError "There was a problem communicating with the server. Please try again later."
      reEnableClosure()
  .fail ->
    stopLoadError "Unable to fetch styles for printout"
    reEnableClosure()
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
      <div>
        <paper-toggle-button id="use-search">Use current search results</paper-toggle-button>
      </div>
    </paper-dialog-scrollable>
    <div class="buttons">
      <paper-button dialog-dismiss>Cancel</paper-button>
      <paper-button id="initiate-csv-download">CSV/SQL</paper-button>
      <paper-button id="initiate-html-download">HTML/PDF</paper-button>
    </div>
  </paper-dialog>
  """
  unless $("#download-chooser").exists()
    $("body").append(html)
  $("#initiate-csv-download").click ->
    # Show a notice to docs for direct queries
    try
      isChecked = p$("#use-search").checked
    catch
      isChecked = false
    try
      p$("#use-search").disabled = true
    downloadCSVList(isChecked)
  $("#initiate-html-download").click ->
    try
      isChecked = p$("#use-search").checked
    catch
      isChecked = false
    try
      p$("#use-search").disabled = true
    downloadHTMLList(isChecked)
  ## Close events
  # When we close it, we want to remove it to reset the
  # progress bar and the disabled's, etc.
  $("#download-chooser")
  .on "iron-overlay-closed", ->
    delay 100, =>
      $(this).remove()
  safariDialogHelper("#download-chooser")
  false
