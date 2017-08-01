var _metaStatus, activityIndicatorOff, activityIndicatorOn, allError, animateHoverShadows, animateLoad, bindClickTargets, bindClicks, bindDismissalRemoval, bindPaperMenuButton, browserBeware, bsAlert, buildArgs, buildQuery, byteCount, checkFileVersion, checkLaggedUpdate, checkLocalVersion, checkTaxonNear, clearSearch, dataUriToBlob, dateMonthToString, deEscape, decode64, deepJQuery, delay, delayPolymerBind, doCORSget, doFontExceptions, doLazily, doNothing, domainPlaceholder, downloadDataUriAsBlob, e, encode64, error1, eutheriaFilterHelper, fetchMajorMinorGroups, foo, formatScientificNames, formatSearchResults, getElementHtml, getFilters, getLocation, getMaxZ, getRandomEntry, goTo, insertCORSWorkaround, insertModalImage, interval, isArray, isBlank, isBool, isEmpty, isJson, isNull, isNumber, isNumeric, jsonTo64, lightboxImages, loadJS, loadSocialMediaSlideoutBar, mapNewWindows, mobileCollapsable, modalTaxon, objToArgs, openLink, openTab, overlayOff, overlayOn, p$, parseTaxonYear, performSearch, post64, prepURI, randomInt, ref, roundNumber, roundNumberSigfig, safariDialogHelper, safariSearchArgHelper, searchParams, setHistory, setupServiceWorker, showBadSearchErrorMessage, smartUpperCasing, sortResults, startLoad, stopLoad, stopLoadError, toFloat, toInt, toObject, toastStatusMessage, uri,
  slice = [].slice,
  indexOf = [].indexOf || function(item) { for (var i = 0, l = this.length; i < l; i++) { if (i in this && this[i] === item) return i; } return -1; };

uri = new Object();

uri.o = $.url();

uri.urlString = uri.o.attr('protocol') + '://' + uri.o.attr('host') + uri.o.attr("directory");

try {
  uri.urlString = uri.urlString.replace(/(.*)\/(((&?[a-zA-Z_\-]+=[a-zA-Z_\-\+0-9%=]+)+)\/?)(.*)/img, "$1/");
  if (uri.urlString.split("/").pop().search(/\./) === -1 && uri.urlString.slice(-1) !== "/") {
    uri.urlString = uri.urlString.slice(0, uri.urlString.search(uri.urlString.split("/").pop()));
  }
} catch (undefined) {}

uri.query = uri.o.attr("fragment");

domainPlaceholder = uri.o.attr("host").split(".");

domainPlaceholder.pop();

uri.domain = (ref = domainPlaceholder[0]) != null ? ref : "";

_metaStatus = new Object();

window.locationData = new Object();

locationData.params = {
  enableHighAccuracy: true
};

locationData.last = void 0;

if (typeof window._asm !== "object") {
  window._asm = new Object();
}

_asm.socialHandles = {
  twitter: "mammalogists"
};

_asm.mobileBreakpoint = 767;

isBool = function(str) {
  return str === true || str === false;
};

isEmpty = function(str) {
  return !str || str.length === 0;
};

isBlank = function(str) {
  return !str || /^\s*$/.test(str);
};

isNull = function(str, dirty) {
  var e, error1, l;
  if (dirty == null) {
    dirty = false;
  }
  if (typeof str === "object") {
    try {
      l = str.length;
      if (l != null) {
        try {
          return l === 0;
        } catch (undefined) {}
      }
      return Object.size === 0;
    } catch (undefined) {}
  }
  try {
    if (isEmpty(str) || isBlank(str) || (str == null)) {
      if (!(str === false || str === 0)) {
        return true;
      }
      if (dirty) {
        if (str === false || str === 0) {
          return true;
        }
      }
    }
  } catch (error1) {
    e = error1;
    return false;
  }
  try {
    str = str.toString().toLowerCase();
  } catch (undefined) {}
  if (str === "undefined" || str === "null") {
    return true;
  }
  if (dirty && (str === "false" || str === "0")) {
    return true;
  }
  return false;
};

