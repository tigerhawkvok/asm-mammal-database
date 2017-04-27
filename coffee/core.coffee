uri = new Object()
uri.o = $.url()
uri.urlString = uri.o.attr('protocol') + '://' + uri.o.attr('host')  + uri.o.attr("directory")
# For mod_rewrite fanciness
try
  uri.urlString = uri.urlString.replace /(.*)\/(((&?[a-zA-Z_\-]+=[a-zA-Z_\-\+0-9%=]+)+)\/?)(.*)/img, "$1/"
uri.query = uri.o.attr("fragment")
domainPlaceholder = uri.o.attr("host").split "."
# Now we pop off the last before taking the zero-index
# This preserves behaviour around localhost
domainPlaceholder.pop()
uri.domain = domainPlaceholder[0] ? ""



_metaStatus = new Object()

window.locationData = new Object()
locationData.params =
  enableHighAccuracy: true
locationData.last = undefined

isBool = (str) -> str is true or str is false

isEmpty = (str) -> not str or str.length is 0

isBlank = (str) -> not str or /^\s*$/.test(str)

isNull = (str, dirty = false) ->
  if typeof str is "object"
    try
      l = str.length
      if l?
        try
          return l is 0
      return Object.size is 0
  try
    if isEmpty(str) or isBlank(str) or not str?
      #unless (str is false or str is 0) and not dirty
      unless str is false or str is 0
        return true
      if dirty
        if str is false or str is 0
          return true
  catch e
    return false
  try
    str = str.toString().toLowerCase()
  if str is "undefined" or str is "null"
    return true
  if dirty and (str is "false" or str is "0")
    return true
  false


isJson = (str) ->
  if typeof str is 'object' then return true
  try
    JSON.parse(str)
    return true
  false

isArray = (arr) ->
  try
    shadow = arr.slice 0
    shadow.push "foo"
    return true
  catch
    return false

isNumber = (n) -> not isNaN(parseFloat(n)) and isFinite(n)

isNumeric = (n) -> isNumber(n)

toFloat = (str, strict = false) ->
  if not isNumber(str) or isNull(str)
    if strict
      return NaN
    return 0
  parseFloat(str)

toInt = (str, strict = false) ->
  if not isNumber(str) or isNull(str)
    if strict
      return NaN
    return 0
  parseInt(str)



toObject = (array) ->
  rv = new Object()
  for index, element of array
    if element isnt undefined then rv[index] = element
  rv

String::toAscii = ->
  ###
  # Remove MS Word bullshit
  ###
  @replace(/[\u2018\u2019\u201A\u201B\u2032\u2035]/g, "'")
    .replace(/[\u201C\u201D\u201E\u201F\u2033\u2036]/g, '"')
    .replace(/[\u2013\u2014]/g, '-')
    .replace(/[\u2026]/g, '...')
    .replace(/\u02C6/g, "^")
    .replace(/\u2039/g, "")
    .replace(/[\u02DC|\u00A0]/g, " ")


String::toBool = -> @toString() is 'true'

Boolean::toBool = -> @toString() is 'true' # In case lazily tested

Number::toBool = -> @toString() is "1"


String::addSlashes = ->
  `this.replace(/[\\"']/g, '\\$&').replace(/\u0000/g, '\\0')`

Array::max = -> Math.max.apply null, this

Array::min = -> Math.min.apply null, this

Array::containsObject = (obj) ->
  # Value-ish rather than indexOf
  # Uses underscore, but since I don't usually use it ...
  try
    res = _.find this, (val) ->
      _.isEqual obj, val
    typeof res is "object"
  catch e
    console.error "Please load underscore.js before using this."
    console.info  "https://cdnjs.cloudflare.com/ajax/libs/underscore.js/1.8.3/underscore-min.js"

Object.toArray = (obj) ->
  try
    shadowObj = obj.slice 0
    shadowObj.push "foo" # Throws error on obj
    return obj
  Object.keys(obj).map (key) =>
    obj[key]

Object.size = (obj) ->
  if typeof obj isnt "object"
    try
      return obj.length
    catch e
      console.error("Passed argument isn't an object and doesn't have a .length parameter")
      console.warn(e.message)
  size = 0
  size++ for key of obj when obj.hasOwnProperty(key)
  size

Object.doOnSortedKeys = (obj, fn) ->
  sortedKeys = Object.keys(obj).sort()
  for key in sortedKeys
    data = obj[key]
    fn data


delay = (ms,f) -> setTimeout(f,ms)
interval = (ms,f) -> setInterval(f,ms)

roundNumber = (number,digits = 0) ->
  multiple = 10 ** digits
  Math.round(number * multiple) / multiple



roundNumberSigfig = (number, digits = 0) ->
  newNumber = roundNumber(number, digits).toString()
  digArr = newNumber.split(".")
  if digArr.length is 1
    return "#{newNumber}.#{Array(digits + 1).join("0")}"
  trailingDigits = digArr.pop()
  significand = "#{digArr[0]}."
  if trailingDigits.length is digits
    return newNumber
  needDigits = digits - trailingDigits.length
  trailingDigits += Array(needDigits + 1).join("0")
  "#{significand}#{trailingDigits}"


