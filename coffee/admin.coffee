###
# The main coffeescript file for administrative stuff
# Triggered from admin-page.html
###
adminParams = new Object()
adminParams.apiTarget = "admin-api.php"
adminParams.adminPageUrl = "https://mammaldiversity.org/admin-page.html"
adminParams.loginDir = "admin/"
adminParams.loginApiTarget = "#{adminParams.loginDir}async_login_handler.php"

loadAdminUi = ->
  ###
  # Main wrapper function. Checks for a valid login state, then
  # fetches/draws the page contents if it's OK. Otherwise, boots the
  # user back to the login page.
  ###
  console.log "Loading admin UI"
  try
    verifyLoginCredentials (data) ->
      # Post verification
      cookieName = "#{uri.domain}_name"
      cookieFullName = "#{uri.domain}_fullname"
      adminParams.cookieName = cookieName
      adminParams.cookieFullName = cookieFullName
      mainHtml = """
      <h3 class="col-xs-12">
        Welcome, #{$.cookie(cookieName)}
        <span id="pib-wrapper-settings" class="pib-wrapper" data-toggle="tooltip" title="User Settings" data-placement="bottom">
          <paper-icon-button icon='settings-applications' class='click' data-url='#{data.login_url}'></paper-icon-button>
        </span>
        <span id="pib-wrapper-exit-to-app" class="pib-wrapper" data-toggle="tooltip" title="Go to SADB app" data-placement="bottom">
          <paper-icon-button icon='exit-to-app' class='click' data-url='#{uri.urlString}' id="app-linkout"></paper-icon-button>
        </span>
      </h3>
      <div id='admin-actions-block' class="col-xs-12">
        <div class='bs-callout bs-callout-info'>
          <p>Please be patient while the administrative interface loads.</p>
        </div>
      </div>
      """
      $("main #main-body").html(mainHtml)
      # $(".pib-wrapper").tooltip()
      bindClicks()
      ###
      # Render out the admin UI
      # We want a search box that we pipe through the API
      # and display the table out for editing
      ###
      searchForm = """
      <form id="admin-search-form" onsubmit="event.preventDefault()" class="row">
        <div class="col-xs-7 col-sm-8">
          <paper-input label="Search for species" id="admin-search" name="admin-search" required autofocus floatingLabel></paper-input>
        </div>
        <div class="col-xs-2 col-lg-1">
          <paper-fab id="do-admin-search" icon="search" raisedButton class="asm-blue"></paper-fab>
        </div>
        <div class="col-xs-2 col-lg-1">
          <paper-fab id="do-admin-add" icon="add" raisedButton class="asm-blue" title="Create New Taxon" data-toggle="tooltip"></paper-fab>
        </div>
        <div class="col-offset-lg-2">
          <!-- Placeholder -->
        </div>
      </form>
      <div id='search-results' class="row"></div>
      """
      $("#admin-actions-block").html("<div class='col-xs-12'>#{searchForm}</div>")
      $("#admin-search-form").submit (e) ->
        e.preventDefault()
      $("#admin-search").keypress (e) ->
        if e.which is 13 then renderAdminSearchResults()
      $("#do-admin-search").click ->
        renderAdminSearchResults()
      $("#do-admin-add").click ->
        createNewTaxon()
      bindClickTargets()
      console.info "Successfully validated user"
      false
  catch e
    console.error "Couldn't check status - #{e.message}"
    console.warn e.stack
    $("main #main-body").html("<div class='bs-callout bs-callout-danger col-xs-12'><h4>Application Error</h4><p>There was an error in the application. Please refresh and try again. If this persists, please contact administration.</p></div>")
  false


verifyLoginCredentials = (callback) ->
  ###
  # Checks the login credentials against the server.
  # This should not be used in place of sending authentication
  # information alongside a restricted action, as a malicious party
  # could force the local JS check to succeed.
  # SECURE AUTHENTICATION MUST BE WHOLLY SERVER SIDE.
  ###
  try
    hash = $.cookie("#{uri.domain}_auth")
    secret = $.cookie("#{uri.domain}_secret")
    link = $.cookie("#{uri.domain}_link")
  catch e
    console.warn "Unable to verify login credentials: #{e.message}"
    console.debug e.stack
  args = "hash=#{hash}&secret=#{secret}&dblink=#{link}"
  $.post adminParams.loginApiTarget, args, "json"
  .done (result) ->
    console.log "Server called back from login credential verification", result
    if result.status is true
      $(".logged-in-values").removeAttr "hidden"
      $(".logged-in-hidden").attr "hidden", "hidden"
      cookieFullName = "#{uri.domain}_fullname"
      $("header .fill-user-fullname").text $.cookie cookieFullName
      if typeof callback is "function"
        callback(result)
    else
      $(".logged-in-values").remove()
      if typeof callback is "function" and _asm.inhibitRedirect isnt true
        unless isNull result.login_url
          goTo(result.login_url)
        else
          $("main #main-body").html("<div class='bs-callout-danger bs-callout col-xs-12'><h4>Couldn't verify login</h4><p>There's currently a server problem. Try back again soon.</p><p>The server said:</p><code>#{result.error}</code></div>")
      else
        console.log "Login credentials checked -- not logged in"
  .fail (result,status) ->
    # Throw up some warning here
    $("main #main-body").html("<div class='bs-callout-danger bs-callout col-xs-12'><h4>Couldn't verify login</h4><p>There's currently a server problem. Try back again soon.</p></div>")
    console.log(result,status)
    false
  false




renderAdminSearchResults = (overrideSearch, containerSelector = "#search-results") ->
  ###
  # Takes parts of performSearch() but only in the admin context
  ###
  s = $("#admin-search").val()
  if isNull(s)
    if typeof overrideSearch is "object"
      s = "#{overrideSearch.genus} #{overrideSearch.species}"
    else
      toastStatusMessage("Please enter a search term")
      return false
  animateLoad()
  $("#admin-search").blur()
  # Remove periods from the search
  s = s.replace(/\./g,"")
  s = prepURI(s.toLowerCase())
  args = "q=#{s}&loose=true"
  # Also update the link
  b64s = Base64.encodeURI(s)
  newLink = "#{uri.urlString}##{b64s}"
  $("#app-linkout").attr("data-url",newLink)
  $.get searchParams.targetApi, args, "json"
  .done (result) ->
    if result.status isnt true or result.count is 0
      stopLoadError()
      if isNull(result.human_error)
        toastStatusMessage("Your search returned no results. Please try again.")
      else
        toastStatusMessage(result.human_error)
      return false
    # Now, take the results and format them
    data = result.result
    html = ""
    htmlHead = "<table id='cndb-result-list' class='table table-striped table-hover'>\n\t<thead class='cndb-row-headers'>"
    htmlClose = "</table>"
    # We start at 0, so we want to count one below
    targetCount = toInt(result.count)-1
    colClass = null
    bootstrapColCount = 0
    # Sort the column output
    requiredKeyOrder = [
      "id"
      "genus"
      "species"
      "subspecies"
      ]
    origData = data
    data = new Object()
    for i, row of origData
      data[i] = new Object()
      for key in requiredKeyOrder
        data[i][key] = row[key]
    # Render the results
    for i, row of data
      if toInt(i) is 0
        j = 0
        htmlHead += "\n<!-- Table Headers - #{Object.size(row)} entries -->"
        console.debug "Got row", row
        for k, v of row
          niceKey = k.replace(/_/g," ")
          if k is "genus" or k is "species" or k is "subspecies"
            htmlHead += "\n\t\t<th class='text-center'>#{niceKey}</th>"
            bootstrapColCount++
          j++
          if j is Object.size(row)
            htmlHead += "\n\t\t<th class='text-center'>Edit</th>"
            bootstrapColCount++
            htmlHead += "\n\t\t<th class='text-center'>Delete</th>"
            bootstrapColCount++
            htmlHead += "\n\t\t<th class='text-center'>View</th>\n\t</thead>"
            bootstrapColCount++
            htmlHead += "\n<!-- End Table Headers -->"
            console.log("Got #{bootstrapColCount} display columns.")
            bootstrapColSize = roundNumber(12/bootstrapColCount,0)
            colClass = "col-md-#{bootstrapColSize}"
      taxonQuery = "#{row.genus.trim()}+#{row.species.trim()}"
      if not isNull(row.subspecies)
        taxonQuery = "#{taxonQuery}+#{row.subspecies.trim()}"
      htmlRow = "\n\t<tr id='cndb-row#{i}' class='cndb-result-entry' data-taxon=\"#{taxonQuery}\">"
      l = 0
      for k, col of row
        if isNull row.genus
          # Next iteration
          return true
        if k is "genus" or k is "species" or k is "subspecies"
          htmlRow += "\n\t\t<td id='#{k}-#{i}' class='#{k} #{colClass}'><span>#{col}</span></td>"
        l++
        if l is Object.size row
          htmlRow += "\n\t\t<td id='edit-#{i}' class='edit-taxon #{colClass} text-center'><paper-icon-button icon='image:edit' class='edit' data-taxon='#{taxonQuery}'></paper-icon-button></td>"
          htmlRow += "\n\t\t<td id='delete-#{i}' class='delete-taxon #{colClass} text-center'><paper-icon-button icon='icons:delete-forever' class='delete-taxon-button fadebg' data-taxon='#{taxonQuery}' data-database-id='#{row.id}'></paper-icon-button></td>"
          htmlRow += "\n\t\t<td id='visit-listing-#{i}' class='view-taxon #{colClass} text-center'><paper-icon-button icon='icons:visibility' class='view-taxon-button fadebg click' data-href='#{uri.urlString}species-account.php?genus=#{row.genus.trim()}&species=#{row.species.trim()}' data-newtab='true'></paper-icon-button></td>"
          htmlRow += "\n\t</tr>"
          html += htmlRow
      if toInt(i) is targetCount
        html = htmlHead + html + htmlClose
        $(containerSelector).html(html)
        console.log("Processed #{toInt(i)+1} rows")
        $(".edit").click ->
          taxon = $(this).attr('data-taxon')
          lookupEditorSpecies(taxon)
        $(".delete-taxon-button").click ->
          taxon = $(this).attr('data-taxon')
          taxaId = $(this).attr('data-database-id')
          deleteTaxon(taxaId)
        bindClicks()
        # Set the argument to the search result
        try
          taxonSplit = s.split(" ")
          taxonObj =
            genus: taxonSplit[0]
            species: taxonSplit[1] ? ""
            subspecies: taxonSplit[2] ? ""
          fragment = jsonTo64 taxonObj
          try
            newPath = uri.o.attr("base") + uri.o.attr("path")
            setHistory "#{newPath}##{fragment}"
        stopLoad()
  .fail (result,status) ->
    console.error("There was an error performing the search")
    console.warn(result,error,result.statusText)
    console.warn "#{searchParams.targetApi}?#{args}"
    error = "#{result.status}::#{result.statusText}"
    stopLoadError("Couldn't execute the search - #{error}")



