uri = new Object()
uri.o = $.url()
uri.urlString = uri.o.attr('protocol') + '://' + uri.o.attr('host')  + uri.o.attr("directory")
# For mod_rewrite fanciness
try
  uri.urlString = uri.urlString.replace /(.*)\/(((&?[a-zA-Z_\-]+=[a-zA-Z_\-\+0-9%=]+)+)\/?)(.*)/img, "$1/"
  if uri.urlString.split("/").pop().search(/\./) is -1 and uri.urlString.slice(-1) isnt "/"
    # No extension? igore it
    uri.urlString = uri.urlString.slice 0, uri.urlString.search(uri.urlString.split("/").pop())
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


unless typeof window._asm is "object"
  window._asm = new Object()

_asm.socialHandles =
  twitter: "mammalogists"

# Breakpoint in px
_asm.mobileBreakpoint = 767


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



String::noExponents = (explicitNum = true) ->
  ###
  # Remove scientific notation from a number
  #
  # After
  # http://stackoverflow.com/a/18719988/1877527
  ###
  data = @.split /[eE]/
  if data.length is 1
    return data[0]
  # Initialize
  z = ""
  sign = if @.slice(0,1) is "-" then "-" else ""
  str = data[0].replace ".", ""
  mag = Number(data[1]) + 1
  # Deal with negative exponents
  if mag <= 0
    z = sign + "0."
    # Add zeros until we hit mag = 0
    until mag >= 0
      z += "0"
      ++mag
    # Append all the trailing digits
    num = z + str.replace /^\-/, ""
    if explicitNum
      return parseFloat num
    else
      return num
  # Positive exponents
  if str.length <= mag
    # There will be no trailing decimals
    mag -= str.length
    # Loop until we hit zero
    until mag <= 0
      z += 0
      --mag
    num = str + z
    if explicitNum
      return parseFloat num
    else
      return num
  else
    # Need to handle the trailing decimal case
    leader = parseFloat data[0]
    multiplier = 10 ** parseInt data[1]
    return leader * multiplier



Number::noExponents = ->
  strVal = String @
  strVal.noExponents(true)


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

Array::sum = ->
  this.reduce (a,b) ->
    a + b

Array::mean = ->
  this.sum() / this.length

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
    name = this.toString().substr( 0, this.toString().indexOf( "(" ) ).replace( "function ", "" )
  if isNull name
    name = md5 this.toString()
    window.name = this
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



loadJS = (src, callback = new Object(), doCallbackOnError = true, async = true) ->
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
  s.setAttribute("type","text/javascript")
  s.src = src
  unless async is false
    s.setAttribute("async","async")
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
            console.warn e.stack
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
            openTab.debounce 50, null, null, url
          else
            goTo 50, null, null, url
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
              window[callable].debounce(50)
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
    value = encodeURIComponent(v).replace /\%20/g, "+"
    queryList.push """#{key}=#{value}"""
  queryList.join "&"

buildArgs = buildQuery



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


objToArgs = (obj) ->
  unless typeof obj is "object"
    error =
      message: "INVALID_TYPE"
    throw error
  argArray = new Array()
  for key, val of obj
    arg = "#{key}=#{encodeURIComponent val}"
    argArray.push arg
  return argArray.join "&"

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


delayPolymerBind = (selector, callback, iter = 0) ->
  unless md5?
    loadJS "bower_components/JavaScript-MD5/js/md5.min.js", ->
      doLoad()
  else
    doLoad()
  doLoad = ->
    unless typeof window._dpb is "object"
      window._dpb = new Object()
    uid = md5(selector) + md5(callback)
    if isNull window._dpb[uid]
      window._dpb[uid] = false
    superSlowBackup = 1000
    if Polymer?.Base?.$$?
      if window._dpb[uid] is false
        iter = 0
        window._dpb[uid] = true
      try
        element = Polymer.Base.$$(selector)
        callback(element)
        # Some browsers are stupid slow, do it again
        delay superSlowBackup, ->
          console.info "Doing #{superSlowBackup}ms delay callback for #{selector}"
          callback(element)
      catch e
        console.warn "Error trying to do the delayed polymer bind - #{e.message}"
        if iter < 10
          ++iter
          # Do a very short wait and try again, in case it's transient
          delay 75, ->
            delayPolymerBind selector, callback, iter
        else
          # See
          # https://github.com/Polymer/polymer/issues/2246
          console.error "Persistent error in polymer binding (#{e.message})"
          console.error e.stack
          # Attempt the last-ditch
          element = $(selector).get(0)
          callback(element)
          delay superSlowBackup, ->
            element = document.querySelector(selector)
            console.info "Doing #{superSlowBackup}ms delay callback for #{selector}"
            console.info "Using element", element
            callback(element)
    else
      if iter < 50
        delay 100, ->
          ++iter
          delayPolymerBind selector, callback, iter
      else
        console.error "Failed to verify Polymer was set up, attempting manual"
        element = document.querySelector(selector)
        callback element
  false



loadSocialMediaSlideoutBar = (handles, selector = "#social-menu", appendTo = "main") ->
  ###
  #
  # @param obj handles -> an object with keys as service and value as handle
  ###
  toggleSocialSlideoutBar = ->
    if $(selector).hasClass "out"
      $(selector)
      .removeClass "out"
      .addClass "in"
    else
      $(selector)
      .removeClass "in"
      .addClass "out"
    false
  window.toggleSocialSlideoutBar = toggleSocialSlideoutBar
  unless $(selector).exists()
    contentHtml = ""
    for service, handle of handles
      switch service
        when "twitter"
          # https://dev.twitter.com/web/embedded-timelines
          # https://publish.twitter.com/#
          serviceHtml = """
          <a class="twitter-timeline" data-link-color="#1DA1F2" href="https://twitter.com/#{handle}">Tweets by @#{handle}</a> <script async src="//platform.twitter.com/widgets.js" charset="utf-8"></script>
          """
        else
          serviceHtml = ""
      contentHtml += "\n#{serviceHtml}\n"
    html = """
<paper-material id="social-menu" class="out" elevation="4">
  <paper-icon-button icon="glyphicon-social:twitter" class="show-social"></paper-icon-button>
  <div class="slideout-content">
    #{contentHtml}
  </div>
</paper-material>
    """
    showButton = """
    """
    $(appendTo).append html
    $(".show-social").click ->
      toggleSocialSlideoutBar.debounce 50
      false
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
    loadSocialMediaSlideoutBar(_asm.socialHandles)
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
  try
    loadJS "bower_components/JavaScript-MD5/js/md5.min.js"

searchParams =
  lastSearch: "*"
  targetApi: "api.php"
  targetContainer: "#result_container"
searchParams.apiPath = uri.urlString + searchParams.targetApi

unless typeof window._asm is "object"
  window._asm = new Object()
# Base query URLs for out-of-site linkouts
_asm.affiliateQueryUrl =
  iucnRedlist: "http://apiv3.iucnredlist.org/api/v3/species/"
  iucnRedlistCN: "http://apiv3.iucnredlist.org/api/v3/species/common_names/"
  iNaturalist: "https://www.inaturalist.org/taxa/search"
  calPhotos: "http://calphotos.berkeley.edu/cgi/img_query"  



