###
# Primary handler for SQL Live Query Input
#
# See issue
# https://github.com/tigerhawkvok/asm-mammal-database/issues/20
# https://github.com/tigerhawkvok/asm-mammal-database/projects/2
#
# @author Philip Kahn
###

loadTerminalDialog = (reinit = false) ->
  getTerminalDependencies ->
    unless $("#sql-query-dialog").exists() or reinit
      html = """
    <paper-dialog id="sql-query-dialog" modal>
      <paper-dialog-scrollable>
        <div class="row query-container">
          <form class="form">
            <div class="form-group">
              <textarea id="sql-input"
                        rows="5"
                        class="form-control"
                        placeholder="SQL query here"
                        autofocus></textarea>
              <p class="text-muted">
                <strong>Tip:</strong> Use <kbd>@@</kbd> to represent the database table and <kbd>!@</kbd> to represent <code class="language-null">SELECT * FROM table</code>. You can search columns using DarwinCore or columns specified in Github.
              </p>
            </div>
          </form>
          <p class="col-xs-12">Interpreted Query:</p>
          <code class="language-sql col-xs-11 col-xs-offset-1" id="interpreted-sql"></code>
        </div>
      </paper-dialog-scrollable>
      <div class="buttons">
        <paper-button id="clear-sql-results">Clear Results</paper-button>
        <paper-button dialog-dismiss>Close</paper-button>
      </div>
    </paper-dialog>
      """
      $("body").append html
      # Events
      $("#sql-query-dialog").find("form").submit (e) ->
        e.preventDefault()
        executeQuery()
        false
      $("#sql-input").keydown (e) ->
        kc = if e.keyCode then e.keyCode else e.which
        if kc is 13
          e.preventDefault()
          executeQuery()
          return false
      $("#sql-input").keyup (e) ->
        kc = if e.keyCode then e.keyCode else e.which
        if kc isnt 13
          # Copy the formatted string
          parseQuery this
        true
      $("#clear-sql-results").click ->
        $("#sql-results").remove()
        false
    p$("#sql-query-dialog").open()
  false

getTerminalDependencies = (callback, args...) ->
  ###
  #
  ###
  if _asm.terminalDependencies is true
    console.log "Dependencies are already loaded, executing immediately"
    if typeof callback is "function"
      callback args...
  dependencies =
    nacl: false
    prism: false
  _asm.terminalDependencies = false
  _asm.terminalDependenciesChecking = false
  checkDependencies = ->
    if _asm.terminalDependencies is true
      return true
    if _asm.terminalDependenciesChecking
      delay 50, ->
        checkDependencies()
      return false
    _asm.terminalDependenciesChecking = true
    ready = true
    for lib, status of dependencies
      ready = ready and status
      unless ready
        console.log "Library #{lib} isn't yet ready..."
        break
    _asm.terminalDependencies = ready
    _asm.terminalDependenciesChecking = false
    if ready
      console.log "Dependencies loaded"
      if typeof callback is "function"
        callback args...
    ready
  # libsodium
  naclCallback = ->
    nacl_factory.instantiate (nacl) ->
      _asm.nacl = nacl
      dependencies.nacl = true
      checkDependencies()
  unless nacl_factory?
    loadJS "bower_components/js-nacl/lib/nacl_factory.js", ->
      naclCallback()
  else
    naclCallback()
  loadJS "bower_components/prism/prism.js", ->
    loadJS "bower_components/prism/components/prism-sql.js", ->
      dependencies.prism = true
      loadJS "bower_components/prism/components/prism-json.js"
      checkDependencies()
      false
    $("head").append """<link href="bower_components/prism/themes/prism.css" rel="stylesheet" />"""
  false


parseQuery = (selector = "#sql-input", codeBoxSelector = "#interpreted-sql") ->
  sql = $(selector).val().trim()
  # Shortcuts
  sql = sql.replace /@@/mig, "`mammal_diversity_database`"
  sql = sql.replace /!@/mig, "SELECT * FROM `mammal_diversity_database`"
  codeBox = $(codeBoxSelector).get(0)
  $(codeBox).text sql
  Prism.highlightElement codeBox
  sql