fetchEditorDropdownContent = (column = "simple_linnean_goup", columnLabel, updateDom = true, localSave = true) ->
  ###
  # Ping the server for a list of unique entries for a given column
  ###
  unless typeof _asm?.dropdownPopulation is "object"
    unless typeof _asm is "object"
      window._asm = new Object()
    _asm.dropdownPopulation = new Object()
  colIdLabel = column.replace /\_/g, "-"
  if isNull columnLabel
    columnLabel = column.replace(/\_/g, " ").toTitleCase()
  # Prepopulate for an instant result if needed
  _asm.dropdownPopulation[column] =
    html: """<paper-input label="#{columnLabel}" id="edit-#{colIdLabel}" name="edit-#{colIdLabel}" class="#{column}" floatingLabel></paper-input>"""
  # Actually do the lookup
  $.get searchParams.targetApi, "get_unique=true&col=#{column}", "json"
  .done (result) ->
    if result.status isnt true
      console.warn "Didn't get a valid set of values for column '#{column}': #{result.error}"
      return false
    # Build the HTML
    valueArray = Object.toArray result.values
    listHtml = ""
    for value in valueArray
      listHtml += """
      <paper-item data-value="#{value}" data-column="#{column}">#{value}</paper-item>\n
      """
    html = """
    <section class="row filled-editor-dropdown">
    <div class="col-xs-9">
      <paper-dropdown-menu label="#{columnLabel}" id="edit-#{colIdLabel}" name="edit-#{colIdLabel}" class="#{column}" data-column="#{column}">
        <paper-listbox class="dropdown-content">
          #{listHtml}
        </paper-listbox>
      </paper-dropdown-menu>
    </div>
    <div class="col-xs-3">
      <paper-icon-button class="add-col-value" data-column=#{column} icon="icons:add-circle" title="Add new #{columnLabel}" data-toggle="tooltip"></paper-icon-button>
    </div>
    </section>
    """
    # Set the local value
    if localSave
      _asm.dropdownPopulation[column] =
        values: valueArray
        html: html
        selector: "#edit-#{colIdLabel}"
    if updateDom
      # Try to update the DOM object
      selector = "#edit-#{colIdLabel}"
      if $(selector).exists()
        $(selector).replaceWith html
    false
  .fail (result, error) ->
    console.warn "Unable to get dropdown content for '#{column}'"
    console.warn result, error
    _asm.dropdownPopulation[column] =
      html: """<paper-input label="#{columnLabel}" id="edit-#{colIdLabel}" name="edit-#{colIdLabel}" class="#{column}" floatingLabel></paper-input>"""
  false



licenseHelper = (selector = "#edit-image-license-dialog") ->
  ###
  # License filler
  ###
  $(selector).unbind()
  _asm._setLicenseDialog = (el) ->
    targetColumn = $(el).attr "data-column"
    if isNull targetColumn
      console.error "Unable to show dialog -- invalud column designator"
      return false
    console.debug "Add column fired -- target is #{targetColumn}"
    # Create the column dialog
    $("paper-dialog#set-license-value").remove()
    currentLicenseName = $(selector).attr "data-license-name"
    currentLicenseUrl = $(selector).attr "data-license-url"
    html = """
    <paper-dialog id="set-license-value" data-column="#{targetColumn}" modal>
      <h2>Set License</h2>
      <paper-dialog-scrollable>
        <paper-input class="new-license-name license-field" label="License Name" floatingLabel autofocus value="#{currentLicenseName}" required autovalidate></paper-input>
        <paper-input class="new-license-url license-field" label="License URL" floatingLabel value="#{currentLicenseUrl}" required autovalidate></paper-input>
      </paper-dialog-scrollable>
      <div class="buttons">
        <paper-button dialog-dismiss>Cancel</paper-button>
        <paper-button class="add-value">Set</paper-button>
      </div>
    </paper-dialog>
    """
    $("body").append html
    # URL matching pattern
    #
    urlPattern = """((?:https?)://(?:(?:(?:[0-9]+\\.){3}[0-9]+|(?:[0-9a-f]+:){6,8}|(?:[\\w~\\-]{2,}\\.)+[\\w]{2,}|localhost))/?(?:[\\w~\\-]*/?)*(?:(?:\\.\\w+)?(?:\\?(?:\\w+=\\w+&?)*)?))(?:#[\\w~\\-]+)?"""
    p$("paper-input.new-license-url").pattern = urlPattern
    p$("paper-input.new-license-url").errorMessage = "This must be a valid URL"
    p$("paper-input.new-license-name").errorMessage = "This cannot be empty"
    _asm._updateLicense = ->
      $("paper-icon-button#edit-image-license-dialog")
      .attr "data-license-name", p$("paper-input.new-license-name").value
      .attr "data-license-url", p$("paper-input.new-license-url").value
      text = "#{p$("paper-input.new-license-name").value} @ #{p$("paper-input.new-license-url").value}"
      p$("#edit-image-license").value = text
      $("#edit-image-license")
      .attr "data-license-name", p$("paper-input.new-license-name").value
      .attr "data-license-url", p$("paper-input.new-license-url").value
      p$("#set-license-value").close()
      false
    $("#set-license-value paper-button.add-value").click ->
      # Are the fields valid?
      isReady = true
      for field in $("#set-license-value .license-field")
        p$(field).validate()
        if p$(field).invalid
          isReady = false
      unless isReady
        return false
      console.debug "isReady", isReady
      try
        _asm._updateLicense.debounce 50
      catch
        console.warn "Couldn't debounce save new col call"
        stopLoadError "There was a problem saving this data"
      false
    $("#set-license-value").on "iron-overlay-opened", ->
      p$(this).refit()
      delay 100, =>
        p$(this).refit()
    p$("#set-license-value").open()
    false
  $(selector).click ->
    console.debug "Set License clicked"
    _asm._setLicenseDialog.debounce 50, null, null, this
    false


newColumnHelper = (selector = ".add-col-value") ->
  $(selector).unbind()
  _asm._addColumnDialog = (el) ->
    targetColumn = $(el).attr "data-column"
    if isNull targetColumn
      console.error "Unable to show dialog -- invalud column designator"
      return false
    console.debug "Add column fired -- target is #{targetColumn}"
    # Create the column dialog
    $("paper-dialog#add-column-value").remove()
    html = """
    <paper-dialog id="add-column-value" data-column="#{targetColumn}" modal>
      <h2>Add New <code>#{targetColumn.replace /[\_-]/g, " "}</code> Value</h2>
      <paper-dialog-scrollable>
        <paper-input class="new-col-value" label="Data Value" floatingLabel autofocus></paper-input>
      </paper-dialog-scrollable>
      <div class="buttons">
        <paper-button dialog-dismiss>Cancel</paper-button>
        <paper-button class="add-value">Add</paper-button>
      </div>
    </paper-dialog>
    """
    $("body").append html
    _asm._saveNewCol = ->
      newValue = $("#add-column-value paper-input.new-col-value").val()
      console.log "Going to test and add '#{newValue}'"
      # validate the new value
      # Make sure it's not a duplicate
      if newValue in _asm.dropdownPopulation[targetColumn].values
        # Set an error
        console.warn "Invalid value: already exists"
        p$("#add-column-value paper-input.new-col-value").errorMessage = "This value already exists"
        p$("#add-column-value paper-input.new-col-value").invalid = true
        p$("#add-column-value").refit()
        return false
      # Append the paper-item to the listbox contents
      item = document.createElement "paper-item"
      item.setAttribute "data-value", newValue
      item.setAttribute "data-column", targetColumn
      item.textContent = newValue
      listHtml = """
      <paper-item data-value="#{newValue}" data-column="#{targetColumn}">#{newValue}</paper-item>\n
      """
      _asm.dropdownPopulation[targetColumn].values.push newValue
      # Sort the array
      _asm.dropdownPopulation[targetColumn].values.sort()
      listbox = p$("paper-dropdown-menu[data-column='#{targetColumn}'] paper-listbox")
      Polymer.dom(listbox).appendChild item
      # Select it
      delay 250, ->
        $("paper-dropdown-menu[data-column='#{targetColumn}']").polymerSelected newValue, true
        p$("#add-column-value").close()
      false
    $("#add-column-value paper-button.add-value").click ->
      try
        _asm._saveNewCol.debounce 50
      catch
        console.warn "Couldn't debounce save new col call"
        stopLoadError "There was a problem saving this data"
      false
    $("#add-column-value paper-input").keyup (e) ->
      kc = if e.keyCode then e.keyCode else e.which
      if kc is 13
        try
          _asm._saveNewCol.debounce 50
        catch
          console.warn "Couldn't debounce save new col call"
          stopLoadError "There was a problem saving this data"
      false
    p$("#add-column-value").open()
    false
  $(selector).click ->
    console.debug "Add column clicked"
    _asm._addColumnDialog.debounce 50, null, null, this
    false



prefetchEditorDropdowns = ->
  needCols =
    major_type: "Clade (eg., boreoeutheria)"
    major_subtype: "Sub-Clade (eg., euarchontoglires)"
    linnean_order: null
    linnean_family: null
    simple_linnean_group: "Common Group (eg., metatheria)"
    simple_linnean_subgroup: "Common type (eg., bat)"
  for col, label of needCols
    fetchEditorDropdownContent col, label
  false

window.prefetchEditorDropdowns = prefetchEditorDropdowns