isJson = function(str) {
  if (typeof str === 'object') {
    return true;
  }
  try {
    JSON.parse(str);
    return true;
  } catch (undefined) {}
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

isNumeric = function(n) {
  return isNumber(n);
};

toFloat = function(str, strict) {
  if (strict == null) {
    strict = false;
  }
  if (!isNumber(str) || isNull(str)) {
    if (strict) {
      return NaN;
    }
    return 0;
  }
  return parseFloat(str);
};

toInt = function(str, strict) {
  if (strict == null) {
    strict = false;
  }
  if (!isNumber(str) || isNull(str)) {
    if (strict) {
      return NaN;
    }
    return 0;
  }
  return parseInt(str);
};

String.prototype.noExponents = function(explicitNum) {
  var data, leader, mag, multiplier, num, sign, str, z;
  if (explicitNum == null) {
    explicitNum = true;
  }

  /*
   * Remove scientific notation from a number
   *
   * After
   * http://stackoverflow.com/a/18719988/1877527
   */
  data = this.split(/[eE]/);
  if (data.length === 1) {
    return data[0];
  }
  z = "";
  sign = this.slice(0, 1) === "-" ? "-" : "";
  str = data[0].replace(".", "");
  mag = Number(data[1]) + 1;
  if (mag <= 0) {
    z = sign + "0.";
    while (!(mag >= 0)) {
      z += "0";
      ++mag;
    }
    num = z + str.replace(/^\-/, "");
    if (explicitNum) {
      return parseFloat(num);
    } else {
      return num;
    }
  }
  if (str.length <= mag) {
    mag -= str.length;
    while (!(mag <= 0)) {
      z += 0;
      --mag;
    }
    num = str + z;
    if (explicitNum) {
      return parseFloat(num);
    } else {
      return num;
    }
  } else {
    leader = parseFloat(data[0]);
    multiplier = Math.pow(10, parseInt(data[1]));
    return leader * multiplier;
  }
};

Number.prototype.noExponents = function() {
  var strVal;
  strVal = String(this);
  return strVal.noExponents(true);
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

String.prototype.toAscii = function() {

  /*
   * Remove MS Word bullshit
   */
  return this.replace(/[\u2018\u2019\u201A\u201B\u2032\u2035]/g, "'").replace(/[\u201C\u201D\u201E\u201F\u2033\u2036]/g, '"').replace(/[\u2013\u2014]/g, '-').replace(/[\u2026]/g, '...').replace(/\u02C6/g, "^").replace(/\u2039/g, "").replace(/[\u02DC|\u00A0]/g, " ");
};

String.prototype.toBool = function() {
  return this.toString() === 'true';
};

Boolean.prototype.toBool = function() {
  return this.toString() === 'true';
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

Array.prototype.sum = function() {
  return this.reduce(function(a, b) {
    return a + b;
  });
};

Array.prototype.mean = function() {
  return this.sum() / this.length;
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
  var data, key, len1, m, results, sortedKeys;
  sortedKeys = Object.keys(obj).sort();
  results = [];
  for (m = 0, len1 = sortedKeys.length; m < len1; m++) {
    key = sortedKeys[m];
    data = obj[key];
    results.push(fn(data));
  }
  return results;
};

delay = function(ms, f) {
  return setTimeout(f, ms);
};

interval = function(ms, f) {
  return setInterval(f, ms);
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

String.prototype.unescape = function(strict) {
  var decodeHTMLEntities, element, tmp;
  if (strict == null) {
    strict = false;
  }

  /*
   * Take escaped text, and return the unescaped version
   *
   * @param string str | String to be used
   * @param bool strict | Stict mode will remove all HTML
   *
   * Test it here:
   * https://jsfiddle.net/tigerhawkvok/t9pn1dn5/
   *
   * Code: https://gist.github.com/tigerhawkvok/285b8631ed6ebef4446d
   */
  element = document.createElement("div");
  decodeHTMLEntities = function(str) {
    if ((str != null) && typeof str === "string") {
      if (strict !== true) {
        str = escape(str).replace(/%26/g, '&').replace(/%23/g, '#').replace(/%3B/g, ';');
      } else {
        str = str.replace(/<script[^>]*>([\S\s]*?)<\/script>/gmi, '');
        str = str.replace(/<\/?\w(?:[^"'>]|"[^"]*"|'[^']*')*>/gmi, '');
      }
      element.innerHTML = str;
      if (element.innerText) {
        str = element.innerText;
        element.innerText = "";
      } else {
        str = element.textContent;
        element.textContent = "";
      }
    }
    return unescape(str);
  };
  tmp = deEscape(this);
  return decodeHTMLEntities(tmp);
};

deEscape = function(string) {
  string = string.replace(/\&amp;#/mg, '&#');
  string = string.replace(/\&quot;/mg, '"');
  string = string.replace(/\&quote;/mg, '"');
  string = string.replace(/\&#95;/mg, '_');
  string = string.replace(/\&#39;/mg, "'");
  string = string.replace(/\&#34;/mg, '"');
  string = string.replace(/\&#62;/mg, '>');
  string = string.replace(/\&#60;/mg, '<');
  return string;
};

String.prototype.escapeQuotes = function() {
  var str;
  str = this.replace(/"/mg, "&#34;");
  str = str.replace(/'/mg, "&#39;");
  return str;
};

getElementHtml = function(el) {
  return el.outerHTML;
};

jQuery.fn.outerHTML = function() {
  var e;
  e = $(this).get(0);
  return e.outerHTML;
};

jQuery.fn.outerHtml = function() {
  return $(this).outerHTML();
};


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
;

jQuery.fn.exists = function() {
  return jQuery(this).length > 0;
};

jQuery.fn.polymerSelected = function(setSelected, attrLookup, dropdownSelector, childElement, ignoreCase) {
  var attr, dropdownId, dropdownUniqueSelector, e, error1, error2, error3, error4, error5, index, item, itemSelector, len1, m, ref1, selectedMatch, selector, text, val;
  if (setSelected == null) {
    setSelected = void 0;
  }
  if (attrLookup == null) {
    attrLookup = "attrForSelected";
  }
  if (dropdownSelector == null) {
    dropdownSelector = "paper-listbox";
  }
  if (childElement == null) {
    childElement = "paper-item";
  }
  if (ignoreCase == null) {
    ignoreCase = true;
  }

  /*
   * See
   * https://elements.polymer-project.org/elements/paper-menu
   * https://elements.polymer-project.org/elements/paper-radio-group
   *
   * @param setSelected ->
   * @param attrLookup is based on
   * https://elements.polymer-project.org/elements/iron-selector?active=Polymer.IronSelectableBehavior
   * @param childElement
   * @param ignoreCase -> match lower case trimmed values
   */
  if (!$(this).exists()) {
    console.error("Nonexistant element");
    return false;
  }
  dropdownId = $(this).attr("id");
  if (isNull(dropdownId)) {
    console.error("Your parent dropdown (eg, paper-dropdown-menu) must have a unique ID");
    return false;
  }
  dropdownUniqueSelector = "#" + dropdownId + " " + dropdownSelector;
  try {
    if (dropdownSelector === $(this).get(0).tagName.toLowerCase()) {
      dropdownUniqueSelector = this;
    }
  } catch (undefined) {}
  if (!$(dropdownUniqueSelector).exists()) {
    dropdownSelector = "paper-menu";
    dropdownUniqueSelector = "#" + dropdownId + " " + dropdownSelector;
    try {
      if (dropdownSelector === $(this).get(0).tagName.toLowerCase()) {
        dropdownUniqueSelector = this;
      }
    } catch (undefined) {}
    if (!$(dropdownUniqueSelector).exists()) {
      try {
        if (!isNull(p$(this).value)) {
          return p$(this).value;
        }
        return null;
      } catch (error1) {
        console.error("Can't identify the dropdown selector for this dropdown list '" + dropdownId + "'", dropdownUniqueSelector, this);
      }
      console.warn("Unable to fetch data for item", "#" + dropdownId);
      return false;
    }
  }
  if (attrLookup !== true) {
    attr = $(dropdownUniqueSelector).attr(attrLookup);
    if (isNull(attr)) {
      attr = true;
    }
  } else {
    attr = true;
  }
  if (setSelected != null) {
    selector = dropdownUniqueSelector;
    if (!isBool(setSelected) && !isNull(setSelected)) {
      try {
        if (attr === true) {
          ref1 = $(this).find(childElement);
          for (m = 0, len1 = ref1.length; m < len1; m++) {
            item = ref1[m];
            text = ignoreCase ? $(item).text().toLowerCase().trim() : $(item).text();
            selectedMatch = ignoreCase ? setSelected.toLowerCase().trim() : setSelected;
            if (text === selectedMatch) {
              index = $(item).index();
              break;
            }
          }
          if (isNull(index)) {
            console.error("Unable to find an index for " + childElement + " with text '" + setSelected + "' (ignore case: " + ignoreCase + ")");
            return false;
          }
          try {
            p$(selector).select(index);
          } catch (error2) {
            e = error2;
            p$(selector).selected = index;
          }
          if (p$(selector).selected !== index) {
            doNothing();
          }
        } else {
          try {
            p$(selector).select(setSelected);
          } catch (error3) {
            p$(selector).selected = setSelected;
          }
        }
        return true;
      } catch (error4) {
        e = error4;
        console.error("Unable to set selected '" + setSelected + "': " + e.message);
        return false;
      }
    } else if (isBool(setSelected)) {
      $(this).parent().children().removeAttribute("aria-selected");
      $(this).parent().children().removeAttribute("active");
      $(this).parent().children().removeClass("iron-selected");
      $(this).prop("selected", setSelected);
      $(this).prop("active", setSelected);
      $(this).prop("aria-selected", setSelected);
      if (setSelected === true) {
        return $(this).addClass("iron-selected");
      }
    }
  } else {
    val = void 0;
    try {
      try {
        val = p$(this).selected;
      } catch (undefined) {}
      if (isNull(val)) {
        val = p$(dropdownUniqueSelector).selected;
      }
      if (isNumber(val) && !isNull(attr)) {
        itemSelector = $(this).find(childElement)[toInt(val)];
        if (attr !== true) {
          val = $(itemSelector).attr(attr);
        } else {
          val = $(itemSelector).text();
        }
      } else {
        console.debug("isNumber(val)", isNumber(val, val));
        console.debug("isNull attr", isNull(attr, attr));
      }
    } catch (error5) {
      e = error5;
      console.error("Couldn't find selected: " + e.message);
      console.warn(e.stack);
      console.debug("Selector", dropdownUniqueSelector);
      return false;
    }
    if (val === "null" || (val == null)) {
      val = void 0;
    }
    try {
      val = val.trim();
    } catch (undefined) {}
    return val;
  }
};

jQuery.fn.polymerChecked = function(setChecked) {
  var val;
  if (setChecked == null) {
    setChecked = void 0;
  }
  if (setChecked != null) {
    return jQuery(this).prop("checked", setChecked);
  } else {
    val = jQuery(this)[0].checked;
    if (val === "null" || (val == null)) {
      val = void 0;
    }
    return val;
  }
};

jQuery.fn.isVisible = function() {
  return jQuery(this).css("display") !== "none";
};

jQuery.fn.hasChildren = function() {
  return Object.size(jQuery(this).children()) > 3;
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

randomInt = function(lower, upper) {
  var ref1, ref2, start;
  if (lower == null) {
    lower = 0;
  }
  if (upper == null) {
    upper = 1;
  }
  start = Math.random();
  if (lower == null) {
    ref1 = [0, lower], lower = ref1[0], upper = ref1[1];
  }
  if (lower > upper) {
    ref2 = [upper, lower], lower = ref2[0], upper = ref2[1];
  }
  return Math.floor(start * (upper - lower + 1) + lower);
};

window.debounce_timer = null;

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
    window.name = this;
  }
  return name;
};

Function.prototype.debounce = function() {
  var args, delayed, e, error1, execAsap, func, key, ref1, threshold, timeout;
  threshold = arguments[0], execAsap = arguments[1], timeout = arguments[2], args = 4 <= arguments.length ? slice.call(arguments, 3) : [];
  if (threshold == null) {
    threshold = 300;
  }
  if (execAsap == null) {
    execAsap = false;
  }
  if (timeout == null) {
    timeout = window.debounce_timer;
  }

  /*
   * Borrowed from http://coffeescriptcookbook.com/chapters/functions/debounce
   * Only run the prototyped function once per interval.
   *
   * @param threshold -> Timeout in ms
   * @param execAsap -> Do it NAOW
   * @param timeout -> backup timeout object
   */
  if (((ref1 = window.core) != null ? ref1.debouncers : void 0) == null) {
    if (window.core == null) {
      window.core = new Object();
    }
    core.debouncers = new Object();
  }
  try {
    key = this.getName();
  } catch (undefined) {}
  try {
    if (core.debouncers[key] != null) {
      timeout = core.debouncers[key];
    }
  } catch (undefined) {}
  func = this;
  delayed = function() {
    if (key != null) {
      clearTimeout(timeout);
      delete core.debouncers[key];
    }
    if (!execAsap) {
      return func.apply(func, args);
    }
  };
  if (timeout != null) {
    try {
      clearTimeout(timeout);
    } catch (error1) {
      e = error1;
    }
  }
  if (execAsap) {
    func.apply(obj, args);
    console.debug("Executed " + key + " immediately");
    return false;
  }
  if (key != null) {
    return core.debouncers[key] = delay(threshold, function() {
      return delayed();
    });
  } else {
    return window.debounce_timer = delay(threshold, function() {
      return delayed();
    });
  }
};

loadJS = function(src, callback, doCallbackOnError, async) {
  var e, error1, errorFunction, onLoadFunction, s;
  if (callback == null) {
    callback = new Object();
  }
  if (doCallbackOnError == null) {
    doCallbackOnError = true;
  }
  if (async == null) {
    async = true;
  }

  /*
   * Load a new javascript file
   *
   * If it's already been loaded, jump straight to the callback
   *
   * @param string src The source URL of the file
   * @param function callback Function to execute after the script has
   *                          been loaded
   * @param bool doCallbackOnError Should the callback be executed if
   *                               loading the script produces an error?
   */
  if ($("script[src='" + src + "']").exists()) {
    if (typeof callback === "function") {
      try {
        callback();
      } catch (error1) {
        e = error1;
        console.error("Script is already loaded, but there was an error executing the callback function - " + e.message);
      }
    }
    return true;
  }
  s = document.createElement("script");
  s.setAttribute("src", src);
  s.setAttribute("type", "text/javascript");
  s.src = src;
  if (async !== false) {
    s.setAttribute("async", "async");
    s.async = true;
  }
  onLoadFunction = function() {
    var error2, error3, state;
    state = s.readyState;
    try {
      if (!callback.done && (!state || /loaded|complete/.test(state))) {
        callback.done = true;
        if (typeof callback === "function") {
          try {
            return callback();
          } catch (error2) {
            e = error2;
            console.error("Postload callback error for '" + src + "' - " + e.message);
            return console.warn(e.stack);
          }
        }
      }
    } catch (error3) {
      e = error3;
      return console.error("Onload error for '" + src + "' - " + e.message);
    }
  };
  errorFunction = function() {
    var error2, error3;
    console.warn("There may have been a problem loading " + src);
    try {
      if (!callback.done) {
        callback.done = true;
        if (typeof callback === "function" && doCallbackOnError) {
          try {
            return callback();
          } catch (error2) {
            e = error2;
            return console.error("Post error callback error - " + e.message);
          }
        }
      }
    } catch (error3) {
      e = error3;
      return console.error("There was an error in the error handler! " + e.message);
    }
  };
  s.setAttribute("onload", onLoadFunction);
  s.setAttribute("onreadystate", onLoadFunction);
  s.setAttribute("onerror", errorFunction);
  s.onload = s.onreadystate = onLoadFunction;
  s.onerror = errorFunction;
  document.getElementsByTagName('head')[0].appendChild(s);
  return true;
};

String.prototype.toTitleCase = function() {
  var len1, len2, lower, lowerRegEx, lowers, m, o, str, upper, upperRegEx, uppers;
  str = this.replace(/([^\W_]+[^\s-]*) */g, function(txt) {
    return txt.charAt(0).toUpperCase() + txt.substr(1).toLowerCase();
  });
  lowers = ["A", "An", "The", "And", "But", "Or", "For", "Nor", "As", "At", "By", "For", "From", "In", "Into", "Near", "Of", "On", "Onto", "To", "With"];
  for (m = 0, len1 = lowers.length; m < len1; m++) {
    lower = lowers[m];
    lowerRegEx = new RegExp("\\s" + lower + "\\s", "g");
    str = str.replace(lowerRegEx, function(txt) {
      return txt.toLowerCase();
    });
  }
  uppers = ["Id", "Tv"];
  for (o = 0, len2 = uppers.length; o < len2; o++) {
    upper = uppers[o];
    upperRegEx = new RegExp("\\b" + upper + "\\b", "g");
    str = str.replace(upperRegEx, upper.toUpperCase());
  }
  return str;
};

smartUpperCasing = function(text) {
  var len1, m, r, replaceLower, replacer, searchUpper, secondWord, secondWordCased, smartCased, specialLowerCaseWords, word;
  if (isNull(text)) {
    return "";
  }
  replacer = function(match) {
    return match.replace(match, match.toUpperCase());
  };
  smartCased = text.replace(/((?=((?!-)[\W\s\r\n]))\s[A-Za-z]|^[A-Za-z])/g, replacer);
  specialLowerCaseWords = ["a", "an", "and", "at", "but", "by", "for", "in", "nor", "of", "on", "or", "out", "so", "to", "the", "up", "yet"];
  try {
    for (m = 0, len1 = specialLowerCaseWords.length; m < len1; m++) {
      word = specialLowerCaseWords[m];
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

mapNewWindows = function(stopPropagation) {
  if (stopPropagation == null) {
    stopPropagation = true;
  }
  return $(".newwindow").each(function() {
    var curHref, openInNewWindow;
    curHref = $(this).attr("href");
    if (curHref == null) {
      curHref = $(this).attr("data-href");
    }
    openInNewWindow = function(url) {
      if (url == null) {
        return false;
      }
      window.open(url);
      return false;
    };
    $(this).click(function(e) {
      if (stopPropagation) {
        e.preventDefault();
        e.stopPropagation();
      }
      return openInNewWindow(curHref);
    });
    return $(this).keypress(function() {
      return openInNewWindow(curHref);
    });
  });
};

toastStatusMessage = function(message, className, duration, selector) {
  var html, showLoader;
  if (className == null) {
    className = "";
  }
  if (duration == null) {
    duration = 3000;
  }
  if (selector == null) {
    selector = "#search-status";
  }

  /*
   * Pop up a status message
   */
  if (window._metaStatus.isToasting === true) {
    delay(250, function() {
      return toastStatusMessage(message, className, duration, selector);
    });
    return false;
  }
  window._metaStatus.isToasting = true;
  if (isNumber(className)) {
    duration = className;
  }
  if (!isNumber(duration)) {
    duration = 3000;
  }
  if (selector.slice(0, 1) === !"#") {
    selector = "#" + selector;
  }
  if (!$(selector).exists()) {
    html = "<paper-toast id=\"" + (selector.slice(1)) + "\" duration=\"" + duration + "\"></paper-toast>";
    $(html).appendTo("body");
  }
  $(selector).attr("text", message).text(message).addClass(className);
  (showLoader = function(i) {
    var error, error1;
    ++i;
    try {
      p$(selector).show();
      return delay(duration + 500, function() {
        var isOpen;
        try {
          isOpen = p$(selector).opened;
        } catch (undefined) {}
        if (typeof isOpen !== "boolean") {
          isOpen = false;
        }
        if (!isOpen) {
          $(selector).empty();
          $(selector).removeClass(className);
          $(selector).attr("text", "");
        }
        window._metaStatus.isToasting = false;
        return false;
      });
    } catch (error1) {
      error = error1;
      if (i <= 50) {
        return delay(50, function() {
          showLoader(i);
          return false;
        });
      } else {
        console.error("Couldn't show loader: " + error.message);
        return console.warn(error.stack);
      }
    }
  })(0);
  delay(duration, function() {
    return _metaStatus.isToasting = false;
  });
  return false;
};

openLink = function(url) {
  if (url == null) {
    return false;
  }
  window.open(url);
  return false;
};

openTab = function(url) {
  return openLink(url);
};

goTo = function(url) {
  if (url == null) {
    return false;
  }
  window.location.href = url;
  return false;
};

if ((_metaStatus != null ? _metaStatus.isLoading : void 0) == null) {
  if (_metaStatus == null) {
    window._metaStatus = new Object();
  }
  _metaStatus.isLoading = false;
  _metaStatus.isToasting = false;
}

animateLoad = function(elId, iteration) {
  var e, error1, selector;
  if (elId == null) {
    elId = "loader";
  }
  if (iteration == null) {
    iteration = 0;
  }

  /*
   * Suggested CSS to go with this:
   *
   * #loader {
   *     position:fixed;
   *     top:50%;
   *     left:50%;
   * }
   * #loader.good::shadow .circle {
   *     border-color: rgba(46,190,17,0.9);
   * }
   * #loader.bad::shadow .circle {
   *     border-color:rgba(255,0,0,0.9);
   * }
   */
  if (isNumber(elId)) {
    elId = "loader";
  }
  if (elId.slice(0, 1) === "#") {
    selector = elId;
    elId = elId.slice(1);
  } else {
    selector = "#" + elId;
  }

  /*
   * This is there for Edge, which sometimes leaves an element
   * We declare this early because Polymer tries to be smart and not
   * actually activate when it's hidden. Thus, this is a prerequisite
   * to actually re-showing it once hidden.
   */
  $(selector).removeAttr("hidden");
  if ((_metaStatus != null ? _metaStatus.isLoading : void 0) == null) {
    if (_metaStatus == null) {
      _metaStatus = new Object();
    }
    _metaStatus.isLoading = false;
  }
  try {
    if (_metaStatus.isLoading) {
      if (iteration < 100) {
        iteration++;
        delay(100, function() {
          return animateLoad(elId, iteration);
        });
        return false;
      } else {
        console.warn("Loader timed out waiting for load completion");
        return false;
      }
    }
    if (!$(selector).exists()) {
      $("body").append("<paper-spinner id=\"" + elId + "\" active></paper-spinner");
    } else {
      $(selector).attr("active", true);
    }
    _metaStatus.isLoading = true;
    return false;
  } catch (error1) {
    e = error1;
    return console.warn('Could not animate loader', e.message);
  }
};

startLoad = function(elementId) {
  if (elementId == null) {
    elementId = null;
  }
  return animateLoad(elementId);
};

stopLoad = function(elId, fadeOut, iteration) {
  var e, endLoad, error1, selector;
  if (elId == null) {
    elId = "loader";
  }
  if (fadeOut == null) {
    fadeOut = 1000;
  }
  if (iteration == null) {
    iteration = 0;
  }
  if (elId.slice(0, 1) === "#") {
    selector = elId;
    elId = elId.slice(1);
  } else {
    selector = "#" + elId;
  }
  try {
    try {
      if (_metaStatus.isLoading !== true && p$(selector).active && $(selector).isVisible()) {
        _metaStatus.isLoading = true;
      }
    } catch (undefined) {}
    if (!_metaStatus.isLoading) {
      if (iteration < 100) {
        iteration++;
        delay(100, function() {
          return stopLoad(elId, fadeOut, iteration);
        });
        return false;
      } else {
        return false;
      }
    }
    if ($(selector).exists()) {
      $(selector).addClass("good");
      (endLoad = function() {
        return delay(fadeOut, function() {
          try {
            p$(selector).active = false;
          } catch (undefined) {}
          $(selector).removeClass("good").attr("active", false).removeAttr("active");
          return delay(1, function() {
            var aliases, ref1;
            $(selector).prop("hidden", true);

            /*
             * Now, the slower part.
             * Edge does weirdness with active being toggled off, but
             * everyone else should have hidden removed so animateLoad()
             * behaves well. So, we check our browser sniffing.
             */
            if ((typeof Browsers !== "undefined" && Browsers !== null ? Browsers.browser : void 0) != null) {
              aliases = ["Spartan", "Project Spartan", "Edge", "Microsoft Edge", "MS Edge"];
              if ((ref1 = Browsers.browser.browser.name, indexOf.call(aliases, ref1) >= 0) || Browsers.browser.engine.name === "EdgeHTML") {
                $(selector).remove();
                return _metaStatus.isLoading = false;
              } else {
                $(selector).removeAttr("hidden");
                return delay(50, function() {
                  return _metaStatus.isLoading = false;
                });
              }
            } else {
              $(selector).removeAttr("hidden");
              return delay(50, function() {
                return _metaStatus.isLoading = false;
              });
            }
          });
        });
      })();
    }
    return false;
  } catch (error1) {
    e = error1;
    return console.warn('Could not stop load animation', e.message);
  }
};

stopLoadError = function(message, elId, fadeOut, iteration) {
  var e, endLoad, error1, selector;
  if (elId == null) {
    elId = "loader";
  }
  if (fadeOut == null) {
    fadeOut = 7500;
  }
  if (elId.slice(0, 1) === "#") {
    selector = elId;
    elId = elId.slice(1);
  } else {
    selector = "#" + elId;
  }
  try {
    if (!_metaStatus.isLoading) {
      if (iteration < 100) {
        iteration++;
        delay(100, function() {
          return stopLoadError(message, elId, fadeOut, iteration);
        });
        return false;
      } else {
        return false;
      }
    }
    if ($(selector).exists()) {
      $(selector).addClass("bad");
      if (message != null) {
        toastStatusMessage(message, "", fadeOut);
      }
      (endLoad = function() {
        return delay(fadeOut, function() {
          $(selector).removeClass("bad").prop("active", false).removeAttr("active");
          return delay(1, function() {
            var aliases, ref1;
            $(selector).prop("hidden", true);

            /*
             * Now, the slower part.
             * Edge does weirdness with active being toggled off, but
             * everyone else should have hidden removed so animateLoad()
             * behaves well. So, we check our browser sniffing.
             */
            if ((typeof Browsers !== "undefined" && Browsers !== null ? Browsers.browser : void 0) != null) {
              aliases = ["Spartan", "Project Spartan", "Edge", "Microsoft Edge", "MS Edge"];
              if ((ref1 = Browsers.browser.browser.name, indexOf.call(aliases, ref1) >= 0) || Browsers.browser.engine.name === "EdgeHTML") {
                $(selector).remove();
                return _metaStatus.isLoading = false;
              } else {
                $(selector).removeAttr("hidden");
                return delay(50, function() {
                  return _metaStatus.isLoading = false;
                });
              }
            } else {
              $(selector).removeAttr("hidden");
              return delay(50, function() {
                return _metaStatus.isLoading = false;
              });
            }
          });
        });
      })();
    }
    return false;
  } catch (error1) {
    e = error1;
    return console.warn('Could not stop load error animation', e.message);
  }
};

doCORSget = function(url, args, callback, callbackFail) {
  var corsFail, createCORSRequest, e, error1, settings, xhr;
  if (callback == null) {
    callback = void 0;
  }
  if (callbackFail == null) {
    callbackFail = void 0;
  }
  corsFail = function() {
    if (typeof callbackFail === "function") {
      return callbackFail();
    } else {
      throw new Error("There was an error performing the CORS request");
    }
  };
  settings = {
    url: url,
    data: args,
    type: "get",
    crossDomain: true
  };
  try {
    $.ajax(settings).done(function(result) {
      if (typeof callback === "function") {
        callback();
        return false;
      }
    }).fail(function(result, status) {
      return console.warn("Couldn't perform jQuery AJAX CORS. Attempting manually.");
    });
  } catch (error1) {
    e = error1;
    console.warn("There was an error using jQuery to perform the CORS request. Attemping manually.");
  }
  url = url + "?" + args;
  createCORSRequest = function(method, url) {
    var xhr;
    if (method == null) {
      method = "get";
    }
    xhr = new XMLHttpRequest();
    if ("withCredentials" in xhr) {
      xhr.open(method, url, true);
    } else if (typeof XDomainRequest !== "undefined") {
      xhr = new XDomainRequest();
      xhr.open(method, url);
    } else {
      xhr = null;
    }
    return xhr;
  };
  xhr = createCORSRequest("get", url);
  if (!xhr) {
    throw new Error("CORS not supported");
  }
  xhr.onload = function() {
    var response;
    response = xhr.responseText;
    if (typeof callback === "function") {
      callback(response);
    }
    return false;
  };
  xhr.onerror = function() {
    console.warn("Couldn't do manual XMLHttp CORS request");
    return corsFail();
  };
  xhr.send();
  return false;
};

deepJQuery = function(selector) {

  /*
   * Do a shadow-piercing selector
   *
   * Cross-browser, works with Chrome, Firefox, Opera, Safari, and IE
   * Falls back to standard jQuery selector when everything fails.
   */
  var e, error1, error2;
  try {
    if (!$("html /deep/ " + selector).exists()) {
      throw "Bad /deep/ selector";
    }
    return $("html /deep/ " + selector);
  } catch (error1) {
    e = error1;
    try {
      if (!$("html >>> " + selector).exists()) {
        throw "Bad >>> selector";
      }
      return $("html >>> " + selector);
    } catch (error2) {
      e = error2;
      return $(selector);
    }
  }
};

p$ = function(selector) {
  var error1, error2;
  try {
    return $$(selector)[0];
  } catch (error1) {
    try {
      return $(selector).get(0);
    } catch (error2) {
      return d$(selector).get(0);
    }
  }
};

window.d$ = function(selector) {
  return deepJQuery(selector);
};

lightboxImages = function(selector, lookDeeply) {
  var jqo, options;
  if (selector == null) {
    selector = ".lightboximage";
  }
  if (lookDeeply == null) {
    lookDeeply = false;
  }

  /*
   * Lightbox images with this selector
   *
   * If the image has it, wrap it in an anchor and bind;
   * otherwise just apply to the selector.
   *
   * Requires ImageLightbox
   * https://github.com/rejas/imagelightbox
   */
  options = {
    onStart: function() {
      return overlayOn();
    },
    onEnd: function() {
      overlayOff();
      return activityIndicatorOff();
    },
    onLoadStart: function() {
      return activityIndicatorOn();
    },
    onLoadEnd: function() {
      return activityIndicatorOff();
    },
    allowedTypes: 'png|jpg|jpeg|gif|bmp|webp',
    quitOnDocClick: true,
    quitOnImgClick: true
  };
  _asm.lightbox = {
    options: options
  };
  jqo = lookDeeply ? d$(selector) : $(selector);
  loadJS("bower_components/imagelightbox/dist/imagelightbox.min.js", function() {
    jqo.click(function(e) {
      var error1;
      try {
        e.preventDefault();
        e.stopPropagation();
        $(this).imageLightbox(options).startImageLightbox();
        return console.warn("Event propagation was stopped when clicking on this.");
      } catch (error1) {
        e = error1;
        return console.error("Unable to lightbox this image!");
      }
    }).each(function() {
      var e, error1, imgUrl, tagHtml;
      console.log("Using selectors '" + selector + "' / '" + this + "' for lightboximages");
      try {
        if (($(this).prop("tagName").toLowerCase() === "img" || $(this).prop("tagName").toLowerCase() === "picture") && $(this).parent().prop("tagName").toLowerCase() !== "a") {
          tagHtml = $(this).removeClass("lightboximage").prop("outerHTML");
          imgUrl = (function() {
            switch (false) {
              case !!isNull($(this).attr("data-layzr-retina")):
                return $(this).attr("data-layzr-retina");
              case !!isNull($(this).attr("data-layzr")):
                return $(this).attr("data-layzr");
              case !!isNull($(this).attr("data-lightbox-image")):
                return $(this).attr("data-lightbox-image");
              case !!isNull($(this).attr("src")):
                return $(this).attr("src");
              default:
                return $(this).find("img").attr("src");
            }
          }).call(this);
          $(this).replaceWith("<a href='" + imgUrl + "' data-lightbox='" + imgUrl + "' class='lightboximage'>" + tagHtml + "</a>");
          return $("a[href='" + imgUrl + "']").imageLightbox(options);
        }
      } catch (error1) {
        e = error1;
        return console.log("Couldn't parse through the elements");
      }
    });
    return console.info("Lightboxed the following:", jqo);
  });
  return false;
};

activityIndicatorOn = function() {
  return $('<div id="imagelightbox-loading"><div></div></div>').appendTo('body');
};

activityIndicatorOff = function() {
  $('#imagelightbox-loading').remove();
  return $("#imagelightbox-overlay").click(function() {
    return $("#imagelightbox").click();
  });
};

overlayOn = function() {
  return $('<div id="imagelightbox-overlay"></div>').appendTo('body');
};

overlayOff = function() {
  return $('#imagelightbox-overlay').remove();
};

formatScientificNames = function(selector) {
  if (selector == null) {
    selector = ".sciname";
  }
  return $(".sciname").each(function() {
    var nameStyle;
    nameStyle = $(this).css("font-style") === "italic" ? "normal" : "italic";
    return $(this).css("font-style", nameStyle);
  });
};

prepURI = function(string) {
  string = encodeURIComponent(string);
  return string.replace(/%20/g, "+");
};

getLocation = function(callback) {
  var geoFail, geoSuccess;
  if (callback == null) {
    callback = void 0;
  }
  geoSuccess = function(pos, callback) {
    window.locationData.lat = pos.coords.latitude;
    window.locationData.lng = pos.coords.longitude;
    window.locationData.acc = pos.coords.accuracy;
    window.locationData.last = Date.now();
    if (callback != null) {
      callback(window.locationData);
    }
    return false;
  };
  geoFail = function(error, callback) {
    var locationError;
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
    if (callback != null) {
      callback(false);
    }
    return false;
  };
  if (navigator.geolocation) {
    return navigator.geolocation.getCurrentPosition(geoSuccess, geoFail, window.locationData.params);
  } else {
    console.warn("This browser doesn't support geolocation!");
    if (callback != null) {
      return callback(false);
    }
  }
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

bindClickTargets = function() {
  bindClicks();
  return false;
};

bindClicks = function(selector) {
  if (selector == null) {
    selector = ".click";
  }

  /*
   * Helper function. Bind everything with a selector
   * to execute a function data-function or to go to a
   * URL data-href.
   */
  $(selector).each(function() {
    var callable, e, error1, error2, ref1, url;
    try {
      url = $(this).attr("data-href");
      if (isNull(url)) {
        url = $(this).attr("data-url");
        if (url != null) {
          $(this).attr("data-newtab", "true");
        }
      }
      if (!isNull(url)) {
        $(this).unbind();
        try {
          if (url === uri.o.attr("path") && $(this).prop("tagName").toLowerCase() === "paper-tab") {
            $(this).parent().prop("selected", $(this).index());
          }
        } catch (error1) {
          e = error1;
          console.warn("tagname lower case error");
        }
        $(this).click(function() {
          var ref1, ref2, ref3;
          url = $(this).attr("data-href");
          if (isNull(url)) {
            url = $(this).attr("data-url");
          }
          if (((ref1 = $(this).attr("newTab")) != null ? ref1.toBool() : void 0) || ((ref2 = $(this).attr("newtab")) != null ? ref2.toBool() : void 0) || ((ref3 = $(this).attr("data-newtab")) != null ? ref3.toBool() : void 0)) {
            return openTab.debounce(50, null, null, url);
          } else {
            return goTo(50, null, null, url);
          }
        });
        return url;
      } else {
        callable = (ref1 = $(this).attr("data-function")) != null ? ref1 : $(this).attr("data-fn");
        if (callable != null) {
          $(this).unbind();
          return $(this).click(function() {
            var error2;
            try {
              return window[callable].debounce(50);
            } catch (error2) {
              e = error2;
              return console.error("'" + callable + "()' is a bad function - " + e.message);
            }
          });
        }
      }
    } catch (error2) {
      e = error2;
      return console.error("There was a problem binding to #" + ($(this).attr("id")) + " - " + e.message);
    }
  });
  return false;
};

getMaxZ = function() {
  var mapFunction;
  mapFunction = function() {
    return $.map($("body *"), function(e, n) {
      if ($(e).css("position") !== "static") {
        return parseInt($(e).css("z-index") || 1);
      }
    });
  };
  return Math.max.apply(null, mapFunction());
};

browserBeware = function() {
  var browsers, e, error1, warnBrowserHtml;
  return false;
  if ((typeof Browsers !== "undefined" && Browsers !== null ? Browsers.hasCheckedBrowser : void 0) == null) {
    if (typeof Browsers === "undefined" || Browsers === null) {
      window.Browsers = new Object();
    }
    Browsers.hasCheckedBrowser = 0;
  }
  try {
    browsers = new WhichBrowser();
    Browsers.browser = browsers;
    if (browsers.isBrowser("Firefox")) {
      warnBrowserHtml = "<div id=\"firefox-warning\" class=\"alert alert-warning alert-dismissible fade in\" role=\"alert\">\n  <button type=\"button\" class=\"close\" data-dismiss=\"alert\" aria-label=\"Close\"><span aria-hidden=\"true\">&times;</span></button>\n  <strong>Warning!</strong> Firefox has buggy support for <a href=\"http://webcomponents.org/\" class=\"alert-link\">webcomponents</a> and the <a href=\"https://www.polymer-project.org\" class=\"alert-link\">Polymer project</a>. If you encounter bugs, try using <a href=\"https://www.google.com/chrome/\" class=\"alert-link\">Chrome</a> (recommended), <a href=\"www.opera.com/computer\" class=\"alert-link\">Opera</a>, Safari, <a href=\"https://www.microsoft.com/en-us/windows/microsoft-edge\" class=\"alert-link\">Edge</a>, or your phone instead &#8212; they'll all be faster, too.\n</div>";
      $("#title").after(warnBrowserHtml);
      $(".alert").alert();
      console.warn("We've noticed you're using Firefox. Firefox has problems with this site, we recommend trying Google Chrome instead:", "https://www.google.com/chrome/");
      console.warn("Firefox took " + (Browsers.hasCheckedBrowser * 250) + "ms after page load to render this error message.");
    }
    if (browsers.isBrowser("Internet Explorer") || browsers.isBrowser("Safari")) {
      return $("#collapse-button").click(function() {
        return $(".collapse").collapse("toggle");
      });
    }
  } catch (error1) {
    e = error1;
    if (Browsers.hasCheckedBrowser === 100) {
      console.warn("We can't check your browser!");
      console.warn("Known issues:");
      console.warn("Firefox: Some VERY buggy behaviour");
      console.warn("IE & Safari: The advanced options may not open");
      return false;
    }
    return delay(250, function() {
      Browsers.hasCheckedBrowser++;
      return browserBeware();
    });
  }
};

bsAlert = function(message, type, fallbackContainer, selector) {
  var alertContainer, alertMessage, closeButton, closeIcon, error1, html, topContainer;
  if (type == null) {
    type = "warning";
  }
  if (fallbackContainer == null) {
    fallbackContainer = "body";
  }
  if (selector == null) {
    selector = "#bs-alert";
  }

  /*
   * Pop up a status message
   * Uses the Bootstrap alert dialog
   *
   * See
   * http://getbootstrap.com/components/#alerts
   * for available types
   */
  try {
    if (!$(selector).exists()) {
      html = "<div class=\"alert alert-" + type + " alert-dismissable hanging-alert\" role=\"alert\" id=\"" + (selector.slice(1)) + "\">\n  <button type=\"button\" class=\"close\" data-dismiss=\"alert\" aria-label=\"Close\"><span aria-hidden=\"true\">&times;</span></button>\n    <div class=\"alert-message\"></div>\n</div>";
      topContainer = $("main").exists() ? "main" : $("article").exists() ? "article" : fallbackContainer;
      $(topContainer).prepend(html);
    } else {
      $(selector).removeClass("alert-warning alert-info alert-danger alert-success");
      $(selector).addClass("alert-" + type);
    }
    $(selector + " .alert-message").html(message);
  } catch (error1) {
    alertContainer = document.createElement("div");
    alertContainer.setAttribute("class", "alert alert-" + type + " alert-dismissable hanging-alert");
    alertContainer.setAttribute("role", "alert");
    alertContainer.setAttribute("id", selector.slice(1));
    closeButton = document.createElement("button");
    closeButton.setAttribute("class", "close");
    closeButton.setAttribute("data-dismiss", "alert");
    closeButton.setAttribute("aria-label", "Close");
    closeIcon = document.createElement("span");
    closeIcon.setAttribute("aria-hidden", "true");
    closeIcon.textContent = "&times;";
    closeButton.appendChild(closeIcon);
    alertContainer.appendChild(closeButton);
    alertMessage = document.createElement("div");
    alertMessage.setAttribute("class", "alert-message");
    alertMessage.textContent = message;
    alertContainer.appendChild(alertMessage);
    try {
      document.querySelector("#bs-alert").remove();
    } catch (undefined) {}
    document.querySelector("body").appendChild(alertContainer);
  }
  bindClicks();
  mapNewWindows();
  return false;
};

animateHoverShadows = function(selector, defaultElevation, raisedElevation) {
  var handlerIn, handlerOut;
  if (selector == null) {
    selector = "paper-card.card-tile";
  }
  if (defaultElevation == null) {
    defaultElevation = 2;
  }
  if (raisedElevation == null) {
    raisedElevation = 4;
  }

  /*
   * Set animation for paper cards to have hover shadows elevation change
   */
  handlerIn = function() {
    return $(this).attr("elevation", raisedElevation);
  };
  handlerOut = function() {
    return $(this).attr("elevation", defaultElevation);
  };
  $(selector).hover(handlerIn, handlerOut);
  return false;
};

allError = function(message) {

  /*
   * Show all the errors
   */
  stopLoadError(message);
  bsAlert(message, "danger");
  console.error(message);
  return false;
};

checkFileVersion = function(forceNow) {
  var checkVersion;
  if (forceNow == null) {
    forceNow = false;
  }

  /*
   * Check to see if the file on the server is up-to-date with what the
   * user sees.
   *
   * @param bool forceNow force a check now
   */
  checkVersion = function() {
    return $.get(uri.urlString + "meta.php", "do=get_last_mod", "json").done(function(result) {
      var html;
      if (forceNow) {
        console.log("Forced version check:", result);
      }
      if (!isNumber(result.last_mod)) {
        return false;
      }
      if (_asm.lastMod == null) {
        _asm.lastMod = result.last_mod;
      }
      if (result.last_mod > _asm.lastMod) {
        html = "<div id=\"outdated-warning\" class=\"alert alert-warning alert-dismissible fade in\" role=\"alert\">\n  <button type=\"button\" class=\"close\" data-dismiss=\"alert\" aria-label=\"Close\"><span aria-hidden=\"true\">&times;</span></button>\n  <strong>We have page updates!</strong> This page has been updated since you last refreshed. <a class=\"alert-link\" id=\"refresh-page\" style=\"cursor:pointer\">Click here to refresh now</a> and get bugfixes and updates.\n</div>";
        if (!$("#outdated-warning").exists()) {
          $("body").append(html);
          $("#refresh-page").click(function() {
            return document.location.reload(true);
          });
        }
        return console.warn("Your current version is out of date! Please refresh the page.");
      } else if (forceNow) {
        return console.info("Your version is up to date: have " + _asm.lastMod + ", got " + result.last_mod);
      }
    }).fail(function() {
      return console.warn("Couldn't check file version!!");
    }).always(function() {
      return delay(5 * 60 * 1000, function() {
        return checkVersion();
      });
    });
  };
  if (forceNow || (_asm.lastMod == null)) {
    checkVersion();
    return true;
  }
  return false;
};

window.checkFileVersion = checkFileVersion;

setupServiceWorker = function() {
  if ("serviceworker" in navigator) {
    navigator.serviceWorker.register("js/serviceWorker.min.js").then(function(registration) {
      return console.log("ServiceWorker registered with scope", registration.scope);
    })["catch"](function(error) {
      return console.warn("ServiceWorker registration failed:", error);
    });
  }
  return false;
};

foo = function() {
  toastStatusMessage("Sorry, this feature is not yet finished");
  stopLoad();
  return false;
};

doNothing = function() {
  return null;
};

buildQuery = function(obj) {
  var k, key, queryList, v, value;
  queryList = new Array();
  for (k in obj) {
    v = obj[k];
    key = k.replace(/[^A-Za-z\-_\[\]]/img, "");
    value = encodeURIComponent(v).replace(/\%20/g, "+");
    queryList.push(key + "=" + value);
  }
  return queryList.join("&");
};

buildArgs = buildQuery;

checkLocalVersion = function() {
  var len1, m, part, prefixUrl, urlBase, urlBaseRaw;
  if (uri.o.attr("host") === "localhost") {
    urlBaseRaw = uri.o.attr("directory").split("/");
    urlBase = new Array();
    for (m = 0, len1 = urlBaseRaw.length; m < len1; m++) {
      part = urlBaseRaw[m];
      if (isNull(part)) {
        continue;
      }
      urlBase.push(part);
    }
    if (urlBase[0].search("~") === 0) {
      prefixUrl = uri.o.attr("protocol") + ("://localhost" + urlBase[0] + "/");
    } else {
      prefixUrl = uri.urlString;
    }
    $.get(prefixUrl + "currentVersion").done(function(result) {
      var args, githubApiEndpoint, version, versionParts;
      console.log("Got tag", result);
      version = result.replace(/v(([0-9]+\.)+[0-9]+)(\-\w+)?/img, "$1");
      if (version.length > 128) {
        console.error("Problem checking version file");
        return false;
      }
      versionParts = version.split(".");
      args = {
        access_token: "7a76691c6beea4d47eaaa6182a53e523c6a16a67"
      };
      githubApiEndpoint = "https://api.github.com/repos/tigerhawkvok/asm-mammal-database/releases";
      return $.get(githubApiEndpoint, buildQuery(args, "json")).done(function(result) {
        var html, i, len2, len3, localVersionPartNumber, o, p, release, tag, tagParts, tagVersion, tagVersionPartNumber;
        console.log("Github API result:", result);
        for (o = 0, len2 = result.length; o < len2; o++) {
          release = result[o];
          console.log("Checking release", release);
          tag = release.tag_name;
          tagVersion = tag.replace(/v(([0-9]+\.)+[0-9]+)(\-\w+)?/img, "$1");
          tagParts = tagVersion.split(".");
          i = 0;
          for (p = 0, len3 = tagParts.length; p < len3; p++) {
            part = tagParts[p];
            tagVersionPartNumber = toInt(part);
            localVersionPartNumber = toInt(versionParts[i]);
            if (tagVersionPartNumber > localVersionPartNumber) {
              console.log("Found mismatched version at", uri.urlString + "/currentVersion");
              console.warn("Notice: tag part '" + tagVersionPartNumber + "' > '" + localVersionPartNumber + "'", tag, version);
              html = "<strong>Head's-Up:</strong> Your local version is behind the latest application release.\n<br/><br/>\nOpen up your terminal, and in your local directory run:\n<br/><br/>\n<code class=\"center-block text-center\">git pull</code>\n<br/>\nTo get your local version up-to-date.";
              bsAlert(html);
              return false;
            } else if (tagVersionPartNumber < localVersionPartNumber) {
              break;
            }
            ++i;
          }
        }
        console.debug("Your version is up-to-date");
        return false;
      });
    });
  } else {
    doNothing();
  }
  return false;
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

objToArgs = function(obj) {
  var arg, argArray, error, key, val;
  if (typeof obj !== "object") {
    error = {
      message: "INVALID_TYPE"
    };
    throw error;
  }
  argArray = new Array();
  for (key in obj) {
    val = obj[key];
    arg = key + "=" + (encodeURIComponent(val));
    argArray.push(arg);
  }
  return argArray.join("&");
};

dataUriToBlob = function(dataUri, callback) {

  /*
   * From
   *
   * http://stackoverflow.com/a/38845151/1877527
   *
   * Itself edited from
   *
   * https://developer.mozilla.org/en-US/docs/Web/API/HTMLCanvasElement/toBlob#Polyfill
   *
   * Chrome has a 2 MiB data uri limit;
   * convert to blob then use that instead.
   */
  var arr, binStr, blob, blobAttr, data, el, encoding, error1, i, len, len1, m, mimeString;
  data = dataUri.split(",")[1];
  encoding = dataUri.split(";")[1].split(",")[0];
  try {
    binStr = atob(data);
  } catch (error1) {
    binStr = decodeURIComponent(data);
  }
  len = binStr.length;
  arr = new Uint8Array(len);
  mimeString = dataUri.split(',')[0].split(':')[1].split(';')[0];
  i = 0;
  for (m = 0, len1 = arr.length; m < len1; m++) {
    el = arr[m];
    arr[i] = binStr.charCodeAt(i);
    ++i;
  }
  blobAttr = {
    type: mimeString
  };
  blob = new Blob([arr], blobAttr);
  if (typeof callback === "function") {
    callback(blob);
  }
  return blob;
};

downloadDataUriAsBlob = function(selector) {
  var blob, data, objUrl;
  if (isNull(selector)) {
    console.error("Needs a data URI or element selector as an argument!");
    return false;
  }
  try {
    if ($(selector).exists()) {
      data = $(selector).attr("href");
    }
  } catch (undefined) {}
  if (isNull(data)) {
    data = selector;
    selector = null;
  }
  blob = dataUriToBlob(data);
  objUrl = URL.createObjectURL(blob);
  if (isNull(selector)) {
    return objUrl;
  }
  $(selector).attr("href", objUrl);
  return false;
};

delayPolymerBind = function(selector, callback, iter) {
  var doLoad;
  if (iter == null) {
    iter = 0;
  }
  if (typeof md5 === "undefined" || md5 === null) {
    loadJS("bower_components/JavaScript-MD5/js/md5.min.js", function() {
      return doLoad();
    });
  } else {
    doLoad();
  }
  doLoad = function() {
    var e, element, error1, ref1, superSlowBackup, uid;
    if (typeof window._dpb !== "object") {
      window._dpb = new Object();
    }
    uid = md5(selector) + md5(callback);
    if (isNull(window._dpb[uid])) {
      window._dpb[uid] = false;
    }
    superSlowBackup = 1000;
    if ((typeof Polymer !== "undefined" && Polymer !== null ? (ref1 = Polymer.Base) != null ? ref1.$$ : void 0 : void 0) != null) {
      if (window._dpb[uid] === false) {
        iter = 0;
        window._dpb[uid] = true;
      }
      try {
        element = Polymer.Base.$$(selector);
        callback(element);
        return delay(superSlowBackup, function() {
          console.info("Doing " + superSlowBackup + "ms delay callback for " + selector);
          return callback(element);
        });
      } catch (error1) {
        e = error1;
        console.warn("Error trying to do the delayed polymer bind - " + e.message);
        if (iter < 10) {
          ++iter;
          return delay(75, function() {
            return delayPolymerBind(selector, callback, iter);
          });
        } else {
          console.error("Persistent error in polymer binding (" + e.message + ")");
          console.error(e.stack);
          element = $(selector).get(0);
          callback(element);
          return delay(superSlowBackup, function() {
            element = document.querySelector(selector);
            console.info("Doing " + superSlowBackup + "ms delay callback for " + selector);
            console.info("Using element", element);
            return callback(element);
          });
        }
      }
    } else {
      if (iter < 50) {
        return delay(100, function() {
          ++iter;
          return delayPolymerBind(selector, callback, iter);
        });
      } else {
        console.error("Failed to verify Polymer was set up, attempting manual");
        element = document.querySelector(selector);
        return callback(element);
      }
    }
  };
  return false;
};

loadSocialMediaSlideoutBar = function(handles, selector, appendTo) {
  var contentHtml, handle, html, service, serviceHtml, showButton, toggleSocialSlideoutBar;
  if (selector == null) {
    selector = "#social-menu";
  }
  if (appendTo == null) {
    appendTo = "main";
  }

  /*
   *
   * @param obj handles -> an object with keys as service and value as handle
   */
  toggleSocialSlideoutBar = function() {
    if ($(selector).hasClass("out")) {
      $(selector).removeClass("out").addClass("in");
    } else {
      $(selector).removeClass("in").addClass("out");
    }
    return false;
  };
  window.toggleSocialSlideoutBar = toggleSocialSlideoutBar;
  if (!$(selector).exists()) {
    contentHtml = "";
    for (service in handles) {
      handle = handles[service];
      switch (service) {
        case "twitter":
          serviceHtml = "<a class=\"twitter-timeline\" data-link-color=\"#1DA1F2\" href=\"https://twitter.com/" + handle + "\">Tweets by @" + handle + "</a> <script async src=\"//platform.twitter.com/widgets.js\" charset=\"utf-8\"></script>";
          break;
        default:
          serviceHtml = "";
      }
      contentHtml += "\n" + serviceHtml + "\n";
    }
    html = "<paper-material id=\"social-menu\" class=\"out\" elevation=\"4\">\n  <paper-icon-button icon=\"glyphicon-social:twitter\" class=\"show-social\"></paper-icon-button>\n  <div class=\"slideout-content\">\n    " + contentHtml + "\n  </div>\n</paper-material>";
    showButton = "    ";
    $(appendTo).append(html);
    $(".show-social").click(function() {
      toggleSocialSlideoutBar.debounce(50);
      return false;
    });
  }
  return false;
};

try {
  $();
} catch (error1) {
  e = error1;
  bsAlert("<strong>You're offline</strong>: We need at least enough data to load a few dependencies. Please put yourself online and try again.", "error");
}

$(function() {
  var caption, captionValue, error2, error3, len1, len2, m, md, mdText, o, offsetImageLabel, ref1, ref2;
  try {
    checkLocalVersion();
    interval(3600 * 1000, function() {
      return checkLocalVersion();
    });
  } catch (undefined) {}
  formatScientificNames();
  bindClicks();
  mapNewWindows();
  try {
    $("body").tooltip({
      selector: "[data-toggle='tooltip']"
    });
  } catch (error2) {
    e = error2;
    console.warn("Tooltips were attempted to be set up, but do not exist");
  }
  try {
    checkAdmin();
    if ((typeof adminParams !== "undefined" && adminParams !== null ? adminParams.loadAdminUi : void 0) === true) {
      loadJS("js/admin.min.js", function() {
        return loadAdminUi();
      });
    }
  } catch (error3) {
    e = error3;
    getLocation();
    loadJS("js/admin.min.js", function() {
      _asm.inhibitRedirect = true;
      return verifyLoginCredentials(function() {
        var adminFragment, html, query;
        delete _asm.inhibitRedirect;
        if (uri.o.attr("file") === "species-account.php") {
          if (typeof window.speciesData === "object") {
            try {
              query = JSON.stringify(window.speciesData);
              adminFragment = "#" + (Base64.encode(query));
              html = "<paper-icon-button\n  class=\"click admin-edit-button\"\n  data-href=\"" + uri.urlString + "admin-page.html" + adminFragment + "\"\n  icon=\"icons:create\"\n  >\n</paper-icon-button>";
              $("header p paper-icon-button[icon='icons:home']").before(html);
              return bindClicks(".admin-edit-button");
            } catch (undefined) {}
          }
        }
      });
    });
    loadJS("js/jquery.cookie.min.js", function() {
      return false;
    });
  }
  try {
    ref1 = $("marked-element");
    for (m = 0, len1 = ref1.length; m < len1; m++) {
      md = ref1[m];
      mdText = $(md).find("script").text();
      if (!isNull(mdText)) {
        p$(md).markdown = mdText;
      }
    }
  } catch (undefined) {}
  browserBeware();
  checkFileVersion();
  try {
    loadSocialMediaSlideoutBar(_asm.socialHandles);
  } catch (undefined) {}
  try {
    ref2 = $("figcaption .caption-description");
    for (o = 0, len2 = ref2.length; o < len2; o++) {
      caption = ref2[o];
      captionValue = $(caption).text().unescape();
      $(caption).text(captionValue);
    }
  } catch (undefined) {}
  try {
    (offsetImageLabel = function(iter) {
      var imageWidth;
      if (!$("figure picture").exists()) {
        console.log("No image on page");
        return false;
      }
      imageWidth = $("figure picture").width();
      if (isNull(imageWidth, true)) {
        ++iter;
        if (iter >= 10) {
          console.log("Never saw a bigger image width");
          return false;
        }
        delay(100, function() {
          return offsetImageLabel(iter);
        });
        return false;
      }
      if (iter > 0) {
        console.warn("Took " + (iter * 100) + "ms to reposition image!");
      }
      $("figure p.picture-label").css("left", "calc(50% - (" + imageWidth + "px/2)*.95)");
      lightboxImages();
      return false;
    })(0);
  } catch (undefined) {}
  try {
    return loadJS("bower_components/JavaScript-MD5/js/md5.min.js");
  } catch (undefined) {}
});

searchParams = {
  lastSearch: "*",
  targetApi: "api.php",
  targetContainer: "#result_container"
};

searchParams.apiPath = uri.urlString + searchParams.targetApi;

if (typeof window._asm !== "object") {
  window._asm = new Object();
}

_asm.affiliateQueryUrl = {
  iucnRedlist: "http://apiv3.iucnredlist.org/api/v3/species/",
  iucnRedlistCN: "http://apiv3.iucnredlist.org/api/v3/species/common_names/",
  iNaturalist: "https://www.inaturalist.org/taxa/search",
  calPhotos: "http://calphotos.berkeley.edu/cgi/img_query"
};

fetchMajorMinorGroups = function(scientific, callback) {
  var error2, ref1, renderItemsList;
  if (scientific == null) {
    scientific = null;
  }
  renderItemsList = function() {
    var buttonHtml, column, itemLabel, itemType, menuItems, ref1, type;
    $("#eutheria-extra").remove();
    menuItems = "<paper-item data-type=\"any\" selected>All</paper-item>";
    ref1 = _asm.major;
    for (itemType in ref1) {
      itemLabel = ref1[itemType];
      menuItems += "<paper-item data-type=\"" + itemType + "\">" + (itemLabel.toTitleCase()) + "</paper-item>";
    }
    column = scientific ? "linnean_family" : "simple_linnean_subgroup";
    buttonHtml = "<paper-menu-button id=\"simple-linnean-groups\" class=\"col-xs-6 col-md-4\">\n  <paper-button class=\"dropdown-trigger\"><iron-icon icon=\"icons:filter-list\"></iron-icon><span id=\"filter-what\" class=\"dropdown-label\"></span></paper-button>\n  <paper-menu label=\"Group\" data-column=\"simple_linnean_group\" class=\"cndb-filter dropdown-content\" id=\"linnean\" name=\"type\" attrForSelected=\"data-type\" selected=\"0\">\n    " + menuItems + "\n  </paper-menu>\n</paper-menu-button>";
    if ($("#simple-linnean-groups").exists()) {
      $("#simple-linnean-groups").replaceWith(buttonHtml);
      $("#simple-linnean-groups").on("iron-select", function() {
        var type;
        type = $(p$("#simple-linnean-groups paper-menu").selectedItem).text();
        return $("#simple-linnean-groups span.dropdown-label").text(type);
      });
      try {
        type = $(p$("#simple-linnean-groups paper-menu").selectedItem).text();
        $("#simple-linnean-groups span.dropdown-label").text(type);
      } catch (undefined) {}
    }
    eutheriaFilterHelper(true);
    if ($("#simple-linnean-groups").exists()) {
      console.log("Replaced menu items with", menuItems);
    }
    if (typeof callback === "function") {
      callback();
    }
    return false;
  };
  if (typeof _asm.mammalGroupsBase === "object" && typeof _asm.major === "object") {
    if (!isArray(_asm.mammalGroupsBase)) {
      _asm.mammalGroupsBase = Object.toArray(_asm.mammalGroupsBase);
    }
    renderItemsList();
    return true;
  } else {
    if (!isBool(scientific)) {
      try {
        scientific = (ref1 = p$("#use-scientific").checked) != null ? ref1 : true;
      } catch (error2) {
        scientific = true;
      }
    }
    $.get(searchParams.apiPath, "fetch-groups=true&scientific=" + scientific).done(function(result) {
      if (result.status !== true) {
        return false;
      }
      _asm.mammalGroupsBase = Object.toArray(result.minor);
      _asm.major = result.major;
      return renderItemsList();
    }).fail(function(result, error) {
      console.error("Failed to hit API");
      console.warn(result, error);
      return false;
    });
  }
  return false;
};

eutheriaFilterHelper = function(skipFetch) {
  if (skipFetch == null) {
    skipFetch = false;
  }
  if (!skipFetch) {
    fetchMajorMinorGroups.debounce(50);
    try {
      $("#use-scientific").on("iron-change", function() {
        delete _asm.mammalGroupsBase;
        return fetchMajorMinorGroups.debounce(50);
      });
    } catch (undefined) {}
  }
  $("#linnean").on("iron-select", function() {
    var column, error2, group, html, humanGroup, len1, len2, m, mammalGroups, mammalItems, o, ref1, ref2, scientific, type;
    try {
      if ($(p$("#linnean").selectedItem).attr("data-type") !== "any") {
        p$("#global_search").checked = false;
      }
    } catch (undefined) {}
    if ($(p$("#linnean").selectedItem).attr("data-type") === "eutheria") {
      mammalGroups = new Array();
      ref1 = _asm.mammalGroupsBase;
      for (m = 0, len1 = ref1.length; m < len1; m++) {
        humanGroup = ref1[m];
        mammalGroups.push(humanGroup.toLowerCase());
      }
      mammalGroups.sort();
      mammalItems = "";
      for (o = 0, len2 = mammalGroups.length; o < len2; o++) {
        group = mammalGroups[o];
        html = "<paper-item data-type=\"" + group + "\">\n  " + (group.toTitleCase()) + "\n</paper-item>";
        mammalItems += html;
      }
      if (!isBool(scientific)) {
        try {
          scientific = (ref2 = p$("#use-scientific").checked) != null ? ref2 : true;
        } catch (error2) {
          scientific = true;
        }
      }
      column = scientific ? "linnean_order" : "simple_linnean_subgroup";
      html = "<div id=\"eutheria-extra\"  class=\"col-xs-12 col-md-5\">\n    <label for=\"type\" class=\"sr-only\">Eutheria Filter</label>\n    <div class=\"row\">\n    <paper-menu-button class=\"col-xs-12\" id=\"eutheria-subfilter\">\n      <paper-button class=\"dropdown-trigger\"><iron-icon icon=\"icons:filter-list\"></iron-icon><span id=\"filter-what\" class=\"dropdown-label\"></span></paper-button>\n      <paper-menu label=\"Group\" data-column=\"" + column + "\" class=\"cndb-filter dropdown-content\" id=\"linnean-eutheria\" name=\"type\" attrForSelected=\"data-type\" selected=\"0\">\n        <paper-item data-type=\"any\" selected>All</paper-item>\n        " + mammalItems + "\n        <!-- As per flag 4 in readme -->\n      </paper-menu>\n    </paper-menu-button>\n    </div>\n  </div>";
      $("#simple-linnean-groups").after(html);
      $("#eutheria-subfilter").on("iron-select", function() {
        var type;
        type = $(p$("#eutheria-subfilter paper-menu").selectedItem).attr("data-type");
        return $("#eutheria-subfilter span.dropdown-label").text(type);
      });
      type = $(p$("#eutheria-subfilter paper-menu").selectedItem).attr("data-type");
      return $("#eutheria-subfilter span.dropdown-label").text(type);
    } else {
      return $("#eutheria-extra").remove();
    }
  });
  try {
    doLazily();
  } catch (undefined) {}
  return false;
};

checkLaggedUpdate = function(result) {

  /*
   *
   */
  var args, error2, finishedLoop, i, iucnCanProvide, j, k, key, len1, m, ref1, shouldSkip, start, taxon;
  console.debug("Executing lagged update check ...");
  iucnCanProvide = ["common_name", "species_authority"];
  start = Date.now();
  if (result.do_client_update === true) {
    k = j = 0;
    finishedLoop = false;
    try {
      ref1 = result.result;
      for (i in ref1) {
        taxon = ref1[i];
        shouldSkip = true;
        for (m = 0, len1 = iucnCanProvide.length; m < len1; m++) {
          key = iucnCanProvide[m];
          if (!isNull(taxon[key])) {
            continue;
          } else {
            shouldSkip = false;
            break;
          }
        }
        if (shouldSkip) {
          continue;
        }
        ++k;
        args = "missing=true&genus=" + taxon.genus + "&species=" + taxon.species;
        $.get(searchParams.targetApi, args, "json").done(function(subResult) {
          var col, row, val;
          ++j;
          if (!subResult.did_update) {
            return false;
          }
          console.log("Update for " + subResult.canonical_sciname, subResult);
          row = $(".cndb-result-entry[data-taxon='" + subResult.genus + "+" + subResult.species + "']");
          for (col in subResult) {
            val = subResult[col];
            if ($(row).find("." + col).exists() && !isNull(val)) {
              if (isNull($(row).find("." + col).text())) {
                console.log("Set " + col + " text of " + subResult.canonical_sciname + " to " + val);
                $(row).find("." + col).text(val);
              }
            } else if ($(row).find("." + col).exists() && isNull(val)) {
              console.warn("Couldn't update " + col + " - got an empty IUCN result");
            }
          }
          return false;
        }).fail(function(subResult, status) {
          console.warn("Couldn't update " + taxon.canonical_sciname, subResult, status);
          console.warn(searchParams.targetApi + "?" + args);
          return false;
        }).always(function() {
          var elapsed;
          if (j === k && finishedLoop) {
            elapsed = Date.now() - start;
            console.log("Finished async IUCN taxa check in " + elapsed + "ms");
            stopLoad();
            return delay(500, function() {
              stopLoad();
              console.debug("About to try a data walk");
              return $.get(uri.urlString + "datawalk.php", "", "json").done(function(result) {
                if (result.status === true) {
                  return console.log("Completed data walk in " + result.execution_time + "ms");
                } else {
                  console.warn("Data walk executed, but failed to complete");
                  return console.warn(result);
                }
              }).fail(function(result, status) {
                return console.warn("Couldn't execute data walk", result, status);
              });
            });
          }
        });
      }
      finishedLoop = true;
    } catch (error2) {
      e = error2;
      console.warn("Couldn't do client update -- " + e.message);
      console.warn(e.stack);
    }
  } else {
    console.debug("Lagged update check unneeded.");
    stopLoad();
  }
  return false;
};

performSearch = function(stateArgs) {
  var argOption, args, filters, len1, m, ref1, s, sOrig, toggle;
  if (stateArgs == null) {
    stateArgs = void 0;
  }

  /*
   * Check the fields and filters and do the async search
   */
  if (stateArgs == null) {
    s = $("#search").val();
    sOrig = s;
    s = s.toLowerCase();
    filters = getFilters();
    if ((isNull(s) || (s == null)) && isNull(filters)) {
      $("#search-status").attr("text", "Please enter a search term.");
      $("#search-status")[0].show();
      return false;
    }
    $("#search").blur();
    s = s.replace(/\./g, "");
    s = prepURI(s);
    ref1 = $("#search_form #search-options-container .bool-search-option paper-toggle-button");
    for (m = 0, len1 = ref1.length; m < len1; m++) {
      toggle = ref1[m];
      if ($(toggle).polymerChecked()) {
        argOption = $(toggle).attr("id");
        s += "&" + argOption + "=true";
      }
    }
    if (!isNull(filters)) {
      s = s + "&filter=" + filters;
    }
    args = "q=" + s;
  } else {
    if (stateArgs === true) {
      args = "q=";
      sOrig = "(all items)";
    } else {
      args = "q=" + stateArgs;
      sOrig = stateArgs.split("&")[0];
    }
  }
  if (s === "#" || (isNull(s) && isNull(args)) || (args === "q=" && stateArgs !== true)) {
    return false;
  }
  animateLoad();
  console.log("Got search value " + s + ", hitting", searchParams.apiPath + "?" + args);
  searchParams.lastSearch = s;
  return $.get(searchParams.targetApi, args, "json").done(function(result) {
    if (toInt(result.count) === 0) {
      console.error("No search results: Got search value " + s + ", from hitting", searchParams.apiPath + "?" + args);
      showBadSearchErrorMessage.debounce(null, null, null, result);
      clearSearch(true);
      delay(500, function() {
        return stopLoadError();
      });
      return false;
    }
    if (result.status === true) {
      console.log("Server response:", result);
      $(".hanging-alert.alert-danger").remove();
      formatSearchResults(result, void 0, function() {
        return checkLaggedUpdate.debounce(1000, null, null, result);
      });
      return false;
    }
    clearSearch(true);
    $("#search-status").attr("text", result.human_error);
    $("#search-status")[0].show();
    console.error(result.error);
    console.warn(result);
    return stopLoadError();
  }).fail(function(result, error) {
    console.error("There was an error performing the search");
    console.warn(result, error, result.statusText);
    error = result.status + " - " + result.statusText;
    $("#search-status").attr("text", "Couldn't execute the search - " + error);
    $("#search-status")[0].show();
    return stopLoadError();
  }).always(function() {
    var b64s;
    b64s = Base64.encodeURI(s);
    if (s != null) {
      setHistory(uri.urlString + "#" + b64s);
    }
    return false;
  });
};

getFilters = function(selector, booleanType) {
  var encodedFilter, error2, filterList, jsonString;
  if (selector == null) {
    selector = ".cndb-filter";
  }
  if (booleanType == null) {
    booleanType = "AND";
  }

  /*
   * Look at $(selector) and apply the filters as per
   * https://github.com/tigerhawkvok/SSAR-species-database#search-flags
   * It's meant to work with Polymer dropdowns, but it'll fall back to <select><option>
   */
  filterList = new Object();
  $(selector).each(function() {
    var col, error2, val;
    col = $(this).attr("data-column");
    if (col == null) {
      return true;
    }
    try {
      val = $(this).polymerSelected();
    } catch (error2) {
      return true;
    }
    if (val === "any" || val === "all" || val === "*") {
      return true;
    }
    if (isNull(val) || val === false) {
      val = $(this).val();
      if (isNull(val)) {
        return true;
      } else {

      }
    }
    return filterList[col] = val.toLowerCase();
  });
  if (Object.size(filterList) === 0) {
    return "";
  }
  try {
    filterList["BOOLEAN_TYPE"] = booleanType;
    jsonString = JSON.stringify(filterList);
    encodedFilter = Base64.encodeURI(jsonString);
    return encodedFilter;
  } catch (error2) {
    e = error2;
    return false;
  }
};

formatSearchResults = function(result, container, callback) {
  var bootstrapColCount, colClass, data, dontShowColumns, elapsed, externalCounter, headers, htmlClose, htmlHead, renderTimeout, requiredKeyOrder, start, tableId, targetCount;
  if (container == null) {
    container = searchParams.targetContainer;
  }

  /*
   * Take a result object from the server's lookup, and format it to
   * display search results.
   *
   * By default, this will try to render the results off-thread with a
   * service worker for the best client performance, but it will fall
   * back on to an on-thread renderer if no service worker exists.
   *
   * See
   *
   * https://mammaldiversity.org/api.php?q=ursus+arctos&loose=true
   *
   * for a sample search result return.
   */
  start = Date.now();
  elapsed = 0;
  $("#result-header-container").removeAttr("hidden");
  data = result.result;
  searchParams.result = data;
  headers = new Array();
  tableId = "cndb-result-list";
  htmlHead = "<table id='" + tableId + "' class='table table-striped table-hover col-md-12'>\n\t<tr class='cndb-row-headers'>";
  htmlClose = "</table>";
  targetCount = result.count;
  if (targetCount > 150) {
    toastStatusMessage("We found " + result.count + " results, please hang on a moment while we render them...", "", 5000);
  } else {
    console.log("Not notifying of render delay, only showing " + targetCount + " items");
  }
  colClass = null;
  bootstrapColCount = 0;
  dontShowColumns = ["id", "minor_type", "notes", "major_type", "taxon_author", "taxon_credit", "image_license", "image_credit", "taxon_credit_date", "parens_auth_genus", "parens_auth_species", "is_alien", "internal_id", "source", "deprecated_scientific", "canonical_sciname", "simple_linnean_group", "iucn", "dwc", "entry", "common_name_source", "image_caption", "species_authority_citation", "genus_authority_citation", "citation", "simple_linnean_group_alt", "linnean_tribe", "linnean_subfamily"];
  externalCounter = 0;
  renderTimeout = delay(7500, function() {
    stopLoadError("There was a problem parsing the search results.");
    console.error("Couldn't finish parsing the results! Expecting " + targetCount + " elements, timed out on " + externalCounter + ".");
    console.warn(data);
    return false;
  });
  requiredKeyOrder = ["common_name", "genus", "species"];
  delay(5, function() {
    var allColsHaveData, colHasData, dataArray, i, k, key, len1, m, origData, ref1, renderDataArray, row, totalLoops, v;
    colHasData = new Array();
    for (i in data) {
      row = data[i];
      allColsHaveData = true;
      for (k in row) {
        v = row[k];
        if (indexOf.call(colHasData, k) >= 0) {
          continue;
        }
        if (isNull(v)) {
          allColsHaveData = false;
        } else {
          colHasData.push(k);
        }
      }
      if (allColsHaveData) {
        break;
      }
    }
    if (indexOf.call(colHasData, "subspecies") >= 0) {
      requiredKeyOrder.push("subspecies");
    }
    ref1 = data[0];
    for (k in ref1) {
      v = ref1[k];
      if (indexOf.call(requiredKeyOrder, k) < 0) {
        if (indexOf.call(dontShowColumns, k) < 0) {
          if (indexOf.call(colHasData, k) >= 0) {
            requiredKeyOrder.push(k);
          }
        }
      }
    }
    origData = data;
    data = new Object();
    for (i in origData) {
      row = origData[i];
      data[i] = new Object();
      for (m = 0, len1 = requiredKeyOrder.length; m < len1; m++) {
        key = requiredKeyOrder[m];
        data[i][key] = row[key];
      }
    }
    totalLoops = 0;
    dataArray = Object.toArray(data);
    return (renderDataArray = function(data, firstIteration, renderChunk) {
      var bootstrapColSize, col, d, error2, error3, error4, finalIteration, frameHtml, genus, html, htmlRow, j, kClass, len2, loopCleanup, nextIterationData, niceKey, o, postMessageContent, rowId, species, split, taxonQuery, wasOffThread, worker, year;
      html = "";
      i = 0;
      nextIterationData = null;
      wasOffThread = false;
      if (!isNumber(renderChunk)) {
        renderChunk = 100;
      }
      finalIteration = data.length <= renderChunk ? true : false;
      try {
        postMessageContent = {
          action: "render-row",
          data: data,
          chunk: renderChunk,
          firstIteration: firstIteration
        };
        worker = new Worker("js/serviceWorker.js");
        console.info("Rendering list off-thread");
        worker.addEventListener("message", function(e) {
          var usedRenderChunk;
          console.info("Got message back from service worker", e.data);
          wasOffThread = true;
          html = e.data.html;
          nextIterationData = e.data.nextChunk;
          usedRenderChunk = e.data.renderChunk;
          i = e.data.loops;
          return loopCleanup();
        });
        worker.postMessage(postMessageContent);
      } catch (error2) {
        console.log("Starting loop with i = " + i + ", renderChunk = " + renderChunk + ", data length = " + data.length, firstIteration, finalIteration);
        for (o = 0, len2 = data.length; o < len2; o++) {
          row = data[o];
          ++totalLoops;
          externalCounter = i;
          if (toInt(i) === 0 && firstIteration) {
            j = 0;
            htmlHead += "\n<!-- Table Headers - " + (Object.size(row)) + " entries -->";
            for (k in row) {
              v = row[k];
              ++totalLoops;
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
            frameHtml = htmlHead + htmlClose;
            html = htmlHead;
            $(container).html(frameHtml);
          }
          taxonQuery = row.genus + "+" + row.species;
          if (!isNull(row.subspecies)) {
            taxonQuery = taxonQuery + "+" + row.subspecies;
          }
          rowId = "msadb-row" + i;
          htmlRow = "\n\t<tr id='" + rowId + "' class='cndb-result-entry' data-taxon=\"" + taxonQuery + "\" data-genus=\"" + row.genus + "\" data-species=\"" + row.species + "\">";
          for (k in row) {
            col = row[k];
            ++totalLoops;
            if (k === "authority_year") {
              if (!isNull(col)) {
                try {
                  d = JSON.parse(col);
                } catch (error3) {
                  e = error3;
                  try {
                    console.warn("There was an error parsing authority_year='" + col + "', attempting to fix - ", e.message);
                    split = col.split(":");
                    year = split[1].slice(split[1].search("\"") + 1, -2);
                    year = year.replace(/"/g, "'");
                    split[1] = "\"" + year + "\"}";
                    col = split.join(":");
                    d = JSON.parse(col);
                  } catch (error4) {
                    e = error4;
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
        loopCleanup();
      }
      return loopCleanup = function() {
        var delayInterval, noticeHtml;
        if (firstIteration) {
          html += htmlClose;
          $(container).html(html);
          $("#result-count").text(" - " + result.count + " entries");
          if (result.method === "space_common_fallback" && !$("#space-fallback-info").exists()) {
            noticeHtml = "<div id=\"space-fallback-info\" class=\"alert alert-info alert-dismissible center-block fade in\" role=\"alert\">\n  <button type=\"button\" class=\"close\" data-dismiss=\"alert\" aria-label=\"Close\"><span aria-hidden=\"true\">&times;</span></button>\n  <strong>Don't see what you want?</strong> We might use a slightly different name. Try <a href=\"\" class=\"alert-link\" id=\"do-instant-fuzzy\">checking the \"fuzzy\" toggle and searching again</a>, or use a shorter search term.\n</div>";
            $("#result_container").before(noticeHtml);
            $("#do-instant-fuzzy").click(function(e) {
              var doBatch;
              e.preventDefault();
              doBatch = function() {
                $("#fuzzy").get(0).checked = true;
                return performSearch();
              };
              return doBatch.debounce();
            });
          } else if ($("#space-fallback-info").exists()) {
            $("#space-fallback-info").prop("hidden", true);
          }
        } else {
          $("table#" + tableId + " tbody").append(html);
        }
        if (!finalIteration) {
          elapsed = Date.now() - start;
          if (nextIterationData == null) {
            nextIterationData = data.slice(i);
          }
          console.log("Chunk rendered at " + elapsed + "ms, next bit with slice @ " + i + ":", nextIterationData);
          if (nextIterationData.length !== 0) {
            delayInterval = wasOffThread ? 25 : 250;
            delay(delayInterval, function() {
              return renderDataArray(nextIterationData, false, renderChunk);
            });
          } else {
            finalIteration = true;
          }
        }
        if (finalIteration) {
          elapsed = Date.now() - start;
          console.log("Finished rendering list in " + elapsed + "ms");
          console.debug("Executed " + totalLoops + " loops");
          if (elapsed > 3000 && !wasOffThread) {
            console.warn("Warning: Took greater than 3 seconds to render!");
          }
          stopLoad();
          delay(250, function() {
            return stopLoad();
          });
          if (typeof callback === "function") {
            try {
              callback();
            } catch (undefined) {}
          }
        }
        clearTimeout(renderTimeout);
        mapNewWindows();
        lightboxImages();
        $(".cndb-result-entry").unbind().click(function() {
          var accountArgs;
          accountArgs = "genus=" + ($(this).attr("data-genus")) + "&species=" + ($(this).attr("data-species"));
          return goTo("species-account.php?" + accountArgs);
        });
        return doFontExceptions();
      };
    })(dataArray, true, 100);
  });
  return false;
};

parseTaxonYear = function(taxonYearString, strict) {
  var d, error2, error3, error4, genus, species, split, year;
  if (strict == null) {
    strict = true;
  }

  /*
   * Take the (theoretically nicely JSON-encoded) taxon year/authority
   * string and turn it into a canonical object for the modal dialog to use
   */
  try {
    d = JSON.parse(taxonYearString);
  } catch (error2) {
    e = error2;
    console.warn("There was an error parsing '" + taxonYearString + "', attempting to fix - ", e.message);
    try {
      split = taxonYearString.split(":");
      year = split[1].slice(split[1].search('"') + 1, -2);
      year = year.replace(/"/g, "'");
      split[1] = "\"" + year + "\"}";
      taxonYearString = split.join(":");
      try {
        d = JSON.parse(taxonYearString);
      } catch (error3) {
        e = error3;
        if (strict) {
          return false;
        } else {
          return taxonYearString;
        }
      }
    } catch (error4) {
      e = error4;
      if (strict) {
        return false;
      } else {
        return taxonYearString;
      }
    }
  }
  genus = Object.keys(d)[0];
  species = d[genus];
  year = new Object();
  year.genus = genus;
  year.species = species;
  return year;
};

checkTaxonNear = function(taxonQuery, callback, selector) {
  var apiUrl, args, cssClass, elapsed, geoIcon, tooltipHint;
  if (taxonQuery == null) {
    taxonQuery = void 0;
  }
  if (callback == null) {
    callback = void 0;
  }
  if (selector == null) {
    selector = "#near-me-container";
  }

  /*
   * Check the iNaturalist API to see if the taxon is in your county
   * See https://github.com/tigerhawkvok/SSAR-species-database/issues/7
   */
  if (taxonQuery == null) {
    console.warn("Please specify a taxon.");
    return false;
  }
  if (locationData.last == null) {
    getLocation();
  }
  elapsed = (Date.now() - locationData.last) / 1000;
  if (elapsed > 15 * 60) {
    getLocation();
  }
  apiUrl = "https://www.inaturalist.org/places.json";
  args = "taxon=" + taxonQuery + "&latitude=" + locationData.lat + "&longitude=" + locationData.lng + "&place_type=county";
  geoIcon = "";
  cssClass = "";
  tooltipHint = "";
  $.get(apiUrl, args, "json").done(function(result) {
    if (Object.size(result) > 0) {
      geoIcon = "communication:location-on";
      cssClass = "good-location";
      return tooltipHint = "This species occurs in your county";
    } else {
      geoIcon = "communication:location-off";
      cssClass = "bad-location";
      return tooltipHint = "This species does not occur in your county";
    }
  }).fail(function(result, status) {
    cssClass = "bad-location";
    geoIcon = "warning";
    return tooltipHint = "We couldn't determine your location";
  }).always(function() {
    var tooltipHtml;
    tooltipHtml = "<div class=\"tooltip fade top in right manual-placement-tooltip\" role=\"tooltip\" style=\"top: 6.5em; left: 4em; right:initial; display:none\" id=\"manual-location-tooltip\">\n  <div class=\"tooltip-arrow\" style=\"top:50%;left:5px\"></div>\n  <div class=\"tooltip-inner\">" + tooltipHint + "</div>\n</div>";
    d$(selector).html("<iron-icon icon='" + geoIcon + "' class='small-icon " + cssClass + " near-me' data-toggle='tooltip' id='near-me-icon'></iron-icon>");
    $(selector).after(tooltipHtml).mouseenter(function() {
      d$("#manual-location-tooltip").css("display", "block");
      return false;
    }).mouseleave(function() {
      d$("#manual-location-tooltip").css("display", "none");
      return false;
    });
    if (callback != null) {
      return callback();
    }
  });
  return false;
};

insertModalImage = function(imageObject, taxon, callback) {
  var args, doneCORS, error2, extension, failCORS, imageUrl, imgArray, imgPath, insertImage, taxonArray, taxonString, warnArgs;
  if (imageObject == null) {
    imageObject = _asm.taxonImage;
  }
  if (taxon == null) {
    taxon = _asm.activeTaxon;
  }
  if (callback == null) {
    callback = void 0;
  }

  /*
   * Insert into the taxon modal a lightboxable photo. If none exists,
   * load from CalPhotos
   *
   * CalPhotos functionality blocked on
   * https://github.com/tigerhawkvok/SSAR-species-database/issues/30
   */
  if (taxon == null) {
    console.error("Tried to insert a modal image, but no taxon was provided!");
    return false;
  }
  if (typeof taxon !== "object") {
    console.error("Invalid taxon data type (expecting object), got " + (typeof taxon));
    warnArgs = {
      taxon: taxon,
      imageUrl: imageUrl,
      defaultTaxon: _asm.activeTaxon,
      defaultImage: _asm.taxonImage
    };
    console.warn(warnArgs);
    return false;
  }
  insertImage = function(image, taxonQueryString, classPrefix) {
    var error2, html, imgCredit, imgLicense, largeImg, largeImgLink, smartFit, thumbnail;
    if (classPrefix == null) {
      classPrefix = "calphoto";
    }

    /*
     * Insert a lightboxed image into the modal taxon dialog. This must
     * be shadow-piercing, since the modal dialog is a
     * paper-dialog.
     *
     * @param image an object with parameters [thumbUri, imageUri,
     *   imageLicense, imageCredit], and optionally imageLinkUri
     */
    thumbnail = image.thumbUri;
    largeImg = image.imageUri;
    largeImgLink = typeof image.imageLinkUri === "function" ? image.imageLinkUri(image.imageUri) : void 0;
    imgLicense = image.imageLicense;
    imgCredit = image.imageCredit;
    html = "<div class=\"modal-img-container\">\n  <a href=\"" + largeImg + "\" class=\"" + classPrefix + "-img-anchor center-block text-center\">\n    <img src=\"" + thumbnail + "\"\n      data-href=\"" + largeImgLink + "\"\n      class=\"" + classPrefix + "-img-thumb\"\n      data-taxon=\"" + taxonQueryString + "\" />\n  </a>\n  <p class=\"small text-muted text-center\">\n    Image by " + imgCredit + " under " + imgLicense + "\n  </p>\n</div>";
    d$("#meta-taxon-info").before(html);
    (smartFit = function(iteration) {
      var error2;
      try {
        d$("#modal-taxon").get(0).fit();
        return delay(250, function() {
          d$("#modal-taxon").get(0).fit();
          return delay(750, function() {
            return d$("#modal-taxon").get(0).fit();
          });
        });
      } catch (error2) {
        e = error2;
        if (iteration < 10) {
          iteration++;
          return delay(100, function() {
            return smartFit(iteration);
          });
        } else {
          return console.warn("Couldn't execute fit!");
        }
      }
    })(0);
    try {
      lightboxImages("." + classPrefix + "-img-anchor", true);
    } catch (error2) {
      e = error2;
      console.error("Error lightboxing images");
    }
    if (typeof callback === "function") {
      callback();
    }
    return false;
  };
  taxonArray = [taxon.genus, taxon.species];
  if (taxon.subspecies != null) {
    taxonArray.push(taxon.subspecies);
  }
  taxonString = taxonArray.join("+");
  if (imageObject.imageUri != null) {
    if (typeof imageObject === "string") {
      imageUrl = imageObject;
      imageObject = new Object();
      imageObject.imageUri = imageUrl;
    }
    imgArray = imageObject.imageUri.split(".");
    extension = imgArray.pop();
    imgPath = imgArray.join(".");
    imageObject.thumbUri = "" + uri.urlString + imgPath + "-thumb." + extension;
    imageObject.imageUri = "" + uri.urlString + imgPath + "." + extension;
    insertImage(imageObject, taxonString, "asmimg");
    return false;
  }

  /*
   * OK, we don't have it, do CalPhotos
   *
   * Hit targets of form
   * http://calphotos.berkeley.edu/cgi-bin/img_query?getthumbinfo=1&num=all&taxon=Acris+crepitans&format=xml
   *
   * See
   * http://calphotos.berkeley.edu/thumblink.html
   * for API reference.
   */
  args = "getthumbinfo=1&num=all&cconly=1&taxon=" + taxonString + "&format=xml";
  doneCORS = function(resultXml) {
    var data, error2, error3, result;
    result = xmlToJSON.parseString(resultXml);
    window.testData = result;
    try {
      data = result.calphotos[0];
    } catch (error2) {
      e = error2;
      data = void 0;
    }
    if (data == null) {
      return false;
    }
    imageObject = new Object();
    try {
      imageObject.thumbUri = data.thumb_url[0]["_text"];
      if (imageObject.thumbUri == null) {
        console.warn("CalPhotos didn't return any valid images for this search!");
        return false;
      }
      imageObject.imageUri = data.enlarge_jpeg_url[0]["_text"];
      imageObject.imageLinkUri = data.enlarge_url[0]["_text"];
      imageObject.imageLicense = data.license[0]["_text"];
      imageObject.imageCredit = data.copyright[0]["_text"] + " (via CalPhotos)";
    } catch (error3) {
      e = error3;
      console.warn("CalPhotos didn't return any valid images for this search!", _asm.affiliateQueryUrl.calPhotos + "?" + args);
      return false;
    }
    insertImage(imageObject, taxonString);
    return false;
  };
  failCORS = function(result, status) {
    insertCORSWorkaround();
    console.error("Couldn't load a CalPhotos image to insert!");
    return false;
  };
  try {
    doCORSget(_asm.affiliateQueryUrl.calPhotos, args, doneCORS, failCORS);
  } catch (error2) {
    e = error2;
    console.error(e.message);
  }
  return false;
};

modalTaxon = function(taxon) {
  var html;
  if (taxon == null) {
    taxon = void 0;
  }

  /*
   * Pop up the modal taxon dialog for a given species
   */
  if (taxon == null) {
    $(".cndb-result-entry").click(function() {
      return modalTaxon($(this).attr("data-taxon"));
    });
    return false;
  }
  animateLoad();
  if (!$("#modal-taxon").exists()) {
    html = "<paper-dialog modal id='modal-taxon' entry-animation=\"scale-up-animation\" exit-animation=\"scale-down-animation\">\n  <h2 id=\"modal-heading\"></h2>\n  <paper-dialog-scrollable id='modal-taxon-content'></paper-dialog-scrollable>\n  <div class=\"buttons\">\n    <paper-button id='modal-inat-linkout'>iNaturalist</paper-button>\n    <paper-button id='modal-calphotos-linkout' class=\"hidden-xs\">CalPhotos</paper-button>\n    <paper-button id='modal-alt-linkout' class=\"hidden-xs\"></paper-button>\n    <paper-button dialog-dismiss autofocus>Close</paper-button>\n  </div>\n</paper-dialog>";
    $("body").append(html);
  }
  $.get(searchParams.targetApi, "q=" + taxon, "json").done(function(result) {
    var buttonText, commonType, data, deprecatedHtml, error2, error3, error4, genusAuthBlock, humanTaxon, i, minorTypeHtml, notes, outboundLink, sn, speciesAuthBlock, taxonArray, taxonCreditDate, year, yearHtml;
    data = result.result[0];
    if (data == null) {
      toastStatusMessage("There was an error fetching the entry details. Please try again later.");
      stopLoadError();
      return false;
    }
    year = parseTaxonYear(data.authority_year);
    yearHtml = "";
    if (year !== false) {
      genusAuthBlock = "<span class='genus_authority authority'>" + data.genus_authority + "</span> " + year.genus;
      speciesAuthBlock = "<span class='species_authority authority'>" + data.species_authority + "</span> " + year.species;
      if (toInt(data.parens_auth_genus).toBool()) {
        genusAuthBlock = "(" + genusAuthBlock + ")";
      }
      if (toInt(data.parens_auth_species).toBool()) {
        speciesAuthBlock = "(" + speciesAuthBlock + ")";
      }
      yearHtml = "<div id=\"is-alien-container\" class=\"tooltip-container\"></div>\n<div id='near-me-container' data-toggle='tooltip' data-placement='top' title='' class='near-me tooltip-container'></div>\n<p>\n  <span class='genus'>" + data.genus + "</span>,\n  " + genusAuthBlock + ";\n  <span class='species'>" + data.species + "</span>,\n  " + speciesAuthBlock + "\n</p>";
    }
    deprecatedHtml = "";
    if (!isNull(data.deprecated_scientific)) {
      deprecatedHtml = "<p>Deprecated names: ";
      try {
        sn = JSON.parse(data.deprecated_scientific);
        i = 0;
        $.each(sn, function(scientific, authority) {
          i++;
          if (i !== 1) {
            deprecatedHtml += "; ";
          }
          deprecatedHtml += "<span class='sciname'>" + scientific + "</span>, " + authority;
          if (i === Object.size(sn)) {
            return deprecatedHtml += "</p>";
          }
        });
      } catch (error2) {
        e = error2;
        deprecatedHtml = "";
        console.error("There were deprecated scientific names, but the JSON was malformed.");
      }
    }
    minorTypeHtml = "";
    if (!isNull(data.minor_type)) {
      minorTypeHtml = " <iron-icon icon='arrow-forward'></iron-icon> <span id='taxon-minor-type'>" + data.minor_type + "</span>";
    }
    if (isNull(data.notes)) {
      data.notes = "Sorry, we have no notes on this taxon yet.";
      data.taxon_credit = "";
    } else {
      if (isNull(data.taxon_credit) || data.taxon_credit === "null") {
        data.taxon_credit = "This taxon information is uncredited.";
      } else {
        taxonCreditDate = isNull(data.taxon_credit_date) || data.taxon_credit_date === "null" ? "" : " (" + data.taxon_credit_date + ")";
        data.taxon_credit = "Taxon information by " + data.taxon_credit + "." + taxonCreditDate;
      }
    }
    try {
      notes = markdown.toHTML(data.notes);
    } catch (error3) {
      e = error3;
      notes = data.notes;
      console.warn("Couldn't parse markdown!! " + e.message);
    }
    notes = notes.replace(/\&amp;(([a-z]+|[0-9]+);)/mg, "&$1");
    commonType = !isNull(data.major_common_type) ? " (<span id='taxon-common-type'>" + data.major_common_type + "</span>) " : "";
    html = "<div id='meta-taxon-info'>\n  " + yearHtml + "\n  <p>\n    English name: <span id='taxon-common-name' class='common_name no-cap'>" + (smartUpperCasing(data.common_name)) + "</span>\n  </p>\n  <p>\n    Type: <span id='taxon-type' class=\"major_type\">" + data.major_type + "</span>\n    " + commonType + "\n    <iron-icon icon='arrow-forward'></iron-icon>\n    <span id='taxon-subtype' class=\"major_subtype\">" + data.major_subtype + "</span>" + minorTypeHtml + "\n  </p>\n  " + deprecatedHtml + "\n</div>\n<h3>Taxon Notes</h3>\n<p id='taxon-notes'>" + notes + "</p>\n<p class=\"text-right small text-muted\">" + data.taxon_credit + "</p>";
    $("#modal-taxon-content").html(html);
    $("#modal-inat-linkout").unbind().click(function() {
      return openTab(_asm.affiliateQueryUrl.iNaturalist + "?q=" + taxon);
    });
    $("#modal-calphotos-linkout").unbind().click(function() {
      return openTab(_asm.affiliateQueryUrl.calPhotos + "?rel-taxon=contains&where-taxon=" + taxon);
    });
    outboundLink = null;
    buttonText = null;
    taxonArray = taxon.split("+");
    _asm.activeTaxon = {
      genus: taxonArray[0],
      species: taxonArray[1],
      subspecies: taxonArray[2]
    };
    if (outboundLink != null) {
      $("#modal-alt-linkout").replaceWith(button);
      $("#modal-alt-linkout").click(function() {
        return openTab(outboundLink);
      });
    } else {
      $("#modal-alt-linkout").addClass("hidden").unbind();
    }
    formatScientificNames();
    doFontExceptions();
    humanTaxon = taxon.charAt(0).toUpperCase() + taxon.slice(1);
    humanTaxon = humanTaxon.replace(/\+/g, " ");
    d$("#modal-heading").text(humanTaxon);
    if (isNull(data.image)) {
      data.image = void 0;
    }
    _asm.taxonImage = {
      imageUri: data.image,
      imageCredit: data.image_credit,
      imageLicense: data.image_license
    };
    try {
      insertModalImage();
    } catch (error4) {
      e = error4;
      console.info("Unable to insert modal image! ");
    }
    checkTaxonNear(taxon, function() {
      var modalElement;
      stopLoad();
      modalElement = d$("#modal-taxon")[0];
      d$("#modal-taxon").on("iron-overlay-opened", function() {
        modalElement.fit();
        modalElement.scrollTop = 0;
        if (toFloat($(modalElement).css("top").slice(0, -2)) > $(window).height()) {
          $(modalElement).css("top", "12.5vh");
        }
        return delay(250, function() {
          return modalElement.fit();
        });
      });
      modalElement.sizingTarget = d$("#modal-taxon-content")[0];
      return safariDialogHelper("#modal-taxon");
    });
    return bindDismissalRemoval();
  }).fail(function(result, status) {
    return stopLoadError();
  });
  return false;
};

bindDismissalRemoval = function() {
  return $("[dialog-dismiss]").unbind().click(function() {
    return $(this).parents("paper-dialog").remove();
  });
};

doFontExceptions = function() {

  /*
   * Look for certain keywords to force into capitalized, or force
   * uncapitalized, overriding display CSS rules
   */
  var alwaysLowerCase, forceSpecialToLower;
  alwaysLowerCase = ["de", "and"];
  forceSpecialToLower = function(authorityText) {
    $.each(alwaysLowerCase, function(i, word) {
      var search;
      search = " " + word + " ";
      if (authorityText != null) {
        return authorityText = authorityText.replace(search, " <span class='force-lower'>" + word + "</span> ");
      }
    });
    return authorityText;
  };
  d$(".authority").each(function() {
    var authorityText;
    authorityText = $(this).text();
    if (!isNull(authorityText)) {
      return $(this).html(forceSpecialToLower(authorityText));
    }
  });
  return false;
};

sortResults = function(by_column) {
  var data;
  return data = searchParams.result;
};

setHistory = function(url, state, title) {
  if (url == null) {
    url = "#";
  }
  if (state == null) {
    state = null;
  }
  if (title == null) {
    title = null;
  }

  /*
   * Set up the history to provide something linkable
   */
  history.pushState(state, title, url);
  uri.query = $.url(url).attr("fragment");
  return false;
};

clearSearch = function(partialReset) {
  var calloutHtml;
  if (partialReset == null) {
    partialReset = false;
  }

  /*
   * Clear out the search and reset it to a "fresh" state.
   */
  $("#result-count").text("");
  calloutHtml = "<div class=\"alert alert-info center-block col-xs-12 col-sm-8 col-md-5\">\n  Search for a common or scientific name above to begin, eg, \"Brown Bear\" or \"<span class=\"sciname\">Ursus arctos</span>\"\n</div>";
  $("#result_container").html(calloutHtml);
  $("#result-header-container").attr("hidden", "hidden");
  $(".hanging-alert.alert-danger").remove();
  if (partialReset === true) {
    return false;
  }
  setHistory();
  $(".cndb-filter").attr("value", "");
  $("#collapse-advanced").collapse('hide');
  $("#search").attr("value", "");
  $("#linnean").polymerSelected("any");
  formatScientificNames();
  return false;
};

safariDialogHelper = function(selector, counter, callback) {
  var delayTimer, error2, error3, newCount;
  if (selector == null) {
    selector = "#download-chooser";
  }
  if (counter == null) {
    counter = 0;
  }

  /*
   * Help Safari display paper-dialogs
   */
  if (typeof callback !== "function") {
    callback = function() {
      return bindDismissalRemoval();
    };
  }
  if (counter < 10) {
    try {
      try {
        p$(selector).open();
      } catch (error2) {
        d$(selector).get(0).open();
      }
      if (typeof callback === "function") {
        callback();
      }
      return stopLoad();
    } catch (error3) {
      e = error3;
      newCount = counter + 1;
      delayTimer = 250;
      return delay(delayTimer, function() {
        console.warn("Trying again to display dialog after " + (newCount * delayTimer) + "ms");
        console.debug("Error caught: " + e.message);
        console.debug(e.stack);
        return safariDialogHelper(selector, newCount, callback);
      });
    }
  } else {
    return stopLoadError("Unable to show dialog. Please try again.");
  }
};

safariSearchArgHelper = function(value, didLateRecheck) {
  var searchArg, trimmed;
  if (didLateRecheck == null) {
    didLateRecheck = false;
  }

  /*
   * If the search argument has a "+" in it, remove it
   * Then write the arg to search.
   *
   * Since Safari doesn't "take" it all the time, keep trying till it does.
   */
  if (value != null) {
    searchArg = value;
  } else {
    searchArg = $("#search").val();
  }
  trimmed = false;
  if (searchArg.search(/\+/) !== -1) {
    trimmed = true;
    searchArg = searchArg.replace(/\+/g, " ").trim();
    delay(100, function() {
      return safariSearchArgHelper();
    });
  }
  if (trimmed || (value != null)) {
    $("#search").attr("value", searchArg);
    if (!didLateRecheck) {
      delay(5000, function() {
        return safariSearchArgHelper(void 0, true);
      });
    }
  }
  return false;
};

insertCORSWorkaround = function() {
  var browserExtensionLink, browsers, error2, html;
  if (_asm.hasShownWorkaround == null) {
    _asm.hasShownWorkaround = false;
  }
  if (_asm.hasShownWorkaround) {
    return false;
  }
  try {
    browsers = new WhichBrowser();
  } catch (error2) {
    e = error2;
    return false;
  }
  if (browsers.isType("mobile")) {
    _asm.hasShownWorkaround = true;
    return false;
  }
  browserExtensionLink = (function() {
    switch (browsers.browser.name) {
      case "Chrome":
        return "Install the extension \"<a class='alert-link' href='https://chrome.google.com/webstore/detail/allow-control-allow-origi/nlfbmbojpeacfghkpbjhddihlkkiljbi?utm_source=chrome-app-launcher-info-dialog'>Allow-Control-Allow-Origin: *</a>\", activate it on this domain, and you'll see them in your popups!";
      case "Firefox":
        return "Follow the instructions <a class='alert-link' href='http://www-jo.se/f.pfleger/forcecors-workaround'>for this ForceCORS add-on</a>, or try Chrome for a simpler extension. Once you've done so, you'll see photos in your popups!";
      case "Internet Explorer":
        return "Follow these <a class='alert-link' href='http://stackoverflow.com/a/20947828'>StackOverflow instructions</a> while on this site, and you'll see them in your popups!";
      default:
        return "";
    }
  })();
  html = "<div class=\"alert alert-info alert-dismissible center-block fade in\" role=\"alert\">\n  <button type=\"button\" class=\"close\" data-dismiss=\"alert\" aria-label=\"Close\"><span aria-hidden=\"true\">&times;</span></button>\n  <strong>Want CalPhotos images in your species dialogs?</strong> " + browserExtensionLink + "\n  We're working with CalPhotos to enable this natively, but it's a server change on their side.\n</div>";
  $("#result_container").before(html);
  $(".alert").alert();
  _asm.hasShownWorkaround = true;
  return false;
};

showBadSearchErrorMessage = function(result) {
  var alertText, error2, error3, filterText, i, sOrig, text;
  try {
    sOrig = result.query.replace(/\+/g, " ");
  } catch (error2) {
    sOrig = $("#search").val();
  }
  try {
    if (result.status === true) {
      if (result.query_params.filter.had_filter === true) {
        filterText = "";
        i = 0;
        $.each(result.query_params.filter.filter_params, function(col, val) {
          if (col !== "BOOLEAN_TYPE") {
            if (i !== 0) {
              filterText = filter_text + " " + result.filter.filter_params.BOOLEAN_TYPE;
            }
            if (isNumber(toInt(val, true))) {
              val = toInt(val) === 1 ? "true" : "false";
            }
            return filterText = filterText + " " + (col.replace(/_/g, " ")) + " is " + val;
          }
        });
        text = "\"" + sOrig + "\" where " + filterText + " returned no results.";
      } else {
        text = "\"" + sOrig + "\" returned no results.";
      }
    } else {
      text = result.human_error;
    }
  } catch (error3) {
    text = "Sorry, there was a problem with your search";
  }
  try {
    if (text.search(/no results/) >= 0) {
      alertText = "<code>ZERO_RESULTS</code><strong>:</strong> " + text;
      bsAlert(alertText, "danger");
      text = "Sorry, your search returned no results";
    }
  } catch (undefined) {}
  return stopLoadError(text);
};

bindPaperMenuButton = function(selector, unbindTargets) {
  var dropdown, len1, m, menu, ref1, relabelSelectedItem;
  if (selector == null) {
    selector = "paper-menu-button";
  }
  if (unbindTargets == null) {
    unbindTargets = true;
  }

  /*
   * Use a paper-menu-button and make the
   * .dropdown-label gain the selected value
   *
   * Reference:
   * https://github.com/polymerelements/paper-menu-button
   * https://elements.polymer-project.org/elements/paper-menu-button
   */
  return false;
  ref1 = $(selector);
  for (m = 0, len1 = ref1.length; m < len1; m++) {
    dropdown = ref1[m];
    menu = $(dropdown).find("paper-menu");
    if (unbindTargets) {
      $(menu).unbind();
    }
    (relabelSelectedItem = function(target, activeDropdown) {
      var labelSpan, selectText;
      selectText = $(target).polymerSelected(null, true);
      labelSpan = $(activeDropdown).find(".dropdown-label");
      $(labelSpan).text(selectText);
      return $(target).polymerSelected();
    })(menu, dropdown);
    $(menu).on("iron-select", function() {
      return relabelSelectedItem(this, dropdown);
    });
  }
  return false;
};

getRandomEntry = function() {

  /*
   * Get a random taxon, and go to that page
   */
  var args;
  startLoad();
  args = {
    random: true,
    require_image: true
  };
  $.get(searchParams.apiPath, buildQuery(args, "json")).done(function(result) {
    var accountQuery, dest;
    if (isNull(result.genus) || isNull(result.species)) {
      stopLoadError("Unable to fetch random entry");
    }
    accountQuery = {
      genus: result.genus,
      species: result.species
    };
    if (!isNull(result.subspecies)) {
      accountQuery.subspecies = result.subspecies;
    }
    dest = uri.urlString + "species-account.php?" + (buildQuery(accountQuery));
    console.log("About to go to", dest);
    goTo(dest);
    return stopLoad();
  }).fail(function() {
    return stopLoadError("Unable to fetch random entry");
  });
  return false;
};

window.getRandomEntry = getRandomEntry;

doLazily = function() {

  /*
   * Load these assets lazily, but only once
   */
  if ((typeof _asm !== "undefined" && _asm !== null ? _asm.hasDoneLazily : void 0) !== true) {
    if (typeof _asm !== "object") {
      window._asm = new Object();
    }
    _asm.hasDoneLazily = true;
    loadJS(uri.urlString + "js/download.min.js", function() {
      var html;
      html = "<paper-icon-button\n  icon=\"icons:cloud-download\"\n  class=\"click\"\n  data-fn=\"showDownloadChooser\"\n  title=\"Download Copy\"\n  data-toggle=\"tooltip\"\n  >\n</paper-icon-button>";
      $("#git-footer").prepend(html);
      bindClicks();
      mobileCollapsable();
      loadJS(uri.urlString + "js/terminal.min.js", function() {
        bindClicks();
        console.debug("Terminal file loaded");
        return stopLoad();
      });
      return false;
    });
    if ($("paper-card.featured-mammal").exists()) {
      $("paper-card.featured-mammal").click(function() {
        var id, path;
        id = $(this).attr("data-taxon-id");
        path = "species-account/id=" + id;
        goTo(path);
        return false;
      });
    }
  }
  return false;
};

mobileCollapsable = function(selector, breakpoint, debounceInterval) {
  var clearDebounce, hasDoneInitialCollapse, ref1;
  if (selector == null) {
    selector = ".search-options-panel";
  }
  if (breakpoint == null) {
    breakpoint = (ref1 = typeof _asm !== "undefined" && _asm !== null ? _asm.mobileBreakpoint : void 0) != null ? ref1 : 767;
  }
  if (debounceInterval == null) {
    debounceInterval = 250;
  }

  /*
   * Collapse all sections inside of selector, using the legend as a trigger
   */
  console.debug("Checking mobile status");
  if ($(window).width() <= breakpoint) {
    if (typeof (typeof core !== "undefined" && core !== null ? core.debouncers : void 0) !== "object") {
      if (typeof core !== "object") {
        window.core = new Object();
      }
      core.debouncers = new Object();
    }
    if (core.debouncers.mobileCollapsable != null) {
      if (Date.now() - core.debouncers.mobileCollapsable <= debounceInterval) {
        return false;
      }
      delete core.debouncers.mobileCollapsable;
      clearTimeout(core.debouncers.mobileCollapseableTimeout);
    }
    core.debouncers.mobileCollapsable = Date.now();
    clearDebounce = 2 * debounceInterval;
    core.debouncers.mobileCollapseableTimeout = delay(clearDebounce, function() {
      return delete core.debouncers.mobileCollapsable;
    });
    $(selector).find("section").collapse();
    hasDoneInitialCollapse = false;
    $($(selector).find("section").get(0)).on("shown.bs.collapse", function() {
      if (!hasDoneInitialCollapse) {
        delay(50, function() {
          var len1, m, ref2, results, section;
          ref2 = $(selector).find("section");
          results = [];
          for (m = 0, len1 = ref2.length; m < len1; m++) {
            section = ref2[m];
            results.push($(section).collapse("hide"));
          }
          return results;
        });
        hasDoneInitialCollapse = true;
      }
      return false;
    });
    $(selector).find("legend").text("Show Options").addClass("btn btn-default").click(function() {
      var isCollapsed;
      isCollapsed = !$(selector).find("section").hasClass("in");
      if (isCollapsed) {
        $(this).text("Hide Options");
        return $(selector).find("section").collapse("show");
      } else {
        $(this).text("Show Options");
        return $(selector).find("section").collapse("hide");
      }
    });
    return true;
  } else {
    console.debug("Not a mobile viewport");
    return false;
  }
};

$(function() {
  var col, devHello, error2, error3, error4, error5, f64, filterObj, fixState, fuzzyState, ignorePages, loadArgs, looseState, openFilters, queryUrl, ref1, selector, setupPolymerReady, simpleAllowedFilters, temp, val;
  devHello = "****************************************************************************\nHello developer!\nIf you're looking for hints on our API information, this site is open-source\nand released under the GPL. Just click on the GitHub link on the bottom of\nthe page, or check out LINK_TO_ORG_REPO\n****************************************************************************";
  console.log(devHello);
  _asm.polymerReady = false;
  ignorePages = ["admin-login.php", "admin-page.html", "admin-page.php"];
  if (ref1 = uri.o.attr("file"), indexOf.call(ignorePages, ref1) >= 0) {
    try {
      (setupPolymerReady = function() {
        var error2, ref2;
        try {
          if ((typeof Polymer !== "undefined" && Polymer !== null ? (ref2 = Polymer.Base) != null ? ref2.$$ : void 0 : void 0) != null) {
            Polymer.Base.ready(function() {
              return _asm.polymerReady = true;
            });
            return delay(250, function() {
              return _asm.polymerReady = true;
            });
          } else {
            throw {
              message: "POLYMER_NOT_READY"
            };
          }
        } catch (error2) {
          return delay(100, function() {
            return setupPolymerReady;
          });
        }
      })();
    } catch (undefined) {}
    return false;
  }
  animateLoad();
  window.addEventListener("popstate", function(e) {
    var error2, loadArgs, temp;
    uri.query = $.url().attr("fragment");
    try {
      loadArgs = Base64.decode(uri.query);
    } catch (error2) {
      e = error2;
      loadArgs = "";
    }
    performSearch.debounce(50, null, null, loadArgs);
    temp = loadArgs.split("&")[0];
    return $("#search").attr("value", temp);
  });
  $("#do-reset-search").click(function() {
    return clearSearch();
  });
  $("#search_form").submit(function(e) {
    e.preventDefault();
    return performSearch.debounce(50);
  });
  $("#collapse-advanced").on("shown.bs.collapse", function() {
    $("#collapse-icon").attr("icon", "icons:unfold-less");
    p$("#global_search").checked = false;
    return false;
  });
  $("#collapse-advanced").on("hidden.bs.collapse", function() {
    return $("#collapse-icon").attr("icon", "icons:unfold-more");
  });
  $("#search_form").keypress(function(e) {
    if (e.which === 13) {
      return performSearch.debounce(50);
    }
  });
  $("#do-search").click(function() {
    return performSearch.debounce(50);
  });
  $("#do-search-all").click(function() {
    return performSearch.debounce(50, null, null, true);
  });
  $("#linnean").on("iron-select", function() {
    if (!isNull($("#search").val())) {
      return performSearch.debounce();
    }
  });
  eutheriaFilterHelper();
  bindPaperMenuButton();
  if (isNull(uri.query)) {
    loadArgs = "";
    try {
      (setupPolymerReady = function() {
        var error2, ref2;
        try {
          if ((typeof Polymer !== "undefined" && Polymer !== null ? (ref2 = Polymer.Base) != null ? ref2.$$ : void 0 : void 0) != null) {
            Polymer.Base.ready(function() {
              return _asm.polymerReady = true;
            });
            return delay(250, function() {
              return _asm.polymerReady = true;
            });
          } else {
            throw {
              message: "POLYMER_NOT_READY"
            };
          }
        } catch (error2) {
          return delay(100, function() {
            return setupPolymerReady;
          });
        }
      })();
    } catch (undefined) {}
  } else {
    try {
      loadArgs = Base64.decode(uri.query);
      queryUrl = $.url(searchParams.apiPath + "?q=" + loadArgs);
      try {
        looseState = queryUrl.param("loose").toBool();
      } catch (error2) {
        e = error2;
        looseState = false;
      }
      try {
        fuzzyState = queryUrl.param("fuzzy").toBool();
      } catch (error3) {
        e = error3;
        fuzzyState = false;
      }
      temp = loadArgs.split("&")[0];
      safariSearchArgHelper(temp);
      (fixState = function() {
        var error4, ref2;
        if ((typeof Polymer !== "undefined" && Polymer !== null ? (ref2 = Polymer.Base) != null ? ref2.$$ : void 0 : void 0) != null) {
          if (!isNull(Polymer.Base.$$("#loose"))) {
            _asm.polymerReady = true;
            delay(250, function() {
              if (looseState) {
                d$("#loose").attr("checked", "checked");
              }
              if (fuzzyState) {
                return d$("#fuzzy").attr("checked", "checked");
              }
            });
            return false;
          }
        }
        if (_asm.stateIter == null) {
          _asm.stateIter = 0;
        }
        ++_asm.stateIter;
        if (_asm.stateIter > 30) {
          console.warn("Couldn't attach Polymer.Base.ready");
          return false;
        }
        try {
          return Polymer.Base.ready(function() {
            _asm.polymerReady = true;
            return delay(250, function() {
              console.info("Doing a late Polymer.Base.ready call");
              if (looseState) {
                d$("#loose").attr("checked", "checked");
              }
              if (fuzzyState) {
                d$("#fuzzy").attr("checked", "checked");
              }
              safariSearchArgHelper();
              return eutheriaFilterHelper();
            });
          });
        } catch (error4) {
          return delay(250, function() {
            return fixState();
          });
        }
      })();
      try {
        f64 = queryUrl.param("filter");
        filterObj = JSON.parse(Base64.decode(f64));
        openFilters = false;
        simpleAllowedFilters = ["simple-linnean-group", "simple-linnean-subgroup", "linnean-family", "type", "BOOLEAN-TYPE"];
        for (col in filterObj) {
          val = filterObj[col];
          col = col.replace(/_/g, "-");
          selector = ".cndb-filter[data-column='" + col + "']";
          if (indexOf.call(simpleAllowedFilters, col) < 0) {
            console.debug("Col '" + col + "' is not a simple filter");
            $(selector).attr("value", val);
            openFilters = true;
          } else {
            $(".cndb-filter[data-column='" + col + "']").polymerSelected(val);
          }
        }
        if (openFilters) {
          $("#collapse-advanced").collapse("show");
        }
      } catch (error4) {
        e = error4;
        f64 = false;
      }
    } catch (error5) {
      e = error5;
      console.error("Bad argument " + uri.query + " => " + loadArgs + ", looseState, fuzzyState", looseState, fuzzyState, searchParams.apiPath + "?q=" + loadArgs);
      console.warn(e.message);
      loadArgs = "";
    }
  }
  if (!isNull(loadArgs) && loadArgs !== "#") {
    try {
      searchParams.lastSearch = loadArgs;
    } catch (undefined) {}
    return $.get(searchParams.targetApi, "q=" + loadArgs, "json").done(function(result) {
      _asm.polymerReady = true;
      console.debug("Server query got", result);
      if (result.status === true && result.count > 0) {
        console.log("Got a valid result, formatting " + result.count + " results.");
        formatSearchResults(result, void 0, function() {
          console.log("Format results finished, checking lagged update");
          return checkLaggedUpdate(result);
        });
        return false;
      }
      console.warn("Bad initial search");
      showBadSearchErrorMessage.debounce(null, null, null, result);
      console.error(result.error);
      return console.warn(result);
    }).fail(function(result, error) {
      console.error("There was an error loading the generic table");
      console.warn(result, error, result.statusText);
      error = result.status + " - " + result.statusText;
      $("#search-status").attr("text", "Couldn't load table - " + error);
      $("#search-status")[0].show();
      return stopLoadError();
    }).always(function() {
      $("#search").attr("disabled", false);
      return false;
    });
  } else {
    stopLoad();
    $("#search").attr("disabled", false);
    return (fixState = function() {
      var error6, ref2;
      if ((typeof Polymer !== "undefined" && Polymer !== null ? (ref2 = Polymer.Base) != null ? ref2.$$ : void 0 : void 0) != null) {
        if (!isNull(Polymer.Base.$$("#loose"))) {
          _asm.polymerReady = true;
          delay(250, function() {
            d$("#loose").attr("checked", "checked");
            return eutheriaFilterHelper();
          });
          return false;
        }
      }
      if (_asm.stateIter == null) {
        _asm.stateIter = 0;
      }
      ++_asm.stateIter;
      if (_asm.stateIter > 30) {
        console.warn("Couldn't attach Polymer.Base.ready");
        return false;
      }
      try {
        return Polymer.Base.ready(function() {
          _asm.polymerReady = true;
          return delay(250, function() {
            d$("#loose").attr("checked", "checked");
            return eutheriaFilterHelper();
          });
        });
      } catch (error6) {
        return delay(250, function() {
          return fixState();
        });
      }
    })();
  }
});

//# sourceMappingURL=maps/c.js.map