String::stripHtml = (stripChildren = false) ->
  str = this
  if stripChildren
    # Pull out the children
    str = str.replace /<(\w+)(?:[^"'>]|"[^"]*"|'[^']*')*>(?:((?:.)*?))<\/?\1(?:[^"'>]|"[^"]*"|'[^']*')*>/mg, ""
  # Script tags
  str = str.replace /<script[^>]*>([\S\s]*?)<\/script>/gmi, ''
  # HTML tags
  str = str.replace /<\/?\w(?:[^"'>]|"[^"]*"|'[^']*')*>/gmi, ''
  str

String::unescape = (strict = false) ->
  ###
  # Take escaped text, and return the unescaped version
  #
  # @param string str | String to be used
  # @param bool strict | Stict mode will remove all HTML
  #
  # Test it here:
  # https://jsfiddle.net/tigerhawkvok/t9pn1dn5/
  #
  # Code: https://gist.github.com/tigerhawkvok/285b8631ed6ebef4446d
  ###
  # Create a dummy element
  element = document.createElement("div")
  decodeHTMLEntities = (str) ->
    if str? and typeof str is "string"
      unless strict is true
        # escape HTML tags
        str = escape(str).replace(/%26/g,'&').replace(/%23/g,'#').replace(/%3B/g,';')
      else
        str = str.replace(/<script[^>]*>([\S\s]*?)<\/script>/gmi, '')
        str = str.replace(/<\/?\w(?:[^"'>]|"[^"]*"|'[^']*')*>/gmi, '')
      element.innerHTML = str
      if element.innerText
        # Do we support innerText?
        str = element.innerText
        element.innerText = ""
      else
        # Firefox
        str = element.textContent
        element.textContent = ""
    unescape(str)
  # Remove encoded or double-encoded tags
  tmp = deEscape(this)
  # Run it
  decodeHTMLEntities(tmp)


deEscape = (string) ->
  string = string.replace(/\&amp;#/mg, '&#') # The rest
  string = string.replace(/\&quot;/mg, '"')
  string = string.replace(/\&quote;/mg, '"')
  string = string.replace(/\&#95;/mg, '_')
  string = string.replace(/\&#39;/mg, "'")
  string = string.replace(/\&#34;/mg, '"')
  string = string.replace(/\&#62;/mg, '>')
  string = string.replace(/\&#60;/mg, '<')
  string


String::escapeQuotes = ->
  str = this.replace /"/mg, "&#34;"
  str = str.replace /'/mg, "&#39;"
  str


getElementHtml = (el) ->
  el.outerHTML


jQuery.fn.outerHTML = ->
  e = $(this).get(0)
  e.outerHTML


jQuery.fn.outerHtml = ->
  $(this).outerHTML()

`
jQuery.fn.selectText = function(){
    var doc = document
        , element = this[0]
        , range, selection
    ;
    if (doc.body.createTextRange) {
        range = document.body.createTextRange();
        range.moveToElementText(element);
        range.select();
    } else if (window.getSelection) {
        selection = window.getSelection();
        range = document.createRange();
        range.selectNodeContents(element);
        selection.removeAllRanges();
        selection.addRange(range);
    }
};
`

jQuery.fn.exists = -> jQuery(this).length > 0

jQuery.fn.polymerSelected = (setSelected = undefined, attrLookup = "attrForSelected", dropdownSelector = "paper-listbox", childElement = "paper-item", ignoreCase = true) ->
  ###
  # See
  # https://elements.polymer-project.org/elements/paper-menu
  # https://elements.polymer-project.org/elements/paper-radio-group
  #
  # @param setSelected ->
  # @param attrLookup is based on
  # https://elements.polymer-project.org/elements/iron-selector?active=Polymer.IronSelectableBehavior
  # @param childElement
  # @param ignoreCase -> match lower case trimmed values
  ###
  unless $(this).exists()
    console.error "Nonexistant element"
    return false
  dropdownId = $(this).attr "id"
  if isNull dropdownId
    console.error "Your parent dropdown (eg, paper-dropdown-menu) must have a unique ID"
    return false
  dropdownUniqueSelector = "##{dropdownId} #{dropdownSelector}"
  try
    if dropdownSelector is $(this).get(0).tagName.toLowerCase()
      dropdownUniqueSelector = this
  unless $(dropdownUniqueSelector).exists()
    dropdownSelector = "paper-menu"
    dropdownUniqueSelector = "##{dropdownId} #{dropdownSelector}"
    try
      if dropdownSelector is $(this).get(0).tagName.toLowerCase()
        dropdownUniqueSelector = this
    unless $(dropdownUniqueSelector).exists()
      try
        # Maybe it's a generic input element
        unless isNull p$(this).value
          return p$(this).value
        return null
      catch
        console.error "Can't identify the dropdown selector for this dropdown list '#{dropdownId}'", dropdownUniqueSelector, this
      console.warn "Unable to fetch data for item", "##{dropdownId}"
      return false
  unless attrLookup is true
    attr = $(dropdownUniqueSelector).attr(attrLookup)
    if isNull attr
      attr = true
  else
    # If we pass the flag true, we get the label instead
    attr = true
  if setSelected?
    selector = dropdownUniqueSelector
    if not isBool(setSelected) and not isNull setSelected
      try
        if attr is true
          for item in $(this).find childElement
            text = if ignoreCase then $(item).text().toLowerCase().trim() else $(item).text()
            selectedMatch = if ignoreCase then setSelected.toLowerCase().trim() else setSelected
            if text is selectedMatch
              index = $(item).index()
              break
          # Set the index
          if isNull index
            console.error "Unable to find an index for #{childElement} with text '#{setSelected}' (ignore case: #{ignoreCase})"
            return false
          try
            p$(selector).select index
          catch e
            p$(selector).selected = index
          if p$(selector).selected isnt index
            doNothing()
        else
          try
            p$(selector).select setSelected
          catch
            p$(selector).selected = setSelected
        return true
      catch e
        console.error "Unable to set selected '#{setSelected}': #{e.message}"
        return false
    else if isBool setSelected
      $(this).parent().children().removeAttribute("aria-selected")
      $(this).parent().children().removeAttribute("active")
      $(this).parent().children().removeClass("iron-selected")
      $(this).prop("selected",setSelected)
      $(this).prop("active",setSelected)
      $(this).prop("aria-selected",setSelected)
      if setSelected is true
        $(this).addClass("iron-selected")
  else
    val = undefined
    try
      try
        val = p$(this).selected
      if isNull val
        val = p$(dropdownUniqueSelector).selected
      if isNumber(val) and not isNull(attr)
        itemSelector = $(this).find(childElement)[toInt(val)]
        unless attr is true
          val = $(itemSelector).attr(attr)
        else
          # Fetch the label
          val = $(itemSelector).text()
      else
        console.debug "isNumber(val)", isNumber val, val
        console.debug "isNull attr", isNull attr, attr
    catch e
      console.error "Couldn't find selected: #{e.message}"
      console.warn e.stack
      console.debug "Selector", dropdownUniqueSelector
      return false
    if val is "null" or not val?
      val = undefined
    try
      val = val.trim()
    val

jQuery.fn.polymerChecked = (setChecked = undefined) ->
  # See
  # https://www.polymer-project.org/docs/elements/paper-elements.html#paper-dropdown-menu
  if setChecked?
    jQuery(this).prop("checked",setChecked)
  else
    val = jQuery(this)[0].checked
    if val is "null" or not val?
      val = undefined
    val

jQuery.fn.isVisible = ->
  jQuery(this).css("display") isnt "none"

jQuery.fn.hasChildren = ->
  Object.size(jQuery(this).children()) > 3

byteCount = (s) => encodeURI(s).split(/%..|./).length - 1

`function shuffle(o) { //v1.0
    for (var j, x, i = o.length; i; j = Math.floor(Math.random() * i), x = o[--i], o[i] = o[j], o[j] = x);
    return o;
}`

randomInt = (lower = 0, upper = 1) ->
  start = Math.random()
  if not lower?
    [lower, upper] = [0, lower]
  if lower > upper
    [lower, upper] = [upper, lower]
  return Math.floor(start * (upper - lower + 1) + lower)


window.debounce_timer = null

Function::getName = ->
  ###
  # Returns a unique identifier for a function
  ###
  name = this.name
  unless name?
    name = this.toString().substr( 0, this.toString().indexOf( "(" ) ).replace( "function ", "" );
  if isNull name
    name = md5 this.toString()
  name

Function::debounce = (threshold = 300, execAsap = false, timeout = window.debounce_timer, args...) ->
  ###
  # Borrowed from http://coffeescriptcookbook.com/chapters/functions/debounce
  # Only run the prototyped function once per interval.
  #
  # @param threshold -> Timeout in ms
  # @param execAsap -> Do it NAOW
  # @param timeout -> backup timeout object
  ###
  unless window.core?.debouncers?
    unless window.core?
      window.core = new Object()
    core.debouncers = new Object()
  try
    key = this.getName()
  try
    if core.debouncers[key]?
      timeout = core.debouncers[key]
  func = this
  delayed = ->
    if key?
      clearTimeout timeout
      delete core.debouncers[key]
    func.apply(func, args) unless execAsap
    # console.debug "Debounce executed for #{key}"
  if timeout?
    try
      clearTimeout timeout
    catch e
      # just do nothing
  if execAsap
    func.apply(obj, args)
    console.debug "Executed #{key} immediately"
    return false
  if key?
    #console.debug "Debouncing '#{key}' for #{threshold} ms"
    core.debouncers[key] = delay threshold, ->
      delayed()
  else
    # console.log "Delaying '#{key}' for GLOBAL #{threshold} ms"
    window.debounce_timer = delay threshold, ->
      delayed()



loadJS = (src, callback = new Object(), doCallbackOnError = true) ->
  ###
  # Load a new javascript file
  #
  # If it's already been loaded, jump straight to the callback
  #
  # @param string src The source URL of the file
  # @param function callback Function to execute after the script has
  #                          been loaded
  # @param bool doCallbackOnError Should the callback be executed if
  #                               loading the script produces an error?
  ###
  if $("script[src='#{src}']").exists()
    if typeof callback is "function"
      try
        callback()
      catch e
        console.error "Script is already loaded, but there was an error executing the callback function - #{e.message}"
    # Whether or not there was a callback, end the script
    return true
  # Create a new DOM selement
  s = document.createElement("script")
  # Set all the attributes. We can be a bit redundant about this
  s.setAttribute("src",src)
  s.setAttribute("async","async")
  s.setAttribute("type","text/javascript")
  s.src = src
  s.async = true
  # Onload function
  onLoadFunction = ->
    state = s.readyState
    try
      if not callback.done and (not state or /loaded|complete/.test(state))
        callback.done = true
        if typeof callback is "function"
          try
            callback()
          catch e
            console.error "Postload callback error for '#{src}' - #{e.message}"
    catch e
      console.error "Onload error for '#{src}' - #{e.message}"
  # Error function
  errorFunction = ->
    console.warn "There may have been a problem loading #{src}"
    try
      unless callback.done
        callback.done = true
        if typeof callback is "function" and doCallbackOnError
          try
            callback()
          catch e
            console.error "Post error callback error - #{e.message}"
    catch e
      console.error "There was an error in the error handler! #{e.message}"
  # Set the attributes
  s.setAttribute("onload",onLoadFunction)
  s.setAttribute("onreadystate",onLoadFunction)
  s.setAttribute("onerror",errorFunction)
  s.onload = s.onreadystate = onLoadFunction
  s.onerror = errorFunction
  document.getElementsByTagName('head')[0].appendChild(s)
  true


String::toTitleCase = ->
  # From http://stackoverflow.com/a/6475125/1877527
  str =
    @replace /([^\W_]+[^\s-]*) */g, (txt) ->
      txt.charAt(0).toUpperCase() + txt.substr(1).toLowerCase()

  # Certain minor words should be left lowercase unless
  # they are the first or last words in the string
  lowers = [
    "A"
    "An"
    "The"
    "And"
    "But"
    "Or"
    "For"
    "Nor"
    "As"
    "At"
    "By"
    "For"
    "From"
    "In"
    "Into"
    "Near"
    "Of"
    "On"
    "Onto"
    "To"
    "With"
    ]
  for lower in lowers
    lowerRegEx = new RegExp("\\s#{lower}\\s","g")
    str = str.replace lowerRegEx, (txt) -> txt.toLowerCase()

  # Certain words such as initialisms or acronyms should be left
  # uppercase
  uppers = [
    "Id"
    "Tv"
    ]
  for upper in uppers
    upperRegEx = new RegExp("\\b#{upper}\\b","g")
    str = str.replace upperRegEx, upper.toUpperCase()
  str


smartUpperCasing = (text) ->
  if isNull text
    return ""
  replacer = (match) ->
    return match.replace(match, match.toUpperCase())
  smartCased = text.replace(/((?=((?!-)[\W\s\r\n]))\s[A-Za-z]|^[A-Za-z])/g, replacer)
  # List of words that should be lower-cased in a title sentence
  # Uses the Associated Press simple list
  # http://www.quickanddirtytips.com/education/grammar/capitalizing-titles?page=2
  specialLowerCaseWords = [
    "a"
    "an"
    "and"
    "at"
    "but"
    "by"
    "for"
    "in"
    "nor"
    "of"
    "on"
    "or"
    "out"
    "so"
    "to"
    "the"
    "up"
    "yet"
    ]
  try
    for word in specialLowerCaseWords
      searchUpper = word.toTitleCase()
      replaceLower = word.toLowerCase()
      r = new RegExp " #{searchUpper} ", "g"
      smartCased = smartCased.replace r, " #{replaceLower} "
  try
    ###
    # Uppercase the second part of a dash
    #
    # See:
    # http://regexr.com/3ef62
    #
    # https://github.com/SSARHERPS/SSAR-species-database/issues/87#issuecomment-254108675
    ###
    if smartCased.match /([a-zA-Z]+ )*[a-zA-Z]+-([a-z]+)( [a-zA-Z]+)*/m
      secondWord = smartCased.replace /([a-zA-Z]+ )*[a-zA-Z]+-([a-z]+)( [a-zA-Z]+)*/mg, "$2"
      secondWordCased = secondWord.toTitleCase()
      smartCased = smartCased.replace secondWord, secondWordCased
  smartCased


mapNewWindows = (stopPropagation = true) ->
  # Do new windows
  $(".newwindow").each ->
    # Add a click and keypress listener to
    # open links with this class in a new window
    curHref = $(this).attr("href")
    if not curHref?
      # Support non-standard elements
      curHref = $(this).attr("data-href")
    openInNewWindow = (url) ->
      if not url? then return false
      window.open(url)
      return false
    $(this).click (e) ->
      if stopPropagation
        e.preventDefault()
        e.stopPropagation()
      openInNewWindow(curHref)
    $(this).keypress ->
      openInNewWindow(curHref)

# Animations

toastStatusMessage = (message, className = "", duration = 3000, selector = "#search-status") ->
  ###
  # Pop up a status message
  ###
  if window._metaStatus.isToasting is true
    delay 250, ->
      # Wait and call again
      toastStatusMessage(message, className, duration, selector)
    return false
  window._metaStatus.isToasting = true
  if isNumber className
    duration = className
  if not isNumber(duration)
    duration = 3000
  if selector.slice(0,1) is not "#"
    selector = "##{selector}"
  if not $(selector).exists()
    html = "<paper-toast id=\"#{selector.slice(1)}\" duration=\"#{duration}\"></paper-toast>"
    $(html).appendTo("body")
  $(selector)
  .attr("text",message)
  .text(message)
  .addClass(className)
  do showLoader = (i = 0) ->
    ++i
    try
      p$(selector).show()
      delay duration + 500, ->
        # A short time after it hides, clean it up
        try
          isOpen = p$(selector).opened
        unless typeof isOpen is "boolean"
          isOpen = false
        unless isOpen
          $(selector).empty()
          $(selector).removeClass(className)
          $(selector).attr("text","")
        window._metaStatus.isToasting = false
        false
    catch error
      if i <= 50
        delay 50, ->
          showLoader i
          false
      else
        console.error "Couldn't show loader: #{error.message}"
        console.warn error.stack
  delay duration, ->
    _metaStatus.isToasting = false
  false

openLink = (url) ->
  if not url? then return false
  window.open(url)
  false

openTab = (url) ->
  openLink(url)

goTo = (url) ->
  if not url? then return false
  window.location.href = url
  false

unless _metaStatus?.isLoading?
  unless _metaStatus?
    window._metaStatus = new Object()
  _metaStatus.isLoading = false
  _metaStatus.isToasting = false

animateLoad = (elId = "loader", iteration = 0) ->
  ###
  # Suggested CSS to go with this:
  #
  # #loader {
  #     position:fixed;
  #     top:50%;
  #     left:50%;
  # }
  # #loader.good::shadow .circle {
  #     border-color: rgba(46,190,17,0.9);
  # }
  # #loader.bad::shadow .circle {
  #     border-color:rgba(255,0,0,0.9);
  # }
  ###
  if isNumber(elId) then elId = "loader"
  if elId.slice(0,1) is "#"
    selector = elId
    elId = elId.slice(1)
  else
    selector = "##{elId}"
  ###
  # This is there for Edge, which sometimes leaves an element
  # We declare this early because Polymer tries to be smart and not
  # actually activate when it's hidden. Thus, this is a prerequisite
  # to actually re-showing it once hidden.
  ###
  $(selector).removeAttr("hidden")
  unless _metaStatus?.isLoading?
    unless _metaStatus?
      _metaStatus = new Object()
    _metaStatus.isLoading = false
  try
    if _metaStatus.isLoading
      # Don't do this again until it's done loading.
      if iteration < 100
        iteration++
        delay 100, ->
          animateLoad(elId, iteration)
        return false
      else
        # Still not done loading? This probably isn't important
        # anymore.
        console.warn("Loader timed out waiting for load completion")
        return false
    unless $(selector).exists()
      $("body").append("<paper-spinner id=\"#{elId}\" active></paper-spinner")
    else
      $(selector)
      .attr("active",true) # Chrome, etc., want this
      #.prop("active",true) # Edge wants this
    _metaStatus.isLoading = true
    false
  catch e
    console.warn('Could not animate loader', e.message)


startLoad = (elementId = null) ->
  animateLoad(elementId)


stopLoad = (elId = "loader", fadeOut = 1000, iteration = 0) ->
  if elId.slice(0,1) is "#"
    selector = elId
    elId = elId.slice(1)
  else
    selector = "##{elId}"
  try
    try
      if _metaStatus.isLoading isnt true and p$(selector).active and $(selector).isVisible()
        _metaStatus.isLoading = true
    unless _metaStatus.isLoading
      # Wait until it's loading before executing again
      if iteration < 100
        iteration++
        delay 100, ->
          stopLoad(elId, fadeOut, iteration)
        return false
      else
        # Probably not worth waiting for anymore
        return false
    if $(selector).exists()
      $(selector).addClass("good")
      do endLoad = ->
        delay fadeOut, ->
          try
            p$(selector).active = false
          $(selector)
          .removeClass("good")
          .attr("active",false)
          .removeAttr("active")
          # Timeout for animations. There aren't any at the moment,
          # but leaving this as a placeholder.
          delay 1, ->
            $(selector).prop("hidden",true) # This is there for Edge, which sometimes leaves an element
            ###
            # Now, the slower part.
            # Edge does weirdness with active being toggled off, but
            # everyone else should have hidden removed so animateLoad()
            # behaves well. So, we check our browser sniffing.
            ###
            if Browsers?.browser?
              aliases = [
                "Spartan"
                "Project Spartan"
                "Edge"
                "Microsoft Edge"
                "MS Edge"
                ]
              if Browsers.browser.browser.name in aliases or Browsers.browser.engine.name is "EdgeHTML"
                # Nuke it from orbit. It's a slight performance hit, but
                # it's the only way to be sure.
                $(selector).remove()
                _metaStatus.isLoading = false
              else
                $(selector).removeAttr("hidden")
                delay 50, ->
                  # Give the DOM a chance to reflect it's no longer hidden
                  _metaStatus.isLoading = false
            else
              # Just default to "everything but Edge"
              $(selector).removeAttr("hidden")
              delay 50, ->
                # Give the DOM a chance to reflect it's no longer hidden
                _metaStatus.isLoading = false
    false
  catch e
    console.warn('Could not stop load animation', e.message)


stopLoadError = (message, elId = "loader", fadeOut = 7500, iteration) ->
  if elId.slice(0,1) is "#"
    selector = elId
    elId = elId.slice(1)
  else
    selector = "##{elId}"
  try
    unless _metaStatus.isLoading
      # Wait until it's loading before executing again
      if iteration < 100
        iteration++
        delay 100, ->
          stopLoadError(message, elId, fadeOut, iteration)
        return false
      else
        # Probably not worth waiting for anymore
        return false
    if $(selector).exists()
      $(selector).addClass("bad")
      if message? then toastStatusMessage(message,"",fadeOut)
      do endLoad = ->
        delay fadeOut, ->
          $(selector)
          .removeClass("bad")
          .prop("active",false)
          .removeAttr("active")
          # Timeout for animations. There aren't any at the moment,
          # but leaving this as a placeholder.
          delay 1, ->
            $(selector).prop("hidden",true) # This is there for Edge, which sometimes leaves an element
            ###
            # Now, the slower part.
            # Edge does weirdness with active being toggled off, but
            # everyone else should have hidden removed so animateLoad()
            # behaves well. So, we check our browser sniffing.
            ###
            if Browsers?.browser?
              aliases = [
                "Spartan"
                "Project Spartan"
                "Edge"
                "Microsoft Edge"
                "MS Edge"
                ]
              if Browsers.browser.browser.name in aliases or Browsers.browser.engine.name is "EdgeHTML"
                # Nuke it from orbit. It's a slight performance hit, but
                # it's the only way to be sure.
                $(selector).remove()
                _metaStatus.isLoading = false
              else
                $(selector).removeAttr("hidden")
                delay 50, ->
                  # Give the DOM a chance to reflect it's no longer hidden
                  _metaStatus.isLoading = false
            else
              # Just default to "everything but Edge"
              $(selector).removeAttr("hidden")
              delay 50, ->
                # Give the DOM a chance to reflect it's no longer hidden
                _metaStatus.isLoading = false
    false
  catch e
    console.warn('Could not stop load error animation', e.message)



doCORSget = (url, args, callback = undefined, callbackFail = undefined) ->
  corsFail = ->
    if typeof callbackFail is "function"
      callbackFail()
    else
      throw new Error("There was an error performing the CORS request")
  # First try the jquery way
  settings =
    url: url
    data: args
    type: "get"
    crossDomain: true
  try
    $.ajax(settings)
    .done (result) ->
      if typeof callback is "function"
        callback()
        return false
    .fail (result,status) ->
      console.warn("Couldn't perform jQuery AJAX CORS. Attempting manually.")
  catch e
    console.warn("There was an error using jQuery to perform the CORS request. Attemping manually.")
  # Then try the long way
  url = "#{url}?#{args}"
  createCORSRequest = (method = "get", url) ->
    # From http://www.html5rocks.com/en/tutorials/cors/
    xhr = new XMLHttpRequest()
    if "withCredentials" of xhr
      # Check if the XMLHttpRequest object has a "withCredentials"
      # property.
      # "withCredentials" only exists on XMLHTTPRequest2 objects.
      xhr.open(method,url,true)
    else if typeof XDomainRequest isnt "undefined"
      # Otherwise, check if XDomainRequest.
      # XDomainRequest only exists in IE, and is IE's way of making CORS requests.
      xhr = new XDomainRequest()
      xhr.open(method,url)
    else
      xhr = null
    return xhr
  # Now execute it
  xhr = createCORSRequest("get",url)
  if !xhr
    throw new Error("CORS not supported")
  xhr.onload = ->
    response = xhr.responseText
    if typeof callback is "function"
      callback(response)
    return false
  xhr.onerror = ->
    console.warn("Couldn't do manual XMLHttp CORS request")
    # Place this in the last error
    corsFail()
  xhr.send()
  false



deepJQuery = (selector) ->
  ###
  # Do a shadow-piercing selector
  #
  # Cross-browser, works with Chrome, Firefox, Opera, Safari, and IE
  # Falls back to standard jQuery selector when everything fails.
  ###
  try
    # Chrome uses /deep/ which has been deprecated
    # See http://dev.w3.org/csswg/css-scoping/#deep-combinator
    # https://w3c.github.io/webcomponents/spec/shadow/#composed-trees
    # This is current as of Chrome 44.0.2391.0 dev-m
    # See https://code.google.com/p/chromium/issues/detail?id=446051
    #
    # However, this is pending deprecation.
    unless $("html /deep/ #{selector}").exists()
      throw("Bad /deep/ selector")
    return $("html /deep/ #{selector}")
  catch e
    try
      # Firefox uses >>> instead of "deep"
      # https://developer.mozilla.org/en-US/docs/Web/Web_Components/Shadow_DOM
      # This is actually the correct selector
      unless $("html >>> #{selector}").exists()
        throw("Bad >>> selector")
      return $("html >>> #{selector}")
    catch e
      # These don't match at all -- do the normal jQuery selector
      return $(selector)


p$ = (selector) ->
  # Try to get an object the Polymer way, then if it fails,
  # do jQuery
  try
    $$(selector)[0]
  catch
    try
      $(selector).get(0)
    catch
      d$(selector).get(0)

window.d$ = (selector) ->
  deepJQuery(selector)


lightboxImages = (selector = ".lightboximage", lookDeeply = false) ->
  ###
  # Lightbox images with this selector
  #
  # If the image has it, wrap it in an anchor and bind;
  # otherwise just apply to the selector.
  #
  # Requires ImageLightbox
  # https://github.com/rejas/imagelightbox
  ###
  # The options!
  options =
      onStart: ->
        overlayOn()
      onEnd: ->
        overlayOff()
        activityIndicatorOff()
      onLoadStart: ->
        activityIndicatorOn()
      onLoadEnd: ->
        activityIndicatorOff()
      allowedTypes: 'png|jpg|jpeg|gif|bmp|webp'
      quitOnDocClick: true
      quitOnImgClick: true
  _asm.lightbox =
    options: options
  jqo = if lookDeeply then d$(selector) else $(selector)
  loadJS "bower_components/imagelightbox/dist/imagelightbox.min.js", ->
    jqo
    .click (e) ->
      try
        # We want to stop the events propogating up for these
        e.preventDefault()
        e.stopPropagation()
        $(this).imageLightbox(options).startImageLightbox()
        console.warn("Event propagation was stopped when clicking on this.")
      catch e
        console.error("Unable to lightbox this image!")
    # Set up the items
    .each ->
      console.log("Using selectors '#{selector}' / '#{this}' for lightboximages")
      try
        if ($(this).prop("tagName").toLowerCase() is "img" or $(this).prop("tagName").toLowerCase() is "picture")and $(this).parent().prop("tagName").toLowerCase() isnt "a"
          tagHtml = $(this).removeClass("lightboximage").prop("outerHTML")
          imgUrl = switch
            when not isNull $(this).attr("data-layzr-retina")
              $(this).attr "data-layzr-retina"
            when not isNull $(this).attr("data-layzr")
              $(this).attr "data-layzr"
            when not isNull $(this).attr("data-lightbox-image")
              $(this).attr "data-lightbox-image"
            when not isNull $(this).attr("src")
              $(this).attr "src"
            else
              $(this).find("img").attr "src"
          $(this).replaceWith("<a href='#{imgUrl}' data-lightbox='#{imgUrl}' class='lightboximage'>#{tagHtml}</a>")
          $("a[href='#{imgUrl}']").imageLightbox(options)
        # Otherwise, we shouldn't need to do anything
      catch e
        console.log("Couldn't parse through the elements")
    console.info "Lightboxed the following:", jqo
  false




activityIndicatorOn = ->
  $('<div id="imagelightbox-loading"><div></div></div>' ).appendTo('body')
activityIndicatorOff = ->
  $('#imagelightbox-loading').remove()
  $("#imagelightbox-overlay").click ->
    # Clicking anywhere on the overlay clicks on the image
    # It loads too late to let the quitOnDocClick work
    $("#imagelightbox").click()
overlayOn = ->
  $('<div id="imagelightbox-overlay"></div>').appendTo('body')
overlayOff = ->
  $('#imagelightbox-overlay').remove()

formatScientificNames = (selector = ".sciname") ->
    $(".sciname").each ->
      # Is it italic?
      nameStyle = if $(this).css("font-style") is "italic" then "normal" else "italic"
      $(this).css("font-style",nameStyle)

prepURI = (string) ->
  string = encodeURIComponent(string)
  string.replace(/%20/g,"+")


getLocation = (callback = undefined) ->
  geoSuccess = (pos,callback) ->
    window.locationData.lat = pos.coords.latitude
    window.locationData.lng = pos.coords.longitude
    window.locationData.acc = pos.coords.accuracy
    window.locationData.last = Date.now() # ms, unix time
    if callback?
      callback(window.locationData)
    false
  geoFail = (error,callback) ->
    locationError = switch error.code
      when 0 then "There was an error while retrieving your location: #{error.message}"
      when 1 then "The user prevented this page from retrieving a location"
      when 2 then "The browser was unable to determine your location: #{error.message}"
      when 3 then "The browser timed out retrieving your location."
    console.error(locationError)
    if callback?
      callback(false)
    false
  if navigator.geolocation
    navigator.geolocation.getCurrentPosition(geoSuccess,geoFail,window.locationData.params)
  else
    console.warn("This browser doesn't support geolocation!")
    if callback?
      callback(false)



dateMonthToString = (month) ->
  conversionObj =
    0: "January"
    1: "February"
    2: "March"
    3: "April"
    4: "May"
    5: "June"
    6: "July"
    7: "August"
    8: "September"
    9: "October"
    10: "November"
    11: "December"
  try
    rv = conversionObj[month]
  catch
    rv = month
  rv



bindClickTargets = ->
  bindClicks()
  false


bindClicks = (selector = ".click") ->
  ###
  # Helper function. Bind everything with a selector
  # to execute a function data-function or to go to a
  # URL data-href.
  ###
  $(selector).each ->
    try
      url = $(this).attr("data-href")
      if isNull(url)
        url = $(this).attr("data-url")
        if url?
          $(this).attr("data-newtab","true")
      unless isNull(url)
        $(this).unbind()
        # console.log("Binding a url to ##{$(this).attr("id")}")
        try
          if url is uri.o.attr("path") and $(this).prop("tagName").toLowerCase() is "paper-tab"
            $(this).parent().prop("selected",$(this).index())
        catch e
          console.warn("tagname lower case error")
        $(this).click ->
          # Use the most up-to-date URL
          url = $(this).attr("data-href")
          if isNull(url)
            url = $(this).attr("data-url")
          if $(this).attr("newTab")?.toBool() or $(this).attr("newtab")?.toBool() or $(this).attr("data-newtab")?.toBool()
            openTab(url)
          else
            goTo(url)
        return url
      else
        # Check for onclick function
        callable = $(this).attr("data-function") ? $(this).attr("data-fn")
        if callable?
          $(this).unbind()
          # console.log("Binding #{callable}() to ##{$(this).attr("id")}")
          $(this).click ->
            try
              # console.log("Executing bound function #{callable}()")
              window[callable]()
            catch e
              console.error("'#{callable}()' is a bad function - #{e.message}")
    catch e
      console.error("There was a problem binding to ##{$(this).attr("id")} - #{e.message}")
  false

getMaxZ = ->
  mapFunction = ->
    $.map $("body *"), (e,n) ->
      if $(e).css("position") isnt "static"
        return parseInt $(e).css("z-index") or 1
  Math.max.apply null, mapFunction()

browserBeware = ->
  return false # for now
  unless Browsers?.hasCheckedBrowser?
    unless Browsers?
      window.Browsers = new Object()
    Browsers.hasCheckedBrowser = 0
  try
    browsers = new WhichBrowser()
    Browsers.browser = browsers
    # Firefox general buggieness
    if browsers.isBrowser("Firefox")
      warnBrowserHtml = """
      <div id="firefox-warning" class="alert alert-warning alert-dismissible fade in" role="alert">
        <button type="button" class="close" data-dismiss="alert" aria-label="Close"><span aria-hidden="true">&times;</span></button>
        <strong>Warning!</strong> Firefox has buggy support for <a href="http://webcomponents.org/" class="alert-link">webcomponents</a> and the <a href="https://www.polymer-project.org" class="alert-link">Polymer project</a>. If you encounter bugs, try using <a href="https://www.google.com/chrome/" class="alert-link">Chrome</a> (recommended), <a href="www.opera.com/computer" class="alert-link">Opera</a>, Safari, <a href="https://www.microsoft.com/en-us/windows/microsoft-edge" class="alert-link">Edge</a>, or your phone instead &#8212; they'll all be faster, too.
      </div>
      """
      $("#title").after(warnBrowserHtml)
      # Firefox doesn't auto-initalize the dismissable
      $(".alert").alert()
      console.warn("We've noticed you're using Firefox. Firefox has problems with this site, we recommend trying Google Chrome instead:","https://www.google.com/chrome/")
      console.warn("Firefox took #{Browsers.hasCheckedBrowser * 250}ms after page load to render this error message.")
    # Fix the collapse behaviour in IE
    if browsers.isBrowser("Internet Explorer") or browsers.isBrowser("Safari")
      $("#collapse-button").click ->
        $(".collapse").collapse("toggle")

  catch e
    if Browsers.hasCheckedBrowser is 100
      # We've waited almost 15 seconds
      console.warn("We can't check your browser!")
      console.warn("Known issues:")
      console.warn("Firefox: Some VERY buggy behaviour")
      console.warn("IE & Safari: The advanced options may not open")
      return false
    delay 250, ->
      Browsers.hasCheckedBrowser++
      browserBeware()



bsAlert = (message, type = "warning", fallbackContainer = "body", selector = "#bs-alert") ->
  ###
  # Pop up a status message
  # Uses the Bootstrap alert dialog
  #
  # See
  # http://getbootstrap.com/components/#alerts
  # for available types
  ###
  try
    if not $(selector).exists()
      html = """
      <div class="alert alert-#{type} alert-dismissable hanging-alert" role="alert" id="#{selector.slice(1)}">
        <button type="button" class="close" data-dismiss="alert" aria-label="Close"><span aria-hidden="true">&times;</span></button>
          <div class="alert-message"></div>
      </div>
      """
      topContainer = if $("main").exists() then "main" else if $("article").exists() then "article" else fallbackContainer
      $(topContainer).prepend(html)
    else
      $(selector).removeClass "alert-warning alert-info alert-danger alert-success"
      $(selector).addClass "alert-#{type}"
    $("#{selector} .alert-message").html(message)
  catch
    # This should always work, so here's an offline fallback
    alertContainer = document.createElement "div"
    alertContainer.setAttribute "class", "alert alert-#{type} alert-dismissable hanging-alert"
    alertContainer.setAttribute "role", "alert"
    alertContainer.setAttribute "id", selector.slice(1)
    closeButton = document.createElement "button"
    closeButton.setAttribute "class", "close"
    closeButton.setAttribute "data-dismiss", "alert"
    closeButton.setAttribute "aria-label", "Close"
    closeIcon = document.createElement "span"
    closeIcon.setAttribute "aria-hidden", "true"
    closeIcon.textContent = "&times;"
    closeButton.appendChild closeIcon
    alertContainer.appendChild closeButton
    alertMessage = document.createElement "div"
    alertMessage.setAttribute "class", "alert-message"
    alertMessage.textContent = message
    alertContainer.appendChild alertMessage
    try
      document.querySelector("#bs-alert").remove()
    document.querySelector("body").appendChild alertContainer
  bindClicks()
  mapNewWindows()
  false


animateHoverShadows = (selector = "paper-card.card-tile", defaultElevation = 2, raisedElevation = 4) ->
  ###
  # Set animation for paper cards to have hover shadows elevation change
  ###
  handlerIn = ->
    $(this).attr "elevation", raisedElevation
  handlerOut = ->
    $(this).attr "elevation", defaultElevation
  $(selector).hover handlerIn, handlerOut
  false


allError = (message) ->
  ###
  # Show all the errors
  ###
  stopLoadError message
  bsAlert message, "danger"
  console.error message
  false




checkFileVersion = (forceNow = false) ->
  ###
  # Check to see if the file on the server is up-to-date with what the
  # user sees.
  #
  # @param bool forceNow force a check now
  ###
  checkVersion = ->
    $.get("#{uri.urlString}meta.php","do=get_last_mod","json")
    .done (result) ->
      if forceNow
        console.log("Forced version check:",result)
      unless isNumber result.last_mod
        return false
      unless _asm.lastMod?
        _asm.lastMod = result.last_mod
      if result.last_mod > _asm.lastMod
        # File has updated
        html = """
        <div id="outdated-warning" class="alert alert-warning alert-dismissible fade in" role="alert">
          <button type="button" class="close" data-dismiss="alert" aria-label="Close"><span aria-hidden="true">&times;</span></button>
          <strong>We have page updates!</strong> This page has been updated since you last refreshed. <a class="alert-link" id="refresh-page" style="cursor:pointer">Click here to refresh now</a> and get bugfixes and updates.
        </div>
        """
        unless $("#outdated-warning").exists()
          $("body").append(html)
          $("#refresh-page").click ->
            document.location.reload(true)
        console.warn("Your current version is out of date! Please refresh the page.")
      else if forceNow
        console.info("Your version is up to date: have #{_asm.lastMod}, got #{result.last_mod}")
    .fail ->
      console.warn("Couldn't check file version!!")
    .always ->
      delay 5*60*1000, ->
        # Delay 5 minutes
        checkVersion()
  if forceNow or not _asm.lastMod?
    checkVersion()
    return true
  false

window.checkFileVersion = checkFileVersion

setupServiceWorker = ->
  # http://www.html5rocks.com/en/tutorials/service-worker/introduction/
  if "serviceworker" of navigator
    navigator.serviceWorker
    .register("js/serviceWorker.min.js")
    .then (registration) ->
      console.log("ServiceWorker registered with scope", registration.scope)
    .catch (error) ->
      console.warn("ServiceWorker registration failed:", error)
  false


foo = ->
  toastStatusMessage("Sorry, this feature is not yet finished")
  stopLoad()
  false
doNothing = ->
  # Placeholder function
  return null


buildQuery = (obj) ->
  queryList = new Array()
  for k, v of obj
    key = k.replace /[^A-Za-z\-_\[\]]/img, ""
    queryList.push """#{key}=#{encodeURIComponent v}"""
  queryList.join "&"




checkLocalVersion = ->
  if uri.o.attr("host") is "localhost"
    # Check the last commit
    urlBaseRaw = uri.o.attr("directory").split("/")
    urlBase = new Array()
    for part in urlBaseRaw
      if isNull part then continue
      urlBase.push part
    if urlBase[0].search("~") is 0
      prefixUrl = uri.o.attr("protocol") + "://localhost#{urlBase[0]}/"
    else
      prefixUrl = uri.urlString
    $.get "#{prefixUrl}currentVersion"
    .done (result) ->
      console.log "Got tag", result
      version = result.replace /v(([0-9]+\.)+[0-9]+)(\-\w+)?/img, "$1"
      if version.length > 128
        console.error "Problem checking version file"
        return false
      versionParts = version.split "."
      # Limited access token to only read private repo status.
      # This token will be revoked when the repo goes public.
      args =
        access_token: "7a76691c6beea4d47eaaa6182a53e523c6a16a67"
      githubApiEndpoint = "https://api.github.com/repos/tigerhawkvok/asm-mammal-database/releases"
      $.get githubApiEndpoint, buildQuery args, "json"
      .done (result) ->
        console.log "Github API result:", result
        for release in result
          console.log "Checking release", release
          tag = release.tag_name
          tagVersion = tag.replace /v(([0-9]+\.)+[0-9]+)(\-\w+)?/img, "$1"
          tagParts = tagVersion.split "."
          i = 0
          for part in tagParts
            tagVersionPartNumber = toInt part
            localVersionPartNumber = toInt versionParts[i]
            if tagVersionPartNumber > localVersionPartNumber
              console.log "Found mismatched version at", "#{uri.urlString}/currentVersion"
              console.warn "Notice: tag part '#{tagVersionPartNumber}' > '#{localVersionPartNumber}'", tag, version
              html = """
              <strong>Head's-Up:</strong> Your local version is behind the latest application release.
              <br/><br/>
              Open up your terminal, and in your local directory run:
              <br/><br/>
              <code class="center-block text-center">git pull</code>
              <br/>
              To get your local version up-to-date.
              """
              bsAlert html
              return false
            else if tagVersionPartNumber < localVersionPartNumber
              # For any given part, it means this tag is irrelevant
              break
            ++i
        console.debug "Your version is up-to-date"
        false
  else
    doNothing()
  false


jsonTo64 = (obj, encode = true) ->
  ###
  #
  # @param obj
  # @param boolean encode -> URI encode base64 string
  ###
  try
    shadowObj = obj.slice 0
    shadowObj.push "foo" # Throws error on obj
    obj = toObject obj
  objString = JSON.stringify obj
  if encode is true
    encoded = post64 objString
  else
    encoded = encode64 encoded
  encoded


encode64 = (string) ->
  try
    Base64.encode(string)
  catch e
    console.warn("Bad encode string provided")
    string
decode64 = (string) ->
  try
    Base64.decode(string)
  catch e
    console.warn("Bad decode string provided")
    string

post64 = (string) ->
  s64 = encode64 string
  p64 = encodeURIComponent s64
  p64


dataUriToBlob = (dataUri, callback) ->
  ###
  # From
  #
  # http://stackoverflow.com/a/38845151/1877527
  #
  # Itself edited from
  #
  # https://developer.mozilla.org/en-US/docs/Web/API/HTMLCanvasElement/toBlob#Polyfill
  #
  # Chrome has a 2 MiB data uri limit;
  # convert to blob then use that instead.
  ###
  # Set it up
  data = dataUri.split(",")[1]
  encoding = dataUri.split(";")[1].split(",")[0]
  try
    binStr = atob data
  catch
    binStr = decodeURIComponent data
  # if encoding is "base64"
  #   # encodedData = data
  #   binStr = atob data #encodedData
  # else
  #   # encodedData = encode64 data
  #   binStr = data
  len = binStr.length
  arr = new Uint8Array(len)
  mimeString = dataUri.split(',')[0].split(':')[1].split(';')[0]
  # Create a blob
  i = 0
  for el in arr
    arr[i] = binStr.charCodeAt i
    ++i
  blobAttr =
    type: mimeString
  blob = new Blob [arr], blobAttr
  if typeof callback is "function"
    callback(blob)
  blob


downloadDataUriAsBlob = (selector) ->
  if isNull selector
    console.error "Needs a data URI or element selector as an argument!"
    return false
  try
    if $(selector).exists()
      data = $(selector).attr "href"
  if isNull data
    data = selector
    selector = null
  blob = dataUriToBlob data
  objUrl = URL.createObjectURL blob
  if isNull selector
    return objUrl
  # Change the data download
  $(selector).attr "href", objUrl
  false



try
  $()
catch e
  bsAlert "<strong>You're offline</strong>: We need at least enough data to load a few dependencies. Please put yourself online and try again.", "error"


$ ->
  try
    checkLocalVersion()
    interval 3600 * 1000, ->
      checkLocalVersion()
  formatScientificNames()
  bindClicks()
  mapNewWindows()
  try
    $("body").tooltip
      selector: "[data-toggle='tooltip']"
    # $('[data-toggle="tooltip"]').tooltip()
  catch e
    console.warn("Tooltips were attempted to be set up, but do not exist")
  try
    checkAdmin()
    if adminParams?.loadAdminUi is true
      loadJS "js/admin.min.js", ->
        loadAdminUi()
  catch e
    # If we're not in admin, get the location
    getLocation()
    # However, we can lazy-load to see if the user is an admin
    loadJS "js/admin.min.js", ->
      _asm.inhibitRedirect = true
      verifyLoginCredentials ->
        delete _asm.inhibitRedirect
        if uri.o.attr("file") is "species-account.php"
          # We should put a link to this critter as an edit if we're an
          # admin
          if typeof window.speciesData is "object"
            try
              query = JSON.stringify window.speciesData
              adminFragment = "##{Base64.encode query}"
              html = """
              <paper-icon-button
                class="click admin-edit-button"
                data-href="#{uri.urlString}admin-page.html#{adminFragment}"
                icon="icons:create"
                >
              </paper-icon-button>
              """
              # Append to the header...
              $("header p paper-icon-button[icon='icons:home']").before html
              bindClicks(".admin-edit-button")
    loadJS "js/jquery.cookie.min.js", ->
      # Now see if the user is an admin
      false
  try
    for md in $("marked-element")
      mdText = $(md).find("script").text()
      unless isNull mdText
        # console.debug "Rendering markdown of", mdText
        p$(md).markdown = mdText
  browserBeware()
  checkFileVersion()
  try
    for caption in $("figcaption .caption-description")
      captionValue = $(caption).text().unescape()
      $(caption).text captionValue
  try
    do offsetImageLabel = (iter = 0) ->
      unless $("figure picture").exists()
        console.log "No image on page"
        return false
      imageWidth = $("figure picture").width()
      if isNull imageWidth, true
        ++iter
        if iter >= 10
          console.log "Never saw a bigger image width"
          return false
        delay 100, ->
          offsetImageLabel iter
        return false
      # console.log "Display image width", imageWidth
      if iter > 0
        console.warn "Took #{iter * 100}ms to reposition image!"
      $("figure p.picture-label").css "left", "calc(50% - (#{imageWidth}px/2)*.95)"
      lightboxImages()
      false