fetchMajorMinorGroups = (scientific = null, callback) ->
  renderItemsList = ->
    $("#eutheria-extra").remove()
    # Change the item list
    menuItems = """
    <paper-item data-type="any" selected>All</paper-item>
    """
    for itemType, itemLabel of _asm.major
      menuItems += """
    <paper-item data-type="#{itemType}">#{itemLabel.toTitleCase()}</paper-item>
      """
    column = if scientific then "linnean_family" else "simple_linnean_subgroup"
    buttonHtml = """
            <paper-menu-button id="simple-linnean-groups" class="col-xs-6 col-md-4">
              <paper-button class="dropdown-trigger"><iron-icon icon="icons:filter-list"></iron-icon><span id="filter-what" class="dropdown-label"></span></paper-button>
              <paper-menu label="Group" data-column="simple_linnean_group" class="cndb-filter dropdown-content" id="linnean" name="type" attrForSelected="data-type" selected="0">
                #{menuItems}
              </paper-menu>
            </paper-menu-button>
    """
    if $("#simple-linnean-groups").exists()
      $("#simple-linnean-groups").replaceWith buttonHtml
      $("#simple-linnean-groups")
      .on "iron-select", ->
        type = $(p$("#simple-linnean-groups paper-menu").selectedItem).text()
        $("#simple-linnean-groups span.dropdown-label").text type
      try
        type = $(p$("#simple-linnean-groups paper-menu").selectedItem).text()
        $("#simple-linnean-groups span.dropdown-label").text type
    eutheriaFilterHelper(true)
    if $("#simple-linnean-groups").exists()
      console.log "Replaced menu items with", menuItems
    if typeof callback is "function"
      callback()
    false
  if typeof _asm.mammalGroupsBase is "object" and typeof _asm.major is "object"
    unless isArray _asm.mammalGroupsBase
      _asm.mammalGroupsBase = Object.toArray _asm.mammalGroupsBase
    renderItemsList()
    return true
  else
    # Hit the API
    unless isBool scientific
      try
        scientific = p$("#use-scientific").checked ? true
      catch
        scientific = true
    $.get searchParams.apiPath, "fetch-groups=true&scientific=#{scientific}"
    .done (result) ->
      # console.log "Group fetch for dropdown got", result
      if result.status isnt true
        return false
      _asm.mammalGroupsBase = Object.toArray result.minor
      _asm.major = result.major
      renderItemsList()
    .fail (result, error) ->
      console.error "Failed to hit API"
      console.warn result, error
      false
  false



eutheriaFilterHelper = (skipFetch = false) ->
  unless skipFetch
    fetchMajorMinorGroups.debounce(50)
    try
      $("#use-scientific")
      .on "iron-change", ->
        delete _asm.mammalGroupsBase
        fetchMajorMinorGroups.debounce(50)
  $("#linnean")
  .on "iron-select", ->
    try
      if $(p$("#linnean").selectedItem).attr("data-type") isnt "any"
        p$("#global_search").checked = false
    if $(p$("#linnean").selectedItem).attr("data-type") is "eutheria"
      # Clean it up for the code
      mammalGroups = new Array()
      for humanGroup in _asm.mammalGroupsBase
        mammalGroups.push humanGroup.toLowerCase()
      mammalGroups.sort()
      mammalItems = ""
      for group in mammalGroups
        html = """
        <paper-item data-type="#{group}">
          #{group.toTitleCase()}
        </paper-item>
        """
        mammalItems += html
      unless isBool scientific
        try
          scientific = p$("#use-scientific").checked ? true
        catch
          scientific = true
      column = if scientific then "linnean_order" else "simple_linnean_subgroup"
      html = """
        <div id="eutheria-extra"  class="col-xs-12 col-md-5">
            <label for="type" class="sr-only">Eutheria Filter</label>
            <div class="row">
            <paper-menu-button class="col-xs-12" id="eutheria-subfilter">
              <paper-button class="dropdown-trigger"><iron-icon icon="icons:filter-list"></iron-icon><span id="filter-what" class="dropdown-label"></span></paper-button>
              <paper-menu label="Group" data-column="#{column}" class="cndb-filter dropdown-content" id="linnean-eutheria" name="type" attrForSelected="data-type" selected="0">
                <paper-item data-type="any" selected>All</paper-item>
                #{mammalItems}
                <!-- As per flag 4 in readme -->
              </paper-menu>
            </paper-menu-button>
            </div>
          </div>
      """
      $("#simple-linnean-groups").after html
      $("#eutheria-subfilter")
      .on "iron-select", ->
        type = $(p$("#eutheria-subfilter paper-menu").selectedItem).attr "data-type"
        $("#eutheria-subfilter span.dropdown-label").text type
      type = $(p$("#eutheria-subfilter paper-menu").selectedItem).attr "data-type"
      $("#eutheria-subfilter span.dropdown-label").text type
    else
      $("#eutheria-extra").remove()
  try
    doLazily()
  false



checkLaggedUpdate = (result) ->
  ###
  #
  ###
  console.debug "Executing lagged update check ..."
  iucnCanProvide = [
    "common_name"
    "species_authority"
    ]
  start = Date.now()
  if result.do_client_update is true
    # console.info "About to trigger client update process"
    k = j = 0
    finishedLoop = false
    try
      for i, taxon of result.result
        shouldSkip = true
        for key in iucnCanProvide
          unless isNull taxon[key]
            continue
          else
            # console.debug "Missing key '#{key}' in ", taxon
            shouldSkip = false
            break
        if shouldSkip
          continue
        ++k
        args = "missing=true&genus=#{taxon.genus}&species=#{taxon.species}"
        #console.log "About to ping missing update url", "#{searchParams.targetApi}?#{args}"
        $.get searchParams.targetApi, args, "json"
        .done (subResult) ->
          ++j
          unless subResult.did_update
            return false
          console.log "Update for #{subResult.canonical_sciname}", subResult
          row = $(".cndb-result-entry[data-taxon='#{subResult.genus}+#{subResult.species}']")
          for col, val of subResult
            if $(row).find(".#{col}").exists() and not isNull val
              if isNull $(row).find(".#{col}").text()
                console.log "Set #{col} text of #{subResult.canonical_sciname} to #{val}"
                $(row).find(".#{col}").text val
            else if $(row).find(".#{col}").exists() and isNull val
              console.warn "Couldn't update #{col} - got an empty IUCN result"
          false
        .fail (subResult, status) ->
          console.warn "Couldn't update #{taxon.canonical_sciname}", subResult, status
          console.warn "#{searchParams.targetApi}?#{args}"
          false
        .always ->
          if j is k and finishedLoop
            elapsed = Date.now() - start
            console.log "Finished async IUCN taxa check in #{elapsed}ms"
            stopLoad()
            delay 500, ->
              stopLoad()
              # Hit the datawalker to update. We don't care about the
              # result.
              console.debug "About to try a data walk"
              $.get "#{uri.urlString}datawalk.php", "", "json"
              .done (result) ->
                if result.status is true
                  console.log "Completed data walk in #{result.execution_time}ms"
                else
                  console.warn "Data walk executed, but failed to complete"
                  console.warn result
              .fail (result, status) ->
                console.warn "Couldn't execute data walk", result, status
      finishedLoop = true
    catch e
      console.warn "Couldn't do client update -- #{e.message}"
      console.warn e.stack
  else
    console.debug "Lagged update check unneeded."
    stopLoad()
  false