loadModalTaxonEditor = (extraHtml = "", affirmativeText = "Save") ->
  ###
  # Load a modal taxon editor
  ###
  #  | <a href="#" "onclick='window.open(this.href); return false;' onkeypress='window.open(this.href); return false;'">Syntax Cheat Sheet</a>
  today = new Date()
  prettyDate = today.toISOString().split("T")[0]
  editHtml = """
  <paper-input label="Genus" id="edit-genus" name="edit-genus" class="genus" floatingLabel></paper-input>
  <paper-input label="Species" id="edit-species" name="edit-species" class="species" floatingLabel></paper-input>
  <paper-input label="Subspecies" id="edit-subspecies" name="edit-subspecies" class="subspecies" floatingLabel></paper-input>
  <paper-input label="Common Name" id="edit-common-name" name="edit-common-name"  class="common_name" floatingLabel></paper-input>
  <paper-input label="Common Name Source" id="edit-common-name-source" name="edit-common-name-source"  class="common_name_source" floatingLabel readonly></paper-input>
  <div class="row">
    <paper-input label="Deprecated Scientific Names" id="edit-deprecated-scientific" name="edit-depreated-scientific" floatingLabel aria-describedby="deprecatedHelp" data-column="deprecated_scientific" class="col-xs-10" readonly></paper-input>
    <div class="col-xs-2">
      <paper-icon-button icon="icons:create" id="fire-deprecated-editor" title="Edit deprecated scientifics" data-toggle="tooltip"></paper-icon-button>
    </div>
    <span class="help-block col-xs-12" id="deprecatedHelp">Click the edit button to fill the old names.</span>
  </div>
  #{_asm.dropdownPopulation.major_type.html}
  #{_asm.dropdownPopulation.major_subtype.html}
  #{_asm.dropdownPopulation.linnean_order.html}
  #{_asm.dropdownPopulation.linnean_family.html}
  #{_asm.dropdownPopulation.simple_linnean_group.html}
  #{_asm.dropdownPopulation.simple_linnean_subgroup.html}
  <paper-input label="Genus authority" id="edit-genus-authority" name="edit-genus-authority" class="genus_authority" floatingLabel></paper-input>
  <paper-input label="Genus authority year" id="edit-gauthyear" name="edit-gauthyear" floatingLabel></paper-input>
  <paper-input label="Genus authority citation" id="edit-genus-authority-citation" name="edit-genus-authority-citation" class="citation-input" floatingLabel></paper-input>
  <iron-label>
    Use Parenthesis for Genus Authority
    <paper-toggle-button id="genus-authority-parens"  checked="false"></paper-toggle-button>
  </iron-label>
  <paper-input label="Species authority" id="edit-species-authority" name="edit-species-authority" class="species_authority" floatingLabel></paper-input>
  <paper-input label="Species authority year" id="edit-sauthyear" name="edit-sauthyear" floatingLabel></paper-input>
  <paper-input label="Species authority citation" id="edit-species-authority-citation" name="edit-species-authority-citation" class="citation-input" floatingLabel></paper-input>
  <iron-label>
    Use Parenthesis for Species Authority
    <paper-toggle-button id="species-authority-parens" checked="false"></paper-toggle-button>
  </iron-label>
  <br/><br/>
  <paper-input label="ASM ID Number" id="edit-internal-id" name="edit-internal-id" floatingLabel></paper-input>
  <br/>
  <span class="help-block" id="notes-help">You can write your notes and entry in Markdown. (<a href="https://daringfireball.net/projects/markdown/syntax" "onclick='window.open(this.href); return false;' onkeypress='window.open(this.href); return false;'">Official Full Syntax Guide</a>)</span>
  <br/><br/>
  <h3 class='text-muted'>Taxon Notes <small>(optional)</small></h3>
  <iron-autogrow-textarea id="edit-notes" rows="5" aria-describedby="notes-help" placeholder="Notes" class="markdown-region"  data-md-field="notes-markdown-preview">
    <textarea placeholder="Notes" id="edit-notes-textarea" name="edit-notes-textarea" aria-describedby="notes-help" rows="5"></textarea>
  </iron-autogrow-textarea>
  <marked-element id="notes-markdown-preview" class="markdown-preview">
    <div class="markdown-html"></div>
  </marked-element>
  <br/><br/>
  <h3 class='text-muted'>Main Taxon Entry</h3>
  <iron-autogrow-textarea id="edit-entry" rows="5" aria-describedby="notes-help" placeholder="Entry" class="markdown-region" data-md-field="entry-markdown-preview">
    <textarea placeholder="Entry" id="edit-entry-textarea" name="edit-entry-textarea" aria-describedby="entry-help" rows="5"></textarea>
  </iron-autogrow-textarea>
  <marked-element id="entry-markdown-preview" class="markdown-preview">
    <div class="markdown-html"></div>
  </marked-element>
  <paper-input label="Data Source" id="edit-source" name="edit-source" floatingLabel></paper-input>
  <paper-input label="Data Citation (Markdown Allowed)" id="edit-citation" name="edit-citation" floatingLabel></paper-input>
  <div id="upload-image"></div>
  <span class="help-block" id="upload-image-help">You can drag and drop an image above, or enter its server path below.</span>
  <paper-input label="Image" id="edit-image" name="edit-image" floatingLabel aria-describedby="imagehelp"></paper-input>
    <span class="help-block" id="imagehelp">The image path here should be relative to the <code>public_html/</code> directory. Check the preview below.</span>
  <paper-input label="Image Caption" id="edit-image-caption" name="edit-image-caption" floatingLabel></paper-input>
  <paper-input label="Image Credit" id="edit-image-credit" name="edit-image-credit" floatingLabel></paper-input>
  <section class="row license-region">
    <div class="col-xs-9">
      <paper-input label="Image License" id="edit-image-license" name="edit-image-license" data-license-name="" data-license-url="" floatingLabel readonly></paper-input>
    </div>
    <div class="col-xs-3">
      <paper-icon-button icon="icons:create" id="edit-image-license-dialog" data-license-name="" data-license-url="" data-column="image_license" data-toggle='tooltip' title="Edit License"></paper-icon-button>
    </div>
  </section>
  <paper-input label="Taxon Credit" id="edit-taxon-credit" name="edit-taxon-credit" floatingLabel aria-describedby="taxon-credit-help" value="#{$.cookie(adminParams.cookieFullName)}"></paper-input>
  <paper-input label="Taxon Credit Date" id="edit-taxon-credit-date" name="edit-taxon-credit-date" floatingLabel value="#{prettyDate}"></paper-input>
  <span class="help-block" id="taxon-credit-help">This will be displayed as "Entry by <span class='taxon-credit-preview'></span> on <span class='taxon-credit-date-preview'></span>."</span>
  #{extraHtml}
  <input type="hidden" name="edit-taxon-author" id="edit-taxon-author" value="" />
  """
  html = """
  <paper-dialog modal id='modal-taxon-edit' entry-animation="scale-up-animation" exit-animation="fade-out-animation">
    <h2 id="editor-title">Taxon Editor</h2>
    <paper-dialog-scrollable id='modal-taxon-editor'>
      #{editHtml}
    </paper-dialog-scrollable>
    <div class="buttons">
      <paper-button id='close-editor' dialog-dismiss>Cancel</paper-button>
      <paper-button id='duplicate-taxon'>Duplicate</paper-button>
      <paper-button id='save-editor'>#{affirmativeText}</paper-button>
    </div>
  </paper-dialog>
  """
  if $("#modal-taxon-edit").exists()
    $("#modal-taxon-edit").remove()
  $("#search-results").after(html)
  try
    newColumnHelper()
  catch e
    console.warn "Couldn't bind columns: #{e.message}"
    console.warn e.stack
  try
    licenseHelper()
  catch e
    console.warn "Couldn't set license helper: #{e.message}"
    console.warn e.stack
  try
    deprecatedHelper()
    $("#fire-deprecated-editor").click ->
      elTarget = p$("#edit-deprecated-scientific")
      _asm._setDeprecatedDialog.debounce null, null, null, elTarget
  catch e
    console.warn "Couldn't set deprecated helper: #{e.message}"
    console.warn e.stack
  try
    $(".citation-input").keyup ->
      validateCitation this
  handleDragDropImage()
  # # Bind the autogrow
  # # https://elements.polymer-project.org/elements/iron-autogrow-textarea
  # try
  #   noteArea = d$("#edit-notes").get(0)
  #   d$("#edit-notes-autogrow").attr("target",noteArea)
  # catch e
  #   console.error("Couldn't bind autogrow")
  # Reset the bindings
  $("#modal-taxon-edit").unbind()
  d$("#save-editor").unbind()
  d$("#duplicate-taxon")
  .unbind()
  .click ->
    createDuplicateTaxon()




