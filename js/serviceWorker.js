
/*
 * Core helpers/imports for web workers
 */
var _asm, byteCount, createHtmlFile, dateMonthToString, deEscape, decode64, delay, downloadCSVFile, encode64, generateCSVFromResults, getLocation, goTo, isArray, isBlank, isBool, isEmpty, isJson, isNull, isNumber, jsonTo64, locationData, markdown, openLink, openTab, post64, prepURI, randomInt, randomString, renderDataArray, roundNumber, roundNumberSigfig, smartUpperCasing, toFloat, toInt, toObject, uri, validateAWebTaxon, window,
  indexOf = [].indexOf || function(item) { for (var i = 0, l = this.length; i < l; i++) { if (i in this && this[i] === item) return i; } return -1; },
  modulo = function(a, b) { return (+a % (b = +b) + b) % b; };

locationData = new Object();

locationData.params = {
  enableHighAccuracy: true
};

locationData.last = void 0;

isBool = function(str, strict) {
  var e, error1;
  if (strict == null) {
    strict = false;
  }
  if (strict) {
    return typeof str === "boolean";
  }
  try {
    if (typeof str === "boolean") {
      return str === true || str === false;
    }
    if (typeof str === "string") {
      return str.toLowerCase() === "true" || str.toLowerCase() === "false";
    }
    if (typeof str === "number") {
      return str === 1 || str === 0;
    }
    return false;
  } catch (error1) {
    e = error1;
    return false;
  }
};

isEmpty = function(str) {
  return !str || str.length === 0;
};

isBlank = function(str) {
  return !str || /^\s*$/.test(str);
};

isNull = function(str) {
  var e, error1;
  try {
    if (isEmpty(str) || isBlank(str) || (str == null)) {
      if (!(str === false || str === 0)) {
        return true;
      }
    }
  } catch (error1) {
    e = error1;
    return false;
  }
  return false;
};

isJson = function(str) {
  var error1;
  if (typeof str === 'object' && !isArray(str)) {
    return true;
  }
  try {
    JSON.parse(str);
    return true;
  } catch (error1) {
    return false;
  }
  return false;
};

isArray = function(arr) {
  var error1, shadow;
  try {
    shadow = arr.slice(0);
    shadow.push("foo");
    return true;
  } catch (error1) {
    return false;
  }
};

isNumber = function(n) {
  return !isNaN(parseFloat(n)) && isFinite(n);
};

toFloat = function(str) {
  if (!isNumber(str) || isNull(str)) {
    return 0;
  }
  return parseFloat(str);
};

toInt = function(str) {
  var f;
  if (!isNumber(str) || isNull(str)) {
    return 0;
  }
  f = parseFloat(str);
  return parseInt(f);
};

String.prototype.toAscii = function() {

  /*
   * Remove MS Word bullshit
   */
  return this.replace(/[\u2018\u2019\u201A\u201B\u2032\u2035]/g, "'").replace(/[\u201C\u201D\u201E\u201F\u2033\u2036]/g, '"').replace(/[\u2013\u2014]/g, '-').replace(/[\u2026]/g, '...').replace(/\u02C6/g, "^").replace(/\u2039/g, "").replace(/[\u02DC|\u00A0]/g, " ");
};

String.prototype.toBool = function() {
  var test;
  test = this.toString().toLowerCase();
  return test === 'true' || test === "1";
};

Boolean.prototype.toBool = function() {
  return this.toString() === "true";
};

Number.prototype.toBool = function() {
  return this.toString() === "1";
};

