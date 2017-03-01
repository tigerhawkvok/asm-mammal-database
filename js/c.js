var _metaStatus, activityIndicatorOff, activityIndicatorOn, animateLoad, asm, bindClickTargets, bindClicks, bindDismissalRemoval, bindPaperMenuButton, browserBeware, byteCount, checkFileVersion, checkTaxonNear, clearSearch, deepJQuery, delay, doCORSget, doFontExceptions, domainPlaceholder, downloadCSVList, downloadHTMLList, eutheriaFilterHelper, foo, formatAlien, formatScientificNames, formatSearchResults, getFilters, getLocation, getMaxZ, goTo, insertCORSWorkaround, insertModalImage, isBlank, isBool, isEmpty, isJson, isNull, isNumber, isNumeric, lightboxImages, loadJS, mapNewWindows, modalTaxon, openLink, openTab, overlayOff, overlayOn, p$, parseTaxonYear, performSearch, prepURI, randomInt, ref, roundNumber, safariDialogHelper, safariSearchArgHelper, searchParams, setHistory, setupServiceWorker, showBadSearchErrorMessage, showDownloadChooser, smartCalPhotosLink, smartReptileDatabaseLink, smartUpperCasing, sortResults, stopLoad, stopLoadError, toFloat, toInt, toObject, toastStatusMessage, uri,
  slice = [].slice,
  indexOf = [].indexOf || function(item) { for (var i = 0, l = this.length; i < l; i++) { if (i in this && this[i] === item) return i; } return -1; };

uri = new Object();

uri.o = $.url();

uri.urlString = uri.o.attr('protocol') + '://' + uri.o.attr('host') + uri.o.attr("directory");

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

isBool = function(str) {
  return str === true || str === false;
};

isEmpty = function(str) {
  return !str || str.length === 0;
};

isBlank = function(str) {
  return !str || /^\s*$/.test(str);
};