performSearch = (stateArgs = undefined) ->
  ###
  # Check the fields and filters and do the async search
  ###
  if not stateArgs?
    # No arguments have been passed in
    s = $("#search").val()
    # Store a version before we do any search modifiers
    sOrig = s
    s = s.toLowerCase()
    filters = getFilters()
    if (isNull(s) or not s?) and isNull(filters)
      $("#search-status").attr("text","Please enter a search term.")
      $("#search-status")[0].show()
      return false
    $("#search").blur()
    # Remove periods from the search
    s = s.replace(/\./g,"")
    s = prepURI(s)
    for toggle in $("#search_form #search-options-container .bool-search-option paper-toggle-button")
      if $(toggle).polymerChecked()
        argOption = $(toggle).attr "id"
        s += "&#{argOption}=true"
    # Add on the filters
    unless isNull(filters)
      # console.log("Got filters - #{filters}")
      s = "#{s}&filter=#{filters}"
    args = "q=#{s}"
  else
    # An argument has been passed in
    if stateArgs is true
      # Special case -- do a search on everything
      args = "q="
      sOrig = "(all items)"
    else
      # Do the search exactly as passed. The fragment should ALREADY
      # be decoded at this point.
      args = "q=#{stateArgs}"
      sOrig = stateArgs.split("&")[0]
    #console.log("Searching on #{stateArgs}")
  if s is "#" or (isNull(s) and isNull(args)) or (args is "q=" and stateArgs isnt true)
    return false
  animateLoad()
  console.log("Got search value #{s}, hitting","#{searchParams.apiPath}?#{args}")
  searchParams.lastSearch = s
  $.get(searchParams.targetApi,args,"json")
  .done (result) ->
    # Populate the result container
    # console.log("Search executed by #{result.method} with #{result.count} results.")
    if toInt(result.count) is 0
      console.error "No search results: Got search value #{s}, from hitting","#{searchParams.apiPath}?#{args}"
      showBadSearchErrorMessage.debounce null, null, null, result
      clearSearch(true)
      delay 500, ->
        stopLoadError()
      return false
    if result.status is true
      console.log "Server response:", result
      # Clear any pending error
      $(".hanging-alert.alert-danger").remove()
      # May be worth moving this part to a service worker
      formatSearchResults result, undefined, ->
        checkLaggedUpdate.debounce 1000, null, null, result
      return false
    clearSearch(true)
    $("#search-status").attr("text",result.human_error)
    $("#search-status")[0].show()
    console.error(result.error)
    console.warn(result)
    stopLoadError()
  .fail (result,error) ->
    console.error("There was an error performing the search")
    console.warn(result,error,result.statusText)
    error = "#{result.status} - #{result.statusText}"
    # It probably doesn't make sense to clear the search on a bad
    # server call ...
    # clearSearch(true)
    $("#search-status").attr("text","Couldn't execute the search - #{error}")
    $("#search-status")[0].show()
    stopLoadError()
  .always ->
    # Anything we always want done
    b64s = Base64.encodeURI s
    if s? then setHistory "#{uri.urlString}##{b64s}"
    false

getFilters = (selector = ".cndb-filter", booleanType = "AND") ->
  ###
  # Look at $(selector) and apply the filters as per
  # https://github.com/tigerhawkvok/SSAR-species-database#search-flags
  # It's meant to work with Polymer dropdowns, but it'll fall back to <select><option>
  ###
  filterList = new Object()
  $(selector).each ->
    col = $(this).attr("data-column")
    if not col?
      # Skip this iteration
      return true
    try
      val = $(this).polymerSelected()
    catch
      return true
    if val is "any" or val is "all" or val is "*"
      # Wildcard filter -- just don't give anything
      # Go to the next iteration
      return true
    if isNull(val) or val is false
      val = $(this).val()
      if isNull(val)
        # Skip this iteration
        return true
      else
    filterList[col] = val.toLowerCase()
  if Object.size(filterList) is 0
    # Pass back an empty string
    # console.log("Got back an empty filter list.")
    return ""
  try
    filterList["BOOLEAN_TYPE"] = booleanType
    jsonString = JSON.stringify(filterList)
    encodedFilter = Base64.encodeURI(jsonString)
    # console.log("Returning #{encodedFilter} from",filterList)
    return encodedFilter
  catch e
    return false


formatSearchResults = (result, container = searchParams.targetContainer, callback) ->
  ###
  # Take a result object from the server's lookup, and format it to
  # display search results.
  #
  # By default, this will try to render the results off-thread with a
  # service worker for the best client performance, but it will fall
  # back on to an on-thread renderer if no service worker exists.
  #
  # See
  #
  # https://mammaldiversity.org/api.php?q=ursus+arctos&loose=true
  #
  # for a sample search result return.
  ###
  start = Date.now()
  elapsed = 0
  $("#result-header-container").removeAttr "hidden"
  data = result.result
  searchParams.result = data
  headers = new Array()
  tableId = "cndb-result-list"
  htmlHead = "<table id='#{tableId}' class='table table-striped table-hover col-md-12'>\n\t<tr class='cndb-row-headers'>"
  htmlClose = "</table>"
  # We start at 0, so we want to count one below
  targetCount = result.count
  if targetCount > 150
    toastStatusMessage "We found #{result.count} results, please hang on a moment while we render them...", "", 5000
  else
    console.log "Not notifying of render delay, only showing #{targetCount} items"
  colClass = null
  bootstrapColCount = 0
  dontShowColumns = [
    "id"
    "minor_type"
    "notes"
    "major_type"
    "taxon_author"
    "taxon_credit"
    "image_license"
    "image_credit"
    "taxon_credit_date"
    "parens_auth_genus"
    "parens_auth_species"
    "is_alien"
    "internal_id"
    "source"
    "deprecated_scientific"
    # "species_authority"
    # "genus_authority"
    # "authority_year"
    "canonical_sciname"
    "simple_linnean_group"
    "iucn"
    "dwc"
    "entry"
    "common_name_source"
    "image_caption"
    "species_authority_citation"
    "genus_authority_citation"
    "citation"
    "simple_linnean_group_alt"
    "linnean_tribe"
    "linnean_subfamily"
    ]
  externalCounter = 0
  renderTimeout = delay 7500, ->
    stopLoadError "There was a problem parsing the search results."
    console.error "Couldn't finish parsing the results! Expecting #{targetCount} elements, timed out on #{externalCounter}."
    console.warn data
    return false
  requiredKeyOrder = [
    "common_name"
    "genus"
    "species"
    ]
  delay 5, ->
    # Remove data-less columns
    colHasData = new Array()
    for i, row of data
      allColsHaveData = true
      for k, v of row
        if k in colHasData
          continue
        if isNull v
          allColsHaveData = false
        else
          # console.log "Col '#{k}' has non-empty value '#{v}' at row #{i}", row
          colHasData.push k
      if allColsHaveData
        break
    if "subspecies" in colHasData
      requiredKeyOrder.push "subspecies"
    # Get all the rows in order
    for k, v of data[0]
      # Don't double-count a column
      unless k in requiredKeyOrder
        # Don't render columns that we shouldn't show, duh
        unless k in dontShowColumns
          # Only render columns that have data
          if k in colHasData
            requiredKeyOrder.push k
    # elapsed = Date.now() - start
    # console.debug "Took #{elapsed}ms to finish sorting keys"
    # Re-sort the data
    origData = data
    data = new Object()
    for i, row of origData
      data[i] = new Object()
      for key in requiredKeyOrder
        data[i][key] = row[key]
    # elapsedBetween = Date.now() - start - elapsed
    # elapsed = Date.now() - start
    # console.debug "Took #{elapsedBetween}ms to re-order data (total time: #{elapsed}ms)"
    # The real render loop
    totalLoops = 0
    dataArray = Object.toArray data
    do renderDataArray = (data = dataArray, firstIteration = true, renderChunk = 100) ->
      html = ""
      i = 0
      nextIterationData = null
      wasOffThread = false
      unless isNumber renderChunk
        renderChunk = 100
      finalIteration = if data.length <= renderChunk then true else false
      try
        postMessageContent =
          action: "render-row"
          data: data
          chunk: renderChunk
          firstIteration: firstIteration
        worker = new Worker "js/serviceWorker.js"
        console.info "Rendering list off-thread"
        worker.addEventListener "message", (e) ->
          console.info "Got message back from service worker", e.data
          wasOffThread = true
          html = e.data.html
          nextIterationData = e.data.nextChunk
          usedRenderChunk = e.data.renderChunk
          i = e.data.loops
          loopCleanup()
        worker.postMessage postMessageContent
      catch
        ###############################
        # No web worker! Fallback
        ###############################
        console.log "Starting loop with i = #{i}, renderChunk = #{renderChunk}, data length = #{data.length}", firstIteration, finalIteration
        for row in data
          ++totalLoops
          externalCounter = i
          if toInt(i) is 0 and firstIteration
            j = 0
            htmlHead += "\n<!-- Table Headers - #{Object.size(row)} entries -->"
            for k, v of row
              ++totalLoops
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
            frameHtml = htmlHead + htmlClose
            html = htmlHead
            $(container).html frameHtml
          # End header construction
          # Start building the data rows
          taxonQuery = "#{row.genus}+#{row.species}"
          if not isNull(row.subspecies)
            taxonQuery = "#{taxonQuery}+#{row.subspecies}"
          rowId = "msadb-row#{i}"
          htmlRow = """\n\t<tr id='#{rowId}' class='cndb-result-entry' data-taxon="#{taxonQuery}" data-genus="#{row.genus}" data-species="#{row.species}">"""
          for k, col of row
            ++totalLoops
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
        loopCleanup()
        # End data loop
      loopCleanup = ->
        if firstIteration
          html += htmlClose
          $(container).html html
          $("#result-count").text(" - #{result.count} entries")
          if result.method is "space_common_fallback" and not $("#space-fallback-info").exists()
            noticeHtml = """
            <div id="space-fallback-info" class="alert alert-info alert-dismissible center-block fade in" role="alert">
              <button type="button" class="close" data-dismiss="alert" aria-label="Close"><span aria-hidden="true">&times;</span></button>
              <strong>Don't see what you want?</strong> We might use a slightly different name. Try <a href="" class="alert-link" id="do-instant-fuzzy">checking the "fuzzy" toggle and searching again</a>, or use a shorter search term.
            </div>
            """
            $("#result_container").before(noticeHtml)
            $("#do-instant-fuzzy").click (e) ->
              e.preventDefault()
              doBatch = ->
                $("#fuzzy").get(0).checked = true
                performSearch()
              doBatch.debounce()
          else if $("#space-fallback-info").exists()
            # We only want to show it once, so we'll hide it now
            $("#space-fallback-info").prop("hidden",true)
            #$("#space-fallback-info").remove()
        else
          # Just add the new rows
          $("table##{tableId} tbody").append html
        unless finalIteration
          elapsed = Date.now() - start
          nextIterationData ?= data.slice i
          console.log "Chunk rendered at #{elapsed}ms, next bit with slice @ #{i}:", nextIterationData
          unless nextIterationData.length is 0
            delayInterval = if wasOffThread then 25 else 250
            delay delayInterval, ->
              renderDataArray nextIterationData, false, renderChunk
          else
            finalIteration = true
        if finalIteration
          elapsed = Date.now() - start
          console.log "Finished rendering list in #{elapsed}ms"
          console.debug "Executed #{totalLoops} loops"
          if elapsed > 3000 and not wasOffThread
            console.warn "Warning: Took greater than 3 seconds to render!"
          stopLoad()
          delay 250, ->
            stopLoad()
          if typeof callback is "function"
            try
              callback()
        clearTimeout renderTimeout
        mapNewWindows()
        lightboxImages()
        # modalTaxon()
        $(".cndb-result-entry")
        .unbind()
        .click ->
          accountArgs = "genus=#{$(this).attr("data-genus")}&species=#{$(this).attr("data-species")}"
          goTo "species-account.php?#{accountArgs}"
        doFontExceptions()
  false