deprecatedHelper = (selector = "#edit-deprecated-taxon-dialog") ->
  ###
  # Helper for the otherwise JSON entries of the deprecated
  ###
  $(selector).unbind()
  _asm._setDeprecatedDialog = (el) ->
    targetColumn = $(el).attr "data-column"
    if isNull targetColumn
      console.error "Unable to show dialog -- invalud column designator"
      return false
    console.debug "Setup deprecated fired -- target is #{targetColumn}"
    dialogSelector = "#set-deprecated-taxa"
    $(dialogSelector).remove()
    currentTaxon =
      genus: p$("#edit-genus").value ? ""
      species: p$("#edit-species").value ? ""
    currentTaxonAuthority =
      genus:
        authority: p$("#edit-genus-authority").value ? ""
        year: p$("#edit-gauthyear").value ? ""
        parens: if p$("#genus-authority-parens").checked then "checked" else ""
      species:
        authority: p$("#edit-species-authority").value ? ""
        year: p$("#edit-gauthyear").value ? ""
        parens: if p$("#species-authority-parens").checked then "checked" else ""
    _asm._updateDeprecatedListItem = (json64attr = undefined) ->
      if isNull json64attr
        # Fetch it
        json64attr = $("#deprecated-taxon-json").val()
      try
        jDep = JSON.parse decode64 json64attr
        console.log "Rendering with", jDep
        listEl = new Array()
        for oldTaxon, authorityString of jDep
          try
            # Potential fixes
            oldTaxon = oldTaxon.replace /\-/g, " "
          authorityParts = authorityString.split(":")
          authorities = authorityParts[0]
          prettyElement = """ #{oldTaxon} <iron-icon icon="icons:arrow-forward"></iron-icon> #{authorities.toTitleCase()} in #{authorityParts[1]}"""
          listEl.push prettyElement
        list = "<li>#{listEl.join("</li>\n<li>")}</li>"
      catch e
        console.warn "Didn't parse JSON: #{e.message}"
        console.warn e.stack
        list = "<em>No deprecated identifiers</em>"
      list
    json64Orig = $("#edit-deprecated-scientific").attr "data-json"
    list = _asm._updateDeprecatedListItem json64Orig
    html = """
    <paper-dialog id="#{dialogSelector.slice(1)}" data-column="#{targetColumn}" modal>
      <h2>Set Deprecated Taxa</h2>
      <paper-dialog-scrollable>
        <div class="row">
          <h3 class="col-xs-12">Alternate Taxon Names</h3>
          <ul id="deprecated-taxon-list" class="col-xs-11 col-xs-offset-1">
            #{list}
          </ul>
          <input type="hidden" value="#{json64Orig}" id="deprecated-taxon-json"/>
        </div>
        <div class="form">
          <div class="row update-old-taxon">
            <paper-input class="col-xs-12" value="#{currentTaxon.genus}" label="Old Genus" placeholder="#{currentTaxon.genus}" id="dialog-update-genus" required autovalidate></paper-input>
            <paper-input class="col-xs-12" value="#{currentTaxon.species}" label="Old Species" placeholder="#{currentTaxon.species}" id="dialog-update-species" required autovalidate></paper-input>
            <paper-input class="col-xs-6" value="#{currentTaxonAuthority.genus.authority}" label="Old Authority" placeholder="#{currentTaxonAuthority.genus.authority}" required autovalidate floatingLabel id="dialog-update-authority"></paper-input>
            <paper-input class="col-xs-6" value="#{currentTaxonAuthority.genus.year}" label="Old Year" placeholder="#{currentTaxonAuthority.genus.year}" pattern="[0-9]{4}" error-message="Invalid Year" required autovalidate floatingLabel id="dialog-update-year"></paper-input>
          </div>
          <div class="row">
            <div class="col-xs-12 text-right pull-right">
              <button class="btn btn-primary" id="add-to-json-list">Add To List</button>
            </div>
          </div>
        </div>
      </paper-dialog-scrollable>
      <div class="buttons">
        <paper-button dialog-dismiss>Cancel</paper-button>
        <paper-button class="add-value">Set</paper-button>
      </div>
    </paper-dialog>
    """
    $("body").append html
    p$(dialogSelector).open()
    addToListClickEvent = ->
      # Make sure everything is valid
      canProceed = true
      for field in $("#{dialogSelector} paper-input")
        p$(field).errorMessage = "This field can't be empty"
        p$(field).validate()
        if p$(field).invalid
          canProceed = false
      unless canProceed
        return false
      # Update the JSON
      json64attr = $("#deprecated-taxon-json").val()
      try
        jDep = JSON.parse decode64 json64attr
        if typeof jDep isnt "object"
          jDep = new Object()
      catch
        jDep = new Object()
      oldTaxon =
        genus: p$("#dialog-update-genus").value.trim().toTitleCase()
        species: p$("#dialog-update-species").value.trim()
        authority: p$("#dialog-update-authority").value.trim()
        year: toInt p$("#dialog-update-year").value.trim()
      # Ensure that the taxon doesn't match the current one
      if currentTaxon.genus.toLowerCase() is oldTaxon.genus.toLowerCase()
        if currentTaxon.species.toLowerCase() is oldTaxon.species.toLowerCase()
          console.warn "Taxon is the same as the primary"
          p$("#dialog-update-genus").errorMessage = "This name is the same as the current one"
          p$("#dialog-update-genus").invalid = true
          p$("#dialog-update-species").errorMessage = "This name is the same as the current one"
          p$("#dialog-update-species").invalid = true
          return false
      # Check the year
      linnaeusYear = 1707 # Linnaeus's birth year
      today = new Date()
      if oldTaxon.year < linnaeusYear or oldTaxon.year > today.getFullYear()
        console.warn "Invalid year"
        p$("#dialog-update-year").errorMessage = "The year must be after #{linnaeusYear} and on or before #{today.getFullYear()}"
        p$("#dialog-update-year").invalid = true
        return false
      # Construct the strings
      oldTaxonString = "#{oldTaxon.genus} #{oldTaxon.species}"
      oldAuthorityString = "#{oldTaxon.authority}:#{oldTaxon.year}"
      console.log "Got strings", oldTaxonString, oldAuthorityString
      jDep[oldTaxonString] = oldAuthorityString
      console.log "Object:", jDep
      jString = JSON.stringify jDep
      console.log "Stringified:", jString
      $("#deprecated-taxon-json").val encode64 jString
      # Get the list
      list = _asm._updateDeprecatedListItem()
      $("#deprecated-taxon-list").html list
      false
    $("#{dialogSelector} #add-to-json-list").click ->
      addToListClickEvent.debounce 75
      false
    _asm._updateDeprecated = ->
      # Make sure JSON is smart, prettify for entry
      json64attr = $("#deprecated-taxon-json").val()
      unless isNull json64attr
        json = decode64 json64attr
      else
        json = "{}"
      prettyEntry = json.slice 1, -1
      p$(el).value = prettyEntry
      false
    $("#{dialogSelector} .buttons paper-button.add-value").click ->
      _asm._updateDeprecated.debounce()
      p$("#{dialogSelector}").close()
      false
    false
  false


renderDeprecatedFromDatabase = ->
  false


fillEmptyCommonName = ->
  false



validateNewTaxon = ->
  ###
  #
  ###
  taxonExistsHelper = (invalid = true) ->
    editFields = [
      "genus"
      "species"
      "subspecies"
      ]
    for fieldLabel in editFields
      selector = "#edit-#{fieldLabel}"
      if invalid
        p$(selector).invalid = true
        p$(selector).errorMessage = "This taxon already exists in the database"
        p$("#save-editor").disabled = true
      else
        p$(selector).invalid = false
        p$("#save-editor").disabled = false
    false
  # Check the field for the taxon name
  taxon =
    genus: p$("#edit-genus").value
    species: p$("#edit-species").value
    subspecies: unless isNull p$("#edit-subspecies").value then p$("#edit-subspecies").value else ""
  args = "q=#{taxon.genus}+#{taxon.species}"
  taxonString = "#{taxon.genus} #{taxon.species}"
  unless isNull taxon.subspecies
    args += "+#{taxon.subspecies}"
    taxonString += " #{taxon.subspecies}"
  # Async ping for duplication
  $.get searchParams.apiPath, "#{args}&dwc_only=true", "json"
  .done (result) ->
    if result.status isnt true
      console.error "Problem validating taxon:", result
      return false
    for testTaxon in Object.toArray result.result
      # See if the objects match up
      if testTaxon.genus.toLowerCase() is taxon.genus.toLowerCase()
        # Same genus
        if testTaxon.specificEpithet.toLowerCase() is taxon.species.toLowerCase()
          # Same species
          try
            if isNull(taxon.subspecies) and isNull(testTaxon.subspecificEpithet)
              console.warn "Taxon sp already exists in DB"
              #taxonExistsHelper()
              return taxonExistsHelper()
            else if taxon.subspecies.toLowerCase() is testTaxon.subspecificEpithet.toLowerCase()
              console.warn "Taxon ssp already exists in DB"
              #taxonExistsHelper()
              return taxonExistsHelper()
            else
              # Non-empty ssp on one, empty on another, or no match
              continue
        else
          # Different species
          continue
      else
        # Different genera
        continue
    # The taxon doesn't already exist.
    taxonExistsHelper false
    # Check the IUCN for its info.
    # Async ping for IUCN data
    args = "missing=true&genus=#{taxon.genus}&species=#{taxon.species}&prefetch=true"
    #$.get _asm.affiliateQueryUrl.iucnRedlist, encodeURIComponent(taxonString), "json"
    $.get searchParams.apiPath, args, "json"
    .done (result) ->
      unless isNumeric result.id
        console.error "Unable to find IUCN result"
        return false
      # iucnData = result.result[0]
      # if isNull iucnData.taxonid
      #   console.warn "Couldn't find IUCN entry for taxon '#{taxonString}'", iucnData
      #   return false
      iucnData = result
      # Fill in IUCN data
      commonName = iucnData.main_common_name ? iucnData.common_name
      speciesAuthority = iucnData.species_authority
      genusAuthority = iucnData.genus_authority
      try
        authorityYear = JSON.parse iucnData.authority_year
        genusAuthorityYear = Object.keys(authorityYear)[0]
        speciesAuthorityYear = authorityYear[genusAuthorityYear]
      catch
        genusAuthorityYear = ""
        speciesAuthorityYear = ""
      p$("#edit-common-name").value = commonName
      p$("#edit-common-name-source").value = "iucn"
      p$("#edit-genus-authority").value = genusAuthority
      p$("#edit-species-authority").value = speciesAuthority
      p$("#edit-gauthyear").value = genusAuthorityYear
      p$("#edit-sauthyear").value = speciesAuthorityYear
      try
        p$("#genus-authority-parens").checked = iucnData.parens_auth_genus.toBool()
        p$("#species-authority-parens").checked = iucnData.parens_auth_species.toBool()
      # TODO
      console.log "Got", commonName, speciesAuthority, genusAuthority, authorityYear, genusAuthorityYear, speciesAuthorityYear
      false
    false
  .fail (result, status) ->
    console.error "FAIL_VALIDATE"
    false
  false