isNull = function(str) {
  try {
    if (isEmpty(str) || isBlank(str) || (str == null)) {
      if (!(str === false || str === 0)) {
        return true;
      }
    }
  } catch (undefined) {}
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

String.prototype.toBool = function() {
  return this.toString() === 'true';
};

Boolean.prototype.toBool = function() {
  return this.toString() === 'true';
};

Number.prototype.toBool = function() {
  return this.toString() === "1";
};

Object.size = function(obj) {
  var key, size;
  size = 0;
  for (key in obj) {
    if (obj.hasOwnProperty(key)) {
      size++;
    }
  }
  return size;
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

jQuery.fn.exists = function() {
  return jQuery(this).length > 0;
};

jQuery.fn.polymerSelected = function(setSelected, attrLookup) {
  var attr, e, error1, error2, itemSelector, val;
  if (setSelected == null) {
    setSelected = void 0;
  }
  if (attrLookup == null) {
    attrLookup = "attrForSelected";
  }

  /*
   * See
   * https://elements.polymer-project.org/elements/paper-menu
   * https://elements.polymer-project.org/elements/paper-radio-group
   *
   * @param attrLookup is based on
   * https://elements.polymer-project.org/elements/iron-selector?active=Polymer.IronSelectableBehavior
   */
  if (attrLookup !== true) {
    attr = $(this).attr(attrLookup);
  } else {
    attr = true;
  }
  if (setSelected != null) {
    if (!isBool(setSelected)) {
      try {
        return $(this).get(0).select(setSelected);
      } catch (error1) {
        e = error1;
        return false;
      }
    } else {
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
      val = $(this).get(0).selected;
      if (isNumber(val) && !isNull(attr)) {
        itemSelector = $(this).find("paper-item")[toInt(val)];
        if (attr !== true) {
          val = $(itemSelector).attr(attr);
        } else {
          val = $(itemSelector).text();
        }
      }
    } catch (error2) {
      e = error2;
      return false;
    }
    if (val === "null" || (val == null)) {
      val = void 0;
    }
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

({
  debounce: function(func, threshold, execAsap) {
    if (threshold == null) {
      threshold = 300;
    }
    if (execAsap == null) {
      execAsap = false;
    }
    return function() {
      var args, delayed, obj;
      args = 1 <= arguments.length ? slice.call(arguments, 0) : [];
      obj = this;
      delayed = function() {
        if (!execAsap) {
          return func.apply(obj, args);
        }
      };
      if (window.debounce_timer != null) {
        clearTimeout(window.debounce_timer);
      } else if (execAsap) {
        func.apply(obj, args);
      }
      return window.debounce_timer = setTimeout(delayed, threshold);
    };
  }
});

Function.prototype.debounce = function() {
  var args, delayed, e, error1, execAsap, func, threshold, timeout;
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
  func = this;
  delayed = function() {
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
  } else if (execAsap) {
    func.apply(obj, args);
  }
  return window.debounce_timer = setTimeout(delayed, threshold);
};

loadJS = function(src, callback, doCallbackOnError) {
  var e, error1, errorFunction, onLoadFunction, s;
  if (callback == null) {
    callback = new Object();
  }
  if (doCallbackOnError == null) {
    doCallbackOnError = true;
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
  s.setAttribute("async", "async");
  s.setAttribute("type", "text/javascript");
  s.src = src;
  s.async = true;
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
            return console.error("Postload callback error - " + e.message);
          }
        }
      }
    } catch (error3) {
      e = error3;
      return console.error("Onload error - " + e.message);
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
  var len, len1, lower, lowerRegEx, lowers, m, o, str, upper, upperRegEx, uppers;
  str = this.replace(/([^\W_]+[^\s-]*) */g, function(txt) {
    return txt.charAt(0).toUpperCase() + txt.substr(1).toLowerCase();
  });
  lowers = ["A", "An", "The", "And", "But", "Or", "For", "Nor", "As", "At", "By", "For", "From", "In", "Into", "Near", "Of", "On", "Onto", "To", "With"];
  for (m = 0, len = lowers.length; m < len; m++) {
    lower = lowers[m];
    lowerRegEx = new RegExp("\\s" + lower + "\\s", "g");
    str = str.replace(lowerRegEx, function(txt) {
      return txt.toLowerCase();
    });
  }
  uppers = ["Id", "Tv"];
  for (o = 0, len1 = uppers.length; o < len1; o++) {
    upper = uppers[o];
    upperRegEx = new RegExp("\\b" + upper + "\\b", "g");
    str = str.replace(upperRegEx, upper.toUpperCase());
  }
  return str;
};

smartUpperCasing = function(text) {
  var len, m, r, replaceLower, replacer, searchUpper, secondWord, secondWordCased, smartCased, specialLowerCaseWords, word;
  replacer = function(match) {
    return match.replace(match, match.toUpperCase());
  };
  smartCased = text.replace(/((?=((?!-)[\W\s\r\n]))\s[A-Za-z]|^[A-Za-z])/g, replacer);
  specialLowerCaseWords = ["a", "an", "and", "at", "but", "by", "for", "in", "nor", "of", "on", "or", "out", "so", "to", "the", "up", "yet"];
  try {
    for (m = 0, len = specialLowerCaseWords.length; m < len; m++) {
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
  var html, ref1;
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
  if (((ref1 = window.metaTracker) != null ? ref1.isToasting : void 0) == null) {
    if (window.metaTracker == null) {
      window.metaTracker = new Object();
      window.metaTracker.isToasting = false;
    }
  }
  if (window.metaTracker.isToasting) {
    delay(250, function() {
      return toastStatusMessage(message, className, duration, selector);
    });
    return false;
  }
  window.metaTracker.isToasting = true;
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
  $(selector).get(0).show();
  return delay(duration + 500, function() {
    $(selector).empty();
    $(selector).removeClass(className);
    $(selector).attr("text", "");
    return window.metaTracker.isToasting = false;
  });
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
   * Plays nice with layzr.js
   * https://callmecavs.github.io/layzr.js/
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
  jqo = lookDeeply ? d$(selector) : $(selector);
  return jqo.click(function(e) {
    var error1;
    try {
      $(this).imageLightbox(options).startImageLightbox();
      e.preventDefault();
      e.stopPropagation();
      return console.warn("Event propagation was stopped when clicking on this.");
    } catch (error1) {
      e = error1;
      return console.error("Unable to lightbox this image!");
    }
  }).each(function() {
    var e, error1, imgUrl, tagHtml;
    try {
      if ($(this).prop("tagName").toLowerCase() === "img" && $(this).parent().prop("tagName").toLowerCase() !== "a") {
        tagHtml = $(this).removeClass("lightboximage").prop("outerHTML");
        imgUrl = (function() {
          switch (false) {
            case !!isNull($(this).attr("data-layzr-retina")):
              return $(this).attr("data-layzr-retina");
            case !!isNull($(this).attr("data-layzr")):
              return $(this).attr("data-layzr");
            default:
              return $(this).attr("src");
          }
        }).call(this);
        return $(this).replaceWith("<a href='" + imgUrl + "' class='lightboximage'>" + tagHtml + "</a>");
      }
    } catch (error1) {
      e = error1;
      return console.warn("Couldn't parse through the elements");
    }
  });
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
    var callable, e, error1, error2, url;
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
            return openTab(url);
          } else {
            return goTo(url);
          }
        });
        return url;
      } else {
        callable = $(this).attr("data-function");
        if (callable != null) {
          $(this).unbind();
          return $(this).click(function() {
            var error2;
            try {
              return window[callable]();
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
      if (asm.lastMod == null) {
        asm.lastMod = result.last_mod;
      }
      if (result.last_mod > asm.lastMod) {
        html = "<div id=\"outdated-warning\" class=\"alert alert-warning alert-dismissible fade in\" role=\"alert\">\n  <button type=\"button\" class=\"close\" data-dismiss=\"alert\" aria-label=\"Close\"><span aria-hidden=\"true\">&times;</span></button>\n  <strong>We have page updates!</strong> This page has been updated since you last refreshed. <a class=\"alert-link\" id=\"refresh-page\" style=\"cursor:pointer\">Click here to refresh now</a> and get bugfixes and updates.\n</div>";
        if (!$("#outdated-warning").exists()) {
          $("body").append(html);
          $("#refresh-page").click(function() {
            return document.location.reload(true);
          });
        }
        return console.warn("Your current version is out of date! Please refresh the page.");
      } else if (forceNow) {
        return console.info("Your version is up to date: have " + asm.lastMod + ", got " + result.last_mod);
      }
    }).fail(function() {
      return console.warn("Couldn't check file version!!");
    }).always(function() {
      return delay(5 * 60 * 1000, function() {
        return checkVersion();
      });
    });
  };
  if (forceNow || (asm.lastMod == null)) {
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

$(function() {
  var e, error1, error2;
  formatScientificNames();
  bindClicks();
  mapNewWindows();
  try {
    $("body").tooltip({
      selector: "[data-toggle='tooltip']"
    });
  } catch (error1) {
    e = error1;
    console.warn("Tooltips were attempted to be set up, but do not exist");
  }
  try {
    checkAdmin();
    if ((typeof adminParams !== "undefined" && adminParams !== null ? adminParams.loadAdminUi : void 0) === true) {
      loadJS("js/admin.min.js", function() {
        return loadAdminUi();
      });
    }
  } catch (error2) {
    e = error2;
    getLocation();
    loadJS("js/jquery.cookie.min.js", function() {
      var html;
      if ($.cookie("asmherps_user") != null) {
        html = "<paper-icon-button icon=\"create\" class=\"click\" data-href=\"" + uri.urlString + "admin/\" data-toggle=\"tooltip\" title=\"Go to administration\" id=\"goto-admin\"></paper-icon-button>";
        $("#bug-footer").append(html);
        bindClicks("#goto-admin");
      }
      return false;
    });
  }
  browserBeware();
  return checkFileVersion();
});

searchParams = new Object();

searchParams.targetApi = "api.php";

searchParams.targetContainer = "#result_container";

searchParams.apiPath = uri.urlString + searchParams.targetApi;

asm = new Object();

asm.affiliateQueryUrl = {
  amphibiaWeb: "http://amphibiaweb.org/cgi/amphib_query",
  reptileDatabase: "http://reptile-database.reptarium.cz/species",
  calPhotos: "http://calphotos.berkeley.edu/cgi/img_query",
  iNaturalist: "https://www.inaturalist.org/taxa/search"
};

eutheriaFilterHelper = function() {
  $("#linnean").on("iron-select", function() {
    var group, html, humanGroup, len, len1, m, mammalGroups, mammalGroupsBase, mammalItems, o;
    if ($(p$("#linnean").selectedItem).attr("data-type") === "eutheria") {
      mammalGroupsBase = ["rodents", "lagomorphs", "primates", "solenodons", "soricomorphs", "bats", "perissodactyls", "pangolins", "musteloids", "pinnipeds", "true bears", "canids", "Mongooses / meerkats", "hyenas", "civets", "true cats", "palm civet", "Whales", "hippos", "cervoids", "non-cervoid ruminants", "camelidae", "suinae", "tethytheria", "elephants", "afroscoricida", "aardvarks", "elephant shrews", "armadillos", "sloths", "anteaters"];
      mammalGroups = new Array();
      for (m = 0, len = mammalGroupsBase.length; m < len; m++) {
        humanGroup = mammalGroupsBase[m];
        mammalGroups.push(humanGroup.toLowerCase());
      }
      mammalGroups.sort();
      mammalItems = "";
      for (o = 0, len1 = mammalGroups.length; o < len1; o++) {
        group = mammalGroups[o];
        html = "<paper-item data-type=\"" + group + "\">\n  " + (group.toTitleCase()) + "\n</paper-item>";
        mammalItems += html;
      }
      html = "<div id=\"eutheria-extra\">\n    <label for=\"type\" class=\"sr-only\">Eutheria Filter</label>\n    <paper-menu-button>\n      <paper-button class=\"dropdown-trigger\"><iron-icon icon=\"icons:filter-list\"></iron-icon><span id=\"filter-what\" class=\"dropdown-label\"></span></paper-button>\n      <paper-menu label=\"Group\" data-column=\"simple_linnean_subgroup\" class=\"cndb-filter dropdown-content\" id=\"linnean-eutheria\" name=\"type\" attrForSelected=\"data-type\" selected=\"0\">\n        <paper-item data-type=\"any\">All</paper-item>\n        " + mammalItems + "\n        <!-- As per flag 4 in readme -->\n      </paper-menu>\n    </paper-menu-button>\n  </div>";
      return $("#simple-linnean-groups").after(html);
    } else {
      return $("#eutheria-extra").remove();
    }
  });
  return false;
};

performSearch = function(stateArgs) {
  var args, filters, s, sOrig;
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
    if ($("#loose").polymerChecked()) {
      s = s + "&loose=true";
    }
    if ($("#fuzzy").polymerChecked()) {
      s = s + "&fuzzy=true";
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
  return $.get(searchParams.targetApi, args, "json").done(function(result) {
    if (toInt(result.count) === 0) {
      showBadSearchErrorMessage(result);
      clearSearch(true);
      return false;
    }
    if (result.status === true) {
      formatSearchResults(result);
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
  var alien, e, encodedFilter, error1, filterList, jsonString;
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
    var col, val;
    col = $(this).attr("data-column");
    if (col == null) {
      return true;
    }
    val = $(this).polymerSelected();
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
  alien = $("#alien-filter").get(0).selected;
  if (alien !== "both") {
    filterList.is_alien = alien === "alien-only" ? 1 : 0;
  }
  if (Object.size(filterList) === 0) {
    return "";
  }
  try {
    filterList["BOOLEAN_TYPE"] = booleanType;
    jsonString = JSON.stringify(filterList);
    encodedFilter = Base64.encodeURI(jsonString);
    return encodedFilter;
  } catch (error1) {
    e = error1;
    return false;
  }
};

formatSearchResults = function(result, container) {
  var alt, bootstrapColCount, bootstrapColSize, col, colClass, d, data, dontShowColumns, e, error1, error2, externalCounter, genus, headers, html, htmlClose, htmlHead, htmlRow, i, j, k, kClass, l, niceKey, noticeHtml, renderTimeout, row, species, split, targetCount, taxonQuery, v, year;
  if (container == null) {
    container = searchParams.targetContainer;
  }

  /*
   * Take a result object from the server's lookup, and format it to
   * display search results.
   * See
   * http://mammaldiversity.org/cndb/commonnames_api.php?q=batrachoseps+attenuatus&loose=true
   * for a sample search result return.
   */
  $("#result-header-container").removeAttr("hidden");
  data = result.result;
  searchParams.result = data;
  headers = new Array();
  html = "";
  htmlHead = "<table id='cndb-result-list' class='table table-striped table-hover col-md-12'>\n\t<tr class='cndb-row-headers'>";
  htmlClose = "</table>";
  targetCount = toInt(result.count) - 1;
  colClass = null;
  bootstrapColCount = 0;
  dontShowColumns = ["id", "minor_type", "notes", "major_type", "taxon_author", "taxon_credit", "image_license", "image_credit", "taxon_credit_date", "parens_auth_genus", "parens_auth_species", "is_alien"];
  externalCounter = 0;
  renderTimeout = delay(5000, function() {
    stopLoadError("There was a problem parsing the search results.");
    console.error("Couldn't finish parsing the results! Expecting " + targetCount + " elements, timed out on " + externalCounter + ".");
    console.warn(data);
    return false;
  });
  for (i in data) {
    row = data[i];
    externalCounter = i;
    if (toInt(i) === 0) {
      j = 0;
      htmlHead += "\n<!-- Table Headers - " + (Object.size(row)) + " entries -->";
      for (k in row) {
        v = row[k];
        niceKey = k.replace(/_/g, " ");
        if (indexOf.call(dontShowColumns, k) < 0) {
          if ($("#show-deprecated").polymerSelected() !== true) {
            alt = "deprecated_scientific";
          } else {
            alt = "";
          }
          if (k !== alt) {
            niceKey = (function() {
              switch (niceKey) {
                case "common name":
                  return "english name";
                case "major subtype":
                  return "english genus name";
                default:
                  return niceKey;
              }
            })();
            htmlHead += "\n\t\t<th class='text-center'>" + niceKey + "</th>";
            bootstrapColCount++;
          }
        }
        j++;
        if (j === Object.size(row)) {
          htmlHead += "\n\t</tr>";
          htmlHead += "\n<!-- End Table Headers -->";
          bootstrapColSize = roundNumber(12 / bootstrapColCount, 0);
          colClass = "col-md-" + bootstrapColSize;
        }
      }
    }
    taxonQuery = row.genus + "+" + row.species;
    if (!isNull(row.subspecies)) {
      taxonQuery = taxonQuery + "+" + row.subspecies;
    }
    htmlRow = "\n\t<tr id='cndb-row" + i + "' class='cndb-result-entry' data-taxon=\"" + taxonQuery + "\">";
    l = 0;
    for (k in row) {
      col = row[k];
      if (indexOf.call(dontShowColumns, k) < 0) {
        if (k === "authority_year") {
          try {
            try {
              d = JSON.parse(col);
            } catch (error1) {
              e = error1;
              console.warn("There was an error parsing '" + col + "', attempting to fix - ", e.message);
              split = col.split(":");
              year = split[1].slice(split[1].search("\"") + 1, -2);
              year = year.replace(/"/g, "'");
              split[1] = "\"" + year + "\"}";
              col = split.join(":");
              d = JSON.parse(col);
            }
            genus = Object.keys(d)[0];
            species = d[genus];
            if (toInt(row.parens_auth_genus).toBool()) {
              genus = "(" + genus + ")";
            }
            if (toInt(row.parens_auth_species).toBool()) {
              species = "(" + species + ")";
            }
            col = "G: " + genus + "<br/>S: " + species;
          } catch (error2) {
            e = error2;
            console.error("There was an error parsing '" + col + "'", e.message);
            d = col;
          }
        }
        if ($("#show-deprecated").polymerSelected() !== true) {
          alt = "deprecated_scientific";
        } else {
          alt = "";
        }
        if (k !== alt) {
          if (k === "image") {
            if (isNull(col)) {
              col = "<paper-icon-button icon='launch' data-href='" + asm.affiliateQueryUrl.calPhotos + "?rel-taxon=contains&where-taxon=" + taxonQuery + "' class='newwindow calphoto click' data-taxon=\"" + taxonQuery + "\"></paper-icon-button>";
            } else {
              col = "<paper-icon-button icon='image:image' data-lightbox='" + uri.urlString + col + "' class='lightboximage'></paper-icon-button>";
            }
          }
          if (k !== "genus" && k !== "species" && k !== "subspecies") {
            kClass = k + " text-center";
          } else {
            kClass = k;
          }
          if (k === "genus_authority" || k === "species_authority") {
            kClass += " authority";
          }
          if (k === "common_name") {
            col = smartUpperCasing(col);
            kClass += " no-cap";
          }
          htmlRow += "\n\t\t<td id='" + k + "-" + i + "' class='" + kClass + " " + colClass + "'>" + col + "</td>";
        }
      }
      l++;
      if (l === Object.size(row)) {
        htmlRow += "\n\t</tr>";
        html += htmlRow;
      }
    }
    if (toInt(i) === targetCount) {
      html = htmlHead + html + htmlClose;
      $(container).html(html);
      clearTimeout(renderTimeout);
      mapNewWindows();
      lightboxImages();
      modalTaxon();
      doFontExceptions();
      $("#result-count").text(" - " + result.count + " entries");
      stopLoad();
    }
  }
  if (result.method === "space_common_fallback" && !$("#space-fallback-info").exists()) {
    noticeHtml = "<div id=\"space-fallback-info\" class=\"alert alert-info alert-dismissible center-block fade in\" role=\"alert\">\n  <button type=\"button\" class=\"close\" data-dismiss=\"alert\" aria-label=\"Close\"><span aria-hidden=\"true\">&times;</span></button>\n  <strong>Don't see what you want?</strong> We might use a slightly different name. Try <a href=\"\" class=\"alert-link\" id=\"do-instant-fuzzy\">checking the \"fuzzy\" toggle and searching again</a>, or use a shorter search term.\n</div>";
    $("#result_container").before(noticeHtml);
    return $("#do-instant-fuzzy").click(function(e) {
      var doBatch;
      e.preventDefault();
      doBatch = function() {
        $("#fuzzy").get(0).checked = true;
        return performSearch();
      };
      return doBatch.debounce();
    });
  } else if ($("#space-fallback-info").exists()) {
    return $("#space-fallback-info").prop("hidden", true);
  }
};

parseTaxonYear = function(taxonYearString, strict) {
  var d, e, error1, error2, genus, species, split, year;
  if (strict == null) {
    strict = true;
  }

  /*
   * Take the (theoretically nicely JSON-encoded) taxon year/authority
   * string and turn it into a canonical object for the modal dialog to use
   */
  try {
    d = JSON.parse(taxonYearString);
  } catch (error1) {
    e = error1;
    console.warn("There was an error parsing '" + taxonYearString + "', attempting to fix - ", e.message);
    split = taxonYearString.split(":");
    year = split[1].slice(split[1].search('"') + 1, -2);
    year = year.replace(/"/g, "'");
    split[1] = "\"" + year + "\"}";
    taxonYearString = split.join(":");
    try {
      d = JSON.parse(taxonYearString);
    } catch (error2) {
      e = error2;
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

formatAlien = function(dataOrAlienBool, selector) {
  var iconHtml, isAlien, tooltipHint, tooltipHtml;
  if (selector == null) {
    selector = "#is-alien-container";
  }

  /*
   * Quick handler to determine if the taxon is alien, and if so, label
   * it
   *
   * After
   * https://github.com/SSARHERPS/SSAR-species-database/issues/51
   * https://github.com/SSARHERPS/SSAR-species-database/issues/52
   */
  if (typeof dataOrAlienBool === "boolean") {
    isAlien = dataOrAlienBool;
  } else if (typeof dataOrAlienBool === "object") {
    isAlien = toInt(dataOrAlienBool.is_alien).toBool();
  } else {
    throw Error("Invalid data given to formatAlien()");
  }
  if (!isAlien) {
    d$(selector).css("display", "none");
    return false;
  }
  iconHtml = "<iron-icon icon=\"maps:flight\" class=\"small-icon alien-speices\" id=\"modal-alien-species\" data-toggle=\"tooltip\"></iron-icon>";
  d$(selector).html(iconHtml);
  tooltipHint = "This species is not native";
  tooltipHtml = "<div class=\"tooltip fade top in right manual-placement-tooltip\" role=\"tooltip\" style=\"top: 6.5em; left: 4em; right:initial; display:none\" id=\"manual-alien-tooltip\">\n  <div class=\"tooltip-arrow\" style=\"top:50%;left:5px\"></div>\n  <div class=\"tooltip-inner\">" + tooltipHint + "</div>\n</div>";
  d$(selector).after(tooltipHtml).mouseenter(function() {
    d$("#manual-alien-tooltip").css("display", "block");
    return false;
  }).mouseleave(function() {
    d$("#manual-alien-tooltip").css("display", "none");
    return false;
  });
  d$("#manual-location-tooltip").css("left", "6em");
  return false;
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
  var args, doneCORS, e, error1, extension, failCORS, imageUrl, imgArray, imgPath, insertImage, taxonArray, taxonString, warnArgs;
  if (imageObject == null) {
    imageObject = asm.taxonImage;
  }
  if (taxon == null) {
    taxon = asm.activeTaxon;
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
      defaultTaxon: asm.activeTaxon,
      defaultImage: asm.taxonImage
    };
    console.warn(warnArgs);
    return false;
  }
  insertImage = function(image, taxonQueryString, classPrefix) {
    var e, error1, html, imgCredit, imgLicense, largeImg, largeImgLink, smartFit, thumbnail;
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
      var e, error1;
      try {
        d$("#modal-taxon").get(0).fit();
        return delay(250, function() {
          d$("#modal-taxon").get(0).fit();
          return delay(750, function() {
            return d$("#modal-taxon").get(0).fit();
          });
        });
      } catch (error1) {
        e = error1;
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
    } catch (error1) {
      e = error1;
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
    var data, e, error1, error2, result;
    result = xmlToJSON.parseString(resultXml);
    window.testData = result;
    try {
      data = result.calphotos[0];
    } catch (error1) {
      e = error1;
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
    } catch (error2) {
      e = error2;
      console.warn("CalPhotos didn't return any valid images for this search!", asm.affiliateQueryUrl.calPhotos + "?" + args);
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
    doCORSget(asm.affiliateQueryUrl.calPhotos, args, doneCORS, failCORS);
  } catch (error1) {
    e = error1;
    console.error(e.message);
  }
  return false;
};

smartReptileDatabaseLink = function() {

  /*
   * We're going to check the remote for synonyms, and fix links
   * After
   * https://github.com/SSARHERPS/SSAR-species-database/issues/77
   */
  var args, humanTaxon, taxon, taxonArray, taxonString, url;
  url = "http://reptile-database.reptarium.cz/interfaces/services/check-taxon";
  taxon = asm.activeTaxon;
  taxonArray = [taxon.genus, taxon.species];
  if (taxon.subspecies != null) {
    taxonArray.push(taxon.subspecies);
  }
  taxonString = taxonArray.join("+");
  humanTaxon = taxonArray.join(" ");
  humanTaxon = humanTaxon.slice(0, 1).toUpperCase() + humanTaxon.slice(1);
  args = "taxon=" + taxonString;
  $.get(url, args, "json").done(function(result) {
    var alternateTaxa, alternateTaxonArray, alternateTaxonString, button, buttonText, data, outboundLink;
    if (result.response === "VALID") {
      console.info("_" + humanTaxon + "_ is the consensus taxon with Reptile Database");
      return true;
    }
    if (result.response === "SYNONYM") {
      alternateTaxa = result.VALID[0];
      alternateTaxonString = alternateTaxa.toLowerCase().replace(/\s/mg, "+");
      alternateTaxonArray = alternateTaxa.split(/\s/);
      data = {
        genus: alternateTaxonArray[0],
        species: alternateTaxonArray[1]
      };
      buttonText = "Reptile Database";
      button = "<paper-button id='modal-alt-linkout' class=\"hidden-xs\">" + buttonText + "</paper-button>";
      outboundLink = asm.affiliateQueryUrl.reptileDatabase + "?genus=" + data.genus + "&species=" + data.species;
      if (outboundLink != null) {
        $("#modal-alt-linkout").replaceWith(button);
        $("#modal-alt-linkout").click(function() {
          return openTab(outboundLink);
        });
      }
      console.info("Reptile Database uses recognizes _" + humanTaxon + "_ as _" + alternateTaxa + "_");
      return smartCalPhotosLink(data);
    } else {
      d$("#modal-alt-linkout").remove();
      return console.warn("Reptile Database couldn't find this taxon at all!");
    }
  }).fail(function() {
    console.warn("Unable to check the taxon on Reptile Database!");
    return false;
  });
  return false;
};

smartCalPhotosLink = function(overrideTaxon) {

  /*
   * Called from smartReptileDatabaseLink()
   * If there were no Cal Photos hits, try
   * the reptile database genus/species with the
   * SSAR species as the subspecies
   */
  var calPhotosTaxon, postImageInsertion, taxonArray;
  calPhotosTaxon = {
    genus: overrideTaxon.genus,
    species: overrideTaxon.species,
    subspecies: asm.activeTaxon.species
  };
  taxonArray = [calPhotosTaxon.genus, calPhotosTaxon.species];
  if (calPhotosTaxon.subspecies != null) {
    taxonArray.push(calPhotosTaxon.subspecies);
  }
  if (d$(".modal-img-container").exists()) {
    console.info("CalPhotos agrees with SSAR");
    return true;
  }
  postImageInsertion = function() {
    var humanTaxon;
    humanTaxon = taxonArray.join(" ");
    humanTaxon = humanTaxon.slice(0, 1).toUpperCase() + humanTaxon.slice(1);
    console.info("CalPhotos agrees with Reptile Database, so we're linking to _" + humanTaxon + "_ for CalPhotos");
    $("#modal-calphotos-linkout").unbind().click(function() {
      return openTab(asm.affiliateQueryUrl.calPhotos + "?rel-taxon=contains&where-taxon=" + (taxonArray.join("+")));
    });
    return false;
  };
  insertModalImage(asm.taxonImage, calPhotosTaxon, postImageInsertion);
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
    var button, buttonText, commonType, data, deprecatedHtml, e, error1, error2, error3, genusAuthBlock, humanTaxon, i, minorTypeHtml, notes, outboundLink, ref1, sn, speciesAuthBlock, taxonArray, taxonCreditDate, year, yearHtml;
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
      } catch (error1) {
        e = error1;
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
    } catch (error2) {
      e = error2;
      notes = data.notes;
      console.warn("Couldn't parse markdown!! " + e.message);
    }
    notes = notes.replace(/\&amp;(([a-z]+|[0-9]+);)/mg, "&$1");
    commonType = !isNull(data.major_common_type) ? " (<span id='taxon-common-type'>" + data.major_common_type + "</span>) " : "";
    html = "<div id='meta-taxon-info'>\n  " + yearHtml + "\n  <p>\n    English name: <span id='taxon-common-name' class='common_name no-cap'>" + (smartUpperCasing(data.common_name)) + "</span>\n  </p>\n  <p>\n    Type: <span id='taxon-type' class=\"major_type\">" + data.major_type + "</span>\n    " + commonType + "\n    <iron-icon icon='arrow-forward'></iron-icon>\n    <span id='taxon-subtype' class=\"major_subtype\">" + data.major_subtype + "</span>" + minorTypeHtml + "\n  </p>\n  " + deprecatedHtml + "\n</div>\n<h3>Taxon Notes</h3>\n<p id='taxon-notes'>" + notes + "</p>\n<p class=\"text-right small text-muted\">" + data.taxon_credit + "</p>";
    $("#modal-taxon-content").html(html);
    $("#modal-inat-linkout").unbind().click(function() {
      return openTab(asm.affiliateQueryUrl.iNaturalist + "?q=" + taxon);
    });
    $("#modal-calphotos-linkout").unbind().click(function() {
      return openTab(asm.affiliateQueryUrl.calPhotos + "?rel-taxon=contains&where-taxon=" + taxon);
    });
    outboundLink = null;
    buttonText = null;
    taxonArray = taxon.split("+");
    asm.activeTaxon = {
      genus: taxonArray[0],
      species: taxonArray[1],
      subspecies: taxonArray[2]
    };
    if ((ref1 = data.linnean_order.toLowerCase()) === "caudata" || ref1 === "anura" || ref1 === "gymnophiona") {
      buttonText = "AmphibiaWeb";
      outboundLink = asm.affiliateQueryUrl.amphibiaWeb + "?where-genus=" + data.genus + "&where-species=" + data.species;
    } else if (!isNull(data.linnean_order)) {
      buttonText = "Reptile Database";
      button = "<paper-button id='modal-alt-linkout' class=\"hidden-xs\">" + buttonText + "</paper-button>";
      outboundLink = asm.affiliateQueryUrl.reptileDatabase + "?genus=" + data.genus + "&species=" + data.species;
      smartReptileDatabaseLink();
    }
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
    asm.taxonImage = {
      imageUri: data.image,
      imageCredit: data.image_credit,
      imageLicense: data.image_license
    };
    try {
      insertModalImage();
    } catch (error3) {
      e = error3;
      console.info("Unable to insert modal image! ");
    }
    checkTaxonNear(taxon, function() {
      var modalElement;
      formatAlien(data);
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
  calloutHtml = "<div class=\"bs-callout bs-callout-info center-block col-xs-12 col-sm-8 col-md-5\">\n  Search for a common or scientific name above to begin, eg, \"California slender salamander\" or \"<span class=\"sciname\">Batrachoseps attenuatus</span>\"\n</div>";
  $("#result_container").html(calloutHtml);
  $("#result-header-container").attr("hidden", "hidden");
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

downloadCSVList = function() {

  /*
   * Download a CSV file list
   *
   * See
   * https://github.com/tigerhawkvok/SSAR-species-database/issues/39
   */
  var adjMonth, args, d, dateString, day, month;
  animateLoad();
  args = "q=*";
  d = new Date();
  adjMonth = d.getMonth() + 1;
  month = adjMonth.toString().length === 1 ? "0" + adjMonth : adjMonth;
  day = d.getDate().toString().length === 1 ? "0" + (d.getDate().toString()) : d.getDate();
  dateString = (d.getUTCFullYear()) + "-" + month + "-" + day;
  $.get("" + searchParams.apiPath, args, "json").done(function(result) {
    var authorityYears, col, colData, csv, csvBody, csvHeader, csvLiteralRow, csvRow, dirtyCol, dirtyColData, downloadable, e, error1, error2, genusYear, html, i, k, makeTitleCase, ref1, row, showColumn, speciesYear, tempCol, v;
    try {
      if (result.status !== true) {
        throw Error("Invalid Result");
      }
      csvBody = "      ";
      csvHeader = new Array();
      showColumn = ["genus", "species", "subspecies", "common_name", "image", "image_credit", "image_license", "major_type", "major_common_type", "major_subtype", "minor_type", "linnean_order", "genus_authority", "species_authority", "deprecated_scientific", "notes", "taxon_credit", "taxon_credit_date"];
      makeTitleCase = ["genus", "common_name", "taxon_author", "major_subtype", "linnean_order"];
      i = 0;
      ref1 = result.result;
      for (k in ref1) {
        row = ref1[k];
        csvRow = new Array();
        if (isNull(row.genus)) {
          continue;
        }
        for (dirtyCol in row) {
          dirtyColData = row[dirtyCol];
          col = dirtyCol.replace(/"/g, '\"\"');
          colData = dirtyColData.replace(/"/g, '\"\"').replace(/&#39;/g, "'");
          if (i === 0) {
            if (indexOf.call(showColumn, col) >= 0) {
              csvHeader.push(col.replace(/_/g, " ").toTitleCase());
            }
          }
          if (indexOf.call(showColumn, col) >= 0) {
            if (/[a-z]+_authority/.test(col)) {
              try {
                authorityYears = JSON.parse(row.authority_year);
                genusYear = "";
                speciesYear = "";
                for (k in authorityYears) {
                  v = authorityYears[k];
                  genusYear = k.replace(/"/g, '\"\"').replace(/&#39;/g, "'");
                  speciesYear = v.replace(/"/g, '\"\"').replace(/&#39;/g, "'");
                }
                switch (col.split("_")[0]) {
                  case "genus":
                    tempCol = (colData.toTitleCase()) + " " + genusYear;
                    if (toInt(row.parens_auth_genus).toBool()) {
                      tempCol = "(" + tempCol + ")";
                    }
                    break;
                  case "species":
                    tempCol = (colData.toTitleCase()) + " " + speciesYear;
                    if (toInt(row.parens_auth_species).toBool()) {
                      tempCol = "(" + tempCol + ")";
                    }
                }
                colData = tempCol;
              } catch (error1) {
                e = error1;
              }
            }
            if (indexOf.call(makeTitleCase, col) >= 0) {
              colData = colData.toTitleCase();
            }
            if (col === "image" && !isNull(colData)) {
              colData = "http://mammaldiversity.org/cndb/" + colData;
            }
            csvRow.push("\"" + colData + "\"");
          }
        }
        i++;
        csvLiteralRow = csvRow.join(",");
        csvBody += "\n" + csvLiteralRow;
      }
      csv = (csvHeader.join(",")) + "\n" + csvBody;
      downloadable = "data:text/csv;charset=utf-8," + encodeURIComponent(csv);
      html = "<paper-dialog class=\"download-file\" id=\"download-csv-file\" modal>\n  <h2>Your file is ready</h2>\n  <paper-dialog-scrollable class=\"dialog-content\">\n    <p>\n      Please note that some special characters in names may be decoded incorrectly by Microsoft Excel. If this is a problem, following the steps in <a href=\"https://github.com/SSARHERPS/SSAR-species-database/blob/master/meta/excel_unicode_readme.md\"  onclick='window.open(this.href); return false;' onkeypress='window.open(this.href); return false;'>this README <iron-icon icon=\"launch\"></iron-icon></a> to force Excel to format it correctly.\n    </p>\n    <p class=\"text-center\">\n      <a href=\"" + downloadable + "\" download=\"asm-common-names-" + dateString + ".csv\" class=\"btn btn-default\"><iron-icon icon=\"file-download\"></iron-icon> Download Now</a>\n    </p>\n  </paper-dialog-scrollable>\n  <div class=\"buttons\">\n    <paper-button dialog-dismiss>Close</paper-button>\n  </div>\n</paper-dialog>";
      if (!$("#download-csv-file").exists()) {
        $("body").append(html);
      } else {
        $("#download-csv-file").replaceWith(html);
      }
      $("#download-chooser").get(0).close();
      return safariDialogHelper("#download-csv-file");
    } catch (error2) {
      e = error2;
      stopLoadError("There was a problem creating the CSV file. Please try again later.");
      console.error("Exception in downloadCSVList() - " + e.message);
      return console.warn("Got", result, "from", searchParams.apiPath + "?" + args, result.status);
    }
  }).fail(function() {
    return stopLoadError("There was a problem communicating with the server. Please try again later.");
  });
  return false;
};

downloadHTMLList = function() {

  /*
   * Download a HTML file list
   *
   * We want to set this up to look similar to the published list
   * http://mammaldiversity.org/wp-content/uploads/2014/07/HC_39_7thEd.pdf
   * Starting with page 11
   *
   * Configured Bootstrap:
   * https://gist.github.com/e14c62a4d4eee8f40b6b
   *
   * Bootstrap Config Link:
   * http://getbootstrap.com/customize/?id=e14c62a4d4eee8f40b6b
   *
   * See
   * https://github.com/tigerhawkvok/SSAR-species-database/issues/40
   */
  var adjMonth, args, d, dateString, day, htmlBody, month;
  animateLoad();
  d = new Date();
  adjMonth = d.getMonth() + 1;
  month = adjMonth.toString().length === 1 ? "0" + adjMonth : adjMonth;
  day = d.getDate().toString().length === 1 ? "0" + (d.getDate().toString()) : d.getDate();
  dateString = (d.getUTCFullYear()) + "-" + month + "-" + day;
  htmlBody = "     <!doctype html>\n     <html lang=\"en\">\n       <head>\n         <title>SSAR Common Names Checklist ver. " + dateString + "</title>\n         <meta http-equiv=\"X-UA-Compatible\" content=\"IE=edge\">\n         <meta charset=\"UTF-8\"/>\n         <meta name=\"theme-color\" content=\"#445e14\"/>\n         <meta name=\"viewport\" content=\"width=device-width, initial-scale=1\" />\n         <link href='http://fonts.googleapis.com/css?family=Droid+Serif:400,700,700italic,400italic|Roboto+Slab:400,700' rel='stylesheet' type='text/css' />\n         <style type=\"text/css\" id=\"asm-checklist-inline-stylesheet\">\n/*!\n* Bootstrap v3.3.5 (http://getbootstrap.com)\n* Copyright 2011-2015 Twitter, Inc.\n* Licensed under MIT (https://github.com/twbs/bootstrap/blob/master/LICENSE)\n*/\n\n/*!\n* Generated using the Bootstrap Customizer (http://getbootstrap.com/customize/?id=e14c62a4d4eee8f40b6b)\n* Config saved to config.json and https://gist.github.com/e14c62a4d4eee8f40b6b\n*//*!\n* Bootstrap v3.3.5 (http://getbootstrap.com)\n* Copyright 2011-2015 Twitter, Inc.\n* Licensed under MIT (https://github.com/twbs/bootstrap/blob/master/LICENSE)\n*//*! normalize.css v3.0.3 | MIT License | github.com/necolas/normalize.css */html{font-family:sans-serif;-ms-text-size-adjust:100%;-webkit-text-size-adjust:100%}body{margin:0}article,aside,details,figcaption,figure,footer,header,hgroup,main,menu,nav,section,summary{display:block}audio,canvas,progress,video{display:inline-block;vertical-align:baseline}audio:not([controls]){display:none;height:0}[hidden],template{display:none}a{background-color:transparent}a:active,a:hover{outline:0}abbr[title]{border-bottom:1px dotted}b,strong{font-weight:bold}dfn{font-style:italic}h1{font-size:2em;margin:0.67em 0}mark{background:#ff0;color:#000}small{font-size:80%}sub,sup{font-size:75%;line-height:0;position:relative;vertical-align:baseline}sup{top:-0.5em}sub{bottom:-0.25em}img{border:0}svg:not(:root){overflow:hidden}figure{margin:1em 40px}hr{-webkit-box-sizing:content-box;-moz-box-sizing:content-box;box-sizing:content-box;height:0}pre{overflow:auto}code,kbd,pre,samp{font-family:monospace, monospace;font-size:1em}button,input,optgroup,select,textarea{color:inherit;font:inherit;margin:0}button{overflow:visible}button,select{text-transform:none}button,html input[type=\"button\"],input[type=\"reset\"],input[type=\"submit\"]{-webkit-appearance:button;cursor:pointer}button[disabled],html input[disabled]{cursor:default}button::-moz-focus-inner,input::-moz-focus-inner{border:0;padding:0}input{line-height:normal}input[type=\"checkbox\"],input[type=\"radio\"]{-webkit-box-sizing:border-box;-moz-box-sizing:border-box;box-sizing:border-box;padding:0}input[type=\"number\"]::-webkit-inner-spin-button,input[type=\"number\"]::-webkit-outer-spin-button{height:auto}input[type=\"search\"]{-webkit-appearance:textfield;-webkit-box-sizing:content-box;-moz-box-sizing:content-box;box-sizing:content-box}input[type=\"search\"]::-webkit-search-cancel-button,input[type=\"search\"]::-webkit-search-decoration{-webkit-appearance:none}fieldset{border:1px solid #c0c0c0;margin:0 2px;padding:0.35em 0.625em 0.75em}legend{border:0;padding:0}textarea{overflow:auto}optgroup{font-weight:bold}table{border-collapse:collapse;border-spacing:0}td,th{padding:0}/*! Source: https://github.com/h5bp/html5-boilerplate/blob/master/src/css/main.css */@media print{*,*:before,*:after{background:transparent !important;color:#000 !important;-webkit-box-shadow:none !important;box-shadow:none !important;text-shadow:none !important}a,a:visited{text-decoration:underline}a[href]:after{content:\" (\" attr(href) \")\"}abbr[title]:after{content:\" (\" attr(title) \")\"}a[href^=\"#\"]:after,a[href^=\"javascript:\"]:after{content:\"\"}pre,blockquote{border:1px solid #999;page-break-inside:avoid}thead{display:table-header-group}tr,img{page-break-inside:avoid}img{max-width:100% !important}p,h2,h3{orphans:3;widows:3}h2,h3{page-break-after:avoid}.navbar{display:none}.btn>.caret,.dropup>.btn>.caret{border-top-color:#000 !important}.label{border:1px solid #000}.table{border-collapse:collapse !important}.table td,.table th{background-color:#fff !important}.table-bordered th,.table-bordered td{border:1px solid #ddd !important}}*{-webkit-box-sizing:border-box;-moz-box-sizing:border-box;box-sizing:border-box}*:before,*:after{-webkit-box-sizing:border-box;-moz-box-sizing:border-box;box-sizing:border-box}html{font-size:10px;-webkit-tap-highlight-color:rgba(0,0,0,0)}body{font-family:\"Roboto Slab\",\"Droid Serif\",Cambria,Georgia,\"Times New Roman\",Times,serif;font-size:14px;line-height:1.42857143;color:#333;background-color:#fff}input,button,select,textarea{font-family:inherit;font-size:inherit;line-height:inherit}a{color:#337ab7;text-decoration:none}a:hover,a:focus{color:#23527c;text-decoration:underline}a:focus{outline:thin dotted;outline:5px auto -webkit-focus-ring-color;outline-offset:-2px}figure{margin:0}img{vertical-align:middle}.img-responsive{display:block;max-width:100%;height:auto}.img-rounded{border-radius:6px}.img-thumbnail{padding:4px;line-height:1.42857143;background-color:#fff;border:1px solid #ddd;border-radius:4px;-webkit-transition:all .2s ease-in-out;-o-transition:all .2s ease-in-out;transition:all .2s ease-in-out;display:inline-block;max-width:100%;height:auto}.img-circle{border-radius:50%}hr{margin-top:20px;margin-bottom:20px;border:0;border-top:1px solid #eee}.sr-only{position:absolute;width:1px;height:1px;margin:-1px;padding:0;overflow:hidden;clip:rect(0, 0, 0, 0);border:0}.sr-only-focusable:active,.sr-only-focusable:focus{position:static;width:auto;height:auto;margin:0;overflow:visible;clip:auto}[role=\"button\"]{cursor:pointer}h1,h2,h3,h4,h5,h6,.h1,.h2,.h3,.h4,.h5,.h6{font-family:inherit;font-weight:500;line-height:1.1;color:inherit}h1 small,h2 small,h3 small,h4 small,h5 small,h6 small,.h1 small,.h2 small,.h3 small,.h4 small,.h5 small,.h6 small,h1 .small,h2 .small,h3 .small,h4 .small,h5 .small,h6 .small,.h1 .small,.h2 .small,.h3 .small,.h4 .small,.h5 .small,.h6 .small{font-weight:normal;line-height:1;color:#777}h1,.h1,h2,.h2,h3,.h3{margin-top:20px;margin-bottom:10px}h1 small,.h1 small,h2 small,.h2 small,h3 small,.h3 small,h1 .small,.h1 .small,h2 .small,.h2 .small,h3 .small,.h3 .small{font-size:65%}h4,.h4,h5,.h5,h6,.h6{margin-top:10px;margin-bottom:10px}h4 small,.h4 small,h5 small,.h5 small,h6 small,.h6 small,h4 .small,.h4 .small,h5 .small,.h5 .small,h6 .small,.h6 .small{font-size:75%}h1,.h1{font-size:36px}h2,.h2{font-size:30px}h3,.h3{font-size:24px}h4,.h4{font-size:18px}h5,.h5{font-size:14px}h6,.h6{font-size:12px}p{margin:0 0 10px}.lead{margin-bottom:20px;font-size:16px;font-weight:300;line-height:1.4}@media (min-width:768px){.lead{font-size:21px}}small,.small{font-size:85%}mark,.mark{background-color:#fcf8e3;padding:.2em}.text-left{text-align:left}.text-right{text-align:right}.text-center{text-align:center}.text-justify{text-align:justify}.text-nowrap{white-space:nowrap}.text-lowercase{text-transform:lowercase}.text-uppercase{text-transform:uppercase}.text-capitalize{text-transform:capitalize}.text-muted{color:#777}.text-primary{color:#337ab7}a.text-primary:hover,a.text-primary:focus{color:#286090}.text-success{color:#3c763d}a.text-success:hover,a.text-success:focus{color:#2b542c}.text-info{color:#31708f}a.text-info:hover,a.text-info:focus{color:#245269}.text-warning{color:#8a6d3b}a.text-warning:hover,a.text-warning:focus{color:#66512c}.text-danger{color:#a94442}a.text-danger:hover,a.text-danger:focus{color:#843534}.bg-primary{color:#fff;background-color:#337ab7}a.bg-primary:hover,a.bg-primary:focus{background-color:#286090}.bg-success{background-color:#dff0d8}a.bg-success:hover,a.bg-success:focus{background-color:#c1e2b3}.bg-info{background-color:#d9edf7}a.bg-info:hover,a.bg-info:focus{background-color:#afd9ee}.bg-warning{background-color:#fcf8e3}a.bg-warning:hover,a.bg-warning:focus{background-color:#f7ecb5}.bg-danger{background-color:#f2dede}a.bg-danger:hover,a.bg-danger:focus{background-color:#e4b9b9}.page-header{padding-bottom:9px;margin:40px 0 20px;border-bottom:1px solid #eee}ul,ol{margin-top:0;margin-bottom:10px}ul ul,ol ul,ul ol,ol ol{margin-bottom:0}.list-unstyled{padding-left:0;list-style:none}.list-inline{padding-left:0;list-style:none;margin-left:-5px}.list-inline>li{display:inline-block;padding-left:5px;padding-right:5px}dl{margin-top:0;margin-bottom:20px}dt,dd{line-height:1.42857143}dt{font-weight:bold}dd{margin-left:0}@media (min-width:768px){.dl-horizontal dt{float:left;width:160px;clear:left;text-align:right;overflow:hidden;text-overflow:ellipsis;white-space:nowrap}.dl-horizontal dd{margin-left:180px}}abbr[title],abbr[data-original-title]{cursor:help;border-bottom:1px dotted #777}.initialism{font-size:90%;text-transform:uppercase}blockquote{padding:10px 20px;margin:0 0 20px;font-size:17.5px;border-left:5px solid #eee}blockquote p:last-child,blockquote ul:last-child,blockquote ol:last-child{margin-bottom:0}blockquote footer,blockquote small,blockquote .small{display:block;font-size:80%;line-height:1.42857143;color:#777}blockquote footer:before,blockquote small:before,blockquote .small:before{content:'\x2014 \x00A0'}.blockquote-reverse,blockquote.pull-right{padding-right:15px;padding-left:0;border-right:5px solid #eee;border-left:0;text-align:right}.blockquote-reverse footer:before,blockquote.pull-right footer:before,.blockquote-reverse small:before,blockquote.pull-right small:before,.blockquote-reverse .small:before,blockquote.pull-right .small:before{content:''}.blockquote-reverse footer:after,blockquote.pull-right footer:after,.blockquote-reverse small:after,blockquote.pull-right small:after,.blockquote-reverse .small:after,blockquote.pull-right .small:after{content:'\x00A0 \x2014'}address{margin-bottom:20px;font-style:normal;line-height:1.42857143}.clearfix:before,.clearfix:after,.dl-horizontal dd:before,.dl-horizontal dd:after{content:\" \";display:table}.clearfix:after,.dl-horizontal dd:after{clear:both}.center-block{display:block;margin-left:auto;margin-right:auto}.pull-right{float:right !important}.pull-left{float:left !important}.hide{display:none !important}.show{display:block !important}.invisible{visibility:hidden}.text-hide{font:0/0 a;color:transparent;text-shadow:none;background-color:transparent;border:0}.hidden{display:none !important}.affix{position:fixed}\n          /* Manual Overrides */\n          .sciname {\n            font-style: italic;\n            }\n          .entry-sciname {\n            font-style: italic;\n            font-weight: bold;\n            }\n           body { padding: 1rem; }\n           .species-entry aside:first-child {\n             margin-top: 5rem;\n             }\n           section .entry-header {\n             text-indent: 2em;\n             }\n           .clade-declaration {\n             font-variant: small-caps;\n             border-top: 1px solid #000;\n             border-bottom: 1px solid #000;\n             page-break-before: always;\n             break-before: always;\n             }\n           .species-entry {\n             page-break-inside: avoid;\n             break-inside: avoid;\n             }\n           @media print {\n             body {\n               font-size:12px;\n               }\n             .h4 {\n               font-size: 13px;\n               }\n             @page {\n               counter-increment: page;\n               /*counter-reset: page 1;*/\n                @bottom-right {\n                 content: counter(page);\n                }\n                /* margin: 0px auto; */\n               }\n           }\n         </style>\n       </head>\n       <body>\n         <div class=\"container-fluid\">\n           <article>\n             <h1 class=\"text-center\">SSAR Common Names Checklist ver. " + dateString + "</h1>";
  args = "q=*&order=linnean_order,genus,species,subspecies";
  $.get("" + searchParams.apiPath, args, "json").done(function(result) {
    var authorityYears, c, dialogHtml, downloadable, e, entryHtml, error1, error2, error3, genusAuth, genusYear, hasReadClade, hasReadGenus, htmlCredit, htmlNotes, k, oneOffHtml, ref1, ref2, ref3, row, shortGenus, speciesAuth, speciesYear, taxonCreditDate, v;
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
      ref1 = result.result;
      for (k in ref1) {
        row = ref1[k];
        if (isNull(row.genus) || isNull(row.species)) {
          continue;
        }
        try {
          authorityYears = JSON.parse(row.authority_year);
          genusYear = "";
          speciesYear = "";
          for (c in authorityYears) {
            v = authorityYears[c];
            genusYear = c.replace(/&#39;/g, "'");
            speciesYear = v.replace(/&#39;/g, "'");
          }
          genusAuth = (row.genus_authority.toTitleCase()) + " " + genusYear;
          if (toInt(row.parens_auth_genus).toBool()) {
            genusAuth = "(" + genusAuth + ")";
          }
          speciesAuth = (row.species_authority.toTitleCase()) + " " + speciesYear;
          if (toInt(row.parens_auth_species).toBool()) {
            speciesAuth = "(" + speciesAuth + ")";
          }
        } catch (error1) {
          e = error1;
          console.warn("There was a problem parsing the authority information for _" + row.genus + " " + row.species + " " + row.subspecies + "_ - " + e.message);
          console.warn(e.stack);
          console.warn("We were working with", authorityYears, genusYear, genusAuth, speciesYear, speciesAuth);
        }
        try {
          htmlNotes = markdown.toHTML(row.notes);
        } catch (error2) {
          e = error2;
          console.warn("Unable to parse Markdown for _" + row.genus + " " + row.species + " " + row.subspecies + "_");
          htmlNotes = row.notes;
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
        if (ref2 = row.linnean_order.trim(), indexOf.call(hasReadClade, ref2) < 0) {
          oneOffHtml += "<h2 class=\"clade-declaration text-capitalize text-center\">" + row.linnean_order + " &#8212; " + row.major_common_type + "</h2>";
          hasReadClade.push(row.linnean_order.trim());
        }
        if (ref3 = row.genus, indexOf.call(hasReadGenus, ref3) < 0) {
          oneOffHtml += "<aside class=\"genus-declaration lead\">\n  <span class=\"entry-sciname text-capitalize\">" + row.genus + "</span>\n  <span class=\"entry-authority\">" + genusAuth + "</span>\n</aside>";
          hasReadGenus.push(row.genus);
        }
        shortGenus = (row.genus.slice(0, 1)) + ". ";
        entryHtml = "<section class=\"species-entry\">\n  " + oneOffHtml + "\n  <p class=\"h4 entry-header\">\n    <span class=\"entry-sciname\">\n      <span class=\"text-capitalize\">" + shortGenus + "</span> " + row.species + " " + row.subspecies + "\n    </span>\n    <span class=\"entry-authority\">\n      " + speciesAuth + "\n    </span>\n    &#8212;\n    <span class=\"common_name no-cap\">\n      " + (smartUpperCasing(row.common_name)) + "\n    </span>\n  </p>\n  <div class=\"entry-content\">\n    " + htmlNotes + "\n    " + htmlCredit + "\n  </div>\n</section>";
        htmlBody += entryHtml;
      }
      htmlBody += "</article>\n</div>\n</body>\n</html>";
      downloadable = "data:text/html;charset=utf-8," + (encodeURIComponent(htmlBody));
      dialogHtml = "<paper-dialog  modal class=\"download-file\" id=\"download-html-file\">\n  <h2>Your file is ready</h2>\n  <paper-dialog-scrollable class=\"dialog-content\">\n    <p class=\"text-center\">\n      <a href=\"" + downloadable + "\" download=\"asm-common-names-" + dateString + ".html\" class=\"btn btn-default\"><iron-icon icon=\"file-download\"></iron-icon> Download Now</a>\n    </p>\n  </paper-dialog-scrollable>\n  <div class=\"buttons\">\n    <paper-button dialog-dismiss>Close</paper-button>\n  </div>\n</paper-dialog>";
      if (!$("#download-html-file").exists()) {
        $("body").append(dialogHtml);
      } else {
        $("#download-html-file").replaceWith(dialogHtml);
      }
      $("#download-chooser").get(0).close();
      safariDialogHelper("#download-html-file");
      return $.post("pdf/pdfwrapper.php", "html=" + (encodeURIComponent(htmlBody)), "json").done(function(result) {
        var pdfDownloadPath;
        console.debug("PDF result", result);
        if (result.status) {
          pdfDownloadPath = "" + uri.urlString + result.file;
          console.debug(pdfDownloadPath);
        } else {
          console.error("Couldn't make PDF file");
        }
        return false;
      }).error(function(result, status) {
        return console.error("Wasn't able to fetch PDF");
      });
    } catch (error3) {
      e = error3;
      stopLoadError("There was a problem creating your file. Please try again later.");
      console.error("Exception in downloadHTMLList() - " + e.message);
      console.warn("Got", result, "from", searchParams.apiPath + "?" + args, result.status);
      return console.warn(e.stack);
    }
  }).fail(function() {
    return stopLoadError("There was a problem communicating with the server. Please try again later.");
  });
  return false;
};

showDownloadChooser = function() {
  var html;
  html = "<paper-dialog id=\"download-chooser\" modal>\n  <h2>Select Download Type</h2>\n  <paper-dialog-scrollable class=\"dialog-content\">\n    <p>\n      Once you select a file type, it will take a moment to prepare your download. Please be patient.\n    </p>\n  </paper-dialog-scrollable>\n  <div class=\"buttons\">\n    <paper-button dialog-dismiss>Cancel</paper-button>\n    <paper-button dialog-confirm id=\"initiate-csv-download\">CSV</paper-button>\n    <paper-button dialog-confirm id=\"initiate-html-download\">HTML</paper-button>\n  </div>\n</paper-dialog>";
  if (!$("#download-chooser").exists()) {
    $("body").append(html);
  }
  d$("#initiate-csv-download").click(function() {
    return downloadCSVList();
  });
  d$("#initiate-html-download").click(function() {
    return downloadHTMLList();
  });
  safariDialogHelper("#download-chooser");
  return false;
};

safariDialogHelper = function(selector, counter, callback) {
  var delayTimer, e, error1, newCount;
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
      d$(selector).get(0).open();
      if (typeof callback === "function") {
        callback();
      }
      return stopLoad();
    } catch (error1) {
      e = error1;
      newCount = counter + 1;
      delayTimer = 250;
      return delay(delayTimer, function() {
        console.warn("Trying again to display dialog after " + (newCount * delayTimer) + "ms");
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
  var browserExtensionLink, browsers, e, error1, html;
  if (asm.hasShownWorkaround == null) {
    asm.hasShownWorkaround = false;
  }
  if (asm.hasShownWorkaround) {
    return false;
  }
  try {
    browsers = new WhichBrowser();
  } catch (error1) {
    e = error1;
    return false;
  }
  if (browsers.isType("mobile")) {
    asm.hasShownWorkaround = true;
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
  asm.hasShownWorkaround = true;
  return false;
};

showBadSearchErrorMessage = function(result) {
  var filterText, i, sOrig, text;
  sOrig = result.query.replace(/\+/g, " ");
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
  return stopLoadError(text);
};

bindPaperMenuButton = function(selector, unbindTargets) {
  var dropdown, len, m, menu, ref1, relabelSelectedItem;
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
  ref1 = $(selector);
  for (m = 0, len = ref1.length; m < len; m++) {
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

$(function() {
  var col, devHello, e, error1, error2, error3, error4, f64, filterObj, fixState, fuzzyState, loadArgs, looseState, openFilters, queryUrl, selectedState, selector, temp, val;
  devHello = "****************************************************************************\nHello developer!\nIf you're looking for hints on our API information, this site is open-source\nand released under the GPL. Just click on the GitHub link on the bottom of\nthe page, or check out LINK_TO_ORG_REPO\n****************************************************************************";
  console.log(devHello);
  animateLoad();
  window.addEventListener("popstate", function(e) {
    var error1, loadArgs, temp;
    uri.query = $.url().attr("fragment");
    try {
      loadArgs = Base64.decode(uri.query);
    } catch (error1) {
      e = error1;
      loadArgs = "";
    }
    performSearch(loadArgs);
    temp = loadArgs.split("&")[0];
    return $("#search").attr("value", temp);
  });
  $("#do-reset-search").click(function() {
    return clearSearch();
  });
  $("#search_form").submit(function(e) {
    e.preventDefault();
    return performSearch();
  });
  $("#collapse-advanced").on("shown.bs.collapse", function() {
    return $("#collapse-icon").attr("icon", "icons:unfold-less");
  });
  $("#collapse-advanced").on("hidden.bs.collapse", function() {
    return $("#collapse-icon").attr("icon", "icons:unfold-more");
  });
  $("#search_form").keypress(function(e) {
    if (e.which === 13) {
      return performSearch();
    }
  });
  $("#do-search").click(function() {
    return performSearch();
  });
  $("#do-search-all").click(function() {
    return performSearch(true);
  });
  $("#linnean").on("iron-select", function() {
    if (!isNull($("#search").val())) {
      return performSearch();
    }
  });
  eutheriaFilterHelper();
  bindPaperMenuButton();
  if (isNull(uri.query)) {
    loadArgs = "";
  } else {
    try {
      loadArgs = Base64.decode(uri.query);
      queryUrl = $.url(searchParams.apiPath + "?q=" + loadArgs);
      try {
        looseState = queryUrl.param("loose").toBool();
      } catch (error1) {
        e = error1;
        looseState = false;
      }
      try {
        fuzzyState = queryUrl.param("fuzzy").toBool();
      } catch (error2) {
        e = error2;
        fuzzyState = false;
      }
      temp = loadArgs.split("&")[0];
      safariSearchArgHelper(temp);
      (fixState = function() {
        var error3, ref1;
        if ((typeof Polymer !== "undefined" && Polymer !== null ? (ref1 = Polymer.Base) != null ? ref1.$$ : void 0 : void 0) != null) {
          if (!isNull(Polymer.Base.$$("#loose"))) {
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
        if (asm.stateIter == null) {
          asm.stateIter = 0;
        }
        ++asm.stateIter;
        if (asm.stateIter > 30) {
          console.warn("Couldn't attach Polymer.Base.ready");
          return false;
        }
        try {
          return Polymer.Base.ready(function() {
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
        } catch (error3) {
          return delay(250, function() {
            return fixState();
          });
        }
      })();
      try {
        f64 = queryUrl.param("filter");
        filterObj = JSON.parse(Base64.decode(f64));
        openFilters = false;
        for (col in filterObj) {
          val = filterObj[col];
          col = col.replace(/_/g, "-");
          selector = "#" + col + "-filter";
          if (col !== "type") {
            if (col !== "is-alien") {
              $(selector).attr("value", val);
              openFilters = true;
            } else {
              selectedState = toInt(val) === 1 ? "alien-only" : "native-only";
              console.log("Setting alien-filter to " + selectedState);
              $("#alien-filter").get(0).selected = selectedState;
              delay(750, function() {
                return $("#alien-filter").get(0).selected = selectedState;
              });
            }
          } else {
            $("#linnean").polymerSelected(val);
          }
        }
        if (openFilters) {
          $("#collapse-advanced").collapse("show");
        }
      } catch (error3) {
        e = error3;
        f64 = false;
      }
    } catch (error4) {
      e = error4;
      console.error("Bad argument " + uri.query + " => " + loadArgs + ", looseState, fuzzyState", looseState, fuzzyState, searchParams.apiPath + "?q=" + loadArgs);
      console.warn(e.message);
      loadArgs = "";
    }
  }
  if (!isNull(loadArgs) && loadArgs !== "#") {
    return $.get(searchParams.targetApi, "q=" + loadArgs, "json").done(function(result) {
      if (result.status === true && result.count > 0) {
        formatSearchResults(result);
        return false;
      }
      showBadSearchErrorMessage(result);
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
      var error5, ref1;
      if ((typeof Polymer !== "undefined" && Polymer !== null ? (ref1 = Polymer.Base) != null ? ref1.$$ : void 0 : void 0) != null) {
        if (!isNull(Polymer.Base.$$("#loose"))) {
          delay(250, function() {
            d$("#loose").attr("checked", "checked");
            return eutheriaFilterHelper();
          });
          return false;
        }
      }
      if (asm.stateIter == null) {
        asm.stateIter = 0;
      }
      ++asm.stateIter;
      if (asm.stateIter > 30) {
        console.warn("Couldn't attach Polymer.Base.ready");
        return false;
      }
      try {
        return Polymer.Base.ready(function() {
          return delay(250, function() {
            d$("#loose").attr("checked", "checked");
            return eutheriaFilterHelper();
          });
        });
      } catch (error5) {
        return delay(250, function() {
          return fixState();
        });
      }
    })();
  }
});

//# sourceMappingURL=maps/c.js.map