String.prototype.addSlashes = function() {
  return this.replace(/[\\"']/g, '\\$&').replace(/\u0000/g, '\\0');
};

Array.prototype.max = function() {
  return Math.max.apply(null, this);
};

Array.prototype.min = function() {
  return Math.min.apply(null, this);
};

Array.prototype.containsObject = function(obj) {
  var e, error1, res;
  try {
    res = _.find(this, function(val) {
      return _.isEqual(obj, val);
    });
    return typeof res === "object";
  } catch (error1) {
    e = error1;
    console.error("Please load underscore.js before using this.");
    return console.info("https://cdnjs.cloudflare.com/ajax/libs/underscore.js/1.8.3/underscore-min.js");
  }
};

Object.toArray = function(obj) {
  var shadowObj;
  try {
    shadowObj = obj.slice(0);
    shadowObj.push("foo");
    return obj;
  } catch (undefined) {}
  return Object.keys(obj).map((function(_this) {
    return function(key) {
      return obj[key];
    };
  })(this));
};

Object.size = function(obj) {
  var e, error1, key, size;
  if (typeof obj !== "object") {
    try {
      return obj.length;
    } catch (error1) {
      e = error1;
      console.error("Passed argument isn't an object and doesn't have a .length parameter");
      console.warn(e.message);
    }
  }
  size = 0;
  for (key in obj) {
    if (obj.hasOwnProperty(key)) {
      size++;
    }
  }
  return size;
};

Object.doOnSortedKeys = function(obj, fn) {
  var data, key, l, len, results, sortedKeys;
  sortedKeys = Object.keys(obj).sort();
  results = [];
  for (l = 0, len = sortedKeys.length; l < len; l++) {
    key = sortedKeys[l];
    data = obj[key];
    results.push(fn(data));
  }
  return results;
};

delay = function(ms, f) {
  return setTimeout(f, ms);
};

roundNumber = function(number, digits) {
  var multiple;
  if (digits == null) {
    digits = 0;
  }
  multiple = Math.pow(10, digits);
  return Math.round(number * multiple) / multiple;
};

roundNumberSigfig = function(number, digits) {
  var digArr, needDigits, newNumber, significand, trailingDigits;
  if (digits == null) {
    digits = 0;
  }
  newNumber = roundNumber(number, digits).toString();
  digArr = newNumber.split(".");
  if (digArr.length === 1) {
    return newNumber + "." + (Array(digits + 1).join("0"));
  }
  trailingDigits = digArr.pop();
  significand = digArr[0] + ".";
  if (trailingDigits.length === digits) {
    return newNumber;
  }
  needDigits = digits - trailingDigits.length;
  trailingDigits += Array(needDigits + 1).join("0");
  return "" + significand + trailingDigits;
};

String.prototype.stripHtml = function(stripChildren) {
  var str;
  if (stripChildren == null) {
    stripChildren = false;
  }
  str = this;
  if (stripChildren) {
    str = str.replace(/<(\w+)(?:[^"'>]|"[^"]*"|'[^']*')*>(?:((?:.)*?))<\/?\1(?:[^"'>]|"[^"]*"|'[^']*')*>/mg, "");
  }
  str = str.replace(/<script[^>]*>([\S\s]*?)<\/script>/gmi, '');
  str = str.replace(/<\/?\w(?:[^"'>]|"[^"]*"|'[^']*')*>/gmi, '');
  return str;
};

String.prototype.unescape = function() {

  /*
   * We can't access 'document', so alias
   */
  return deEscape(this);
};

deEscape = function(string) {
  var i, newString, stringIn;
  stringIn = string;
  i = 0;
  while (newString !== stringIn) {
    if (i !== 0) {
      stringIn = newString;
      string = newString;
    }
    string = string.replace(/\&amp;#/mig, '&#');
    string = string.replace(/\&amp;/mig, '&');
    string = string.replace(/\&quot;/mig, '"');
    string = string.replace(/\&quote;/mg, '"');
    string = string.replace(/\&#95;/mg, '_');
    string = string.replace(/\&#39;/mg, "'");
    string = string.replace(/\&#34;/mg, '"');
    string = string.replace(/\&#62;/mg, '>');
    string = string.replace(/\&#60;/mg, '<');
    ++i;
    if (i >= 10) {
      console.warn("deEscape quitting after " + i + " iterations");
      break;
    }
    newString = string;
  }
  return decodeURIComponent(string);
};

jsonTo64 = function(obj, encode) {
  var encoded, objString, shadowObj;
  if (encode == null) {
    encode = true;
  }

  /*
   *
   * @param obj
   * @param boolean encode -> URI encode base64 string
   */
  try {
    shadowObj = obj.slice(0);
    shadowObj.push("foo");
    obj = toObject(obj);
  } catch (undefined) {}
  objString = JSON.stringify(obj);
  if (encode === true) {
    encoded = post64(objString);
  } else {
    encoded = encode64(encoded);
  }
  return encoded;
};

encode64 = function(string) {
  var e, error1;
  try {
    return Base64.encode(string);
  } catch (error1) {
    e = error1;
    console.warn("Bad encode string provided");
    return string;
  }
};

decode64 = function(string) {
  var e, error1;
  try {
    return Base64.decode(string);
  } catch (error1) {
    e = error1;
    console.warn("Bad decode string provided");
    return string;
  }
};

post64 = function(string) {
  var p64, s64;
  s64 = encode64(string);
  p64 = encodeURIComponent(s64);
  return p64;
};

byteCount = (function(_this) {
  return function(s) {
    return encodeURI(s).split(/%..|./).length - 1;
  };
})(this);

function shuffle(o) { //v1.0
    for (var j, x, i = o.length; i; j = Math.floor(Math.random() * i), x = o[--i], o[i] = o[j], o[j] = x);
    return o;
};

toObject = function(array) {
  var element, index, rv;
  rv = new Object();
  for (index in array) {
    element = array[index];
    if (element !== void 0) {
      rv[index] = element;
    }
  }
  return rv;
};

String.prototype.toTitleCase = function() {
  var l, len, len1, lower, lowerRegEx, lowers, m, str, upper, upperRegEx, uppers;
  str = this.replace(/([^\W_]+[^\s-]*) */g, function(txt) {
    return txt.charAt(0).toUpperCase() + txt.substr(1).toLowerCase();
  });
  lowers = ["A", "An", "The", "And", "But", "Or", "For", "Nor", "As", "At", "By", "For", "From", "In", "Into", "Near", "Of", "On", "Onto", "To", "With"];
  for (l = 0, len = lowers.length; l < len; l++) {
    lower = lowers[l];
    lowerRegEx = new RegExp("\\s" + lower + "\\s", "g");
    str = str.replace(lowerRegEx, function(txt) {
      return txt.toLowerCase();
    });
  }
  uppers = ["Id", "Tv"];
  for (m = 0, len1 = uppers.length; m < len1; m++) {
    upper = uppers[m];
    upperRegEx = new RegExp("\\b" + upper + "\\b", "g");
    str = str.replace(upperRegEx, upper.toUpperCase());
  }
  return str;
};

smartUpperCasing = function(text) {
  var l, len, r, replaceLower, replacer, searchUpper, secondWord, secondWordCased, smartCased, specialLowerCaseWords, word;
  if (isNull(text)) {
    return "";
  }
  replacer = function(match) {
    return match.replace(match, match.toUpperCase());
  };
  smartCased = text.replace(/((?=((?!-)[\W\s\r\n]))\s[A-Za-z]|^[A-Za-z])/g, replacer);
  specialLowerCaseWords = ["a", "an", "and", "at", "but", "by", "for", "in", "nor", "of", "on", "or", "out", "so", "to", "the", "up", "yet"];
  try {
    for (l = 0, len = specialLowerCaseWords.length; l < len; l++) {
      word = specialLowerCaseWords[l];
      searchUpper = word.toTitleCase();
      replaceLower = word.toLowerCase();
      r = new RegExp(" " + searchUpper + " ", "g");
      smartCased = smartCased.replace(r, " " + replaceLower + " ");
    }
  } catch (undefined) {}
  try {

    /*
     * Uppercase the second part of a dash
     *
     * See:
     * http://regexr.com/3ef62
     *
     * https://github.com/SSARHERPS/SSAR-species-database/issues/87#issuecomment-254108675
     */
    if (smartCased.match(/([a-zA-Z]+ )*[a-zA-Z]+-([a-z]+)( [a-zA-Z]+)*/m)) {
      secondWord = smartCased.replace(/([a-zA-Z]+ )*[a-zA-Z]+-([a-z]+)( [a-zA-Z]+)*/mg, "$2");
      secondWordCased = secondWord.toTitleCase();
      smartCased = smartCased.replace(secondWord, secondWordCased);
    }
  } catch (undefined) {}
  return smartCased;
};

Function.prototype.getName = function() {

  /*
   * Returns a unique identifier for a function
   */
  var name;
  name = this.name;
  if (name == null) {
    name = this.toString().substr(0, this.toString().indexOf("(")).replace("function ", "");
  }
  if (isNull(name)) {
    name = md5(this.toString());
  }
  return name;
};

randomInt = function(lower, upper) {
  var ref, ref1, start;
  if (lower == null) {
    lower = 0;
  }
  if (upper == null) {
    upper = 1;
  }
  start = Math.random();
  if (lower == null) {
    ref = [0, lower], lower = ref[0], upper = ref[1];
  }
  if (lower > upper) {
    ref1 = [upper, lower], lower = ref1[0], upper = ref1[1];
  }
  return Math.floor(start * (upper - lower + 1) + lower);
};

randomString = function(length) {
  var char, charBottomSearchSpace, charUpperSearchSpace, i, stringArray;
  if (length == null) {
    length = 8;
  }
  i = 0;
  charBottomSearchSpace = 65;
  charUpperSearchSpace = 126;
  stringArray = new Array();
  while (i < length) {
    ++i;
    char = randomInt(charBottomSearchSpace, charUpperSearchSpace);
    stringArray.push(String.fromCharCode(char));
  }
  return stringArray.join("");
};

openLink = function(url) {
  if (url == null) {
    return false;
  }
  open(url);
  return false;
};

openTab = function(url) {
  return openLink(url);
};

goTo = function(url) {
  if (url == null) {
    return false;
  }
  location.href = url;
  return false;
};

dateMonthToString = function(month) {
  var conversionObj, error1, rv;
  conversionObj = {
    0: "January",
    1: "February",
    2: "March",
    3: "April",
    4: "May",
    5: "June",
    6: "July",
    7: "August",
    8: "September",
    9: "October",
    10: "November",
    11: "December"
  };
  try {
    rv = conversionObj[month];
  } catch (error1) {
    rv = month;
  }
  return rv;
};

prepURI = function(string) {
  string = encodeURIComponent(string);
  return string.replace(/%20/g, "+");
};

locationData = new Object();

locationData.params = {
  enableHighAccuracy: true
};

locationData.last = void 0;

getLocation = function(callback) {
  var geoFail, geoSuccess, geoTimeout, retryTimeout;
  if (callback == null) {
    callback = void 0;
  }
  retryTimeout = 1500;
  geoSuccess = function(pos) {
    var elapsed, last;
    clearTimeout(geoTimeout);
    locationData.lat = pos.coords.latitude;
    locationData.lng = pos.coords.longitude;
    locationData.acc = pos.coords.accuracy;
    last = locationData.last;
    locationData.last = Date.now();
    elapsed = locationData.last - last;
    if (elapsed < retryTimeout) {
      return false;
    }
    console.info("Successfully set location");
    if (typeof callback === "function") {
      callback(locationData);
    }
    return false;
  };
  geoFail = function(error) {
    var locationError;
    clearTimeout(geoTimeout);
    locationError = (function() {
      switch (error.code) {
        case 0:
          return "There was an error while retrieving your location: " + error.message;
        case 1:
          return "The user prevented this page from retrieving a location";
        case 2:
          return "The browser was unable to determine your location: " + error.message;
        case 3:
          return "The browser timed out retrieving your location.";
      }
    })();
    console.error(locationError);
    if (typeof callback === "function") {
      callback(false);
    }
    return false;
  };
  if (navigator.geolocation) {
    console.log("Querying location");
    navigator.geolocation.getCurrentPosition(geoSuccess, geoFail, locationData.params);
    return geoTimeout = delay(1500, function() {
      return getLocation(callback);
    });
  } else {
    console.warn("This browser doesn't support geolocation!");
    if (callback != null) {
      return callback(false);
    }
  }
};

downloadCSVFile = function(data, options) {

  /*
   * Options:
   *
  options = new Object()
  options.create ?= false
  options.downloadFile ?= "datalist.csv"
  options.classes ?= "btn btn-default"
  options.buttonText ?= "Download File"
  options.iconHtml ?= """<iron-icon icon="icons:cloud-download"></iron-icon>"""
  options.selector ?= "#download-file"
  options.splitValues ?= false
   */
  var c, col, e, elapsed, error1, file, header, headerPlaceholder, headerStr, html, id, jsonObject, k, l, len, parser, response, selector, startTime, textAsset;
  startTime = Date.now();
  textAsset = "";
  if (isJson(data) && typeof data === "string") {
    console.info("Parsing as JSON string");
    try {
      jsonObject = JSON.parse(data);
    } catch (error1) {
      e = error1;
      console.error("COuldn't parse json! " + e.message);
      console.warn(e.stack);
      console.info(data);
      throw "error";
    }
  } else if (isArray(data)) {
    console.info("Parsing as array");
    jsonObject = toObject(data);
  } else if (typeof data === "object") {
    console.info("Parsing as object");
    jsonObject = data;
  } else {
    console.error("Unexpected data type '" + (typeof data) + "' for downloadCSVFile()", data);
    return false;
  }
  if (options == null) {
    options = new Object();
  }
  if (options.create == null) {
    options.create = false;
  }
  if (options.downloadFile == null) {
    options.downloadFile = "datalist.csv";
  }
  if (options.classes == null) {
    options.classes = "btn btn-default";
  }
  if (options.buttonText == null) {
    options.buttonText = "Download File";
  }
  if (options.iconHtml == null) {
    options.iconHtml = "<iron-icon icon=\"icons:cloud-download\"></iron-icon>";
  }
  if (options.selector == null) {
    options.selector = "#download-file";
  }
  if (options.splitValues == null) {
    options.splitValues = false;
  }
  if (options.cascadeObjects == null) {
    options.cascadeObjects = false;
  }
  if (options.objectAsValues == null) {
    options.objectAsValues = true;
  }
  headerPlaceholder = new Array();
  (parser = function(jsonObj, cascadeObjects) {
    var col, dataVal, error2, escapedKey, handleValue, key, l, len, results, row, tmpRow, tmpRowString, value;
    row = 0;
    if (options.objectAsValues) {
      options.splitValues = "::@@::";
    }
    results = [];
    for (key in jsonObj) {
      value = jsonObj[key];
      if (typeof value === "function") {
        continue;
      }
      ++row;
      try {
        escapedKey = key.toString().replace(/"/g, '""');
        if (row === 1) {
          if (!options.objectAsValues) {
            console.log("Boring options", options.objectAsValues, options);
            headerPlaceholder.push(escapedKey);
          } else {
            console.info("objectAsValues set");
            for (col in value) {
              data = value[col];
              if (isArray(options.acceptableCols)) {
                if (indexOf.call(options.acceptableCols, col) >= 0) {
                  headerPlaceholder.push(col);
                }
              } else {
                headerPlaceholder.push(col);
              }
            }
            console.log("Using as header", headerPlaceholder);
          }
        }
        if (typeof value === "object" && cascadeObjects) {
          value = parser(value, true);
        }
        handleValue = function(providedValue, providedOptions) {
          var escapedValue, tempValue, tempValueArr, tmpTextAsset;
          if (providedValue == null) {
            providedValue = value;
          }
          if (providedOptions == null) {
            providedOptions = options;
          }
          if (isNull(value)) {
            escapedValue = "";
          } else {
            if (typeof providedValue === "object") {
              providedValue = JSON.stringify(providedValue);
            }
            providedValue = providedValue.toString();
            tempValue = providedValue.replace(/,/g, '\,');
            tempValue = tempValue.replace(/"/g, '""');
            tempValue = tempValue.replace(/<\/p><p>/g, '","');
            if (typeof providedOptions.splitValues === "string") {
              tempValueArr = tempValue.split(providedOptions.splitValues);
              tempValue = tempValueArr.join("\",\"");
              escapedKey = false;
            }
            escapedValue = tempValue;
          }
          if (escapedKey === false) {
            tmpTextAsset = "\"" + escapedValue + "\"\n";
          } else if (isNumber(escapedKey)) {
            tmpTextAsset = "\"" + escapedValue + "\",";
          } else if (!isNull(escapedKey)) {
            tmpTextAsset = "\"" + escapedKey + "\",\"" + escapedValue + "\"\n";
          }
          return tmpTextAsset;
        };
        if (!options.objectAsValues) {
          results.push(textAsset += handleValue(value));
        } else {
          tmpRow = new Array();
          for (l = 0, len = headerPlaceholder.length; l < len; l++) {
            col = headerPlaceholder[l];
            dataVal = value[col];
            if (typeof dataVal === "object") {
              try {
                dataVal = JSON.stringify(dataVal);
                dataVal = dataVal.replace(/"/g, '""');
              } catch (undefined) {}
            }
            tmpRow.push(dataVal);
          }
          tmpRowString = tmpRow.join(options.splitValues);
          results.push(textAsset += handleValue(tmpRowString, options));
        }
      } catch (error2) {
        e = error2;
        console.warn("Unable to run key " + key + " on row " + row, value, jsonObj);
        results.push(console.warn(e.stack));
      }
    }
    return results;
  })(jsonObject, options.cascadeObjects);
  textAsset = textAsset.trim();
  k = 0;
  for (l = 0, len = headerPlaceholder.length; l < len; l++) {
    col = headerPlaceholder[l];
    col = col.replace(/"/g, '""');
    headerPlaceholder[k] = col;
    ++k;
  }
  if (options.objectAsValues) {
    options.header = headerPlaceholder;
  }
  if (isArray(options.header)) {
    headerStr = options.header.join("\",\"");
    textAsset = "\"" + headerStr + "\"\n" + textAsset;
    textAsset = textAsset.trim();
    header = "present";
  } else {
    header = "absent";
  }
  if (textAsset.slice(-1) === ",") {
    textAsset = textAsset.slice(0, -1);
  }
  file = ("data:text/csv;charset=utf-8;header=" + header + ",") + encodeURIComponent(textAsset);
  selector = options.selector;
  if (options.create === true) {
    c = randomInt(0, 9999);
    id = (selector.slice(1)) + "-download-button-" + c;
    html = "<a id=\"" + id + "\" class=\"" + options.classes + "\" href=\"" + file + "\" download=\"" + options.downloadFile + "\">\n  " + options.iconHtml + "\n  " + options.buttonText + "\n</a>";
  } else {
    html = "";
  }
  response = {
    file: file,
    options: options,
    html: html
  };
  elapsed = Date.now() - startTime;
  console.debug("CSV Worker saved " + elapsed + "ms from main thread");
  return response;
};

generateCSVFromResults = function(resultArray, caller, selector) {
  var error1, options, response;
  if (selector == null) {
    selector = "#modal-sql-details-list";
  }
  console.info("Worker CSV: Given", resultArray);
  options = {
    objectAsValues: true,
    downloadFile: "adp-global-search-result-data_" + (Date.now()) + ".csv"
  };
  try {
    response = downloadCSVFile(resultArray, options);
  } catch (error1) {
    console.error("Sorry, there was a problem with this dataset and we can't do that right now.");
    response = {
      file: "",
      options: options,
      html: ""
    };
  }
  return response;
};

validateAWebTaxon = function(taxonObj, callback) {
  var args, doCallback, validationMeta;
  if (callback == null) {
    callback = null;
  }

  /*
   *
   *
   * @param Object taxonObj -> object with keys "genus", "species", and
   *   optionally "subspecies"
   * @param function callback -> Callback function
   */
  if ((typeof validationMeta !== "undefined" && validationMeta !== null ? validationMeta.validatedTaxons : void 0) == null) {
    if (typeof validationMeta !== "object") {
      validationMeta = new Object();
    }
    validationMeta.validatedTaxons = new Array();
  }
  doCallback = function(validatedTaxon) {
    if (typeof callback === "function") {
      callback(validatedTaxon);
    }
    return false;
  };
  if (validationMeta.validatedTaxons.containsObject(taxonObj)) {
    console.info("Already validated taxon, skipping revalidation", taxonObj);
    doCallback(taxonObj);
    return false;
  }
  args = "action=validate&genus=" + taxonObj.genus + "&species=" + taxonObj.species;
  if (taxonObj.subspecies != null) {
    args += "&subspecies=" + taxonObj.subspecies;
  }
  _adp.currentAsyncJqxhr = $.post("api.php", args, "json").done(function(result) {
    if (result.status) {
      taxonObj.genus = result.validated_taxon.genus;
      taxonObj.species = result.validated_taxon.species;
      taxonObj.subspecies = result.validated_taxon.subspecies;
      if (taxonObj.clade == null) {
        taxonObj.clade = result.validated_taxon.family;
      }
      validationMeta.validatedTaxons.push(taxonObj);
    } else {
      taxonObj.invalid = true;
    }
    taxonObj.response = result;
    doCallback(taxonObj);
    return false;
  }).fail(function(result, status) {
    var prettyTaxon;
    prettyTaxon = taxonObj.genus + " " + taxonObj.species;
    prettyTaxon = taxonObj.subspecies != null ? prettyTaxon + " " + taxonObj.subspecies : prettyTaxon;
    bsAlert("<strong>Problem validating taxon:</strong> " + prettyTaxon + " couldn't be validated.");
    return console.warn("Warning: Couldn't validated " + prettyTaxon + " with AmphibiaWeb");
  });
  return false;
};


/*
 * Service worker!
 */

if (typeof uri !== "object") {
  uri = {
    urlString: ""
  };
}

if (typeof _asm !== "object") {
  _asm = {
    affiliateQueryUrl: {
      iucnRedlist: "http://apiv3.iucnredlist.org/api/v3/species/common_names/"
    }
  };
}

self.addEventListener("message", function(e) {
  var chunkSize, data, firstIteration, ref;
  switch (e.data.action) {
    case "render-row":
      data = e.data.data;
      chunkSize = isNumber(e.data.chunk) ? toInt(e.data.chunk) : 100;
      firstIteration = (ref = e.data.firstIteration.toBool()) != null ? ref : false;
      return renderDataArray(data, firstIteration, chunkSize);
    case "render-html":
      console.log("Got info from file on thread", e.data);
      return createHtmlFile(e.data.data, e.data.htmlHeader);
  }
});

window = new Object();

self.importScripts("markdown.min.js");

self.importScripts("markdown.min.js");

markdown = window.markdown;

renderDataArray = function(data, firstIteration, renderChunk) {
  var bootstrapColCount, bootstrapColSize, col, colClass, d, e, error1, error2, externalCounter, finalIteration, genus, headers, html, htmlClose, htmlHead, htmlRow, i, j, k, kClass, l, len, message, niceKey, row, rowId, species, split, tableId, taxonQuery, v, year;
  if (data == null) {
    data = dataArray;
  }
  if (firstIteration == null) {
    firstIteration = true;
  }
  if (renderChunk == null) {
    renderChunk = 100;
  }
  html = "";
  headers = new Array();
  tableId = "cndb-result-list";
  htmlHead = "<table id='" + tableId + "' class='table table-striped table-hover col-md-12'>\n\t<tr class='cndb-row-headers'>";
  htmlClose = "</table>";
  bootstrapColCount = 0;
  if (!isNumber(renderChunk)) {
    renderChunk = 100;
  }
  finalIteration = data.length <= renderChunk ? true : false;
  i = 0;
  console.log("Starting loop with i = " + i + ", renderChunk = " + renderChunk + ", data length = " + data.length, firstIteration, finalIteration);
  for (l = 0, len = data.length; l < len; l++) {
    row = data[l];
    externalCounter = i;
    if (toInt(i) === 0 && firstIteration) {
      j = 0;
      htmlHead += "\n<!-- Table Headers - " + (Object.size(row)) + " entries -->";
      for (k in row) {
        v = row[k];
        niceKey = k.replace(/_/g, " ");
        niceKey = (function() {
          switch (niceKey) {
            case "simple linnean subgroup":
              return "Group";
            case "major subtype":
              return "Clade";
            default:
              return niceKey;
          }
        })();
        htmlHead += "\n\t\t<th class='text-center'>" + niceKey + "</th>";
        bootstrapColCount++;
        j++;
      }
      htmlHead += "\n\t</tr>";
      htmlHead += "\n<!-- End Table Headers -->";
      console.log("Got " + bootstrapColCount + " display columns.");
      bootstrapColSize = roundNumber(12 / bootstrapColCount, 0);
      colClass = "col-md-" + bootstrapColSize;
      html = htmlHead;
    }
    taxonQuery = row.genus + "+" + row.species;
    if (!isNull(row.subspecies)) {
      taxonQuery = taxonQuery + "+" + row.subspecies;
    }
    rowId = "msadb-row" + i;
    htmlRow = "\n\t<tr id='" + rowId + "' class='cndb-result-entry' data-taxon=\"" + taxonQuery + "\" data-genus=\"" + row.genus + "\" data-species=\"" + row.species + "\">";
    for (k in row) {
      col = row[k];
      if (k === "authority_year") {
        if (!isNull(col)) {
          try {
            d = JSON.parse(col);
          } catch (error1) {
            e = error1;
            try {
              console.warn("There was an error parsing authority_year='" + col + "', attempting to fix - ", e.message);
              split = col.split(":");
              year = split[1].slice(split[1].search("\"") + 1, -2);
              year = year.replace(/"/g, "'");
              split[1] = "\"" + year + "\"}";
              col = split.join(":");
              d = JSON.parse(col);
            } catch (error2) {
              e = error2;
              console.error("There was an error parsing '" + col + "'", e.message);
              d = col;
            }
          }
          try {
            genus = Object.keys(d)[0];
            species = d[genus];
            if (toInt(row.parens_auth_genus).toBool()) {
              genus = "(" + genus + ")";
            }
            if (toInt(row.parens_auth_species).toBool()) {
              species = "(" + species + ")";
            }
            col = "G: " + genus + "<br/>S: " + species;
          } catch (undefined) {}
        } else {
          d = col;
        }
      }
      if (k === "image") {
        if (isNull(col)) {
          col = "<paper-icon-button icon='launch' data-href='" + _asm.affiliateQueryUrl.mammalPhotos + "?rel-taxon=contains&where-taxon=" + taxonQuery + "' class='newwindow calphoto click' data-taxon=\"" + taxonQuery + "\"></paper-icon-button>";
        } else {
          col = "<paper-icon-button icon='image:image' data-lightbox='" + uri.urlString + col + "' class='lightboximage'></paper-icon-button>";
        }
      }

      /*
       * Assign classes to the rows
       */
      if (k !== "genus" && k !== "species" && k !== "subspecies") {
        kClass = k + " text-center";
      } else {
        kClass = k;
      }
      if (k === "genus_authority" || k === "species_authority") {
        kClass += " authority";
      } else if (k === "common_name") {
        col = smartUpperCasing(col);
        kClass += " no-cap";
      }
      htmlRow += "\n\t\t<td id='" + k + "-" + i + "' class='" + kClass + " " + colClass + "'>" + col + "</td>";
    }
    htmlRow += "\n\t</tr>";
    html += htmlRow;
    i++;
    if (i >= renderChunk) {
      break;
    }
  }
  console.log("Ended data loop with i = " + i + ", renderChunk = " + renderChunk);
  if (firstIteration) {
    html += htmlClose;
  }
  message = {
    html: html,
    nextChunk: data.slice(i),
    renderChunk: renderChunk,
    loops: i
  };
  self.postMessage(message);
  return self.close();
};

createHtmlFile = function(result, htmlBody) {

  /*
   * The off-thread component to download.coffee->downloadHTMLList()
   *
   * Requires the JSOn result from the main function.
   */
  var authorityYears, c, duration, e, entryHtml, error1, error2, error3, error4, error5, genusAuth, genusYear, hangTimeout, hasReadClade, hasReadGenus, hasReadSubClade, htmlCredit, htmlNotes, k, message, oneOffHtml, ref, ref1, ref2, ref3, row, shortGenus, speciesAuth, speciesYear, split, startTime, taxonCreditDate, total, v, year;
  startTime = Date.now();
  console.debug("Got", result);
  console.debug("Got body provided?", !isNull(htmlBody));
  total = result.count;
  try {
    if (result.status !== true) {
      throw Error("Invalid Result");
    }

    /*
     * Let's work with each result
     *
     * We're going to construct an entry for each, then go through
     * and append that to to the text blobb htmlBody
     */
    hasReadGenus = new Array();
    hasReadClade = new Array();
    hasReadSubClade = new Array();
    ref = result.result;
    for (k in ref) {
      row = ref[k];
      try {
        if (modulo(k, 100) === 0) {
          console.log("Parsing row " + k + " of " + total);
          if (modulo(k, 500) === 0 && k > 0) {
            message = {
              status: true,
              done: false,
              updateUser: "Parsing " + k + " of " + total + ", please wait"
            };
            self.postMessage(message);
          }
        }
      } catch (undefined) {}
      if (isNull(row.genus) || isNull(row.species)) {
        continue;
      }
      try {
        clearTimeout(hangTimeout);
        hangTimeout = delay(250, function() {
          console.warn("Possible hang on row #" + k, row);
          return hangTimeout = delay(1000, function() {
            message = {
              status: false,
              done: false,
              updateUser: "Failure to parse row " + k
            };
            self.postMessage(message);
            return self.close();
          });
        });
      } catch (undefined) {}
      try {
        if (typeof row.authority_year !== "object") {
          authorityYears = new Object();
          try {
            if (isNumber(row.authority_year)) {
              authorityYears[row.authority_year] = row.authority_year;
            } else if (isNull(row.authority_year)) {
              row.species_authority = row.species_authority.replace(/(<\/|<|&lt;|&lt;\/).*?(>|&gt;)/img, "");
              if (/^\(? *((['"])? *([\w\.\-\&; \[\]]+(,|&|&amp;|&amp;amp;|&#[\w0-9]+;)?)+ *\2) *, *([0-9]{4}) *\)?/i.test(row.species_authority)) {
                year = row.species_authority.replace(/^\(? *((['"])? *([\w\.\-\&; \[\]]+(,|&|&amp;|&amp;amp;|&#[\w0-9]+;)?)+ *\2) *, *([0-9]{4}) *\)?/ig, "$5");
                row.species_authority = row.species_authority.replace(/^\(? *((['"])? *([\w\.\-\&; \[\]]+(,|&|&amp;|&amp;amp;|&#[\w0-9]+;)?)+ *\2) *, *([0-9]{4}) *\)?/ig, "$1");
                authorityYears[year] = year;
                row.authority_year = authorityYears;
              } else {
                authorityYears["No Year"] = "No Year";
              }
            } else {
              authorityYears = JSON.parse(row.authority_year);
            }
          } catch (error1) {
            e = error1;
            console.debug("authority isnt number, null, or object, with bad species_authority '" + row.authority_year + "'");
            split = row.authority_year.split(":");
            if (split.length > 1) {
              year = split[1].slice(split[1].search("\"") + 1, -2);
              year = year.replace(/"/g, "'");
              split[1] = "\"" + year + "\"}";
              authorityYears = JSON.parse(split.join(":"));
            } else {
              console.warn("Unable to figure out the type of data for `authority_year`: " + e.message, JSON.stringify(row));
              console.warn(e.stack);
            }
          }
        } else {
          authorityYears = row.authority_year;
        }
        try {
          genusYear = Object.keys(authorityYears)[0];
          speciesYear = authorityYears[genusYear];
          genusYear = genusYear.replace(/&#39;/g, "'");
          speciesYear = speciesYear.replace(/&#39;/g, "'");
        } catch (error2) {
          for (c in authorityYears) {
            v = authorityYears[c];
            genusYear = c.replace(/&#39;/g, "'");
            speciesYear = v.replace(/&#39;/g, "'");
          }
        }
        if (isNull(row.genus_authority)) {
          row.genus_authority = row.species_authority;
        } else if (isNull(row.species_authority)) {
          row.species_authority = row.genus_authority;
        }
        genusAuth = (row.genus_authority.toTitleCase()) + " " + genusYear;
        if (toInt(row.parens_auth_genus).toBool()) {
          genusAuth = "(" + genusAuth + ")";
        }
        speciesAuth = (row.species_authority.toTitleCase()) + " " + speciesYear;
        if (toInt(row.parens_auth_species).toBool()) {
          speciesAuth = "(" + speciesAuth + ")";
        }
      } catch (error3) {
        e = error3;
        console.warn("There was a problem parsing the authority information for _" + row.genus + " " + row.species + " " + row.subspecies + "_ - " + e.message);
        console.warn(e.stack);
        console.warn("Bad parse for authority year -- tried to fix >>" + row.authority_year + "<<", authorityYears, row.authority_year);
        console.warn("We were working with", authorityYears, genusYear, genusAuth, speciesYear, speciesAuth);
      }
      if (!isNull(row.entry)) {
        try {
          htmlNotes = markdown.toHTML(row.entry);
        } catch (error4) {
          e = error4;
          console.warn("Unable to parse Markdown for _" + row.genus + " " + row.species + " " + row.subspecies + "_");
          htmlNotes = row.entry;
        }
      } else {
        htmlNotes = "";
      }
      htmlCredit = "";
      if (!(isNull(htmlNotes) || isNull(row.taxon_credit))) {
        taxonCreditDate = "";
        if (!isNull(row.taxon_credit_date)) {
          taxonCreditDate = ", " + row.taxon_credit_date;
        }
        htmlCredit = "<p class=\"text-right small text-muted\">\n  <cite>\n    " + row.taxon_credit + taxonCreditDate + "\n  </cite>\n</p>";
      }
      oneOffHtml = "";
      if (ref1 = row.linnean_order.trim(), indexOf.call(hasReadClade, ref1) < 0) {
        oneOffHtml += "<h2 class=\"clade-declaration text-capitalize text-center\">" + row.linnean_order + "</h2>";
        hasReadClade.push(row.linnean_order.trim());
      }
      if (ref2 = row.linnean_family.trim(), indexOf.call(hasReadSubClade, ref2) < 0) {
        oneOffHtml += "<h3 class=\"subclade-declaration text-capitalize text-center\">" + row.linnean_family + "</h3>";
        hasReadSubClade.push(row.linnean_family.trim());
      }
      if (ref3 = row.genus, indexOf.call(hasReadGenus, ref3) < 0) {
        oneOffHtml += "<aside class=\"genus-declaration lead\">\n  <span class=\"entry-sciname text-capitalize\">" + row.genus + "</span>\n  <span class=\"entry-authority\">" + (genusAuth.unescape()) + "</span>\n</aside>";
        hasReadGenus.push(row.genus);
      }
      shortGenus = (row.genus.slice(0, 1)) + ". ";
      entryHtml = "<section class=\"species-entry\">\n  " + oneOffHtml + "\n  <p class=\"h4 entry-header\">\n    <span class=\"entry-sciname\">\n      <span class=\"text-capitalize\">" + shortGenus + "</span> " + row.species + " " + row.subspecies + "\n    </span>\n    <span class=\"entry-authority\">\n      " + (speciesAuth.unescape()) + "\n    </span>\n    &#8212;\n    <span class=\"common_name no-cap\">\n      " + (smartUpperCasing(row.common_name)) + "\n    </span>\n  </p>\n  <div class=\"entry-content\">\n    " + htmlNotes + "\n    " + htmlCredit + "\n  </div>\n</section>";
      htmlBody += entryHtml;
    }
    htmlBody += "</article>\n</div>\n</body>\n</html>";
    duration = Date.now() - startTime;
    console.log("HTML file prepped in " + duration + "ms off-thread");
    message = {
      html: htmlBody,
      status: true,
      done: true
    };
    self.postMessage(message);
    return self.close();
  } catch (error5) {
    e = error5;
    console.error("There was a problem creating your file. Please try again later.");
    console.error("Exception in createHtmlFile() - " + e.message);
    console.warn(e.stack);
    message = {
      status: false,
      done: true
    };
    self.postMessage(message);
    return self.close();
  }
};

//# sourceMappingURL=maps/serviceWorker.js.map