createNewTaxon = ->
  ###
  # Load a blank modal taxon editor, ready to make a new one
  ###
  animateLoad()
  loadModalTaxonEditor("","Create")
  d$("#editor-title").text("Create New Taxon")
  windowHeight = $(window).height() * .5
  d$("#modal-taxon-editor")
  .css("min-height","#{windowHeight}px")
  d$("#modal-taxon-editor div.scrollable").css("max-height","")
  d$("#modal-taxon-edit")
  .addClass("create-new-taxon")
  #.get(0).refit()
  # Remove the dupliate button
  d$("#duplicate-taxon").remove()
  # Append the editor value
  whoEdited = if isNull($.cookie("#{uri.domain}_fullname")) then $.cookie("#{uri.domain}_user") else $.cookie("#{uri.domain}_fullname")
  d$("#edit-taxon-author").attr("value",whoEdited)
  # Bind the save button
  d$("#save-editor")
  .click ->
    saveEditorEntry("new")
  $("#modal-taxon-edit").on "iron-overlay-opened", ->
    # Binding new taxon events
    console.log "Binding new taxon events"
    editFields = [
      "genus"
      "species"
      "subspecies"
      ]
    for fieldLabel in editFields
      selector = "#edit-#{fieldLabel}"
      $(selector).keyup ->
        validateNewTaxon.debounce()
    try
      # Fill the markdown previews
      entry = $(p$("#edit-entry").textarea).val()
      notes = $(p$("#edit-notes").textarea).val()
      p$("#entry-markdown-preview").markdown = entry
      p$("#notes-markdown-preview").markdown = notes
      for region in $(".markdown-region")
        $(p$(region).textarea).keyup ->
          md = $(this).val()
          target = $(this).parents("iron-autogrow-textarea").attr "data-md-field"
          try
            p$("##{target}").markdown = md
            console.debug "Wrote markdown to target '##{target}'"
          catch e
            console.warn "Can't update preview for target '##{target}'", $(this).get(0), md
    catch e
      console.error "Couldn't run markdown previews"
    validateNewTaxon()
  try
    p$("#modal-taxon-edit").open()
  catch
    $("#modal-taxon-edit").get(0).open()
  stopLoad()



createDuplicateTaxon = ->
  ###
  # Accessed from an existing taxon modal editor.
  #
  # Remove the edited notes, remove the duplicate button, and change
  # the bidings so a new entry is created.
  ###
  animateLoad()
  try
    # Change the open editor ID value
    d$("#taxon-id").remove()
    d$("#last-edited-by").remove()
    d$("#duplicate-taxon").remove()
    d$("#editor-title").text("Create Duplicate Taxon")
    # Rebind the saves
    newButton = """
    <paper-button id="save-editor">Create</paper-button>
    """
    d$("#save-editor")
    .replaceWith(newButton)
    d$("#save-editor")
    .click ->
      saveEditorEntry("new")
    delay 250, ->
      stopLoad()
    editFields = [
      "genus"
      "species"
      "subspecies"
      ]
    for fieldLabel in editFields
      selector = "#edit-#{fieldLabel}"
      $(selector).keyup ->
        validateNewTaxon.debounce()
    validateNewTaxon()
  catch e
    stopLoadError("Unable to duplicate taxon")
    console.error("Couldn't duplicate taxon! #{e.message}")
    d$("#modal-taxon-edit").get(0).close()
  true


