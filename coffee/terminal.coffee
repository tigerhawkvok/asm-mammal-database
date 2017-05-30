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
                        placeholder="SQL query here"></textarea>
            </div>
          </form>
          <p class="col-xs-12">Interpreted Query:</p>
          <code class="language-sql" id="interpreted-sql"></code>
        </div>
      </paper-dialog-scrollable>
      <div class="buttons">
        <paper-button dialog-dimiss>Close</paper-button>
      </div>
    </paper-dialog>
      """
      $("body").append html
      # Events
      $("#sql-query-dialog").find("form").submit (e) ->
        e.preventDefault()
        executeQuery()
        false
      $("#sql-input").keyup (e) ->
        kc = if e.keyCode then e.keyCode else e.which
        if kc is 13
          return executeQuery()
        else
          # Copy the formatted string
          sql = $(this).val().trim()
          # Shortcuts
          sql = sql.replace /@@/mig, "`mammal_diversity_database`"
          sql = sql.replace /!@/mig, "SELECT * FROM `mammal_diversity_database`"
          codeBox = $("#interpreted-sql").get(0)
          $(codeBox).text sql
          Prism.highlightElement codeBox
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
      checkDependencies()
    $("head").append """<link href="bower_components/prism/themes/prism.css" rel="stylesheet" />"""
  false


executeQuery = ->
  ###
  #
  ###
  handleSqlError = (errorMessage = "Error") ->
    alertId = _asm.nacl.decode_utf8 _asm.nacl.crypto_hash_string errorMessage + Date.now()
    html = """
<div class="alert alert-danger alert-dismissable col-xs-8 center-block" role="alert" id="#{alertId}">
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
  query = $("#intepreted-sql").text().trim()
  if isNull query
    return handleSqlError "Sorry, you can't use an empty query"
  args =
    sql_query: post64 query
    action: query
    dwc: darwinCoreOnly ? false
  $.post "#{uri.urlString}api.php", buildQuery args, "json"
  .done (result) ->
    console.log "Got result", result
    false
  .fail (result, status) ->
    console.error result, status
    console.warn "Couldn't hit target"
    handlSqlError "Problem talking to the server, please try again"
    false
  false


$ ->
  false