executeQuery = ->
  ###
  #
  ###
  handleSqlError = (errorMessage = "Error") ->
    try
      alertId = _asm.nacl.decode_utf8 _asm.nacl.crypto_hash_string errorMessage + Date.now()
    catch e
      console.warn e.message
      console.warn e.stack
      alertId = "sql-query-alert"
    html = """
<div class="alert alert-danger alert-dismissable col-xs-8 col-offset-xs-2 center-block clear clearfix" role="alert" id="#{alertId}">
  <button type="button" class="close" data-dismiss="alert" aria-label="Close"><span aria-hidden="true">&times;</span></button>
  <div class="alert-message">#{errorMessage}</div>
</div>
    """
    $("#sql-input").parents("paper-dialog").find(".alert").remove()
    $("#sql-input").parents("form").after html
    stopLoadError()
    false
  try
    darwinCoreOnly = p$("#dwc-only").checked
  query = parseQuery()
  if isNull query
    return handleSqlError "Sorry, you can't use an empty query"
  args =
    sql_query: post64 query
    action: "query"
    dwc: darwinCoreOnly ? false
  console.debug "Posting to target", "#{uri.urlString}api.php?#{buildQuery args}"
  $.post "#{uri.urlString}api.php", buildQuery args, "json"
  .done (result) ->
    console.log "Got result", result
    $("#sql-results").remove()
    try
      if result.statements?
        statements = Object.toArray result.statements
    if result.status isnt true
      if isNull result.statement_count
        error = result.error ? result.human_error ? "UNKNOWN_ERROR"
        return handleSqlError error
      # There were no OBVIOUS problems ...
      for statement in statements
        if statement.result is "ERROR"
          errorMessage = "Your query <code class='language-sql'>#{statement.provided}</code> "
          if statement.error.safety_check isnt true
            errorMessage += "failed a safety check."
          else if statement.error.sql_response is false
            errorMessage += "has or generated during parsing a syntax error.<br/><br/>If you believe your syntax to be valid, try simplifying it as we strictly limit the types of queries accessible here."
          else if statement.error.was_server_exception
            errorMessage += "generated a problem on the server and was refused to be executed. Please report this."
          else
            errorMessage += "gave <code>UNKNOWN_QUERY_ERROR</code>"
          errorMessage += "<br/><br/>Execution of your query was halted here."
          return handleSqlError errorMessage
    # The query worked
    $("#sql-input").parents("paper-dialog").find(".alert").remove()
    html = """
    <div id="sql-results" class="sql-results col-xs-12">
    </div>
    """
    if $("#interpreted-sql").exists()
      $("#interpreted-sql").after html
    else
      $("#sql-input").parents("form").after html
    rows = new Array()
    i = 0
    for statement in statements
      results = Object.toArray statement.result
      if results.length is 0
        rowHtml = """
        <code>ZERO_RESULTS</code>
        """
        rows.push rowHtml
      else
        ++i
        k = 0
        for row in results
          ++k
          try
            rowData = JSON.stringify row
            rowData = rowData.replace /,"/mig, ", \""
            language = "json"
          catch
            rowData = "Unable to parse row"
            language = "text"
          rowHtml = """
          <div>
            #{i}.#{k}:
            <code class="language-#{language}">#{rowData}</code>
          </div>
          """
          rows.push rowHtml
    $("#sql-results").html rows.join("<br/><br/>")
    Prism.highlightAll()
    false
  .fail (result, status) ->
    console.error result, status
    console.warn "Couldn't hit target"
    handleSqlError "Problem talking to the server, please try again"
    false
  false


$ ->
  html = """
  <paper-icon-button icon="icons:code" id="launch-term" title="Directly Query Database" data-toggle="tooltip">
  </paper-icon-button>
  """
  $("#git-footer").append html
  $("#launch-term").click ->
    loadTerminalDialog.debounce()
  false
