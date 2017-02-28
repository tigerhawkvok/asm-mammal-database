###
# The main coffeescript file for administrative stuff
# Triggered from admin-page.html
###
adminParams = new Object()
adminParams.apiTarget = "admin_api.php"
adminParams.adminPageUrl = "https://mammaldiversity.org/cndb/admin-page.html"
adminParams.loginDir = "admin/"
adminParams.loginApiTarget = "#{adminParams.loginDir}async_login_handler.php"

loadAdminUi = ->
  ###
  # Main wrapper function. Checks for a valid login state, then
  # fetches/draws the page contents if it's OK. Otherwise, boots the
  # user back to the login page.
  ###
  try
    verifyLoginCredentials (data) ->
      # Post verification
      cookieName = "#{uri.domain}_name"
      articleHtml = """
      <h3>
        Welcome, #{$.cookie(cookieName)}
        <span id="pib-wrapper-settings" class="pib-wrapper" data-toggle="tooltip" title="User Settings" data-placement="bottom">
          <paper-icon-button icon='settings-applications' class='click' data-url='#{data.login_url}'></paper-icon-button>
        </span>
        <span id="pib-wrapper-exit-to-app" class="pib-wrapper" data-toggle="tooltip" title="Go to CNDB app" data-placement="bottom">
          <paper-icon-button icon='exit-to-app' class='click' data-url='#{uri.urlString}' id="app-linkout"></paper-icon-button>
        </span>
      </h3>
      <div id='admin-actions-block'>
        <div class='bs-callout bs-callout-info'>
          <p>Please be patient while the administrative interface loads.</p>
        </div>
      </div>
      """
      $("article #main-body").html(articleHtml)
      # $(".pib-wrapper").tooltip()
      bindClicks()
      ###
      # Render out the admin UI
      # We want a search box that we pipe through the API
      # and display the table out for editing
      ###
      searchForm = """
      <form id="admin-search-form" onsubmit="event.preventDefault()" class="row">
        <div>
          <paper-input label="Search for species" id="admin-search" name="admin-search" required autofocus floatingLabel class="col-xs-7 col-sm-8"></paper-input>
          <paper-fab id="do-admin-search" icon="search" raisedButton class="materialblue"></paper-fab>
          <paper-fab id="do-admin-add" icon="add" raisedButton class="materialblue"></paper-fab>
        </div>
      </form>
      <div id='search-results' class="row"></div>
      """
      $("#admin-actions-block").html(searchForm)
      $("#admin-search-form").submit (e) ->
        e.preventDefault()
      $("#admin-search").keypress (e) ->
        if e.which is 13 then renderAdminSearchResults()
      $("#do-admin-search").click ->
        renderAdminSearchResults()
      $("#do-admin-add").click ->
        createNewTaxon()
      bindClickTargets()
      false
  catch e
    $("article #main-body").html("<div class='bs-callout bs-callout-danger'><h4>Application Error</h4><p>There was an error in the application. Please refresh and try again. If this persists, please contact administration.</p></div>")
  false


verifyLoginCredentials = (callback) ->
  ###
  # Checks the login credentials against the server.
  # This should not be used in place of sending authentication
  # information alongside a restricted action, as a malicious party
  # could force the local JS check to succeed.
  # SECURE AUTHENTICATION MUST BE WHOLLY SERVER SIDE.
  ###
  hash = $.cookie("#{uri.domain}_auth")
  secret = $.cookie("#{uri.domain}_secret")
  link = $.cookie("#{uri.domain}_link")
  args = "hash=#{hash}&secret=#{secret}&dblink=#{link}"
  $.post(adminParams.loginApiTarget,args,"json")
  .done (result) ->
    if result.status is true
      callback(result)
    else
      goTo(result.login_url)
  .fail (result,status) ->
    # Throw up some warning here
    $("article #main-body").html("<div class='bs-callout-danger bs-callout'><h4>Couldn't verify login</h4><p>There's currently a server problem. Try back again soon.</p>'</div>")
    console.log(result,status)
    false
  false


