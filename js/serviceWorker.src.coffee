###
# Core helpers/imports for web workers
###

# jQuery DOM workaround
# `var document = self.document = {parentNode: null, nodeType: 9, toString: function() {return "FakeDocument"}};
# var window = self.window = self;
# var fakeElement = Object.create(document);
# fakeElement.nodeType = 1;
# fakeElement.toString=function() {return "FakeElement"};
# fakeElement.parentNode = fakeElement.firstChild = fakeElement.lastChild = fakeElement;
# fakeElement.ownerDocument = document;

# document.head = document.body = fakeElement;
# document.ownerDocument = document.documentElement = document;
# document.getElementById = document.createElement = function() {return fakeElement;};
# document.createDocumentFragment = function() {return this;};
# document.createElement = function() {return this;};
# document.getElementsByTagName = document.getElementsByClassName = function() {return [fakeElement];};
# document.getAttribute = document.setAttribute = document.removeChild =
#   document.addEventListener = document.removeEventListener =
#   function() {return null;};
# document.cloneNode = document.appendChild = function() {return this;};
# document.appendChild = function(child) {return child;};`

# importScripts "https://ajax.googleapis.com/ajax/libs/jquery/2.1.3/jquery.min.js"
# try
#   importScripts "purl.min.js"
#   # Set up basic URI parameters
#   # Uses
#   # https://github.com/allmarkedup/purl
#   try
#     uri = new Object()
#     uri.o = $.url()
#     uri.urlString = uri.o.attr('protocol') + '://' + uri.o.attr('host')  + uri.o.attr("directory")
#     uri.query = uri.o.attr("fragment")
#   catch e
#     console.warn("PURL not installed!")

locationData = new Object()
locationData.params =
  enableHighAccuracy: true
locationData.last = undefined


isBool = (str,strict = false) ->
  if strict
    return typeof str is "boolean"
  try
    if typeof str is "boolean"
      return str is true or str is false
    if typeof str is "string"
      return str.toLowerCase() is "true" or str.toLowerCase() is "false"
    if typeof str is "number"
      return str is 1 or str is 0
    false
  catch e
    return false

isEmpty = (str) -> not str or str.length is 0

isBlank = (str) -> not str or /^\s*$/.test(str)

isNull = (str) ->
  try
    if isEmpty(str) or isBlank(str) or not str?
      unless str is false or str is 0 then return true
  catch e
    return false
  false

isJson = (str) ->
  if typeof str is 'object' and not isArray str then return true
  try
    JSON.parse(str)
    return true
  catch
    return false
  false

isArray = (arr) ->
  try
    shadow = arr.slice 0
    shadow.push "foo"
    return true
  catch
    return false


isNumber = (n) -> not isNaN(parseFloat(n)) and isFinite(n)

toFloat = (str) ->
  if not isNumber(str) or isNull(str) then return 0
  parseFloat(str)

toInt = (str) ->
  if not isNumber(str) or isNull(str) then return 0
  f = parseFloat(str) # For stuff like 1.2e12
  parseInt(f)

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


String::toBool = ->
  test = @toString().toLowerCase()
  test is 'true' or test is "1"

Boolean::toBool = -> @toString() is "true"

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

String::unescape = ->
  ###
  # We can't access 'document', so alias
  ###
  deEscape this