lookupEditorSpecies = (taxon = undefined) ->
  ###
  # Lookup a given species and load it for editing
  # Has some hooks for badly formatted taxa.
  #
  # @param taxon a URL-encoded string for a taxon.
  ###
  if not taxon?
    return false
  animateLoad()
  lastEdited = """
    <p id="last-edited-by">
      Last edited by <span id="taxon-author-last" class="capitalize"></span>
    </p>
    <input type='hidden' name='taxon-id' id='taxon-id'/>
  """
  loadModalTaxonEditor(lastEdited)
  # Bind the save button
  d$("#save-editor")
  .click ->
    saveEditorEntry()
  existensial = d$("#last-edited-by").exists()
  unless existensial
    d$("#taxon-credit-help").after(lastEdited)
  ###
  # After
  # https://github.com/tigerhawkvok/SSAR-species-database/issues/33 :
  #
  # Some entries have illegal scientific names. Fix them, and assume
  # the wrong ones are deprecated.
  #
  # Therefore, "Phrynosoma (Anota) platyrhinos"  should use
  # "Anota platyrhinos" as the real name and "Phrynosoma platyrhinos"
  # as the deprecated.
  ###
  replacementNames = undefined
  originalNames = undefined
  args = "q=#{taxon}"
  if taxon.search(/\(/) isnt -1
    originalNames =
      genus: ""
      species: ""
      subspecies: ""
    replacementNames =
      genus: ""
      species: ""
      subspecies: ""
    taxonArray = taxon.split("+")
    k = 0
    while k < taxonArray.length
      v = taxonArray[k]
      console.log("Checking '#{v}'")
      switch toInt(k)
        when 0
          genusArray = v.split("(")
          console.log("Looking at genus array",genusArray)
          originalNames.genus = genusArray[0].trim()
          replacementNames.genus = if genusArray[1]? then genusArray[1].trim()[... -1] else genusArray[0]
        when 1
          speciesArray = v.split("(")
          console.log("Looking at species array",speciesArray)
          originalNames.species = speciesArray[0].trim()
          replacementNames.species = if speciesArray[1]? then speciesArray[1].trim()[... -1] else speciesArray[0]
        when 2
          subspeciesArray = v.split("(")
          console.log("Looking at ssp array",subspeciesArray)
          originalNames.subspecies = subspeciesArray[0].trim()
          replacementNames.subspecies = if subspeciesArray[1]? then subspeciesArray[1].trim()[... -1] else subspeciesArray[0]
        else
          console.error("K value of '#{k}' didn't match 0,1,2!")
      taxonArray[k] = v.trim()
      k++
    taxon = "#{originalNames.genus}+#{originalNames.species}"
    unless isNull(originalNames.subspecies)
      taxon += originalNames.subspecies
    args = "q=#{taxon}&loose=true"
    console.warn("Bad name! Calculated out:")
    console.warn("Should be currently",replacementNames)
    console.warn("Was previously",originalNames)
    console.warn("Pinging with","#{uri.urlString}#{searchParams.targetApi}?q=#{taxon}")
  # The actual query! This is what populates the editor.
  # Look up the taxon, take the first result, and populate
  $.get(searchParams.targetApi,args,"json")
  .done (result) ->
    try
      # We'll always take the first result. They query should be
      # perfectly specific, so we want the closest match in case of
      # G. sp. vs. G. sp. ssp.
      console.debug "Admin lookup rending editor UI for", result
      data = result.result[0]
      unless data?
        stopLoadError("Sorry, there was a problem parsing the information for this taxon. If it persists, you may have to fix it manually.")
        console.error("No data returned for","#{searchParams.targetApi}?q=#{taxon}")
        return false
      # The deprecated_scientific object is a json-string. We wan to
      # have this as an object to work with down the road.
      try
        data.deprecated_scientific = JSON.parse(data.deprecated_scientific)
      catch e
        # Do nothing -- it's probably empty.
      # Above, we defined originalNames as undefined, and it only
      # became an object if things needed to be cleaned up.
      if originalNames?
        # We have replacements to perform
        toastStatusMessage("Bad information found. Please review and resave.")
        data.genus = replacementNames.genus
        data.species = replacementNames.species
        data.subspecies = replacementNames.subspecies
        unless typeof data.deprecated_scientific is "object"
          data.deprecated_scientific = new Object()
        speciesString = originalNames.species
        unless isNull(originalNames.subspecies)
          speciesString += " #{originalNames.subspecies}"
        data.deprecated_scientific["#{originalNames.genus.toTitleCase()} #{speciesString}"] = "AUTHORITY: YEAR"
      # We've finished cleaning up the data from the server, time to
      # actually populate the edior.
      toggleColumns = [
        "parens_auth_genus"
        "parens_auth_species"
        ]
      console.debug "Using data", data
      console.debug JSON.stringify data
      for col, d of data
        # For each column, replace _ with - and prepend "edit"
        # This should be the selector
        try
          if typeof d is "string"
            # Clean up any strings that may have random spaces.
            d = d.trim()
        if col is "id"
          $("#taxon-id").attr("value",d)
        colAsDropdownExists = false
        try
          dropdownTentativeSelector = "#edit-#{col.replace /\_/g,"-"}"
          if $(dropdownTentativeSelector).get(0).tagName.toLowerCase() is "paper-dropdown-menu"
            colAsDropdownExists = true
        console.debug "Col editor exists for '#{dropdownTentativeSelector}'?", colAsDropdownExists
        if colAsDropdownExists
          console.debug "Trying to polymer-select", d
          $(dropdownTentativeSelector).polymerSelected d, true
        if col is "species_authority" or col is "genus_authority"
          # Check if the authority is in full format, eg, "(Linnaeus, 1758)"
          #unless isNull d.match /\(? *([\w\. \[\]]+), *([0-9]{4}) *\)?/g
          if /[0-9]{4}/im.test d
            unformattedAuthorityRe = /^\(? *((['"]?) *(?:(?:\b|[\u00C0-\u017F])[a-z\u00C0-\u017F\u2019 \.\-\[\]\?]+(?:,|,? *&|,? *&amp;| *&amp;amp;| *&(?:[a-z]+|#[0-9]+);)? *)+ *\2) *, *([0-9]{4}) *\)?/img
            unformattedAuthorityReOrig = /^\(? *((['"])? *([\w\u00C0-\u017F\. \-\&;\[\]]+(,|&|&amp;|&amp;amp;|&#[\w0-9]+;)?)+ *\2) *, *([0-9]{4}) *\)?/im
            if unformattedAuthorityRe.test d
              hasParens = d.search(/\(/) >= 0 and d.search(/\)/) >= 0
              #year = d.replace /^\(? *((['"])? *([\w\u00C0-\u017F\.\-\&; \[\]]+(,|&|&amp;|&amp;amp;|&#[\w0-9]+;)?)+ *\2) *, *([0-9]{4}) *\)?/ig, "$5"
              year = d.replace unformattedAuthorityRe, "$3"
              #d = d.replace /^\(? *((['"])? *([\w\u00C0-\u017F\.\-\&; \[\]]+(,|&|&amp;|&amp;amp;|&#[\w0-9]+;)?)+ *\2) *, *([0-9]{4}) *\)?/ig, "$1"
              d = d.replace unformattedAuthorityRe, "$1"
              if col is "genus_authority"
                $("#edit-gauthyear").attr("value",year)
              if col is "species_authority"
                $("#edit-sauthyear").attr("value",year)
              if hasParens
                p$("##{col.replace(/\_/g,"-")}-parens").checked = true
        if col is "authority_year"
          # Parse it out
          year = parseTaxonYear(d)
          if typeof year is "object"
            $("#edit-gauthyear").attr("value",year.genus)
            $("#edit-sauthyear").attr("value",year.species)
        else if col in toggleColumns
          # Check the paper-toggle-button
          colSplit = col.split("_")
          if colSplit[0] is "parens"
            category = col.split("_").pop()
            tempSelector = "##{category}-authority-parens"
          else
            tempSelector = "##{col.replace(/_/g,"-")}"
          d$(tempSelector).polymerChecked(toInt(d).toBool())
        else if col is "taxon_author"
          if d is "null" or isNull(d)
            $("#last-edited-by").remove()
            console.warn("Removed #last-edited-by! Didn't have an author provided for column '#{col}', giving '#{d}'. It's probably the first edit to this taxon.")
          else
            d$("#taxon-author-last").text(d)
          whoEdited = if isNull($.cookie("#{uri.domain}_fullname")) then $.cookie("#{uri.domain}_user") else $.cookie("#{uri.domain}_fullname")
          d$("#edit-taxon-author").attr("value",whoEdited)
        else if col is "taxon_credit"
          fieldSelector = "#edit-#{col.replace(/_/g,"-")}"
          p$(fieldSelector).value = $.cookie(adminParams.cookieFullName)
        else if col is "image_license"
          jstr = d.unescape()
          try
            j = JSON.parse jstr
            for license, licenseUrl of j
              $("#edit-image-license-dialog")
              .attr "data-license-name", license
              .attr "data-license-url", licenseUrl
              $("#edit-image-license")
              .attr "data-license-name", license
              .attr "data-license-url", licenseUrl
              d = "#{license} @ #{licenseUrl}"
              break
          catch
            d = jstr
          p$("#edit-image-license").value = d
        else if col is "taxon_credit_date"
          if isNull d
            today = new Date()
            d = today.toISOString().split("T")[0]
            fieldSelector = "#edit-#{col.replace(/_/g,"-")}"
            p$(fieldSelector).value = d
        else
          fieldSelector = "#edit-#{col.replace(/_/g,"-")}"
          if col is "deprecated_scientific"
            try
              $(fieldSelector).attr "data-json", encode64(JSON.stringify(d))
            # Create a "neat" string from it
            d = JSON.stringify(d).trim().replace(/\\/g,"")
            d = d.replace(/{/,"")
            d = d.replace(/}/,"")
            if d is '""'
              d = ""
          try
            if typeof d is "string"
              d = d.unescape()
          textAreas = [
            "notes"
            "entry"
            ]
          unless col in textAreas
            d$(fieldSelector).attr("value",d)
          else
            # Change the width of edit-notes and edit-entry
            width = $("#modal-taxon-edit").width() * .9
            d$(fieldSelector).css("width","#{width}px")
            textarea = p$(fieldSelector).textarea
            $(textarea).text(d.unescape())
      # Finally, open the editor
      modalElement = p$("#modal-taxon-edit")
      $("#modal-taxon-edit").on "iron-overlay-opened", ->
        p$("#modal-taxon-edit").refit()
        # Bind the common name source field
        origCommonName = p$("#edit-common-name").value
        $("#edit-common-name").keyup ->
          console.debug "Common name field edited!"
          if p$(this).value isnt origCommonName
            name = $.cookie adminParams.cookieFullName
            userValue = "user:#{name}"
          else
            userValue = "iucn"
          p$("#edit-common-name-source").value = userValue
          false
        _asm.updateImageField = (el) ->
          path = p$(el).value
          console.log "Should render preview image of ", path
          if $("#preview-main-image").exists()
            $("#preview-main-image").remove()
          previewImageHtml = """
          <img id="preview-main-image" class='preview-image' src="#{path}" />
          """
          $("#imagehelp").after previewImageHtml
          false
        $("#edit-image")
        .on "focus", ->
          el = this
          _asm.updateImageField.debounce null, null, null, el
          false
        .on "blur", ->
          el = this
          _asm.updateImageField.debounce null, null, null, el
          false
        .on "keyup", ->
          el = this
          _asm.updateImageField.debounce null, null, null, el
          false
        try
          _asm.updateImageField(p$("#edit-image"))
        # Credit preview thigns
        nameFill = (el) ->
          name = p$(el).value
          $("#taxon-credit-help .taxon-credit-preview").text name
          name
        dateFill = (el) ->
          dateEntry = p$(el).value
          dateObj = new Date(dateEntry)
          dateString = "#{dateObj.getUTCDate()} #{dateMonthToString dateObj.getUTCMonth()} #{dateObj.getUTCFullYear()}"
          $("#taxon-credit-help .taxon-credit-date-preview").text dateString
          dateString
        $("#edit-taxon-credit").keyup ->
          nameFill this
          false
        $("#edit-taxon-credit-date").keyup ->
          dateFill this
          false
        nameFill p$("#edit-taxon-credit")
        dateFill p$("#edit-taxon-credit-date")
        # Fill the markdown previews
        entry = $(p$("#edit-entry").textarea).val()
        notes = $(p$("#edit-notes").textarea).val()
        p$("#entry-markdown-preview").markdown = entry
        p$("#notes-markdown-preview").markdown = notes
        for region in $(".markdown-region")
          $(p$(region).textarea).keyup ->
            md = $(this).val()
            target = $(this).parents("iron-autogrow-textarea").attr "data-md-field"
            try
              p$("##{target}").markdown = md
              console.debug "Wrote markdown to target '##{target}'"
            catch e
              console.warn "Can't update preview for target '##{target}'", $(this).get(0), md
      safariDialogHelper("#modal-taxon-edit")
      stopLoad()
    catch e
      stopLoadError("Unable to populate the editor for this taxon - #{e.message}")
      console.error "Error populating the taxon popup -- #{e.message}"
      console.warn e.stack
  .fail (result,status) ->
    stopLoadError("There was a server error populating this taxon. Please try again.")
  false


validateCitation = (citation) ->
  ###
  # Check a citation for validity
  ###
  markInvalid = false
  try
    if $(citation).exists()
      selector = citation
      if typeof p$(citation).validate is "function"
        markInvalid = true
        citation = p$(selector).value
      else
        citation = $(selector).val()
  cleanup = (result, replacement) ->
    if markInvalid
      if result is false
        p$(selector).errorMessage = "Please enter a valid DOI or ISBN"
      else
        unless isNull replacement
          p$(selector).value = replacement
      p$(selector).invalid = not result
    return result
  # DOIs
  doi = /^(?:doi:|https?:\/\/dx.doi.org\/)?(10.\d{4,9}\/[-._;()\/:A-Z0-9]+|10.1002\/[^\s]+|10.\d{4}\/\d+-\d+X?(\d+)\d+<[\d\w]+:[\d\w]*>\d+.\d+.\w+;\d|10.1207\/[\w\d]+\&\d+_\d+)$/im
  if doi.test(citation)
    # Picked up via
    # https://www.crossref.org/blog/dois-and-matching-regular-expressions/
    replace = citation.replace doi, "$1"
    return cleanup true, replace
  # ISBNs
  if citation.search(/isbn/i) is 0
    # Via https://gist.github.com/oscarmorrison/3744fa216dcfdb3d0bcb
    isbn10 = /^(?:ISBN(?:-10)?:?\ )?(?=[0-9X]{10}$|(?=(?:[0-9]+[-\ ]){3})[-\ 0-9X]{13}$)[0-9]{1,5}[-\ ]?[0-9]+[-\ ]?[0-9]+[-\ ]?[0-9X]$/
    isbn13 = /^(?:ISBN(?:-13)?:?\ )?(?=[0-9]{13}$|(?=(?:[0-9]+[-\ ]){4})[-\ 0-9]{17}$)97[89][-\ ]?[0-9]{1,5}[-\ ]?[0-9]+[-\ ]?[0-9]+[-\ ]?[0-9]$/
    return cleanup isbn10.test(citation) and isbn13.test(citation)
  # Generic journal formatting
  cleanup false




saveEditorEntry = (performMode = "save") ->
  ###
  # Send an editor state along with login credentials,
  # and report the save result back to the user
  ###
  # Make all the entries lowercase EXCEPT notes and taxon_credit.
  # Close it on a successful save
  examineIds = [
    "genus"
    "species"
    "subspecies"
    "common-name"
    "major-type"
    "major-subtype"
    "linnean-order"
    "linnean-family"
    "simple-linnean-group"
    "simple-linnean-subgroup"
    "genus-authority"
    "species-authority"
    "notes"
    "entry"
    "image"
    "image-credit"
    "image-license"
    "image-caption"
    "taxon-author"
    "taxon-credit"
    "taxon-credit-date"
    "internal-id"
    "source"
    "citation"
    "species-authority-citation"
    "genus-authority-citation"
    ]
  saveObject = new Object()
  escapeCompletion = false
  d$("paper-input").removeAttr("invalid")
  ## Manual parses
  try
    # Authority year
    testAuthorityYear = (authYearDeepInputSelector, directYear = false) ->
      ###
      # Helper function!
      # Take in a deep element selector, then run it through match
      # patterns for the authority year.
      #
      # @param authYearDeepInputSelector -- Selector for a shadow DOM
      #          element, ideally a paper-input.
      ###
      if directYear
        yearString = authYearDeepInputSelector
      else
        yearString = d$(authYearDeepInputSelector).val()
      error = undefined
      linnaeusYear = 1707 # Linnaeus's birth year
      d = new Date()
      nextYear = d.getUTCFullYear() + 1 # So we can honestly say "between" and mean it
      # Authority date regex
      # From
      # https://github.com/tigerhawkvok/SSAR-species-database/issues/37
      #authorityRegex = /^\d{4}$|^\d{4} (\"|')\d{4}\1$/
      authorityRegex = /^[1-2][07-9]\d{2}$|^[1-2][07-9]\d{2} (\"|')[1-2][07-9]\d{2}\1$/
      unless isNumber(yearString) and linnaeusYear < yearString < nextYear
        unless authorityRegex.test(yearString)
          # It's definitely bad, we just need to decide how bad
          if yearString.search(" ") is -1
            error = "This must be a valid year between #{linnaeusYear} and #{nextYear}"
          else
            error = "Nonstandard years must be of the form: YYYY 'YYYY', eg, 1801 '1802'"
        else
          # It matches the regex, but fails the check
          # So, it may be valid, but we need to check
          if yearString.search(" ") is -1
            # It's a simple year, but fails the check.
            # Therefore, it's out of range.
            error = "This must be a valid year between #{linnaeusYear} and #{nextYear}"
          else
            # There's a space, so it's of format:
            #   1801 '1802'
            # So we need to parse that out for a valid year check
            # The format is otherwise assured by the regex
            years = yearString.split(" ")
            unless linnaeusYear < years[0] < nextYear
              error = "The first year must be a valid year between #{linnaeusYear} and #{nextYear}"
            altYear = years[1].replace(/(\"|')/g,"")
            unless linnaeusYear < altYear < nextYear
              error = "The second year must be a valid year between #{linnaeusYear} and #{nextYear}"
            # Now, for input consistency, replace single-quotes with
            # double-quotes
            yearString = yearString.replace(/'/g,'"')
      # If there were any error strings assigned, display an error.
      if error?
        escapeCompletion = true
        completionErrorMessage = "#{authYearDeepInputSelector} failed its validity checks for `#{yearString}`!"
        console.warn completionErrorMessage
        unless directYear
          # Populate the paper-input errors
          # See
          # https://elements.polymer-project.org/elements/paper-input?active=Polymer.PaperInputBehavior
          # https://elements.polymer-project.org/elements/paper-input
          d$("#{authYearDeepInputSelector}")
          .attr("error-message",error)
          .attr("invalid","invalid")
        else
          throw Error(error)
      # Return the value for assignment
      return yearString
    # Test and assign all in one go
    try
      gYear = testAuthorityYear("#edit-gauthyear")
      sYear = testAuthorityYear("#edit-sauthyear")
      console.log("Escape Completion State:",escapeCompletion)
    catch e
      console.error("Unable to parse authority year! #{e.message}")
      authYearString = ""
    auth = new Object()
    auth[gYear] = sYear
    authYearString = JSON.stringify(auth)
  catch e
    # Didn't work
    console.error("Failed to JSON parse the authority year - #{e.message}")
    authYearString = ""
  saveObject["authority_year"] = authYearString
  try
    dep = new Object()
    depS = d$("#edit-deprecated-scientific").val()
    unless isNull(depS)
      depA = depS.split('","')
      for k in depA
        item = k.split("\":\"")
        dep[item[0].replace(/"/g,"")] = item[1].replace(/"/g,"")
      # We now have an object representing the deprecated
      # scientific. Check the internal values.
      console.log("Validating",dep)
      for taxon, authority of dep
        # We're going to assume the taxon is right.
        # Check the authority.
        authorityA = authority.split(":")
        console.log("Testing #{authority}",authorityA)
        unless authorityA.length is 2
          throw Error("Authority string should have an authority and year seperated by a colon.")
        auth = authorityA[0].trim()
        trimmedYearString = authorityA[1].trim()
        if trimmedYearString.search(",") isnt -1
          throw Error """Looks like there may be an extra space, or forgotten ", near '#{trimmedYearString}' """
        year = testAuthorityYear(trimmedYearString,true)
        console.log("Validated",auth,year)
      # Stringify it for the database saving
      depString = JSON.stringify(dep)
      # Compare the pretty string against the input string. Let's be
      # sure they match.
      if depString.replace(/[{}]/g,"") isnt depS
        throw Error("Badly formatted entry - generated doesn't match read")
    else
      # We have an empty deprecated field
      depString = ""
  catch e
    console.error("Failed to parse the deprecated scientifics - #{e.message}. They may be empty.")
    depString = ""
    error = "#{e.message}. Check your formatting!"
    d$("#edit-deprecated-scientific")
    .attr("error-message",error)
    .attr("invalid",true)
    escapeCompletion = true
    completionErrorMessage = "There was a problem with your formatting for the deprecated scientifics. Please check it and try again."
  saveObject["deprecated_scientific"] = depString
  # For the rest of the items, iterate over and put on saveObject
  keepCase = [
    "notes"
    "entry"
    "taxon_credit"
    "image"
    "image_credit"
    "image_license"
    "image_caption"
    "species-authority-citation"
    "species_authority_citation"
    "genus-authority-citation"
    "genus_authority_citation"
    "citation"
    ]
  # List of IDs that can't be empty
  # Reserved use pending
  # https://github.com/jashkenas/coffeescript/issues/3594
  requiredNotEmpty = [
    "genus"
    "species"
    "major-type"
    "linnean-order"
    "genus-authority"
    "species-authority"
    ]
  unless isNull(d$("#edit-image").val())
    # We have an image, need a credit
    requiredNotEmpty.push("image-credit")
    requiredNotEmpty.push("image-license")
  unless isNull(d$("#edit-taxon-credit").val())
    # We have a taxon credit, need a date for it
    requiredNotEmpty.push("taxon-credit-date")
  for k, id of examineIds
    if typeof id isnt "string"
      continue
    console.log(k,id)
    try
      col = id.replace(/-/g,"_")
    catch
      console.warn "Unable to test against id '#{id}'"
      continue
    testSelector = "#edit-#{col.replace /\_/img,"-"}"
    # Check it
    colAsDropdownExists = false
    try
      dropdownTentativeSelector = testSelector
      if $(dropdownTentativeSelector).get(0).tagName.toLowerCase() is "paper-dropdown-menu"
        colAsDropdownExists = true
    console.debug "Col editor exists for '#{dropdownTentativeSelector}'?", colAsDropdownExists
    if colAsDropdownExists
      val = $(dropdownTentativeSelector).polymerSelected()
    else
      if col is "image_license"
        valJson = new Object()
        licenseName = $("#edit-image-license").attr "data-license-name"
        licenseUrl = $("#edit-image-license").attr "data-license-url"
        valJson[licenseName] = licenseUrl
        val = JSON.stringify valJson
      else
        isTextArea = false
        try
          if $("#edit-#{id}").get(0).tagName.toLowerCase() is "iron-autogrow-textarea"
            isTextArea = true
        unless isTextArea
          try
            val = d$("#edit-#{id}").val().trim()
          catch e
            val = ""
            err =  "Unable to get value for #{id}"
            console.warn "#{err}: #{e.message}"
            toastStatusMessage err
        else
          val = p$("#edit-#{id}").value
          if isNull val
            val = $(p$("#edit-#{id}").textarea).val()
          try
            val = val.trim()
    unless col in keepCase
      # We want these to be as literally typed, rather than
      # smart-formatted.
      # Deprecated scientifics are already taken care of.
      try
        if isNumber val
          if val is toInt(val).toString()
            val = toInt val
          else if vale is toFloat(val).toString()
            val = toFloat val
        val = val.toLowerCase()
      catch e
        console.warn "Column '#{col}' threw error for value '#{val}': #{e.message}"
        if isNull val
          val = ""
    ## Do the input validation
    switch id
      when "genus", "species", "subspecies"
        # Scientific name must be well-formed
        error = "This required field must have only letters"
        nullTest = if id is "genus" or id is "species" then isNull(val) else false
        if /[^A-Za-z]/m.test(val) or nullTest
          d$("#edit-#{id}")
          .attr("error-message",error)
          .attr("invalid","invalid")
          escapeCompletion = true
          completionErrorMessage = "Invalid Scientific Name"
      when "major-type", "linnean-order", "genus-authority", "species-authority"
        # I'd love to syntactically clean this up via the empty array
        # requiredNotEmpty above, but that's pending
        # https://github.com/jashkenas/coffeescript/issues/3594
        #
        # These must just exist
        error = "This cannot be empty"
        if isNull(val)
          $("#edit-#{id}")
          .attr("error-message",error)
          .attr("invalid","invalid")
          escapeCompletion = true
          completionErrorMessage = "Missing Field"
      else
        if id in requiredNotEmpty
          selectorSample = "#edit-#{id}"
          spilloverError = "This must not be empty"
          # console.log("Checking '#{selectorSample}'")
          if selectorSample is "#edit-image-credit" or selectorSample is "#edit-image-license"
            # We have an image, need a credit
            spilloverError = "This cannot be empty if an image is provided"
          if selectorSample is "#edit-taxon-credit-date"
            # We have a taxon credit, need a date for it
            parsedDate = new Date(val)
            if parsedDate is "Invalid Date"
              spilloverError = "We couldn't understand your date format. Please try again."
              val = null
            else
              val = parsedDate.toISOString().split("T")[0]
              $(selectorSample).attr "value", val
              spilloverError = "If you have a taxon credit, it also needs a date"
          if isNull(val)
            d$("#edit-#{id}")
            .attr("error-message",spilloverError)
            .attr("invalid","invalid")
            escapeCompletion = true
            completionErrorMessage = "REQUIRED_FIELD_EMPTY"
    # Finally, tack it on to the saveObject
    saveObject[col] = val
  # Some other save object items...
  saveObject.id = toInt d$("#taxon-id").val()
  # The parens checks
  saveObject.parens_auth_genus = d$("#genus-authority-parens").polymerChecked()
  saveObject.parens_auth_species = d$("#species-authority-parens").polymerChecked()
  saveObject.canonical_sciname = if isNull(saveObject.subspecies) then "#{saveObject.genus.toTitleCase()} #{saveObject.species}" else "#{saveObject.genus.toTitleCase()} #{saveObject.species} #{saveObject.subspecies}"
  # We've ended the loop! Did we hit an escape condition?
  if escapeCompletion
    animateLoad()
    consoleError = completionErrorMessage ? "Bad characters in entry. Stopping ..."
    completionErrorMessage = "There was a problem with your entry. Please correct your entry and try again. #{completionErrorMessage}"
    stopLoadError(completionErrorMessage)
    console.error(consoleError)
    console.warn "Save object so far:", saveObject
    return true
  if performMode is "save"
    unless isNumber(saveObject.id)
      animateLoad()
      stopLoadError("The system was unable to generate a valid taxon ID for this entry. Please see the console for more details.")
      console.error("Unable to get a valid, numeric taxon id! We got '#{saveObject.id}'.")
      console.warn("The total save object so far is:",saveObject)
      return false
  saveString = JSON.stringify(saveObject)
  s64 = Base64.encodeURI(saveString)
  if isNull(saveString) or isNull(s64)
    animateLoad()
    stopLoadError("The system was unable to parse this entry for the server. Please see the console for more details.")
    console.error("Unable to stringify the JSON!.")
    console.warn("The total save object so far is:",saveObject)
    console.warn("Got the output string",saveSring)
    console.warn("Sending b64 string",s64)
    return true
  hash = $.cookie("#{uri.domain}_auth")
  secret = $.cookie("#{uri.domain}_secret")
  link = $.cookie("#{uri.domain}_link")
  userVerification = "hash=#{hash}&secret=#{secret}&dblink=#{link}"
  args = "perform=#{performMode}&#{userVerification}&data=#{s64}"
  console.log("Going to save",saveObject)
  console.log("Using mode '#{performMode}'")
  animateLoad()
  $.post(adminParams.apiTarget,args,"json")
  .done (result) ->
    if result.status is true
      console.log("Server returned",result)
      if escapeCompletion
        stopLoadError "Warning! The item saved, even though it wasn't supposed to."
        return false
      d$("#modal-taxon-edit").get(0).close()
      unless isNull($("#admin-search").val())
        renderAdminSearchResults()
      # We may have updated the dropdowns
      prefetchEditorDropdowns()
      stopLoad()
      delay 250, ->
        stopLoad()
      console.log "Save complete"
      return false
    stopLoadError result.human_error
    console.error(result.error)
    console.warn("Server returned",result)
    console.warn("We sent","#{uri.urlString}#{adminParams.apiTarget}?#{args}")
    return false
  .fail (result,status) ->
    stopLoadError("Failed to send the data to the server.")
    console.error("Server error! We sent","#{uri.urlString}#{adminParams.apiTarget}?#{args}")
    false


deleteTaxon = (taxaId) ->
  caller = $(".delete-taxon .delete-taxon-button[data-database-id='#{taxaId}']")
  taxonRaw = caller.attr("data-taxon").replace(/\+/g," ")
  taxon = taxonRaw.substr(0,1).toUpperCase() + taxonRaw.substr(1)
  unless caller.hasClass("extreme-danger")
    # Prevent a double-click
    window.deleteWatchTimer = Date.now()
    delay 300, ->
      delete window.deleteWatchTimer
    caller
    .addClass("extreme-danger")
    .attr "icon", "icons:delete-sweep"
    safetyTimeout = 7500
    delay safetyTimeout, ->
      caller
      .removeClass("extreme-danger")
      .attr "icon", "icons:delete-forever"
    toastStatusMessage "Click again to confirm deletion of #{taxon}. This can't be undone.", "", safetyTimeout
    return false
  if window.deleteWatchTimer?
    # It has been less than 300 ms since delete was first tapped.
    # Deny it.
    diff = Date.now() - window.deleteWatchTimer
    console.warn("The taxon was asked to be deleted #{diff}ms after the confirmation was prompted. Rejecting ...")
    return false
  animateLoad()
  args = "perform=delete&id=#{taxaId}"
  $.post adminParams.apiTarget, args, "json"
  .done (result) ->
    console.log "Filed delete", "#{adminParams.apiTarget}?#{args}"
    console.log "Server response", result
    if result.status is true
      # Remove the visual row
      caller.parents("tr").remove()
      try
        p$("#search-status").hide()
      window._metaStatus.isToasting = false
      delay 250, ->
        toastStatusMessage("#{taxon} with ID #{taxaId} has been removed from the database.")
      stopLoad()
    else
      stopLoadError(result.human_error)
      console.error(result.error)
      console.warn(result)
    false
  .fail (result,status) ->
    stopLoadError("Failed to communicate with the server.")
    false

handleDragDropImage = (uploadTargetSelector = "#upload-image", callback) ->
  ###
  # Take a drag-and-dropped image, and save it out to the database.
  # If we trigger this, we need to disable #edit-image
  ###
  unless typeof callback is "function"
    callback = (file, result) ->
      unless result.status is true
        # Yikes! Didn't work
        result.human_error ?= "There was a problem uploading your image."
        toastStatusMessage(result.human_error)
        console.error("Error uploading!",result)
        return false
      try
        fileName = file.name
        # Disable the selector
        _asm.dropzone.disable()
        # Now, process the rename and insert it into the file area
        # Get the MD5 of the original filename
        ext = fileName.split(".").pop()
        # MD5.extension is the goal
        fullFile = "#{md5(fileName)}.#{ext}"
        fullPath = "species_photos/#{fullFile}"
        # Insert it into the field
        d$("#edit-image")
        .attr("disabled","disabled")
        .attr("value",fullPath)
        toastStatusMessage("Upload complete")
      catch e
        console.error("There was a problem with upload post-processing - #{e.message}")
        console.warn("Using",fileName,result)
        toastStatusMessage("Your upload completed, but we couldn't post-process it.")
      false
  # Load dependencies
  loadJS "bower_components/JavaScript-MD5/js/md5.min.js"
  loadJS "bower_components/dropzone/dist/min/dropzone.min.js", ->
    # Dropzone has been loaded!
    # Add the CSS
    c = document.createElement("link")
    c.setAttribute("rel","stylesheet")
    c.setAttribute("type","text/css")
    c.setAttribute("href","css/dropzone.min.css")
    document.getElementsByTagName('head')[0].appendChild(c)
    Dropzone.autoDiscover = false
    # See http://www.dropzonejs.com/#configuration
    defaultText = "Drop a high-resolution image for the taxon here."
    dragCancel = ->
      d$(uploadTargetSelector)
      .css("box-shadow","")
      .css("border","")
      d$("#{uploadTargetSelector} .dz-message span").text(defaultText)
    dropzoneConfig =
      url: "#{uri.urlString}meta.php?do=upload_image"
      acceptedFiles: "image/*"
      autoProcessQueue: true
      maxFiles: 1
      dictDefaultMessage: defaultText
      init: ->
        @on "error", ->
          toastStatusMessage("An error occured sending your image to the server.")
        @on "canceled", ->
          toastStatusMessage("Upload canceled.")
        @on "dragover", ->
          d$("#{uploadTargetSelector} .dz-message span").text("Drop here to upload the image")
          ###
          # box-shadow: 0px 0px 15px rgba(15,157,88,.8);
          # border: 1px solid #0F9D58;
          ###
          d$(uploadTargetSelector)
          .css("box-shadow","0px 0px 15px rgba(15,157,88,.8)")
          .css("border","1px solid #0F9D58")
        @on "dragleave", ->
          dragCancel()
        @on "dragend", ->
          dragCancel()
        @on "drop", ->
          dragCancel()
        @on "success", (file, result) ->
          callback(file, result)
    # Create the upload target
    unless d$(uploadTargetSelector).hasClass("dropzone")
      d$(uploadTargetSelector).addClass("dropzone")
    fileUploadDropzone = new Dropzone(d$(uploadTargetSelector).get(0), dropzoneConfig)
    _asm.dropzone = fileUploadDropzone
  false



adminPreloadSearch = ->
  ###
  # Take a fragment with a JSON species and preload a search
  #
  # This is in a different format from the one in the standard search;
  # the standard search uses the verbatim entry of the user, this uses
  # a JSON constructed by the system
  ###
  if _asm.preloaderBlocked is true
    console.debug "Skipping re-running active search preload"
    return false
  console.debug "Preloader firing"
  _asm.preloaderBlocked = true
  start = Date.now()
  try
    uri.query = decodeURIComponent $.url().attr("fragment")
  if uri.query is "#" or isNull uri.query
    return false
  try
    loadArgs = Base64.decode(uri.query)
    loadArgs = JSON.parse loadArgs
  if typeof loadArgs is "object"
    if isNull(loadArgs.genus) or not loadArgs.species?
      console.error "Bad taxon format"
      return false
    for k, v of loadArgs
      cleanedArg = decodeURIComponent v
      cleanedArg = cleanedArg.replace /(\+|\%20|\s)+/g, " "
      loadArgs[k] = cleanedArg.trim()
    fill = "#{loadArgs.genus} #{loadArgs.species}"
    unless isNull loadArgs.subspecies
      fill += " #{loadArgs.subspecies}"
    fillTimeout = 10 * 1000
    do fillWhenReady = ->
      try
        isAttached = p$("#admin-search").isAttached
      catch
        isAttached = false
      if _asm?.polymerReady and isAttached
        try
          p$("#admin-search").value = fill
        catch
          $("#admin-search").val fill
        # Do the search
        renderAdminSearchResults loadArgs
        duration = Date.now() - start
        console.log "Search preload finished in #{duration}ms"
        _asm.preloaderBlocked = false
      else
        duration = Date.now() - start
        console.debug "NOT READY: Duration @ #{duration}ms", _asm?.polymerReady, isAttached, _asm.polymerReady and isAttached
        unless duration > fillTimeout
          delay 100, ->
            fillWhenReady()
        else
          console.error "Timeout waiting for polymerReady!! Not filling search."
          _asm.preloaderBlocked = false
          return false
  else
    console.error "Bad fragment: unable to read JSON", loadArgs
  false



$ ->
  try
    thisUrl = uri.o.attr("source")
    isAdminActive = /^https?:\/\/(?:.*?\/)+(admin-.*\.(?:php|html)|admin\/)(?:\?(?:&?[\w\-_]+=[\w+\-_%]+)+)?(?:\#[\w\+%]+)?$/im.test thisUrl
  catch
    # We validate everything anyway, so run speculatively
    isAdminActive = true
  if $("#next").exists()
    $("#next")
    .unbind()
    .click ->
      openTab(adminParams.adminPageUrl)
  loadJS "bower_components/bootstrap/dist/js/bootstrap.min.js", ->
    $("[data-toggle='tooltip']").tooltip()
  if isAdminActive
    try
      prefetchEditorDropdowns()
    try
      adminPreloadSearch()
  else
    console.debug "Not an admin page"
  # The rest of the onload for the admin has been moved to the core.coffee file.