parseTaxonYear = (taxonYearString, strict = true) ->
  ###
  # Take the (theoretically nicely JSON-encoded) taxon year/authority
  # string and turn it into a canonical object for the modal dialog to use
  ###
  try
    d = JSON.parse(taxonYearString)
  catch e
    # attempt to fix it
    console.warn("There was an error parsing '#{taxonYearString}', attempting to fix - ",e.message)
    try
      split = taxonYearString.split(":")
      year = split[1].slice(split[1].search('"')+1,-2)
      # console.log("Examining #{year}")
      year = year.replace(/"/g,"'")
      split[1] = "\"#{year}\"}"
      taxonYearString = split.join(":")
      # console.log("Reconstructed #{taxonYearString}")
      try
        d = JSON.parse(taxonYearString)
      catch e
        if strict
          return false
        else
          return taxonYearString
    catch e
      if strict
        return false
      else
        return taxonYearString
  genus = Object.keys(d)[0]
  species = d[genus]
  year = new Object()
  year.genus = genus
  year.species = species
  return year


checkTaxonNear = (taxonQuery = undefined, callback = undefined, selector = "#near-me-container") ->
  ###
  # Check the iNaturalist API to see if the taxon is in your county
  # See https://github.com/tigerhawkvok/SSAR-species-database/issues/7
  ###
  if not taxonQuery?
    console.warn("Please specify a taxon.")
    return false
  if not locationData.last?
    getLocation()
  elapsed = (Date.now() - locationData.last)/1000
  if elapsed > 15*60 # 15 minutes
    getLocation()
  # Now actually check
  apiUrl = "https://www.inaturalist.org/places.json"
  args = "taxon=#{taxonQuery}&latitude=#{locationData.lat}&longitude=#{locationData.lng}&place_type=county"
  geoIcon = ""
  cssClass = ""
  tooltipHint = ""
  $.get(apiUrl,args,"json")
  .done (result) ->
    if Object.size(result) > 0
      geoIcon = "communication:location-on"
      cssClass = "good-location"
      tooltipHint = "This species occurs in your county"
    else
      geoIcon = "communication:location-off"
      cssClass = "bad-location"
      tooltipHint = "This species does not occur in your county"
  .fail (result,status) ->
    cssClass = "bad-location"
    geoIcon = "warning"
    tooltipHint = "We couldn't determine your location"
  .always ->
    tooltipHtml = """
    <div class="tooltip fade top in right manual-placement-tooltip" role="tooltip" style="top: 6.5em; left: 4em; right:initial; display:none" id="manual-location-tooltip">
      <div class="tooltip-arrow" style="top:50%;left:5px"></div>
      <div class="tooltip-inner">#{tooltipHint}</div>
    </div>
    """
    # Append it all
    d$(selector).html("<iron-icon icon='#{geoIcon}' class='small-icon #{cssClass} near-me' data-toggle='tooltip' id='near-me-icon'></iron-icon>")
    $(selector)
    .after(tooltipHtml)
    .mouseenter ->
      d$("#manual-location-tooltip").css("display","block")
      false
    .mouseleave ->
      d$("#manual-location-tooltip").css("display","none")
      false
    if callback?
      callback()
  false



insertModalImage = (imageObject = _asm.taxonImage, taxon = _asm.activeTaxon, callback = undefined) ->
  ###
  # Insert into the taxon modal a lightboxable photo. If none exists,
  # load from CalPhotos
  #
  # CalPhotos functionality blocked on
  # https://github.com/tigerhawkvok/SSAR-species-database/issues/30
  ###
  # Is the modal dialog open?
  unless taxon?
    console.error("Tried to insert a modal image, but no taxon was provided!")
    return false
  unless typeof taxon is "object"
    console.error("Invalid taxon data type (expecting object), got #{typeof taxon}")
    warnArgs =
      taxon: taxon
      imageUrl: imageUrl
      defaultTaxon: _asm.activeTaxon
      defaultImage: _asm.taxonImage
    console.warn(warnArgs)
    return false
  # Image insertion helper
  insertImage = (image, taxonQueryString, classPrefix = "calphoto") ->
    ###
    # Insert a lightboxed image into the modal taxon dialog. This must
    # be shadow-piercing, since the modal dialog is a
    # paper-dialog.
    #
    # @param image an object with parameters [thumbUri, imageUri,
    #   imageLicense, imageCredit], and optionally imageLinkUri
    ###
    # Build individual args from object
    thumbnail = image.thumbUri
    largeImg = image.imageUri
    largeImgLink = image.imageLinkUri? image.imageUri
    imgLicense = image.imageLicense
    imgCredit = image.imageCredit
    html = """
    <div class="modal-img-container">
      <a href="#{largeImg}" class="#{classPrefix}-img-anchor center-block text-center">
        <img src="#{thumbnail}"
          data-href="#{largeImgLink}"
          class="#{classPrefix}-img-thumb"
          data-taxon="#{taxonQueryString}" />
      </a>
      <p class="small text-muted text-center">
        Image by #{imgCredit} under #{imgLicense}
      </p>
    </div>
    """
    d$("#meta-taxon-info").before(html)
    do smartFit = (iteration = 0) ->
      try
        d$("#modal-taxon").get(0).fit()
        delay 250, ->
          d$("#modal-taxon").get(0).fit()
          delay 750, ->
            d$("#modal-taxon").get(0).fit()
      catch e
        if iteration < 10
          iteration++
          delay 100, ->
            smartFit(iteration)
        else
          console.warn("Couldn't execute fit!")
    try
      # Call lightboxImages with the second argument "true" to do a
      # shadow-piercing lookup
      lightboxImages(".#{classPrefix}-img-anchor", true)
    catch e
      console.error("Error lightboxing images")
    if typeof callback is "function"
      callback()
    false
  # Now that that's out of the way, we actually check the information
  # and process it
  taxonArray = [taxon.genus,taxon.species]
  if taxon.subspecies?
    taxonArray.push(taxon.subspecies)
  taxonString = taxonArray.join("+")

  if imageObject.imageUri?
    # The image URI is valid, so insert it
    if typeof imageObject is "string"
      # Make it conform to expectations
      imageUrl = imageObject
      imageObject = new Object()
      imageObject.imageUri = imageUrl
    # Construct the thumb URI from the provided full-sized path
    imgArray = imageObject.imageUri.split(".")
    extension = imgArray.pop()
    # In case the uploaded file has "." in it's name, we want to re-join
    imgPath = imgArray.join(".")
    imageObject.thumbUri = "#{uri.urlString}#{imgPath}-thumb.#{extension}"
    imageObject.imageUri = "#{uri.urlString}#{imgPath}.#{extension}"
    # And finally, call our helper function
    insertImage(imageObject, taxonString, "asmimg")
    return false

  ###
  # OK, we don't have it, do CalPhotos
  #
  # Hit targets of form
  # http://calphotos.berkeley.edu/cgi-bin/img_query?getthumbinfo=1&num=all&taxon=Acris+crepitans&format=xml
  #
  # See
  # http://calphotos.berkeley.edu/thumblink.html
  # for API reference.
  ###

  args = "getthumbinfo=1&num=all&cconly=1&taxon=#{taxonString}&format=xml"
  # console.log("Looking at","#{_asm.affiliateQueryUrl.calPhotos}?#{args}")
  ## CalPhotos doesn't have good headers set up. Try a CORS request.
  # CORS success callback
  doneCORS = (resultXml) ->
    result = xmlToJSON.parseString(resultXml)
    window.testData = result
    try
      data = result.calphotos[0]
    catch e
      data = undefined
    unless data?
      # console.warn("CalPhotos didn't return any valid images for this search! Looked for #{taxonString}")
      return false
    imageObject = new Object()
    try
      imageObject.thumbUri = data.thumb_url[0]["_text"]
      unless imageObject.thumbUri?
        console.warn("CalPhotos didn't return any valid images for this search!")
        return false
      imageObject.imageUri = data.enlarge_jpeg_url[0]["_text"]
      imageObject.imageLinkUri = data.enlarge_url[0]["_text"]
      imageObject.imageLicense = data.license[0]["_text"]
      imageObject.imageCredit = "#{data.copyright[0]["_text"]} (via CalPhotos)"
    catch e
      console.warn("CalPhotos didn't return any valid images for this search!","#{_asm.affiliateQueryUrl.calPhotos}?#{args}")
      return false
    # Do the image insertion via our helper function
    insertImage(imageObject,taxonString)
    false
  # CORS failure callback
  failCORS = (result,status) ->
    insertCORSWorkaround()
    console.error("Couldn't load a CalPhotos image to insert!")
    false
  # The actual call attempts.
  try
    doCORSget(_asm.affiliateQueryUrl.calPhotos, args, doneCORS, failCORS)
  catch e
    console.error(e.message)
  false





modalTaxon = (taxon = undefined) ->
  ###
  # Pop up the modal taxon dialog for a given species
  ###
  if not taxon?
    # If we have no taxon defined at all, bind all the result entries
    # from a search into popping one of these up
    $(".cndb-result-entry").click ->
      modalTaxon($(this).attr("data-taxon"))
    return false
  # Pop open a paper action dialog ...
  # https://elements.polymer-project.org/elements/paper-dialog
  animateLoad()
  if not $("#modal-taxon").exists()
    # On very small devices, for both real-estate and
    # optimization-related reasons, we'll hide calphotos and the alternate
    html = """
    <paper-dialog modal id='modal-taxon' entry-animation="scale-up-animation" exit-animation="scale-down-animation">
      <h2 id="modal-heading"></h2>
      <paper-dialog-scrollable id='modal-taxon-content'></paper-dialog-scrollable>
      <div class="buttons">
        <paper-button id='modal-inat-linkout'>iNaturalist</paper-button>
        <paper-button id='modal-calphotos-linkout' class="hidden-xs">CalPhotos</paper-button>
        <paper-button id='modal-alt-linkout' class="hidden-xs"></paper-button>
        <paper-button dialog-dismiss autofocus>Close</paper-button>
      </div>
    </paper-dialog>
    """
    $("body").append(html)
  $.get(searchParams.targetApi,"q=#{taxon}","json")
  .done (result) ->
    data = result.result[0]
    unless data?
      toastStatusMessage("There was an error fetching the entry details. Please try again later.")
      stopLoadError()
      return false
    # console.log("Got",data)
    year = parseTaxonYear(data.authority_year)
    yearHtml = ""
    if year isnt false
      genusAuthBlock = """
      <span class='genus_authority authority'>#{data.genus_authority}</span> #{year.genus}
      """
      speciesAuthBlock = """
      <span class='species_authority authority'>#{data.species_authority}</span> #{year.species}
      """
      if toInt(data.parens_auth_genus).toBool()
        genusAuthBlock = "(#{genusAuthBlock})"
      if toInt(data.parens_auth_species).toBool()
        speciesAuthBlock = "(#{speciesAuthBlock})"
      yearHtml = """
      <div id="is-alien-container" class="tooltip-container"></div>
      <div id='near-me-container' data-toggle='tooltip' data-placement='top' title='' class='near-me tooltip-container'></div>
      <p>
        <span class='genus'>#{data.genus}</span>,
        #{genusAuthBlock};
        <span class='species'>#{data.species}</span>,
        #{speciesAuthBlock}
      </p>
      """
    deprecatedHtml = ""
    if not isNull(data.deprecated_scientific)
      deprecatedHtml = "<p>Deprecated names: "
      try
        sn = JSON.parse(data.deprecated_scientific)
        i = 0
        $.each sn, (scientific,authority) ->
          i++
          if i isnt 1
            deprecatedHtml += "; "
          deprecatedHtml += "<span class='sciname'>#{scientific}</span>, #{authority}"
          if i is Object.size(sn)
            deprecatedHtml += "</p>"
      catch e
        # skip it
        deprecatedHtml = ""
        console.error("There were deprecated scientific names, but the JSON was malformed.")
    minorTypeHtml = ""
    if not isNull(data.minor_type)
      minorTypeHtml = " <iron-icon icon='arrow-forward'></iron-icon> <span id='taxon-minor-type'>#{data.minor_type}</span>"
    # Populate the taxon
    if isNull(data.notes)
      data.notes = "Sorry, we have no notes on this taxon yet."
      data.taxon_credit = ""
    else
      if isNull(data.taxon_credit) or data.taxon_credit is "null"
        data.taxon_credit = "This taxon information is uncredited."
      else
        taxonCreditDate = if isNull(data.taxon_credit_date) or data.taxon_credit_date is "null" then "" else " (#{data.taxon_credit_date})"
        data.taxon_credit = "Taxon information by #{data.taxon_credit}.#{taxonCreditDate}"
    try
      notes = markdown.toHTML(data.notes)
    catch e
      notes = data.notes
      console.warn("Couldn't parse markdown!! #{e.message}")
    # For the notes, we want to fix any badly-encoded html with real
    # encodings
    notes = notes.replace(/\&amp;(([a-z]+|[0-9]+);)/mg, "&$1")
    commonType = unless isNull(data.major_common_type) then " (<span id='taxon-common-type'>#{data.major_common_type}</span>) " else ""
    html = """
    <div id='meta-taxon-info'>
      #{yearHtml}
      <p>
        English name: <span id='taxon-common-name' class='common_name no-cap'>#{smartUpperCasing data.common_name}</span>
      </p>
      <p>
        Type: <span id='taxon-type' class="major_type">#{data.major_type}</span>
        #{commonType}
        <iron-icon icon='arrow-forward'></iron-icon>
        <span id='taxon-subtype' class="major_subtype">#{data.major_subtype}</span>#{minorTypeHtml}
      </p>
      #{deprecatedHtml}
    </div>
    <h3>Taxon Notes</h3>
    <p id='taxon-notes'>#{notes}</p>
    <p class="text-right small text-muted">#{data.taxon_credit}</p>
    """
    $("#modal-taxon-content").html(html)
    ## Bind the dismissive buttons
    # iNaturalist
    $("#modal-inat-linkout")
    .unbind()
    .click ->
      openTab("#{_asm.affiliateQueryUrl.iNaturalist}?q=#{taxon}")
    # CalPhotos
    $("#modal-calphotos-linkout")
    .unbind()
    .click ->
      openTab("#{_asm.affiliateQueryUrl.calPhotos}?rel-taxon=contains&where-taxon=#{taxon}")
    # AmphibiaWeb or Reptile Database
    # See
    # https://github.com/tigerhawkvok/SSAR-species-database/issues/35
    outboundLink = null
    buttonText = null
    taxonArray = taxon.split("+")
    _asm.activeTaxon =
      genus: taxonArray[0]
      species: taxonArray[1]
      subspecies: taxonArray[2]
    if outboundLink?
      # First, un-hide it in case it was hidden
      $("#modal-alt-linkout")
      .replaceWith(button)
      $("#modal-alt-linkout")
      .click ->
        # console.log "Should outbound to", outboundLink
        openTab(outboundLink)
    else
      # Well, wasn't expecting this! But we'll handle it anyway.
      # Hide the link
      $("#modal-alt-linkout")
      .addClass("hidden")
      .unbind()
    formatScientificNames()
    doFontExceptions()
    # Set the heading
    humanTaxon = taxon.charAt(0).toUpperCase()+taxon[1...]
    humanTaxon = humanTaxon.replace(/\+/g," ")
    d$("#modal-heading").text(humanTaxon)
    # Open it
    if isNull(data.image) then data.image = undefined
    _asm.taxonImage =
      imageUri: data.image
      imageCredit: data.image_credit
      imageLicense: data.image_license
    # Insert the image
    try
      insertModalImage()
    catch e
      console.info("Unable to insert modal image! ")
    checkTaxonNear taxon, ->
      stopLoad()
      modalElement = d$("#modal-taxon")[0]
      d$("#modal-taxon").on "iron-overlay-opened", ->
        modalElement.fit()
        modalElement.scrollTop = 0
        if toFloat($(modalElement).css("top").slice(0,-2)) > $(window).height()
          # Firefox is weird about this sometimes ...
          # Let's add a catch-all 'top' adjustment
          $(modalElement).css("top","12.5vh")
        delay 250, ->
          modalElement.fit()
      modalElement.sizingTarget = d$("#modal-taxon-content")[0]
      safariDialogHelper("#modal-taxon")
    bindDismissalRemoval()
  .fail (result,status) ->
    stopLoadError()
  false


bindDismissalRemoval = ->
  $("[dialog-dismiss]")
  .unbind()
  .click ->
    $(this).parents("paper-dialog").remove()


doFontExceptions = ->
  ###
  # Look for certain keywords to force into capitalized, or force
  # uncapitalized, overriding display CSS rules
  ###
  alwaysLowerCase = [
    "de"
    "and"
    ]

  forceSpecialToLower = (authorityText) ->
    # Returns HTML
    $.each alwaysLowerCase, (i,word) ->
      # Do this to each
      #console.log("Checking #{authorityText} for #{word}")
      search = " #{word} "
      if authorityText?
        authorityText = authorityText.replace(search, " <span class='force-lower'>#{word}</span> ")
    return authorityText

  d$(".authority").each ->
    authorityText = $(this).text()
    unless isNull(authorityText)
      #console.log("Forcing format of #{authorityText}")
      $(this).html(forceSpecialToLower(authorityText))
  false



sortResults = (by_column) ->
  # Somethign clever -- look at each of the by_column points, then
  # throw those into an array and sort those, using their index as a
  # map to data and re-mapping data by those orders. May need to use
  # the index of a duplicated array as the reference - walk through
  # sorted and lookup position in reference, then data[index] = data[ref_pos]
  data = searchParams.result

setHistory = (url = "#",state = null, title = null) ->
  ###
  # Set up the history to provide something linkable
  ###
  history.pushState(state,title,url)
  # Rewrite the query URL
  uri.query = $.url(url).attr("fragment")
  false

clearSearch = (partialReset = false) ->
  ###
  # Clear out the search and reset it to a "fresh" state.
  ###
  $("#result-count").text("")
  calloutHtml = """
  <div class="alert alert-info center-block col-xs-12 col-sm-8 col-md-5">
    Search for a common or scientific name above to begin, eg, "Brown Bear" or "<span class="sciname">Ursus arctos</span>"
  </div>
  """
  $("#result_container").html(calloutHtml)
  $("#result-header-container").attr "hidden", "hidden"
  # Clear any pending error
  $(".hanging-alert.alert-danger").remove()
  if partialReset is true then return false
  # Do a history breakpoint
  setHistory()
  # Reset the fields
  $(".cndb-filter").attr("value","")
  $("#collapse-advanced").collapse('hide')
  $("#search").attr("value","")
  $("#linnean").polymerSelected("any")
  formatScientificNames()
  false



safariDialogHelper = (selector = "#download-chooser", counter = 0, callback) ->
  ###
  # Help Safari display paper-dialogs
  ###
  unless typeof callback is "function"
    callback = ->
      bindDismissalRemoval()
  if counter < 10
    try
      # Safari is stupid and like to throw an error. Presumably
      # it's VERY slow about creating the element.
      try
        p$(selector).open()
      catch
        d$(selector).get(0).open()
      if typeof callback is "function"
        callback()
      stopLoad()
    catch e
      # Ah, Safari threw an error. Let's delay and try up to
      # 10x.
      newCount = counter + 1
      delayTimer = 250
      delay delayTimer, ->
        console.warn "Trying again to display dialog after #{newCount * delayTimer}ms"
        console.debug "Error caught: #{e.message}"
        console.debug e.stack
        safariDialogHelper(selector, newCount, callback)
  else
    stopLoadError("Unable to show dialog. Please try again.")


safariSearchArgHelper = (value, didLateRecheck = false) ->
  ###
  # If the search argument has a "+" in it, remove it
  # Then write the arg to search.
  #
  # Since Safari doesn't "take" it all the time, keep trying till it does.
  ###
  if value?
    searchArg = value
  else
    searchArg = $("#search").val()
  trimmed = false
  if searchArg.search(/\+/) isnt -1
    trimmed = true
    searchArg = searchArg.replace(/\+/g," ").trim()
    # console.log("Trimmed a plus")
    delay 100, ->
      safariSearchArgHelper()
  if trimmed or value?
    $("#search").attr("value",searchArg)
    # console.log("Updated the search args")
    unless didLateRecheck
      delay 5000, ->
        # What? Safari is VERY slow on older devices,
        # and this check will fix them.
        safariSearchArgHelper(undefined, true)
  false


insertCORSWorkaround = ->
  unless _asm.hasShownWorkaround?
    _asm.hasShownWorkaround = false
  if _asm.hasShownWorkaround
    return false
  try
    browsers = new WhichBrowser()
  catch e
    # Defer it till next time
    return false
  if browsers.isType("mobile")
    # We don't need to show this at all -- no extensions!
    _asm.hasShownWorkaround = true
    return false
  browserExtensionLink = switch browsers.browser.name
    when "Chrome"
      """
      Install the extension "<a class='alert-link' href='https://chrome.google.com/webstore/detail/allow-control-allow-origi/nlfbmbojpeacfghkpbjhddihlkkiljbi?utm_source=chrome-app-launcher-info-dialog'>Allow-Control-Allow-Origin: *</a>", activate it on this domain, and you'll see them in your popups!
      """
    when "Firefox"
      """
      Follow the instructions <a class='alert-link' href='http://www-jo.se/f.pfleger/forcecors-workaround'>for this ForceCORS add-on</a>, or try Chrome for a simpler extension. Once you've done so, you'll see photos in your popups!
      """
    when "Internet Explorer"
      """
      Follow these <a class='alert-link' href='http://stackoverflow.com/a/20947828'>StackOverflow instructions</a> while on this site, and you'll see them in your popups!
      """
    else ""
  html = """
  <div class="alert alert-info alert-dismissible center-block fade in" role="alert">
    <button type="button" class="close" data-dismiss="alert" aria-label="Close"><span aria-hidden="true">&times;</span></button>
    <strong>Want CalPhotos images in your species dialogs?</strong> #{browserExtensionLink}
    We're working with CalPhotos to enable this natively, but it's a server change on their side.
  </div>
  """
  $("#result_container").before(html)
  $(".alert").alert()
  _asm.hasShownWorkaround = true
  false


showBadSearchErrorMessage = (result) ->
  try
    sOrig = result.query.replace(/\+/g," ")
  catch
    sOrig = $("#search").val()
  try
    if result.status is true
      if result.query_params.filter.had_filter is true
        filterText = ""
        i = 0
        $.each result.query_params.filter.filter_params, (col,val) ->
          if col isnt "BOOLEAN_TYPE"
            if i isnt 0
              filterText = "#{filter_text} #{result.filter.filter_params.BOOLEAN_TYPE}"
            if isNumber(toInt(val,true))
              val = if toInt(val) is 1 then "true" else "false"
            filterText = "#{filterText} #{col.replace(/_/g," ")} is #{val}"
        text = "\"#{sOrig}\" where #{filterText} returned no results."
      else
        text = "\"#{sOrig}\" returned no results."
    else
      text = result.human_error
  catch
    text = "Sorry, there was a problem with your search"
  try
    if text.search(/no results/) >= 0
      alertText = """
      <code>ZERO_RESULTS</code><strong>:</strong> #{text}
      """
      bsAlert alertText, "danger"
      text = "Sorry, your search returned no results"
  stopLoadError(text)




bindPaperMenuButton = (selector = "paper-menu-button", unbindTargets = true) ->
  ###
  # Use a paper-menu-button and make the
  # .dropdown-label gain the selected value
  #
  # Reference:
  # https://github.com/polymerelements/paper-menu-button
  # https://elements.polymer-project.org/elements/paper-menu-button
  ###
  return false
  for dropdown in $(selector)
    menu = $(dropdown).find("paper-menu")
    if unbindTargets
      $(menu).unbind()
    do relabelSelectedItem = (target = menu, activeDropdown = dropdown) ->
      # A menu item has been selected!
      selectText = $(target).polymerSelected(null, true)
      # console.log("iron-select fired! We fetched '#{selectText}'")
      labelSpan = $(activeDropdown).find(".dropdown-label")
      $(labelSpan).text(selectText)
      $(target).polymerSelected()
    $(menu).on "iron-select", ->
      relabelSelectedItem this, dropdown
  false



getRandomEntry = ->
  ###
  # Get a random taxon, and go to that page
  ###
  startLoad()
  args =
    random: true
    require_image: true
  $.get searchParams.apiPath, buildQuery args, "json"
  .done (result) ->
    if isNull(result.genus) or isNull result.species
      stopLoadError "Unable to fetch random entry"
    accountQuery =
      genus: result.genus
      species: result.species
    unless isNull result.subspecies
      accountQuery.subspecies = result.subspecies
    dest = "#{uri.urlString}species-account.php?#{buildQuery accountQuery}"
    console.log "About to go to", dest
    goTo dest
    stopLoad() # Just in case
  .fail ->
    stopLoadError "Unable to fetch random entry"
  false


window.getRandomEntry = getRandomEntry



doLazily = ->
  ###
  # Load these assets lazily, but only once
  ###
  unless _asm?.hasDoneLazily is true
    unless typeof _asm is "object"
      window._asm = new Object()
    _asm.hasDoneLazily = true
    loadJS "#{uri.urlString}js/download.min.js", ->
      # Insert an icon into the footer to trigger the download
      # (eg, invoke showDownloadChooser())
      html = """
      <paper-icon-button
        icon="icons:cloud-download"
        class="click"
        data-fn="showDownloadChooser"
        title="Download Copy"
        data-toggle="tooltip"
        >
      </paper-icon-button>
      """
      $("#git-footer").prepend html
      bindClicks()
      mobileCollapsable()
      loadJS "#{uri.urlString}js/terminal.min.js", ->
        bindClicks()
        console.debug "Terminal file loaded"
        stopLoad()
      false
    if $("paper-card.featured-mammal").exists()
      $("paper-card.featured-mammal").click ->
        id = $(this).attr "data-taxon-id"
        # Cheat for now rather than populating a dialog
        path = "species-account/id=#{id}"
        goTo path
        false
  false



mobileCollapsable = (selector = ".search-options-panel", breakpoint = _asm?.mobileBreakpoint ? 767, debounceInterval = 250) ->
  ###
  # Collapse all sections inside of selector, using the legend as a trigger
  ###
  console.debug "Checking mobile status"
  if $(window).width() <= breakpoint
    unless typeof core?.debouncers is "object"
      unless typeof core is "object"
        window.core = new Object()
      core.debouncers = new Object()
    if core.debouncers.mobileCollapsable?
      if Date.now() - core.debouncers.mobileCollapsable <= debounceInterval
        return false
      delete core.debouncers.mobileCollapsable
      clearTimeout core.debouncers.mobileCollapseableTimeout
    core.debouncers.mobileCollapsable = Date.now()
    clearDebounce = 2 * debounceInterval
    core.debouncers.mobileCollapseableTimeout = delay clearDebounce, ->
      delete core.debouncers.mobileCollapsable
    $(selector).find("section").collapse()
    hasDoneInitialCollapse = false
    $($(selector).find("section").get(0)).on "shown.bs.collapse", ->
      unless hasDoneInitialCollapse
        delay 50, ->
          for section in $(selector).find("section")
            $(section).collapse("hide")
        hasDoneInitialCollapse = true
      false
    $(selector).find("legend")
    .text "Show Options"
    .addClass "btn btn-default"
    .click ->
      isCollapsed = not $(selector).find("section").hasClass "in"
      if isCollapsed
        $(this).text "Hide Options"
        $(selector).find("section").collapse("show")
      else
        $(this).text "Show Options"
        $(selector).find("section").collapse("hide")
    true
  else
    console.debug "Not a mobile viewport"
    false


$ ->
  devHello = """
  ****************************************************************************
  Hello developer!
  If you're looking for hints on our API information, this site is open-source
  and released under the GPL. Just click on the GitHub link on the bottom of
  the page, or check out LINK_TO_ORG_REPO
  ****************************************************************************
  """
  console.log(devHello)
  _asm.polymerReady = false
  ignorePages = [
    "admin-login.php"
    "admin-page.html"
    "admin-page.php"
    ]
  if uri.o.attr("file") in ignorePages
    try
      do setupPolymerReady = ->
        try
          if Polymer?.Base?.$$?
            Polymer.Base.ready ->
              _asm.polymerReady = true
            delay 250, ->
              _asm.polymerReady = true
          else
            throw {message:"POLYMER_NOT_READY"}
        catch
          delay 100, ->
            setupPolymerReady
    return false
  # Do bindings
  # console.log("Doing onloads ...")
  animateLoad()
  # Set up popstate
  window.addEventListener "popstate", (e) ->
    uri.query = $.url().attr("fragment")
    try
      loadArgs = Base64.decode(uri.query)
    catch e
      loadArgs = ""
    #console.log("Popping state to #{loadArgs}")
    performSearch.debounce 50, null, null, loadArgs
    temp = loadArgs.split("&")[0]
    $("#search").attr("value",temp)
  ## Set events
  $("#do-reset-search").click ->
    clearSearch()
  $("#search_form").submit (e) ->
    e.preventDefault()
    performSearch.debounce 50
  $("#collapse-advanced").on "shown.bs.collapse", ->
    $("#collapse-icon").attr("icon","icons:unfold-less")
    # We need to uncheck the global search
    p$("#global_search").checked = false
    false
  $("#collapse-advanced").on "hidden.bs.collapse", ->
    $("#collapse-icon").attr("icon","icons:unfold-more")
  # Bind enter keydown
  $("#search_form").keypress (e) ->
    if e.which is 13 then performSearch.debounce 50
  # Bind clicks
  $("#do-search").click ->
    performSearch.debounce 50
  $("#do-search-all").click ->
    performSearch.debounce 50, null, null, true
  $("#linnean").on "iron-select", ->
    # We do want to auto-trigger this when there's a search value,
    # but not when it's empty (even though this is valid)
    if not isNull($("#search").val()) then performSearch.debounce()
  eutheriaFilterHelper()
  bindPaperMenuButton()
  # Do a fill of the result container
  if isNull uri.query
    loadArgs = ""
    try
      do setupPolymerReady = ->
        try
          if Polymer?.Base?.$$?
            Polymer.Base.ready ->
              _asm.polymerReady = true
            delay 250, ->
              _asm.polymerReady = true
          else
            throw {message:"POLYMER_NOT_READY"}
        catch
          delay 100, ->
            setupPolymerReady
  else
    try
      loadArgs = Base64.decode(uri.query)
      queryUrl = $.url("#{searchParams.apiPath}?q=#{loadArgs}")
      try
        looseState = queryUrl.param("loose").toBool()
      catch e
        looseState = false
      try
        fuzzyState = queryUrl.param("fuzzy").toBool()
      catch e
        fuzzyState = false
      temp = loadArgs.split("&")[0]
      # Remove any plus signs in the query
      safariSearchArgHelper(temp)
      # Delay these for polyfilled element registration
      # See
      # https://github.com/PolymerElements/paper-toggle-button/issues/29
      do fixState = ->
        if Polymer?.Base?.$$?
          unless isNull Polymer.Base.$$("#loose")
            _asm.polymerReady = true
            delay 250, ->
              if looseState
                d$("#loose").attr("checked", "checked")
              if fuzzyState
                d$("#fuzzy").attr("checked", "checked")
            return false
        unless _asm.stateIter?
          _asm.stateIter = 0
        ++_asm.stateIter
        if _asm.stateIter > 30
          console.warn("Couldn't attach Polymer.Base.ready")
          return false
        try
          Polymer.Base.ready ->
            # The whenReady makes the toggle work, but it won't toggle
            # without this "real" delay
            _asm.polymerReady = true
            delay 250, ->
              console.info "Doing a late Polymer.Base.ready call"
              if looseState
                d$("#loose").attr("checked", "checked")
              if fuzzyState
                d$("#fuzzy").attr("checked", "checked")
              safariSearchArgHelper()
              eutheriaFilterHelper()
        catch
          delay 250, ->
            fixState()
      # Filters
      try
        f64 = queryUrl.param("filter")
        filterObj = JSON.parse(Base64.decode(f64))
        openFilters = false
        simpleAllowedFilters = [
          "simple-linnean-group"
          "simple-linnean-subgroup"
          "linnean-family"
          "type"
          "BOOLEAN-TYPE"
          ]
        for col, val of filterObj
          col = col.replace(/_/g,"-")
          #selector = "##{col}-filter"
          selector = ".cndb-filter[data-column='#{col}']"
          unless col in simpleAllowedFilters
            console.debug "Col '#{col}' is not a simple filter"
            $(selector).attr("value",val)
            openFilters = true
          else
            $(".cndb-filter[data-column='#{col}']").polymerSelected(val)
        if openFilters
          # Open up #collapse-advanced
          $("#collapse-advanced").collapse("show")
      catch e
        # Do nothing
        f64 = false
    catch e
      console.error("Bad argument #{uri.query} => #{loadArgs}, looseState, fuzzyState",looseState,fuzzyState,"#{searchParams.apiPath}?q=#{loadArgs}")
      console.warn(e.message)
      loadArgs = ""
  # Perform the initial search
  if not isNull(loadArgs) and loadArgs isnt "#"
    # console.log("Doing initial search with '#{loadArgs}', hitting","#{searchParams.apiPath}?q=#{loadArgs}")
    try
      searchParams.lastSearch = loadArgs
    $.get searchParams.targetApi,"q=#{loadArgs}","json"
    .done (result) ->
      # Populate the result container
      _asm.polymerReady = true
      console.debug "Server query got", result
      if result.status is true and result.count > 0
        console.log "Got a valid result, formatting #{result.count} results."
        formatSearchResults result, undefined, ->
          console.log "Format results finished, checking lagged update"
          checkLaggedUpdate result
        return false
      console.warn "Bad initial search"
      showBadSearchErrorMessage.debounce null, null, null, result
      console.error result.error
      console.warn result
    .fail (result,error) ->
      console.error("There was an error loading the generic table")
      console.warn(result,error,result.statusText)
      error = "#{result.status} - #{result.statusText}"
      $("#search-status").attr("text","Couldn't load table - #{error}")
      $("#search-status")[0].show()
      stopLoadError()
    .always ->
      # Anything we always want done
      $("#search").attr("disabled",false)
      false
  else
    stopLoad()
    $("#search").attr("disabled",false)
    # Delay this for polyfilled element registration
    # See
    # https://github.com/PolymerElements/paper-toggle-button/issues/29
    do fixState = ->
      if Polymer?.Base?.$$?
        unless isNull Polymer.Base.$$("#loose")
          _asm.polymerReady = true
          delay 250, ->
            d$("#loose").attr("checked", "checked")
            eutheriaFilterHelper()
          return false
      unless _asm.stateIter?
        _asm.stateIter = 0
      ++_asm.stateIter
      if _asm.stateIter > 30
        console.warn("Couldn't attach Polymer.Base.ready")
        return false
      try
        Polymer.Base.ready ->
          # The whenReady makes the toggle work, but it won't toggle
          # without this "real" delay
          _asm.polymerReady = true
          delay 250, ->
            d$("#loose").attr("checked", "checked")
            eutheriaFilterHelper()
      catch
        delay 250, ->
          fixState()