renderAdminSearchResults = (containerSelector = "#search-results") ->
  ###
  # Takes parts of performSearch() but only in the admin context
  ###
  s = $("#admin-search").val()
  if isNull(s)
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
  $.get(searchParams.targetApi,args,"json")
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
    htmlHead = "<table id='cndb-result-list' class='table table-striped table-hover'>\n\t<tr class='cndb-row-headers'>"
    htmlClose = "</table>"
    # We start at 0, so we want to count one below
    targetCount = toInt(result.count)-1
    colClass = null
    bootstrapColCount = 0
    $.each data, (i,row) ->
      if toInt(i) is 0
        j = 0
        htmlHead += "\n<!-- Table Headers - #{Object.size(row)} entries -->"
        $.each row, (k,v) ->
          niceKey = k.replace(/_/g," ")
          if k is "genus" or k is "species" or k is "subspecies"
            htmlHead += "\n\t\t<th class='text-center'>#{niceKey}</th>"
            bootstrapColCount++
          j++
          if j is Object.size(row)
            htmlHead += "\n\t\t<th class='text-center'>Edit</th>"
            bootstrapColCount++
            htmlHead += "\n\t\t<th class='text-center'>Delete</th>\n\t</tr>"
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
      $.each row, (k,col) ->
        if isNull(row.genus)
          # Next iteration
          return true
        if k is "genus" or k is "species" or k is "subspecies"
          htmlRow += "\n\t\t<td id='#{k}-#{i}' class='#{k} #{colClass}'>#{col}</td>"
        l++
        if l is Object.size(row)
          htmlRow += "\n\t\t<td id='edit-#{i}' class='edit-taxon #{colClass} text-center'><paper-icon-button icon='image:edit' class='edit' data-taxon='#{taxonQuery}'></paper-icon-button></td>"
          htmlRow += "\n\t\t<td id='delete-#{i}' class='delete-taxon #{colClass} text-center'><paper-icon-button icon='delete' class='delete-taxon-button fadebg' data-taxon='#{taxonQuery}' data-database-id='#{row.id}'></paper-icon-button></td>"
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
        stopLoad()
  .fail (result,status) ->
    console.error("There was an error performing the search")
    console.warn(result,error,result.statusText)
    error = "#{result.status} - #{result.statusText}"
    $("#search-status").attr("text","Couldn't execute the search - #{error}")
    $("#search-status")[0].show()
    stopLoadError()