deEscape = (string) ->
  stringIn = string
  i = 0
  while newString isnt stringIn
    if i isnt 0
      stringIn = newString
      string = newString
    string = string.replace(/\&amp;#/mig, '&#') # The rest
    string = string.replace(/\&amp;/mig, '&')
    string = string.replace(/\&quot;/mig, '"')
    string = string.replace(/\&quote;/mg, '"')
    string = string.replace(/\&#95;/mg, '_')
    string = string.replace(/\&#39;/mg, "'")
    string = string.replace(/\&#34;/mg, '"')
    string = string.replace(/\&#62;/mg, '>')
    string = string.replace(/\&#60;/mg, '<')
    ++i
    if i >= 10
      console.warn "deEscape quitting after #{i} iterations"
      break
    newString = string
  decodeURIComponent string




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

byteCount = (s) => encodeURI(s).split(/%..|./).length - 1

`function shuffle(o) { //v1.0
    for (var j, x, i = o.length; i; j = Math.floor(Math.random() * i), x = o[--i], o[i] = o[j], o[j] = x);
    return o;
}`



toObject = (array) ->
  rv = new Object()
  for index, element of array
    if element isnt undefined then rv[index] = element
  rv

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



randomInt = (lower = 0, upper = 1) ->
  start = Math.random()
  if not lower?
    [lower, upper] = [0, lower]
  if lower > upper
    [lower, upper] = [upper, lower]
  return Math.floor(start * (upper - lower + 1) + lower)


randomString = (length = 8) ->
  i = 0
  charBottomSearchSpace = 65 # "A"
  charUpperSearchSpace = 126
  stringArray = new Array()
  while i < length
    ++i
    # Search space
    char = randomInt charBottomSearchSpace, charUpperSearchSpace
    stringArray.push String.fromCharCode char
  stringArray.join ""




openLink = (url) ->
  if not url? then return false
  open(url)
  false

openTab = (url) ->
  openLink(url)

goTo = (url) ->
  if not url? then return false
  location.href = url
  false



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



prepURI = (string) ->
  string = encodeURIComponent(string)
  string.replace(/%20/g,"+")


locationData = new Object()
locationData.params =
  enableHighAccuracy: true
locationData.last = undefined

getLocation = (callback = undefined) ->
  retryTimeout = 1500
  geoSuccess = (pos) ->
    clearTimeout geoTimeout
    locationData.lat = pos.coords.latitude
    locationData.lng = pos.coords.longitude
    locationData.acc = pos.coords.accuracy
    last = locationData.last
    locationData.last = Date.now() # ms, unix time
    elapsed = locationData.last - last
    if elapsed < retryTimeout
      # Don't run too many times
      return false
    console.info "Successfully set location"
    if typeof callback is "function"
      callback(locationData)
    false
  geoFail = (error) ->
    clearTimeout geoTimeout
    locationError = switch error.code
      when 0 then "There was an error while retrieving your location: #{error.message}"
      when 1 then "The user prevented this page from retrieving a location"
      when 2 then "The browser was unable to determine your location: #{error.message}"
      when 3 then "The browser timed out retrieving your location."
    console.error(locationError)
    if typeof callback is "function"
      callback(false)
    false
  # Actual location query
  if navigator.geolocation
    console.log "Querying location"
    navigator.geolocation.getCurrentPosition(geoSuccess,geoFail,locationData.params)
    geoTimeout = delay 1500, ->
      getLocation callback
  else
    console.warn("This browser doesn't support geolocation!")
    if callback?
      callback(false)


downloadCSVFile = (data, options) ->
  ###
  # Options:
  #
  options = new Object()
  options.create ?= false
  options.downloadFile ?= "datalist.csv"
  options.classes ?= "btn btn-default"
  options.buttonText ?= "Download File"
  options.iconHtml ?= """<iron-icon icon="icons:cloud-download"></iron-icon>"""
  options.selector ?= "#download-file"
  options.splitValues ?= false
  ###
  startTime = Date.now()
  textAsset = ""
  if isJson(data) and typeof data is "string"
    console.info "Parsing as JSON string"
    try
      jsonObject = JSON.parse data
    catch e
      console.error "COuldn't parse json! #{e.message}"
      console.warn e.stack
      console.info data
      throw "error"
  else if isArray data
    console.info "Parsing as array"
    jsonObject = toObject data
  else if typeof data is "object"
    console.info "Parsing as object"
    jsonObject = data
  else
    console.error "Unexpected data type '#{typeof data}' for downloadCSVFile()", data
    return false
  # Make sure options are available the rest of the way down
  unless options?
    options = new Object()
  options.create ?= false
  options.downloadFile ?= "datalist.csv"
  options.classes ?= "btn btn-default"
  options.buttonText ?= "Download File"
  options.iconHtml ?= """<iron-icon icon="icons:cloud-download"></iron-icon>"""
  options.selector ?= "#download-file"
  options.splitValues ?= false
  options.cascadeObjects ?= false
  options.objectAsValues ?= true
  # Parse it
  headerPlaceholder = new Array()
  do parser = (jsonObj = jsonObject, cascadeObjects = options.cascadeObjects) ->
    row = 0
    if options.objectAsValues
      options.splitValues = "::@@::"
    for key, value of jsonObj
      if typeof value is "function" then continue
      ++row
      # Escape as per RFC4180
      # https://tools.ietf.org/html/rfc4180#page-2
      try
        escapedKey = key.toString().replace(/"/g,'""')
        if row is 1
          unless options.objectAsValues
            console.log "Boring options", options.objectAsValues, options
            headerPlaceholder.push escapedKey
          else
            console.info "objectAsValues set"
            for col, data of value
              if isArray options.acceptableCols
                if col in options.acceptableCols
                  headerPlaceholder.push col
              else
                headerPlaceholder.push col
            console.log "Using as header", headerPlaceholder
        if typeof value is "object" and cascadeObjects
          # Parse it differently
          value = parser(value, true)
        handleValue = (providedValue = value, providedOptions = options) ->
          # Parse it all
          if isNull value
            escapedValue = ""
          else
            if typeof providedValue is "object"
              providedValue = JSON.stringify providedValue
            providedValue = providedValue.toString()
            tempValue = providedValue.replace(/,/g,'\,')
            tempValue = tempValue.replace(/"/g,'""')
            tempValue = tempValue.replace(/<\/p><p>/g,'","')
            if typeof providedOptions.splitValues is "string"
              tempValueArr = tempValue.split providedOptions.splitValues
              tempValue = tempValueArr.join "\",\""
              escapedKey = false
            escapedValue = tempValue
          if escapedKey is false
            # Special case of split values
            tmpTextAsset = "\"#{escapedValue}\"\n"
          else if isNumber escapedKey
            tmpTextAsset = "\"#{escapedValue}\","
          else unless isNull escapedKey
            tmpTextAsset = """"#{escapedKey}","#{escapedValue}"

            """
          tmpTextAsset
        # Build the textAsset string
        unless options.objectAsValues
          textAsset += handleValue(value)
        else
          tmpRow = new Array()
          for col in headerPlaceholder
            dataVal = value[col]
            if typeof dataVal is "object"
              try
                dataVal = JSON.stringify dataVal
                dataVal = dataVal.replace(/"/g,'""')
            tmpRow.push dataVal
          tmpRowString = tmpRow.join options.splitValues
          textAsset += handleValue tmpRowString, options
      catch e
        console.warn "Unable to run key #{key} on row #{row}", value, jsonObj
        console.warn e.stack
  textAsset = textAsset.trim()
  k = 0
  for col in headerPlaceholder
    col = col.replace(/"/g,'""')
    headerPlaceholder[k] = col
    ++k
  if options.objectAsValues
    options.header = headerPlaceholder
  if isArray options.header
    headerStr = options.header.join "\",\""
    textAsset = """
    "#{headerStr}"
    #{textAsset}
    """
    # CoffeScript 1.10 has a bug with """ leading ", so we needed to
    # start on a new line above. Remove it.
    textAsset = textAsset.trim()
    header = "present" # https://tools.ietf.org/html/rfc4180#page-4
  else
    # https://tools.ietf.org/html/rfc4180#page-4
    header = "absent"
  if textAsset.slice(-1) is ","
    textAsset = textAsset.slice(0, -1)
  file = "data:text/csv;charset=utf-8;header=#{header}," + encodeURIComponent(textAsset)
  selector = options.selector
  if options.create is true
    c = randomInt 0, 9999
    id = "#{selector.slice(1)}-download-button-#{c}"
    html = """
    <a id="#{id}" class="#{options.classes}" href="#{file}" download="#{options.downloadFile}">
      #{options.iconHtml}
      #{options.buttonText}
    </a>
    """
  else
    html = ""
  response =
    file: file
    options: options
    html: html
  elapsed = Date.now() - startTime
  console.debug "CSV Worker saved #{elapsed}ms from main thread"
  response



generateCSVFromResults = (resultArray, caller, selector = "#modal-sql-details-list") ->
  console.info "Worker CSV: Given", resultArray
  options =
    objectAsValues: true
    downloadFile: "adp-global-search-result-data_#{Date.now()}.csv"
    # acceptableCols: [
    #   "collectionid"
    #   "catalognumber"
    #   "fieldnumber"
    #   "sampleid"
    #   "diseasetested"
    #   "diseasestrain"
    #   "samplemethod"
    #   "sampledisposition"
    #   "diseasedetected"
    #   "fatal"
    #   "cladesampled"
    #   "genus"
    #   "specificepithet"
    #   "infraspecificepithet"
    #   "lifestage"
    #   "dateidentified"
    #   "decimallatitude"
    #   "decimallongitude"
    #   "alt"
    #   "coordinateuncertaintyinmeters"
    #   "collector"
    #   "fimsextra"
    #   "originaltaxa"
    #   ]
  try
    response = downloadCSVFile(resultArray, options)
  catch
    console.error "Sorry, there was a problem with this dataset and we can't do that right now."
    response =
      file: ""
      options: options
      html: ""
  response




validateAWebTaxon = (taxonObj, callback = null) ->
  ###
  #
  #
  # @param Object taxonObj -> object with keys "genus", "species", and
  #   optionally "subspecies"
  # @param function callback -> Callback function
  ###
  unless validationMeta?.validatedTaxons?
    # Just being thorough on this check
    unless typeof validationMeta is "object"
      validationMeta = new Object()
    # Create the array if it doesn't exist yet
    validationMeta.validatedTaxons = new Array()
  doCallback = (validatedTaxon) ->
    if typeof callback is "function"
      callback(validatedTaxon)
    false
  # Check the taxon against pre-validated ones
  if validationMeta.validatedTaxons.containsObject taxonObj
    console.info "Already validated taxon, skipping revalidation", taxonObj
    doCallback(taxonObj)
    return false
  args = "action=validate&genus=#{taxonObj.genus}&species=#{taxonObj.species}"
  if taxonObj.subspecies?
    args += "&subspecies=#{taxonObj.subspecies}"
  _adp.currentAsyncJqxhr = $.post "api.php", args, "json"
  .done (result) ->
    if result.status
      # Success! Save validated taxon, and run callback
      taxonObj.genus = result.validated_taxon.genus
      taxonObj.species = result.validated_taxon.species
      taxonObj.subspecies = result.validated_taxon.subspecies
      taxonObj.clade ?= result.validated_taxon.family
      validationMeta.validatedTaxons.push taxonObj
    else
      taxonObj.invalid = true
    taxonObj.response = result
    doCallback(taxonObj)
    return false
  .fail (result, status) ->
    # On fail, notify the user that the taxon wasn't actually validated
    # with a BSAlert, rather than toast
    prettyTaxon = "#{taxonObj.genus} #{taxonObj.species}"
    prettyTaxon = if taxonObj.subspecies? then "#{prettyTaxon} #{taxonObj.subspecies}" else prettyTaxon
    bsAlert "<strong>Problem validating taxon:</strong> #{prettyTaxon} couldn't be validated."
    console.warn "Warning: Couldn't validated #{prettyTaxon} with AmphibiaWeb"
  false

###
# Service worker!
###

#authorityTest = /^\(? *((['"])? *([\w\u00C0-\u017F\. \-\&;\[\]]+(,|&|&amp;|&amp;amp;|&#[\w0-9]+;)?)+ *\2) *, *([0-9]{4}) *\)?/img
#yearMatch = "$5"
authorityTest = /^\(? *((['"]?) *(?:(?:\b|[\u00C0-\u017F])[a-z\u00C0-\u017F\u2019 \.\-\[\]\?]+(?:,|,? *&|,? *&amp;| *&amp;amp;| *&(?:[a-z]+|#[0-9]+);)? *)+ *\2) *, *([0-9]{4}) *\)?/img
yearMatch = "$3"
authorityMatch = "$1"
commalessTest = /^(\(?)(.*?[^,]) ([0-9]{4})(\)?)$/img
progressStepCount = 1000.0

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
      console.log "Got HTML info from file on thread", e.data
      createHtmlFile e.data.data, e.data.htmlHeader
    when "render-csv"
      console.log "Got CSV info from file on thread", e.data
      createCSVFile e.data.data
    else
      console.error "No valid action recieved from worker initialization!", e.data
      console.warn e


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
  progressStep = total / progressStepCount
  console.debug "Step size", progressStep
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
        if k > 0
          if toInt(k %% progressStep) is 0
            message =
              status: true
              done: false
              progress: toInt k / progressStep
            self.postMessage message
          if k %% 100 is 0
            #console.log "Parsing row #{k} of #{total}"
            if k %% 500 is 0
              message =
                status: true
                done: false
                updateUser: "Parsing #{k} of #{total}, please wait"
              self.postMessage message
      if isNull(row.genus) or isNull(row.species)
        # Skip this clearly unfinished entry
        continue
      try
        clearTimeout hangTimeout
        hangTimeout = delay 250, ->
          console.warn "Possible hang on row ##{k}", row
          hangTimeout = delay 1000, ->
            message =
              status: false
              done: false
              updateUser: "Failure to parse row #{k}"
            self.postMessage message
            self.close()
      # try
      #   if 2900 <= k <= 3000
      #     console.warn "Testing row #{k}", row
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
              # Strip HTML
              row.species_authority = row.species_authority.replace /(<\/|<|&lt;|&lt;\/).*?(>|&gt;)/img, ""
              # Prevent a catastrophic backtrack
              if commalessTest.test row.species_authority
                row.species_authority = row.species_authority.replace commalessTest, "$1$2, $3$4"
              # The real tester
              if authorityTest.test(row.species_authority)
                year = row.species_authority.replace authorityTest, yearMatch
                row.species_authority = row.species_authority.replace authorityTest, authorityMatch
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
        if not genusAuth?
          genusAuth = ""
        oneOffHtml += """
        <aside class="genus-declaration lead">
          <span class="entry-sciname text-capitalize">#{row.genus}</span>
          <span class="entry-authority">#{genusAuth?.unescape()}</span>
        </aside>
        """
        hasReadGenus.push row.genus
      shortGenus = "#{row.genus.slice(0,1)}. "
      if not speciesAuth?
        speciesAuth = ""
      entryHtml = """
      <section class="species-entry">
        #{oneOffHtml}
        <p class="h4 entry-header">
          <span class="entry-sciname">
            <span class="text-capitalize">#{shortGenus}</span> #{row.species} #{row.subspecies}
          </span>
          <span class="entry-authority">
            #{speciesAuth?.unescape()}
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
    message =
      status: true
      done: false
      progress: progressStepCount
    self.postMessage message
    duration = Date.now() - startTime
    console.log "HTML file prepped in #{duration}ms off-thread"
    message =
      html: htmlBody
      status: true
      done: true
    self.postMessage message
    console.debug "Completed worker!"
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




createCSVFile = (result) ->
  startTime = Date.now()
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
    # "parens_auth_genus"
    "species_authority"
    # "parens_auth_species"
    # "authority_year"
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
  boolToString = [
    "parens_auth_genus"
    "parens_auth_species"
    ]
  i = 0
  console.debug "Got result"
  totalCount = Object.size result.result
  progressStep = totalCount / progressStepCount
  console.debug "Step size", progressStep
  try
    for k, row of result.result
      if k > 0
        if toInt(k %% progressStep) is 0
          message =
            status: true
            done: false
            progress: toInt k / progressStep
          self.postMessage message
        if k %% 100 is 0
          console.debug "CSV-ing row #{k} of #{totalCount}"
          if k %% 500 is 0
            message =
              status: true
              done: false
              updateUser: "Parsing #{k} of #{totalCount}, please wait"
            self.postMessage message
      # Line by line ... do each result
      csvRow = new Array()
      if isNull(row.genus) or isNull(row.species)
        # Skip this clearly unfinished entry
        continue
      #for dirtyCol, dirtyColData of row
      for dirtyCol in showColumn
        dirtyColData = row[dirtyCol]
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
            colData = colData.unescape()
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
                    # Prevent a catastrophic backtrack
                    if commalessTest.test row.species_authority
                      row.species_authority = row.species_authority.replace commalessTest, "$1$2, $3$4"
                    # The real tester
                    if authorityTest.test(row.species_authority)
                      year = row.species_authority.replace authorityTest, yearMatch
                      row.species_authority = row.species_authority.replace authorityTest, authorityMatch
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
              if typeof row.authority_year is "string"
                row.authority_year = row.authority_year.trim()
              if isNull row.authority_year
                row.authority_year = JSON.stringify authorityYears
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
                row.genus_authority = "#{row.species_authority} [assumed]"
              else if isNull row.species_authority
                row.species_authority = row.genus_authority
              if isNull colData
                # It may have been updated above
                try
                  colData = row[dirtyCol].unescape()
                if isNull(colData) or colData.trim() is "[assumed]"
                  colData = "Unknown"
              switch col.split("_")[0]
                when "genus"
                  tempCol = "#{colData.toTitleCase()}, #{genusYear}"
                  if toInt(row.parens_auth_genus).toBool()
                    tempCol = "(#{tempCol})"
                when "species"
                  tempCol = "#{colData.toTitleCase()}, #{speciesYear}"
                  if toInt(row.parens_auth_species).toBool()
                    tempCol = "(#{tempCol})"
              colData = tempCol
            catch e
              # Bad authority year, just don't use it
          if dirtyCol is "authority_year"
            if isNull colData and not isNull row[dirtyCol]
              try
                colData = row[dirtyCol]
                if typeof colData is "object"
                  colData = JSON.stringify(colData).replace /"/g,'\"\"'
            else
              console.debug "auth year '#{colData}' is valid", isNull colData, not isNull row[dirtyCol], col, dirtyCol
          if dirtyCol is "deprecated_scientific"
            if typeof colData is "object"
              colData = JSON.stringify colData
          if col in makeTitleCase
            colData = colData.toTitleCase()
          if col is "image" and not isNull(colData)
            colData = "#{uri.urlString}#{colData}"
          if col in boolToString
            try
              colData = colData.toBool().toString()
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
    message =
      status: true
      done: false
      progress: progressStepCount
    self.postMessage message
    duration = Date.now() - startTime
    console.log "CSV file prepped in #{duration}ms off-thread"
    message =
      csv: downloadable
      status: true
      done: true
    self.postMessage message
    console.debug "Completed worker!"
    self.close()
  catch e
    console.error "There was a problem creating your file. Please try again later."
    console.error("Exception in createCSVFile() - #{e.message}")
    console.warn(e.stack)
    message =
      status: false
      done: true
    self.postMessage message
    self.close()