loadModalTaxonEditor = (extraHtml = "", affirmativeText = "Save") ->
  ###
  # Load a modal taxon editor
  ###
  #  | <a href="#" "onclick='window.open(this.href); return false;' onkeypress='window.open(this.href); return false;'">Syntax Cheat Sheet</a>
  editHtml = """
  <paper-input label="Genus" id="edit-genus" name="edit-genus" class="genus" floatingLabel></paper-input>
  <paper-input label="Species" id="edit-species" name="edit-species" class="species" floatingLabel></paper-input>
  <paper-input label="Subspecies" id="edit-subspecies" name="edit-subspecies" class="subspecies" floatingLabel></paper-input>
  <iron-label>
    Alien species?
    <paper-toggle-button id="is-alien"  checked="false"></paper-toggle-button>
  </iron-label>
  <paper-input label="Common Name" id="edit-common-name" name="edit-common-name"  class="common_name" floatingLabel></paper-input>
  <paper-input label="Deprecated Scientific Names" id="edit-deprecated-scientific" name="edit-depreated-scientific" floatingLabel aria-describedby="deprecatedHelp"></paper-input>
    <span class="help-block" id="deprecatedHelp">List names here in the form <span class="code">"Genus species":"Authority: year","Genus species":"Authority: year",[...]</span>.<br/>There should be no spaces between the quotes and comma or colon. If there are, it may not save correctly.</span>
  <paper-input label="Clade" class="capitalize" id="edit-major-type" name="edit-major-type" floatingLabel></paper-input>
  <paper-input label="Subtype" class="capitalize" id="edit-major-subtype" name="edit-major-subtype" floatingLabel></paper-input>
  <paper-input label="Minor clade / 'Family'" id="edit-minor-type" name="edit-minor-type" floatingLabel></paper-input>
  <paper-input label="Linnean Order" id="edit-linnean-order" name="edit-linnean-order" class="linnean_order" floatingLabel></paper-input>
  <paper-input label="Common Type (eg., 'lizard')" id="edit-major-common-type" name="edit-major-common-type" class="major_common_type" floatingLabel></paper-input>
  <paper-input label="Genus authority" id="edit-genus-authority" name="edit-genus-authority" class="genus_authority" floatingLabel></paper-input>
  <paper-input label="Genus authority year" id="edit-gauthyear" name="edit-gauthyear" floatingLabel></paper-input>
  <iron-label>
    Use Parenthesis for Genus Authority
    <paper-toggle-button id="genus-authority-parens"  checked="false"></paper-toggle-button>
  </iron-label>
  <paper-input label="Species authority" id="edit-species-authority" name="edit-species-authority" class="species_authority" floatingLabel></paper-input>
  <paper-input label="Species authority year" id="edit-sauthyear" name="edit-sauthyear" floatingLabel></paper-input>
  <iron-label>
    Use Parenthesis for Species Authority
    <paper-toggle-button id="species-authority-parens" checked="false"></paper-toggle-button>
  </iron-label>
  <br/><br/>
  <iron-autogrow-textarea id="edit-notes" rows="5" aria-describedby="notes-help" placeholder="Notes">
    <textarea placeholder="Notes" id="edit-notes-textarea" name="edit-notes-textarea" aria-describedby="notes-help" rows="5"></textarea>
  </iron-autogrow-textarea>
  <span class="help-block" id="notes-help">You can write your notes in Markdown. (<a href="https://daringfireball.net/projects/markdown/syntax" "onclick='window.open(this.href); return false;' onkeypress='window.open(this.href); return false;'">Official Full Syntax Guide</a>)</span>
  <div id="upload-image"></div>
  <span class="help-block" id="upload-image-help">You can drag and drop an image above, or enter its server path below.</span>
  <paper-input label="Image" id="edit-image" name="edit-image" floatingLabel aria-describedby="imagehelp"></paper-input>
    <span class="help-block" id="imagehelp">The image path here should be relative to the <span class="code">public_html/cndb/</span> directory.</span>
  <paper-input label="Image Credit" id="edit-image-credit" name="edit-image-credit" floatingLabel></paper-input>
  <paper-input label="Image License" id="edit-image-license" name="edit-image-license" floatingLabel></paper-input>
  <paper-input label="Taxon Credit" id="edit-taxon-credit" name="edit-taxon-credit" floatingLabel aria-describedby="taxon-credit-help"></paper-input>
    <span class="help-block" id="taxon-credit-help">This will be displayed as "Taxon information by [your entry]."</span>
  <paper-input label="Taxon Credit Date" id="edit-taxon-credit-date" name="edit-taxon-credit-date" floatingLabel></paper-input>
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
        "is_alien"
        ]
      for col, d of data
        # For each column, replace _ with - and prepend "edit"
        # This should be the selector
        try
          if typeof d is "string"
            # Clean up any strings that may have random spaces.
            d = d.trim()
        catch e
          # Do nothing -- probably numeric, and in any case we're no
          # worse than we started.
        if col is "id"
          $("#taxon-id").attr("value",d)
        if col is "authority_year"
          # Parse it out
          year = parseTaxonYear(d)
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
        else
          fieldSelector = "#edit-#{col.replace(/_/g,"-")}"
          if col is "deprecated_scientific"
            # Create a "neat" string from it
            d = JSON.stringify(d).trim().replace(/\\/g,"")
            d = d.replace(/{/,"")
            d = d.replace(/}/,"")
            if d is '""'
              d = ""
          if col isnt "notes"
            d$(fieldSelector).attr("value",d)
          else
            width = $("#modal-taxon-edit").width() * .9
            d$(fieldSelector).css("width","#{width}px")
            textarea = d$(fieldSelector).get(0).textarea
            $(textarea).text(d)
            try
              # This is different than the docs;
              # see
              # https://github.com/PolymerElements/iron-autogrow-textarea/issues/24
              d$(fieldSelector).get(0)._update()
            catch e
              console.warn "Couldn't update the textarea! See", "https://github.com/PolymerElements/iron-autogrow-textarea/issues/24"
      # Finally, open the editor
      modalElement = $("#modal-taxon-edit")[0]
      $("#modal-taxon-edit").on "iron-overlay-opened", ->
        modalElement.fit()
        modalElement.scrollTop = 0
        if toFloat($(modalElement).css("top").slice(0,-2)) > $(window).height()
          # Firefox is weird about this sometimes ...
          # Let's add a catch-all 'top' adjustment
          $(modalElement).css("top","12.5vh")
        delay 250, ->
          modalElement.fit()
      modalElement.sizingTarget = d$("#modal-taxon-editor")[0]
      safariDialogHelper("#modal-taxon-edit")
      # $("#modal-taxon-edit")[0].open()
      stopLoad()
    catch e
      stopLoadError("Unable to populate the editor for this taxon - #{e.message}")
  .fail (result,status) ->
    stopLoadError("There was a server error populating this taxon. Please try again.")
  false

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
    "major-common-type"
    "major-subtype"
    "minor-type"
    "linnean-order"
    "genus-authority"
    "species-authority"
    "notes"
    "image"
    "image-credit"
    "image-license"
    "taxon-author"
    "taxon-credit"
    "taxon-credit-date"
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
        console.warn("#{authYearDeepInputSelector} failed its validity checks for #{yearString}!")
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
          throw Error("Looks like there may be an extra space, or forgotten \", near '#{trimmedYearString}'")
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
    "taxon_credit"
    "image"
    "image_credit"
    "image_license"
    ]
  # List of IDs that can't be empty
  # Reserved use pending
  # https://github.com/jashkenas/coffeescript/issues/3594
  requiredNotEmpty = [
    "common-name"
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
    # console.log(k,id)
    col = id.replace(/-/g,"_")
    unless col is "notes"
      val = d$("#edit-#{id}").val().trim()
    else
      val = d$("#edit-notes").get(0).textarea.value
    unless col in keepCase
      # We want these to be as literally typed, rather than
      # smart-formatted.
      # Deprecated scientifics are already taken care of.
      val = val.toLowerCase()
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
      when "common-name", "major-type", "linnean-order", "genus-authority", "species-authority"
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
            spilloverError = "If you have a taxon credit, it also needs a date"
          if isNull(val)
            d$("#edit-#{id}")
            .attr("error-message",spilloverError)
            .attr("invalid","invalid")
            escapeCompletion = true
    # Finally, tack it on to the saveObject
    saveObject[col] = val
  # We've ended the loop! Did we hit an escape condition?
  if escapeCompletion
    animateLoad()
    consoleError = completionErrorMessage ? "Bad characters in entry. Stopping ..."
    completionErrorMessage ?= "There was a problem with your entry. Please correct your entry and try again."
    stopLoadError(completionErrorMessage)
    console.error(consoleError)
    return true
  saveObject.id = d$("#taxon-id").val()
  # The parens checks
  saveObject.parens_auth_genus = d$("#genus-authority-parens").polymerChecked()
  saveObject.parens_auth_species = d$("#species-authority-parens").polymerChecked()
  saveObject.is_alien = d$("#is-alien").polymerChecked()
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
        console.error("Warning! The item saved, even though it wasn't supposed to.")
        return false
      d$("#modal-taxon-edit").get(0).close()
      unless isNull($("#admin-search").val())
        renderAdminSearchResults()
      return false
    stopLoadError()
    toastStatusMessage(result.human_error)
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
    caller.addClass("extreme-danger")
    delay 7500, ->
      caller.removeClass("extreme-danger")
    toastStatusMessage("Click again to confirm deletion of #{taxon}")
    return false
  if window.deleteWatchTimer?
    # It has been less than 300 ms since delete was first tapped.
    # Deny it.
    diff = Date.now() - window.deleteWatchTimer
    console.warn("The taxon was asked to be deleted #{diff}ms after the confirmation was prompted. Rejecting ...")
    return false
  animateLoad()
  args = "perform=delete&id=#{taxaId}"
  $.post(adminParams.apiTarget,args,"json")
  .done (result) ->
    if result.status is true
      # Remove the visual row
      caller.parents("tr").remove()
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
        asm.dropzone.disable()
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
  loadJS("bower_components/JavaScript-MD5/js/md5.min.js")
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
    asm.dropzone = fileUploadDropzone
  false


$ ->
  if $("#next").exists()
    $("#next")
    .unbind()
    .click ->
      openTab(adminParams.adminPageUrl)
  loadJS "https://mammaldiversity.org/cndb/bower_components/bootstrap/dist/js/bootstrap.min.js", ->
    $("[data-toggle='tooltip']").tooltip()
  # The rest of the onload for the admin has been moved to the core.coffee file.
