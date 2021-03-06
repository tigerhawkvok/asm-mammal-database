
/*
 * The main coffeescript file for administrative stuff
 * Triggered from admin-page.html
 */
var adminParams, adminPreloadSearch, createDuplicateTaxon, createNewTaxon, deleteTaxon, deprecatedHelper, fetchEditorDropdownContent, fillEmptyCommonName, handleDragDropImage, licenseHelper, loadAdminUi, loadModalTaxonEditor, lookupEditorSpecies, newColumnHelper, prefetchEditorDropdowns, renderAdminSearchResults, renderDeprecatedFromDatabase, saveEditorEntry, validateCitation, validateNewTaxon, verifyLoginCredentials,
  indexOf = [].indexOf || function(item) { for (var i = 0, l = this.length; i < l; i++) { if (i in this && this[i] === item) return i; } return -1; };

adminParams = new Object();

adminParams.apiTarget = "admin-api.php";

adminParams.adminPageUrl = "https://mammaldiversity.org/admin-page.html";

adminParams.loginDir = "admin/";

adminParams.loginApiTarget = adminParams.loginDir + "async_login_handler.php";

loadAdminUi = function() {

  /*
   * Main wrapper function. Checks for a valid login state, then
   * fetches/draws the page contents if it's OK. Otherwise, boots the
   * user back to the login page.
   */
  var e, error1;
  console.log("Loading admin UI");
  try {
    verifyLoginCredentials(function(data) {
      var cookieFullName, cookieName, mainHtml, searchForm;
      cookieName = uri.domain + "_name";
      cookieFullName = uri.domain + "_fullname";
      adminParams.cookieName = cookieName;
      adminParams.cookieFullName = cookieFullName;
      mainHtml = "<h3 class=\"col-xs-12\">\n  Welcome, " + ($.cookie(cookieName)) + "\n  <span id=\"pib-wrapper-settings\" class=\"pib-wrapper\" data-toggle=\"tooltip\" title=\"User Settings\" data-placement=\"bottom\">\n    <paper-icon-button icon='settings-applications' class='click' data-url='" + data.login_url + "'></paper-icon-button>\n  </span>\n  <span id=\"pib-wrapper-exit-to-app\" class=\"pib-wrapper\" data-toggle=\"tooltip\" title=\"Go to SADB app\" data-placement=\"bottom\">\n    <paper-icon-button icon='exit-to-app' class='click' data-url='" + uri.urlString + "' id=\"app-linkout\"></paper-icon-button>\n  </span>\n</h3>\n<div id='admin-actions-block' class=\"col-xs-12\">\n  <div class='bs-callout bs-callout-info'>\n    <p>Please be patient while the administrative interface loads.</p>\n  </div>\n</div>";
      $("main #main-body").html(mainHtml);
      bindClicks();

      /*
       * Render out the admin UI
       * We want a search box that we pipe through the API
       * and display the table out for editing
       */
      searchForm = "<form id=\"admin-search-form\" onsubmit=\"event.preventDefault()\" class=\"row\">\n  <div class=\"col-xs-7 col-sm-8\">\n    <paper-input label=\"Search for species\" id=\"admin-search\" name=\"admin-search\" required autofocus floatingLabel></paper-input>\n  </div>\n  <div class=\"col-xs-2 col-lg-1\">\n    <paper-fab id=\"do-admin-search\" icon=\"search\" raisedButton class=\"asm-blue\"></paper-fab>\n  </div>\n  <div class=\"col-xs-2 col-lg-1\">\n    <paper-fab id=\"do-admin-add\" icon=\"add\" raisedButton class=\"asm-blue\" title=\"Create New Taxon\" data-toggle=\"tooltip\"></paper-fab>\n  </div>\n  <div class=\"col-offset-lg-2\">\n    <!-- Placeholder -->\n  </div>\n</form>\n<div id='search-results' class=\"row\"></div>";
      $("#admin-actions-block").html("<div class='col-xs-12'>" + searchForm + "</div>");
      $("#admin-search-form").submit(function(e) {
        return e.preventDefault();
      });
      $("#admin-search").keypress(function(e) {
        if (e.which === 13) {
          return renderAdminSearchResults();
        }
      });
      $("#do-admin-search").click(function() {
        return renderAdminSearchResults();
      });
      $("#do-admin-add").click(function() {
        return createNewTaxon();
      });
      bindClickTargets();
      console.info("Successfully validated user");
      return false;
    });
  } catch (error1) {
    e = error1;
    console.error("Couldn't check status - " + e.message);
    console.warn(e.stack);
    $("main #main-body").html("<div class='bs-callout bs-callout-danger col-xs-12'><h4>Application Error</h4><p>There was an error in the application. Please refresh and try again. If this persists, please contact administration.</p></div>");
  }
  return false;
};

verifyLoginCredentials = function(callback) {

  /*
   * Checks the login credentials against the server.
   * This should not be used in place of sending authentication
   * information alongside a restricted action, as a malicious party
   * could force the local JS check to succeed.
   * SECURE AUTHENTICATION MUST BE WHOLLY SERVER SIDE.
   */
  var args, e, error1, hash, link, secret;
  try {
    hash = $.cookie(uri.domain + "_auth");
    secret = $.cookie(uri.domain + "_secret");
    link = $.cookie(uri.domain + "_link");
  } catch (error1) {
    e = error1;
    console.warn("Unable to verify login credentials: " + e.message);
    console.debug(e.stack);
  }
  args = "hash=" + hash + "&secret=" + secret + "&dblink=" + link;
  $.post(adminParams.loginApiTarget, args, "json").done(function(result) {
    var cookieFullName;
    console.log("Server called back from login credential verification", result);
    if (result.status === true) {
      $(".logged-in-values").removeAttr("hidden");
      $(".logged-in-hidden").attr("hidden", "hidden");
      cookieFullName = uri.domain + "_fullname";
      $("header .fill-user-fullname").text($.cookie(cookieFullName));
      if (typeof callback === "function") {
        return callback(result);
      }
    } else {
      $(".logged-in-values").remove();
      if (typeof callback === "function" && _asm.inhibitRedirect !== true) {
        if (!isNull(result.login_url)) {
          return goTo(result.login_url);
        } else {
          return $("main #main-body").html("<div class='bs-callout-danger bs-callout col-xs-12'><h4>Couldn't verify login</h4><p>There's currently a server problem. Try back again soon.</p><p>The server said:</p><code>" + result.error + "</code></div>");
        }
      } else {
        return console.log("Login credentials checked -- not logged in");
      }
    }
  }).fail(function(result, status) {
    $("main #main-body").html("<div class='bs-callout-danger bs-callout col-xs-12'><h4>Couldn't verify login</h4><p>There's currently a server problem. Try back again soon.</p></div>");
    console.log(result, status);
    return false;
  });
  return false;
};

renderAdminSearchResults = function(overrideSearch, containerSelector) {
  var args, b64s, newLink, s;
  if (containerSelector == null) {
    containerSelector = "#search-results";
  }

  /*
   * Takes parts of performSearch() but only in the admin context
   */
  s = $("#admin-search").val();
  if (isNull(s)) {
    if (typeof overrideSearch === "object") {
      s = overrideSearch.genus + " " + overrideSearch.species;
    } else {
      toastStatusMessage("Please enter a search term");
      return false;
    }
  }
  animateLoad();
  $("#admin-search").blur();
  s = s.replace(/\./g, "");
  s = prepURI(s.toLowerCase());
  args = "q=" + s + "&loose=true";
  b64s = Base64.encodeURI(s);
  newLink = uri.urlString + "#" + b64s;
  $("#app-linkout").attr("data-url", newLink);
  return $.get(searchParams.targetApi, args, "json").done(function(result) {
    var bootstrapColCount, bootstrapColSize, col, colClass, data, fragment, html, htmlClose, htmlHead, htmlRow, i, j, k, key, l, len, m, newPath, niceKey, origData, ref, ref1, requiredKeyOrder, row, targetCount, taxonObj, taxonQuery, taxonSplit, v;
    if (result.status !== true || result.count === 0) {
      stopLoadError();
      if (isNull(result.human_error)) {
        toastStatusMessage("Your search returned no results. Please try again.");
      } else {
        toastStatusMessage(result.human_error);
      }
      return false;
    }
    data = result.result;
    html = "";
    htmlHead = "<table id='cndb-result-list' class='table table-striped table-hover'>\n\t<thead class='cndb-row-headers'>";
    htmlClose = "</table>";
    targetCount = toInt(result.count) - 1;
    colClass = null;
    bootstrapColCount = 0;
    requiredKeyOrder = ["id", "genus", "species", "subspecies"];
    origData = data;
    data = new Object();
    for (i in origData) {
      row = origData[i];
      data[i] = new Object();
      for (m = 0, len = requiredKeyOrder.length; m < len; m++) {
        key = requiredKeyOrder[m];
        data[i][key] = row[key];
      }
    }
    for (i in data) {
      row = data[i];
      if (toInt(i) === 0) {
        j = 0;
        htmlHead += "\n<!-- Table Headers - " + (Object.size(row)) + " entries -->";
        console.debug("Got row", row);
        for (k in row) {
          v = row[k];
          niceKey = k.replace(/_/g, " ");
          if (k === "genus" || k === "species" || k === "subspecies") {
            htmlHead += "\n\t\t<th class='text-center'>" + niceKey + "</th>";
            bootstrapColCount++;
          }
          j++;
          if (j === Object.size(row)) {
            htmlHead += "\n\t\t<th class='text-center'>Edit</th>";
            bootstrapColCount++;
            htmlHead += "\n\t\t<th class='text-center'>Delete</th>";
            bootstrapColCount++;
            htmlHead += "\n\t\t<th class='text-center'>View</th>\n\t</thead>";
            bootstrapColCount++;
            htmlHead += "\n<!-- End Table Headers -->";
            console.log("Got " + bootstrapColCount + " display columns.");
            bootstrapColSize = roundNumber(12 / bootstrapColCount, 0);
            colClass = "col-md-" + bootstrapColSize;
          }
        }
      }
      taxonQuery = (row.genus.trim()) + "+" + (row.species.trim());
      if (!isNull(row.subspecies)) {
        taxonQuery = taxonQuery + "+" + (row.subspecies.trim());
      }
      htmlRow = "\n\t<tr id='cndb-row" + i + "' class='cndb-result-entry' data-taxon=\"" + taxonQuery + "\">";
      l = 0;
      for (k in row) {
        col = row[k];
        if (isNull(row.genus)) {
          return true;
        }
        if (k === "genus" || k === "species" || k === "subspecies") {
          htmlRow += "\n\t\t<td id='" + k + "-" + i + "' class='" + k + " " + colClass + "'><span>" + col + "</span></td>";
        }
        l++;
        if (l === Object.size(row)) {
          htmlRow += "\n\t\t<td id='edit-" + i + "' class='edit-taxon " + colClass + " text-center'><paper-icon-button icon='image:edit' class='edit' data-taxon='" + taxonQuery + "'></paper-icon-button></td>";
          htmlRow += "\n\t\t<td id='delete-" + i + "' class='delete-taxon " + colClass + " text-center'><paper-icon-button icon='icons:delete-forever' class='delete-taxon-button fadebg' data-taxon='" + taxonQuery + "' data-database-id='" + row.id + "'></paper-icon-button></td>";
          htmlRow += "\n\t\t<td id='visit-listing-" + i + "' class='view-taxon " + colClass + " text-center'><paper-icon-button icon='icons:visibility' class='view-taxon-button fadebg click' data-href='" + uri.urlString + "species-account.php?genus=" + (row.genus.trim()) + "&species=" + (row.species.trim()) + "' data-newtab='true'></paper-icon-button></td>";
          htmlRow += "\n\t</tr>";
          html += htmlRow;
        }
      }
      if (toInt(i) === targetCount) {
        html = htmlHead + html + htmlClose;
        $(containerSelector).html(html);
        console.log("Processed " + (toInt(i) + 1) + " rows");
        $(".edit").click(function() {
          var taxon;
          taxon = $(this).attr('data-taxon');
          return lookupEditorSpecies(taxon);
        });
        $(".delete-taxon-button").click(function() {
          var taxaId, taxon;
          taxon = $(this).attr('data-taxon');
          taxaId = $(this).attr('data-database-id');
          return deleteTaxon(taxaId);
        });
        bindClicks();
        try {
          taxonSplit = s.split(" ");
          taxonObj = {
            genus: taxonSplit[0],
            species: (ref = taxonSplit[1]) != null ? ref : "",
            subspecies: (ref1 = taxonSplit[2]) != null ? ref1 : ""
          };
          fragment = jsonTo64(taxonObj);
          try {
            newPath = uri.o.attr("base") + uri.o.attr("path");
            setHistory(newPath + "#" + fragment);
          } catch (undefined) {}
        } catch (undefined) {}
        stopLoad();
      }
    }
  }).fail(function(result, status) {
    var error;
    console.error("There was an error performing the search");
    console.warn(result, error, result.statusText);
    console.warn(searchParams.targetApi + "?" + args);
    error = result.status + "::" + result.statusText;
    return stopLoadError("Couldn't execute the search - " + error);
  });
};

fetchEditorDropdownContent = function(column, columnLabel, updateDom, localSave) {
  var colIdLabel;
  if (column == null) {
    column = "simple_linnean_goup";
  }
  if (updateDom == null) {
    updateDom = true;
  }
  if (localSave == null) {
    localSave = true;
  }

  /*
   * Ping the server for a list of unique entries for a given column
   */
  if (typeof (typeof _asm !== "undefined" && _asm !== null ? _asm.dropdownPopulation : void 0) !== "object") {
    if (typeof _asm !== "object") {
      window._asm = new Object();
    }
    _asm.dropdownPopulation = new Object();
  }
  colIdLabel = column.replace(/\_/g, "-");
  if (isNull(columnLabel)) {
    columnLabel = column.replace(/\_/g, " ").toTitleCase();
  }
  _asm.dropdownPopulation[column] = {
    html: "<paper-input label=\"" + columnLabel + "\" id=\"edit-" + colIdLabel + "\" name=\"edit-" + colIdLabel + "\" class=\"" + column + "\" floatingLabel></paper-input>"
  };
  $.get(searchParams.targetApi, "get_unique=true&col=" + column, "json").done(function(result) {
    var html, len, listHtml, m, selector, value, valueArray;
    if (result.status !== true) {
      console.warn("Didn't get a valid set of values for column '" + column + "': " + result.error);
      return false;
    }
    valueArray = Object.toArray(result.values);
    listHtml = "";
    for (m = 0, len = valueArray.length; m < len; m++) {
      value = valueArray[m];
      listHtml += "<paper-item data-value=\"" + value + "\" data-column=\"" + column + "\">" + value + "</paper-item>\n";
    }
    html = "<section class=\"row filled-editor-dropdown\">\n<div class=\"col-xs-9\">\n  <paper-dropdown-menu label=\"" + columnLabel + "\" id=\"edit-" + colIdLabel + "\" name=\"edit-" + colIdLabel + "\" class=\"" + column + "\" data-column=\"" + column + "\">\n    <paper-listbox class=\"dropdown-content\">\n      " + listHtml + "\n    </paper-listbox>\n  </paper-dropdown-menu>\n</div>\n<div class=\"col-xs-3\">\n  <paper-icon-button class=\"add-col-value\" data-column=" + column + " icon=\"icons:add-circle\" title=\"Add new " + columnLabel + "\" data-toggle=\"tooltip\"></paper-icon-button>\n</div>\n</section>";
    if (localSave) {
      _asm.dropdownPopulation[column] = {
        values: valueArray,
        html: html,
        selector: "#edit-" + colIdLabel
      };
    }
    if (updateDom) {
      selector = "#edit-" + colIdLabel;
      if ($(selector).exists()) {
        $(selector).replaceWith(html);
      }
    }
    return false;
  }).fail(function(result, error) {
    console.warn("Unable to get dropdown content for '" + column + "'");
    console.warn(result, error);
    return _asm.dropdownPopulation[column] = {
      html: "<paper-input label=\"" + columnLabel + "\" id=\"edit-" + colIdLabel + "\" name=\"edit-" + colIdLabel + "\" class=\"" + column + "\" floatingLabel></paper-input>"
    };
  });
  return false;
};

licenseHelper = function(selector) {
  if (selector == null) {
    selector = "#edit-image-license-dialog";
  }

  /*
   * License filler
   */
  $(selector).unbind();
  _asm._setLicenseDialog = function(el) {
    var currentLicenseName, currentLicenseUrl, html, targetColumn, urlPattern;
    targetColumn = $(el).attr("data-column");
    if (isNull(targetColumn)) {
      console.error("Unable to show dialog -- invalud column designator");
      return false;
    }
    console.debug("Add column fired -- target is " + targetColumn);
    $("paper-dialog#set-license-value").remove();
    currentLicenseName = $(selector).attr("data-license-name");
    currentLicenseUrl = $(selector).attr("data-license-url");
    html = "<paper-dialog id=\"set-license-value\" data-column=\"" + targetColumn + "\" modal>\n  <h2>Set License</h2>\n  <paper-dialog-scrollable>\n    <paper-input class=\"new-license-name license-field\" label=\"License Name\" floatingLabel autofocus value=\"" + currentLicenseName + "\" required autovalidate></paper-input>\n    <paper-input class=\"new-license-url license-field\" label=\"License URL\" floatingLabel value=\"" + currentLicenseUrl + "\" required autovalidate></paper-input>\n  </paper-dialog-scrollable>\n  <div class=\"buttons\">\n    <paper-button dialog-dismiss>Cancel</paper-button>\n    <paper-button class=\"add-value\">Set</paper-button>\n  </div>\n</paper-dialog>";
    $("body").append(html);
    urlPattern = "((?:https?)://(?:(?:(?:[0-9]+\\.){3}[0-9]+|(?:[0-9a-f]+:){6,8}|(?:[\\w~\\-]{2,}\\.)+[\\w]{2,}|localhost))/?(?:[\\w~\\-]*/?)*(?:(?:\\.\\w+)?(?:\\?(?:\\w+=\\w+&?)*)?))(?:#[\\w~\\-]+)?";
    p$("paper-input.new-license-url").pattern = urlPattern;
    p$("paper-input.new-license-url").errorMessage = "This must be a valid URL";
    p$("paper-input.new-license-name").errorMessage = "This cannot be empty";
    _asm._updateLicense = function() {
      var text;
      $("paper-icon-button#edit-image-license-dialog").attr("data-license-name", p$("paper-input.new-license-name").value).attr("data-license-url", p$("paper-input.new-license-url").value);
      text = (p$("paper-input.new-license-name").value) + " @ " + (p$("paper-input.new-license-url").value);
      p$("#edit-image-license").value = text;
      $("#edit-image-license").attr("data-license-name", p$("paper-input.new-license-name").value).attr("data-license-url", p$("paper-input.new-license-url").value);
      p$("#set-license-value").close();
      return false;
    };
    $("#set-license-value paper-button.add-value").click(function() {
      var error1, field, isReady, len, m, ref;
      isReady = true;
      ref = $("#set-license-value .license-field");
      for (m = 0, len = ref.length; m < len; m++) {
        field = ref[m];
        p$(field).validate();
        if (p$(field).invalid) {
          isReady = false;
        }
      }
      if (!isReady) {
        return false;
      }
      console.debug("isReady", isReady);
      try {
        _asm._updateLicense.debounce(50);
      } catch (error1) {
        console.warn("Couldn't debounce save new col call");
        stopLoadError("There was a problem saving this data");
      }
      return false;
    });
    $("#set-license-value").on("iron-overlay-opened", function() {
      p$(this).refit();
      return delay(100, (function(_this) {
        return function() {
          return p$(_this).refit();
        };
      })(this));
    });
    p$("#set-license-value").open();
    return false;
  };
  return $(selector).click(function() {
    console.debug("Set License clicked");
    _asm._setLicenseDialog.debounce(50, null, null, this);
    return false;
  });
};

newColumnHelper = function(selector) {
  if (selector == null) {
    selector = ".add-col-value";
  }
  $(selector).unbind();
  _asm._addColumnDialog = function(el) {
    var html, targetColumn;
    targetColumn = $(el).attr("data-column");
    if (isNull(targetColumn)) {
      console.error("Unable to show dialog -- invalud column designator");
      return false;
    }
    console.debug("Add column fired -- target is " + targetColumn);
    $("paper-dialog#add-column-value").remove();
    html = "<paper-dialog id=\"add-column-value\" data-column=\"" + targetColumn + "\" modal>\n  <h2>Add New <code>" + (targetColumn.replace(/[\_-]/g, " ")) + "</code> Value</h2>\n  <paper-dialog-scrollable>\n    <paper-input class=\"new-col-value\" label=\"Data Value\" floatingLabel autofocus></paper-input>\n  </paper-dialog-scrollable>\n  <div class=\"buttons\">\n    <paper-button dialog-dismiss>Cancel</paper-button>\n    <paper-button class=\"add-value\">Add</paper-button>\n  </div>\n</paper-dialog>";
    $("body").append(html);
    _asm._saveNewCol = function() {
      var item, listHtml, listbox, newValue;
      newValue = $("#add-column-value paper-input.new-col-value").val();
      console.log("Going to test and add '" + newValue + "'");
      if (indexOf.call(_asm.dropdownPopulation[targetColumn].values, newValue) >= 0) {
        console.warn("Invalid value: already exists");
        p$("#add-column-value paper-input.new-col-value").errorMessage = "This value already exists";
        p$("#add-column-value paper-input.new-col-value").invalid = true;
        p$("#add-column-value").refit();
        return false;
      }
      item = document.createElement("paper-item");
      item.setAttribute("data-value", newValue);
      item.setAttribute("data-column", targetColumn);
      item.textContent = newValue;
      listHtml = "<paper-item data-value=\"" + newValue + "\" data-column=\"" + targetColumn + "\">" + newValue + "</paper-item>\n";
      _asm.dropdownPopulation[targetColumn].values.push(newValue);
      _asm.dropdownPopulation[targetColumn].values.sort();
      listbox = p$("paper-dropdown-menu[data-column='" + targetColumn + "'] paper-listbox");
      Polymer.dom(listbox).appendChild(item);
      delay(250, function() {
        $("paper-dropdown-menu[data-column='" + targetColumn + "']").polymerSelected(newValue, true);
        return p$("#add-column-value").close();
      });
      return false;
    };
    $("#add-column-value paper-button.add-value").click(function() {
      var error1;
      try {
        _asm._saveNewCol.debounce(50);
      } catch (error1) {
        console.warn("Couldn't debounce save new col call");
        stopLoadError("There was a problem saving this data");
      }
      return false;
    });
    $("#add-column-value paper-input").keyup(function(e) {
      var error1, kc;
      kc = e.keyCode ? e.keyCode : e.which;
      if (kc === 13) {
        try {
          _asm._saveNewCol.debounce(50);
        } catch (error1) {
          console.warn("Couldn't debounce save new col call");
          stopLoadError("There was a problem saving this data");
        }
      }
      return false;
    });
    p$("#add-column-value").open();
    return false;
  };
  return $(selector).click(function() {
    console.debug("Add column clicked");
    _asm._addColumnDialog.debounce(50, null, null, this);
    return false;
  });
};

prefetchEditorDropdowns = function() {
  var col, label, needCols;
  needCols = {
    major_type: "Clade (eg., boreoeutheria)",
    major_subtype: "Sub-Clade (eg., euarchontoglires)",
    linnean_order: null,
    linnean_family: null,
    linnean_tribe: null,
    linnean_subfamily: null,
    simple_linnean_group: "Common Group (eg., metatheria)",
    simple_linnean_subgroup: "Common type (eg., bat)"
  };
  for (col in needCols) {
    label = needCols[col];
    fetchEditorDropdownContent(col, label);
  }
  return false;
};

window.prefetchEditorDropdowns = prefetchEditorDropdowns;

loadModalTaxonEditor = function(extraHtml, affirmativeText) {
  var e, editHtml, error1, error2, error3, html, prettyDate, today;
  if (extraHtml == null) {
    extraHtml = "";
  }
  if (affirmativeText == null) {
    affirmativeText = "Save";
  }

  /*
   * Load a modal taxon editor
   */
  today = new Date();
  prettyDate = today.toISOString().split("T")[0];
  editHtml = "<paper-input label=\"Genus\" id=\"edit-genus\" name=\"edit-genus\" class=\"genus\" floatingLabel></paper-input>\n<paper-input label=\"Species\" id=\"edit-species\" name=\"edit-species\" class=\"species\" floatingLabel></paper-input>\n<paper-input label=\"Subspecies\" id=\"edit-subspecies\" name=\"edit-subspecies\" class=\"subspecies\" floatingLabel></paper-input>\n<paper-input label=\"Common Name\" id=\"edit-common-name\" name=\"edit-common-name\"  class=\"common_name\" floatingLabel></paper-input>\n<paper-input label=\"Common Name Source\" id=\"edit-common-name-source\" name=\"edit-common-name-source\"  class=\"common_name_source\" floatingLabel readonly></paper-input>\n<div class=\"row\">\n  <paper-input label=\"Deprecated Scientific Names\" id=\"edit-deprecated-scientific\" name=\"edit-depreated-scientific\" floatingLabel aria-describedby=\"deprecatedHelp\" data-column=\"deprecated_scientific\" class=\"col-xs-10\" readonly></paper-input>\n  <div class=\"col-xs-2\">\n    <paper-icon-button icon=\"icons:create\" id=\"fire-deprecated-editor\" title=\"Edit deprecated scientifics\" data-toggle=\"tooltip\"></paper-icon-button>\n  </div>\n  <span class=\"help-block col-xs-12\" id=\"deprecatedHelp\">Click the edit button to fill the old names.</span>\n</div>\n" + _asm.dropdownPopulation.major_type.html + "\n" + _asm.dropdownPopulation.major_subtype.html + "\n" + _asm.dropdownPopulation.linnean_order.html + "\n" + _asm.dropdownPopulation.linnean_family.html + "\n" + _asm.dropdownPopulation.linnean_subfamily.html + "\n" + _asm.dropdownPopulation.linnean_tribe.html + "\n" + _asm.dropdownPopulation.simple_linnean_group.html + "\n" + _asm.dropdownPopulation.simple_linnean_subgroup.html + "\n<paper-input label=\"Genus authority\" id=\"edit-genus-authority\" name=\"edit-genus-authority\" class=\"genus_authority\" floatingLabel></paper-input>\n<paper-input label=\"Genus authority year\" id=\"edit-gauthyear\" name=\"edit-gauthyear\" floatingLabel></paper-input>\n<paper-input label=\"Genus authority citation\" id=\"edit-genus-authority-citation\" name=\"edit-genus-authority-citation\" class=\"citation-input\" floatingLabel></paper-input>\n<iron-label>\n  Use Parenthesis for Genus Authority\n  <paper-toggle-button id=\"genus-authority-parens\"  checked=\"false\"></paper-toggle-button>\n</iron-label>\n<paper-input label=\"Species authority\" id=\"edit-species-authority\" name=\"edit-species-authority\" class=\"species_authority\" floatingLabel></paper-input>\n<paper-input label=\"Species authority year\" id=\"edit-sauthyear\" name=\"edit-sauthyear\" floatingLabel></paper-input>\n<paper-input label=\"Species authority citation\" id=\"edit-species-authority-citation\" name=\"edit-species-authority-citation\" class=\"citation-input\" floatingLabel></paper-input>\n<iron-label>\n  Use Parenthesis for Species Authority\n  <paper-toggle-button id=\"species-authority-parens\" checked=\"false\"></paper-toggle-button>\n</iron-label>\n<br/><br/>\n<paper-input label=\"ASM ID Number\" id=\"edit-internal-id\" name=\"edit-internal-id\" floatingLabel></paper-input>\n<br/>\n<span class=\"help-block\" id=\"notes-help\">You can write your notes and entry in Markdown. (<a href=\"https://daringfireball.net/projects/markdown/syntax\" \"onclick='window.open(this.href); return false;' onkeypress='window.open(this.href); return false;'\">Official Full Syntax Guide</a>)</span>\n<br/><br/>\n<h3 class='text-muted'>Taxon Notes <small>(optional)</small></h3>\n<iron-autogrow-textarea id=\"edit-notes\" rows=\"5\" aria-describedby=\"notes-help\" placeholder=\"Notes\" class=\"markdown-region\"  data-md-field=\"notes-markdown-preview\">\n  <textarea placeholder=\"Notes\" id=\"edit-notes-textarea\" name=\"edit-notes-textarea\" aria-describedby=\"notes-help\" rows=\"5\"></textarea>\n</iron-autogrow-textarea>\n<marked-element id=\"notes-markdown-preview\" class=\"markdown-preview\">\n  <div class=\"markdown-html\"></div>\n</marked-element>\n<br/><br/>\n<h3 class='text-muted'>Main Taxon Entry</h3>\n<iron-autogrow-textarea id=\"edit-entry\" rows=\"5\" aria-describedby=\"notes-help\" placeholder=\"Entry\" class=\"markdown-region\" data-md-field=\"entry-markdown-preview\">\n  <textarea placeholder=\"Entry\" id=\"edit-entry-textarea\" name=\"edit-entry-textarea\" aria-describedby=\"entry-help\" rows=\"5\"></textarea>\n</iron-autogrow-textarea>\n<marked-element id=\"entry-markdown-preview\" class=\"markdown-preview\">\n  <div class=\"markdown-html\"></div>\n</marked-element>\n<paper-input label=\"Data Source\" id=\"edit-source\" name=\"edit-source\" floatingLabel></paper-input>\n<paper-input label=\"Data Citation (Markdown Allowed)\" id=\"edit-citation\" name=\"edit-citation\" floatingLabel></paper-input>\n<div id=\"upload-image\"></div>\n<span class=\"help-block\" id=\"upload-image-help\">You can drag and drop an image above, or enter its server path below.</span>\n<paper-input label=\"Image\" id=\"edit-image\" name=\"edit-image\" floatingLabel aria-describedby=\"imagehelp\"></paper-input>\n  <span class=\"help-block\" id=\"imagehelp\">The image path here should be relative to the <code>public_html/</code> directory. Check the preview below.</span>\n<paper-input label=\"Image Caption\" id=\"edit-image-caption\" name=\"edit-image-caption\" floatingLabel></paper-input>\n<paper-input label=\"Image Credit\" id=\"edit-image-credit\" name=\"edit-image-credit\" floatingLabel></paper-input>\n<section class=\"row license-region\">\n  <div class=\"col-xs-9\">\n    <paper-input label=\"Image License\" id=\"edit-image-license\" name=\"edit-image-license\" data-license-name=\"\" data-license-url=\"\" floatingLabel readonly></paper-input>\n  </div>\n  <div class=\"col-xs-3\">\n    <paper-icon-button icon=\"icons:create\" id=\"edit-image-license-dialog\" data-license-name=\"\" data-license-url=\"\" data-column=\"image_license\" data-toggle='tooltip' title=\"Edit License\"></paper-icon-button>\n  </div>\n</section>\n<paper-input label=\"Taxon Credit\" id=\"edit-taxon-credit\" name=\"edit-taxon-credit\" floatingLabel aria-describedby=\"taxon-credit-help\" value=\"" + ($.cookie(adminParams.cookieFullName)) + "\"></paper-input>\n<paper-input label=\"Taxon Credit Date\" id=\"edit-taxon-credit-date\" name=\"edit-taxon-credit-date\" floatingLabel value=\"" + prettyDate + "\"></paper-input>\n<span class=\"help-block\" id=\"taxon-credit-help\">This will be displayed as \"Entry by <span class='taxon-credit-preview'></span> on <span class='taxon-credit-date-preview'></span>.\"</span>\n" + extraHtml + "\n<input type=\"hidden\" name=\"edit-taxon-author\" id=\"edit-taxon-author\" value=\"\" />";
  html = "<paper-dialog modal id='modal-taxon-edit' entry-animation=\"scale-up-animation\" exit-animation=\"fade-out-animation\">\n  <h2 id=\"editor-title\">Taxon Editor</h2>\n  <paper-dialog-scrollable id='modal-taxon-editor'>\n    " + editHtml + "\n  </paper-dialog-scrollable>\n  <div class=\"buttons\">\n    <paper-button id='close-editor' dialog-dismiss>Cancel</paper-button>\n    <paper-button id='duplicate-taxon'>Duplicate</paper-button>\n    <paper-button id='save-editor'>" + affirmativeText + "</paper-button>\n  </div>\n</paper-dialog>";
  if ($("#modal-taxon-edit").exists()) {
    $("#modal-taxon-edit").remove();
  }
  $("#search-results").after(html);
  try {
    newColumnHelper();
  } catch (error1) {
    e = error1;
    console.warn("Couldn't bind columns: " + e.message);
    console.warn(e.stack);
  }
  try {
    licenseHelper();
  } catch (error2) {
    e = error2;
    console.warn("Couldn't set license helper: " + e.message);
    console.warn(e.stack);
  }
  try {
    deprecatedHelper();
    $("#fire-deprecated-editor").click(function() {
      var elTarget;
      elTarget = p$("#edit-deprecated-scientific");
      return _asm._setDeprecatedDialog.debounce(null, null, null, elTarget);
    });
  } catch (error3) {
    e = error3;
    console.warn("Couldn't set deprecated helper: " + e.message);
    console.warn(e.stack);
  }
  try {
    $(".citation-input").keyup(function() {
      return validateCitation(this);
    });
  } catch (undefined) {}
  handleDragDropImage();
  $("#modal-taxon-edit").unbind();
  d$("#save-editor").unbind();
  return d$("#duplicate-taxon").unbind().click(function() {
    return createDuplicateTaxon();
  });
};

deprecatedHelper = function(selector) {
  if (selector == null) {
    selector = "#edit-deprecated-taxon-dialog";
  }

  /*
   * Helper for the otherwise JSON entries of the deprecated
   */
  $(selector).unbind();
  _asm._setDeprecatedDialog = function(el) {
    var addToListClickEvent, currentTaxon, currentTaxonAuthority, dialogSelector, html, json64Orig, list, ref, ref1, ref2, ref3, ref4, ref5, targetColumn;
    targetColumn = $(el).attr("data-column");
    if (isNull(targetColumn)) {
      console.error("Unable to show dialog -- invalud column designator");
      return false;
    }
    console.debug("Setup deprecated fired -- target is " + targetColumn);
    dialogSelector = "#set-deprecated-taxa";
    $(dialogSelector).remove();
    currentTaxon = {
      genus: (ref = p$("#edit-genus").value) != null ? ref : "",
      species: (ref1 = p$("#edit-species").value) != null ? ref1 : ""
    };
    currentTaxonAuthority = {
      genus: {
        authority: (ref2 = p$("#edit-genus-authority").value) != null ? ref2 : "",
        year: (ref3 = p$("#edit-gauthyear").value) != null ? ref3 : "",
        parens: p$("#genus-authority-parens").checked ? "checked" : ""
      },
      species: {
        authority: (ref4 = p$("#edit-species-authority").value) != null ? ref4 : "",
        year: (ref5 = p$("#edit-gauthyear").value) != null ? ref5 : "",
        parens: p$("#species-authority-parens").checked ? "checked" : ""
      }
    };
    _asm._updateDeprecatedListItem = function(json64attr) {
      var authorities, authorityParts, authorityString, e, error1, jDep, list, listEl, oldTaxon, prettyElement, yearParts;
      if (json64attr == null) {
        json64attr = void 0;
      }
      if (isNull(json64attr)) {
        json64attr = $("#deprecated-taxon-json").val();
      }
      try {
        jDep = JSON.parse(decode64(json64attr));
        console.log("Rendering with", jDep);
        listEl = new Array();
        for (oldTaxon in jDep) {
          authorityString = jDep[oldTaxon];
          try {
            oldTaxon = oldTaxon.replace(/\-/g, " ");
          } catch (undefined) {}
          authorityParts = authorityString.split(":");
          authorities = authorityParts[0];
          yearParts = authorityParts[1].split("$");
          prettyElement = " " + oldTaxon + " <iron-icon icon=\"icons:arrow-forward\"></iron-icon> " + (authorities.toTitleCase()) + " in " + yearParts[0];
          listEl.push(prettyElement);
        }
        list = "<li>" + (listEl.join("</li>\n<li>")) + "</li>";
      } catch (error1) {
        e = error1;
        console.warn("Didn't parse JSON: " + e.message);
        console.warn(e.stack);
        list = "<em>No deprecated identifiers</em>";
      }
      return list;
    };
    json64Orig = $("#edit-deprecated-scientific").attr("data-json");
    list = _asm._updateDeprecatedListItem(json64Orig);
    html = "<paper-dialog id=\"" + (dialogSelector.slice(1)) + "\" data-column=\"" + targetColumn + "\" modal>\n  <h2>Set Deprecated Taxa</h2>\n  <paper-dialog-scrollable>\n    <div class=\"row\">\n      <h3 class=\"col-xs-12\">Alternate Taxon Names</h3>\n      <ul id=\"deprecated-taxon-list\" class=\"col-xs-11 col-xs-offset-1\">\n        " + list + "\n      </ul>\n      <input type=\"hidden\" value=\"" + json64Orig + "\" id=\"deprecated-taxon-json\"/>\n    </div>\n    <div class=\"form\">\n      <div class=\"row update-old-taxon\">\n        <paper-input class=\"col-xs-12\" value=\"" + currentTaxon.genus + "\" label=\"Old Genus\" placeholder=\"" + currentTaxon.genus + "\" id=\"dialog-update-genus\" required autovalidate></paper-input>\n        <paper-input class=\"col-xs-12\" value=\"" + currentTaxon.species + "\" label=\"Old Species\" placeholder=\"" + currentTaxon.species + "\" id=\"dialog-update-species\" required autovalidate></paper-input>\n        <paper-input class=\"col-xs-6\" value=\"" + currentTaxonAuthority.genus.authority + "\" label=\"Old Authority\" placeholder=\"" + currentTaxonAuthority.genus.authority + "\" required autovalidate floatingLabel id=\"dialog-update-authority\"></paper-input>\n        <paper-input class=\"col-xs-6\" value=\"" + currentTaxonAuthority.genus.year + "\" label=\"Old Year\" placeholder=\"" + currentTaxonAuthority.genus.year + "\" pattern=\"[0-9]{4}\" error-message=\"Invalid Year\" required autovalidate floatingLabel id=\"dialog-update-year\"></paper-input>\n        <paper-input class=\"col-xs-6\" value=\"" + currentTaxonAuthority.genus.year + "\" label=\"Year Assigned\" placeholder=\"" + currentTaxonAuthority.genus.year + "\" pattern=\"[0-9]{4}\" error-message=\"Invalid Year\" required autovalidate floatingLabel id=\"dialog-update-citeyear\"></paper-input>\n      </div>\n      <div class=\"row\">\n        <div class=\"col-xs-12 text-right pull-right\">\n          <button class=\"btn btn-primary\" id=\"add-to-json-list\">Add To List</button>\n        </div>\n      </div>\n    </div>\n  </paper-dialog-scrollable>\n  <div class=\"buttons\">\n    <paper-button dialog-dismiss>Cancel</paper-button>\n    <paper-button class=\"add-value\">Set</paper-button>\n  </div>\n</paper-dialog>";
    $("body").append(html);
    p$(dialogSelector).open();
    addToListClickEvent = function() {
      var canProceed, error1, field, jDep, jString, json64attr, len, linnaeusYear, m, oldAuthorityString, oldTaxon, oldTaxonString, ref6, today;
      canProceed = true;
      ref6 = $(dialogSelector + " paper-input");
      for (m = 0, len = ref6.length; m < len; m++) {
        field = ref6[m];
        p$(field).errorMessage = "This field can't be empty";
        p$(field).validate();
        if (p$(field).invalid) {
          canProceed = false;
        }
      }
      if (!canProceed) {
        return false;
      }
      json64attr = $("#deprecated-taxon-json").val();
      try {
        jDep = JSON.parse(decode64(json64attr));
        if (typeof jDep !== "object") {
          jDep = new Object();
        }
      } catch (error1) {
        jDep = new Object();
      }
      oldTaxon = {
        genus: p$("#dialog-update-genus").value.trim().toTitleCase(),
        species: p$("#dialog-update-species").value.trim(),
        authority: p$("#dialog-update-authority").value.trim(),
        year: toInt(p$("#dialog-update-year").value.trim()),
        citeYear: toInt(p$("#dialog-update-citeyear").value.trim())
      };
      if (currentTaxon.genus.toLowerCase() === oldTaxon.genus.toLowerCase()) {
        if (currentTaxon.species.toLowerCase() === oldTaxon.species.toLowerCase()) {
          console.warn("Taxon is the same as the primary");
          p$("#dialog-update-genus").errorMessage = "This name is the same as the current one";
          p$("#dialog-update-genus").invalid = true;
          p$("#dialog-update-species").errorMessage = "This name is the same as the current one";
          p$("#dialog-update-species").invalid = true;
          return false;
        }
      }
      linnaeusYear = 1707;
      today = new Date();
      if (oldTaxon.year < linnaeusYear || oldTaxon.year > today.getFullYear()) {
        console.warn("Invalid year");
        p$("#dialog-update-year").errorMessage = "The year must be after " + linnaeusYear + " and on or before " + (today.getFullYear());
        p$("#dialog-update-year").invalid = true;
        return false;
      }
      oldTaxonString = oldTaxon.genus + " " + oldTaxon.species;
      oldAuthorityString = oldTaxon.authority + ":" + oldTaxon.year + "$" + oldTaxon.citeYear;
      console.log("Got strings", oldTaxonString, oldAuthorityString);
      jDep[oldTaxonString] = oldAuthorityString;
      console.log("Object:", jDep);
      jString = JSON.stringify(jDep);
      console.log("Stringified:", jString);
      $("#deprecated-taxon-json").val(encode64(jString));
      list = _asm._updateDeprecatedListItem();
      $("#deprecated-taxon-list").html(list);
      return false;
    };
    $(dialogSelector + " #add-to-json-list").click(function() {
      addToListClickEvent.debounce(75);
      return false;
    });
    _asm._updateDeprecated = function() {
      var json, json64attr, prettyEntry;
      json64attr = $("#deprecated-taxon-json").val();
      if (!isNull(json64attr)) {
        json = decode64(json64attr);
      } else {
        json = "{}";
      }
      prettyEntry = json.slice(1, -1);
      p$(el).value = prettyEntry;
      return false;
    };
    $(dialogSelector + " .buttons paper-button.add-value").click(function() {
      _asm._updateDeprecated.debounce();
      p$("" + dialogSelector).close();
      return false;
    });
    return false;
  };
  return false;
};

renderDeprecatedFromDatabase = function() {
  return false;
};

fillEmptyCommonName = function() {
  return false;
};

validateNewTaxon = function() {

  /*
   *
   */
  var args, taxon, taxonExistsHelper, taxonString;
  taxonExistsHelper = function(invalid) {
    var editFields, fieldLabel, len, m, selector;
    if (invalid == null) {
      invalid = true;
    }
    editFields = ["genus", "species", "subspecies"];
    for (m = 0, len = editFields.length; m < len; m++) {
      fieldLabel = editFields[m];
      selector = "#edit-" + fieldLabel;
      if (invalid) {
        p$(selector).invalid = true;
        p$(selector).errorMessage = "This taxon already exists in the database";
        p$("#save-editor").disabled = true;
      } else {
        p$(selector).invalid = false;
        p$("#save-editor").disabled = false;
      }
    }
    return false;
  };
  taxon = {
    genus: p$("#edit-genus").value,
    species: p$("#edit-species").value,
    subspecies: !isNull(p$("#edit-subspecies").value) ? p$("#edit-subspecies").value : ""
  };
  args = "q=" + taxon.genus + "+" + taxon.species;
  taxonString = taxon.genus + " " + taxon.species;
  if (!isNull(taxon.subspecies)) {
    args += "+" + taxon.subspecies;
    taxonString += " " + taxon.subspecies;
  }
  $.get(searchParams.apiPath, args + "&dwc_only=true", "json").done(function(result) {
    var len, m, ref, testTaxon;
    if (result.status !== true) {
      console.error("Problem validating taxon:", result);
      return false;
    }
    ref = Object.toArray(result.result);
    for (m = 0, len = ref.length; m < len; m++) {
      testTaxon = ref[m];
      if (testTaxon.genus.toLowerCase() === taxon.genus.toLowerCase()) {
        if (testTaxon.specificEpithet.toLowerCase() === taxon.species.toLowerCase()) {
          try {
            if (isNull(taxon.subspecies) && isNull(testTaxon.subspecificEpithet)) {
              console.warn("Taxon sp already exists in DB");
              return taxonExistsHelper();
            } else if (taxon.subspecies.toLowerCase() === testTaxon.subspecificEpithet.toLowerCase()) {
              console.warn("Taxon ssp already exists in DB");
              return taxonExistsHelper();
            } else {
              continue;
            }
          } catch (undefined) {}
        } else {
          continue;
        }
      } else {
        continue;
      }
    }
    taxonExistsHelper(false);
    args = "missing=true&genus=" + taxon.genus + "&species=" + taxon.species + "&prefetch=true";
    $.get(searchParams.apiPath, args, "json").done(function(result) {
      var authorityYear, commonName, error1, genusAuthority, genusAuthorityYear, iucnData, ref1, speciesAuthority, speciesAuthorityYear;
      if (!isNumeric(result.id)) {
        console.error("Unable to find IUCN result");
        return false;
      }
      iucnData = result;
      commonName = (ref1 = iucnData.main_common_name) != null ? ref1 : iucnData.common_name;
      speciesAuthority = iucnData.species_authority;
      genusAuthority = iucnData.genus_authority;
      try {
        authorityYear = JSON.parse(iucnData.authority_year);
        genusAuthorityYear = Object.keys(authorityYear)[0];
        speciesAuthorityYear = authorityYear[genusAuthorityYear];
      } catch (error1) {
        genusAuthorityYear = "";
        speciesAuthorityYear = "";
      }
      p$("#edit-common-name").value = commonName;
      p$("#edit-common-name-source").value = "iucn";
      p$("#edit-genus-authority").value = genusAuthority;
      p$("#edit-species-authority").value = speciesAuthority;
      p$("#edit-gauthyear").value = genusAuthorityYear;
      p$("#edit-sauthyear").value = speciesAuthorityYear;
      try {
        p$("#genus-authority-parens").checked = iucnData.parens_auth_genus.toBool();
        p$("#species-authority-parens").checked = iucnData.parens_auth_species.toBool();
      } catch (undefined) {}
      console.log("Got", commonName, speciesAuthority, genusAuthority, authorityYear, genusAuthorityYear, speciesAuthorityYear);
      return false;
    });
    return false;
  }).fail(function(result, status) {
    console.error("FAIL_VALIDATE");
    return false;
  });
  return false;
};

createNewTaxon = function() {

  /*
   * Load a blank modal taxon editor, ready to make a new one
   */
  var error1, whoEdited, windowHeight;
  animateLoad();
  loadModalTaxonEditor("", "Create");
  d$("#editor-title").text("Create New Taxon");
  windowHeight = $(window).height() * .5;
  d$("#modal-taxon-editor").css("min-height", windowHeight + "px");
  d$("#modal-taxon-editor div.scrollable").css("max-height", "");
  d$("#modal-taxon-edit").addClass("create-new-taxon");
  d$("#duplicate-taxon").remove();
  whoEdited = isNull($.cookie(uri.domain + "_fullname")) ? $.cookie(uri.domain + "_user") : $.cookie(uri.domain + "_fullname");
  d$("#edit-taxon-author").attr("value", whoEdited);
  d$("#save-editor").click(function() {
    return saveEditorEntry("new");
  });
  $("#modal-taxon-edit").on("iron-overlay-opened", function() {
    var e, editFields, entry, error1, fieldLabel, len, len1, m, n, notes, ref, region, selector;
    console.log("Binding new taxon events");
    editFields = ["genus", "species", "subspecies"];
    for (m = 0, len = editFields.length; m < len; m++) {
      fieldLabel = editFields[m];
      selector = "#edit-" + fieldLabel;
      $(selector).keyup(function() {
        return validateNewTaxon.debounce();
      });
    }
    try {
      entry = $(p$("#edit-entry").textarea).val();
      notes = $(p$("#edit-notes").textarea).val();
      p$("#entry-markdown-preview").markdown = entry;
      p$("#notes-markdown-preview").markdown = notes;
      ref = $(".markdown-region");
      for (n = 0, len1 = ref.length; n < len1; n++) {
        region = ref[n];
        $(p$(region).textarea).keyup(function() {
          var e, error1, md, target;
          md = $(this).val();
          target = $(this).parents("iron-autogrow-textarea").attr("data-md-field");
          try {
            p$("#" + target).markdown = md;
            return console.debug("Wrote markdown to target '#" + target + "'");
          } catch (error1) {
            e = error1;
            return console.warn("Can't update preview for target '#" + target + "'", $(this).get(0), md);
          }
        });
      }
    } catch (error1) {
      e = error1;
      console.error("Couldn't run markdown previews");
    }
    return validateNewTaxon();
  });
  try {
    p$("#modal-taxon-edit").open();
  } catch (error1) {
    $("#modal-taxon-edit").get(0).open();
  }
  return stopLoad();
};

createDuplicateTaxon = function() {

  /*
   * Accessed from an existing taxon modal editor.
   *
   * Remove the edited notes, remove the duplicate button, and change
   * the bidings so a new entry is created.
   */
  var e, editFields, error1, fieldLabel, len, m, newButton, selector;
  animateLoad();
  try {
    d$("#taxon-id").remove();
    d$("#last-edited-by").remove();
    d$("#duplicate-taxon").remove();
    d$("#editor-title").text("Create Duplicate Taxon");
    newButton = "<paper-button id=\"save-editor\">Create</paper-button>";
    d$("#save-editor").replaceWith(newButton);
    d$("#save-editor").click(function() {
      return saveEditorEntry("new");
    });
    delay(250, function() {
      return stopLoad();
    });
    editFields = ["genus", "species", "subspecies"];
    for (m = 0, len = editFields.length; m < len; m++) {
      fieldLabel = editFields[m];
      selector = "#edit-" + fieldLabel;
      $(selector).keyup(function() {
        return validateNewTaxon.debounce();
      });
    }
    validateNewTaxon();
  } catch (error1) {
    e = error1;
    stopLoadError("Unable to duplicate taxon");
    console.error("Couldn't duplicate taxon! " + e.message);
    d$("#modal-taxon-edit").get(0).close();
  }
  return true;
};

lookupEditorSpecies = function(taxon) {
  var args, existensial, genusArray, k, lastEdited, originalNames, replacementNames, speciesArray, subspeciesArray, taxonArray, v;
  if (taxon == null) {
    taxon = void 0;
  }

  /*
   * Lookup a given species and load it for editing
   * Has some hooks for badly formatted taxa.
   *
   * @param taxon a URL-encoded string for a taxon.
   */
  if (taxon == null) {
    return false;
  }
  animateLoad();
  lastEdited = "<p id=\"last-edited-by\">\n  Last edited by <span id=\"taxon-author-last\" class=\"capitalize\"></span>\n</p>\n<input type='hidden' name='taxon-id' id='taxon-id'/>";
  loadModalTaxonEditor(lastEdited);
  d$("#save-editor").click(function() {
    return saveEditorEntry();
  });
  existensial = d$("#last-edited-by").exists();
  if (!existensial) {
    d$("#taxon-credit-help").after(lastEdited);
  }

  /*
   * After
   * https://github.com/tigerhawkvok/SSAR-species-database/issues/33 :
   *
   * Some entries have illegal scientific names. Fix them, and assume
   * the wrong ones are deprecated.
   *
   * Therefore, "Phrynosoma (Anota) platyrhinos"  should use
   * "Anota platyrhinos" as the real name and "Phrynosoma platyrhinos"
   * as the deprecated.
   */
  replacementNames = void 0;
  originalNames = void 0;
  args = "q=" + taxon;
  if (taxon.search(/\(/) !== -1) {
    originalNames = {
      genus: "",
      species: "",
      subspecies: ""
    };
    replacementNames = {
      genus: "",
      species: "",
      subspecies: ""
    };
    taxonArray = taxon.split("+");
    k = 0;
    while (k < taxonArray.length) {
      v = taxonArray[k];
      console.log("Checking '" + v + "'");
      switch (toInt(k)) {
        case 0:
          genusArray = v.split("(");
          console.log("Looking at genus array", genusArray);
          originalNames.genus = genusArray[0].trim();
          replacementNames.genus = genusArray[1] != null ? genusArray[1].trim().slice(0, -1) : genusArray[0];
          break;
        case 1:
          speciesArray = v.split("(");
          console.log("Looking at species array", speciesArray);
          originalNames.species = speciesArray[0].trim();
          replacementNames.species = speciesArray[1] != null ? speciesArray[1].trim().slice(0, -1) : speciesArray[0];
          break;
        case 2:
          subspeciesArray = v.split("(");
          console.log("Looking at ssp array", subspeciesArray);
          originalNames.subspecies = subspeciesArray[0].trim();
          replacementNames.subspecies = subspeciesArray[1] != null ? subspeciesArray[1].trim().slice(0, -1) : subspeciesArray[0];
          break;
        default:
          console.error("K value of '" + k + "' didn't match 0,1,2!");
      }
      taxonArray[k] = v.trim();
      k++;
    }
    taxon = originalNames.genus + "+" + originalNames.species;
    if (!isNull(originalNames.subspecies)) {
      taxon += originalNames.subspecies;
    }
    args = "q=" + taxon + "&loose=true";
    console.warn("Bad name! Calculated out:");
    console.warn("Should be currently", replacementNames);
    console.warn("Was previously", originalNames);
    console.warn("Pinging with", "" + uri.urlString + searchParams.targetApi + "?q=" + taxon);
  }
  $.get(searchParams.targetApi, args, "json").done(function(result) {
    var category, col, colAsDropdownExists, colSplit, d, data, dropdownTentativeSelector, e, error1, error2, error3, fieldSelector, hasParens, j, jstr, license, licenseUrl, modalElement, speciesString, tempSelector, textAreas, textarea, today, toggleColumns, unformattedAuthorityRe, unformattedAuthorityReOrig, whoEdited, width, year;
    try {
      console.debug("Admin lookup rending editor UI for", result);
      data = result.result[0];
      if (data == null) {
        stopLoadError("Sorry, there was a problem parsing the information for this taxon. If it persists, you may have to fix it manually.");
        console.error("No data returned for", searchParams.targetApi + "?q=" + taxon);
        return false;
      }
      try {
        data.deprecated_scientific = JSON.parse(data.deprecated_scientific);
      } catch (error1) {
        e = error1;
      }
      if (originalNames != null) {
        toastStatusMessage("Bad information found. Please review and resave.");
        data.genus = replacementNames.genus;
        data.species = replacementNames.species;
        data.subspecies = replacementNames.subspecies;
        if (typeof data.deprecated_scientific !== "object") {
          data.deprecated_scientific = new Object();
        }
        speciesString = originalNames.species;
        if (!isNull(originalNames.subspecies)) {
          speciesString += " " + originalNames.subspecies;
        }
        data.deprecated_scientific[(originalNames.genus.toTitleCase()) + " " + speciesString] = "AUTHORITY: YEAR";
      }
      toggleColumns = ["parens_auth_genus", "parens_auth_species"];
      console.debug("Using data", data);
      console.debug(JSON.stringify(data));
      for (col in data) {
        d = data[col];
        try {
          if (typeof d === "string") {
            d = d.trim();
          }
        } catch (undefined) {}
        if (col === "id") {
          $("#taxon-id").attr("value", d);
        }
        colAsDropdownExists = false;
        try {
          dropdownTentativeSelector = "#edit-" + (col.replace(/\_/g, "-"));
          if ($(dropdownTentativeSelector).get(0).tagName.toLowerCase() === "paper-dropdown-menu") {
            colAsDropdownExists = true;
          }
        } catch (undefined) {}
        console.debug("Col editor exists for '" + dropdownTentativeSelector + "'?", colAsDropdownExists);
        if (colAsDropdownExists) {
          console.debug("Trying to polymer-select", d);
          $(dropdownTentativeSelector).polymerSelected(d, true);
        }
        if (col === "species_authority" || col === "genus_authority") {
          if (/[0-9]{4}/im.test(d)) {
            unformattedAuthorityRe = /^\(? *((['"]?) *(?:(?:\b|[\u00C0-\u017F])[a-z\u00C0-\u017F\u2019 \.\-\[\]\?]+(?:,|,? *&|,? *&amp;| *&amp;amp;| *&(?:[a-z]+|#[0-9]+);)? *)+ *\2) *, *([0-9]{4}) *\)?/img;
            unformattedAuthorityReOrig = /^\(? *((['"])? *([\w\u00C0-\u017F\. \-\&;\[\]]+(,|&|&amp;|&amp;amp;|&#[\w0-9]+;)?)+ *\2) *, *([0-9]{4}) *\)?/im;
            if (unformattedAuthorityRe.test(d)) {
              hasParens = d.search(/\(/) >= 0 && d.search(/\)/) >= 0;
              year = d.replace(unformattedAuthorityRe, "$3");
              d = d.replace(unformattedAuthorityRe, "$1");
              if (col === "genus_authority") {
                $("#edit-gauthyear").attr("value", year);
              }
              if (col === "species_authority") {
                $("#edit-sauthyear").attr("value", year);
              }
              if (hasParens) {
                p$("#" + (col.replace(/\_/g, "-")) + "-parens").checked = true;
              }
            }
          }
        }
        if (col === "authority_year") {
          year = parseTaxonYear(d);
          if (typeof year === "object") {
            $("#edit-gauthyear").attr("value", year.genus);
            $("#edit-sauthyear").attr("value", year.species);
          }
        } else if (indexOf.call(toggleColumns, col) >= 0) {
          colSplit = col.split("_");
          if (colSplit[0] === "parens") {
            category = col.split("_").pop();
            tempSelector = "#" + category + "-authority-parens";
          } else {
            tempSelector = "#" + (col.replace(/_/g, "-"));
          }
          d$(tempSelector).polymerChecked(toInt(d).toBool());
        } else if (col === "taxon_author") {
          if (d === "null" || isNull(d)) {
            $("#last-edited-by").remove();
            console.warn("Removed #last-edited-by! Didn't have an author provided for column '" + col + "', giving '" + d + "'. It's probably the first edit to this taxon.");
          } else {
            d$("#taxon-author-last").text(d);
          }
          whoEdited = isNull($.cookie(uri.domain + "_fullname")) ? $.cookie(uri.domain + "_user") : $.cookie(uri.domain + "_fullname");
          d$("#edit-taxon-author").attr("value", whoEdited);
        } else if (col === "taxon_credit") {
          fieldSelector = "#edit-" + (col.replace(/_/g, "-"));
          p$(fieldSelector).value = $.cookie(adminParams.cookieFullName);
        } else if (col === "image_license") {
          jstr = d.unescape();
          try {
            j = JSON.parse(jstr);
            for (license in j) {
              licenseUrl = j[license];
              $("#edit-image-license-dialog").attr("data-license-name", license).attr("data-license-url", licenseUrl);
              $("#edit-image-license").attr("data-license-name", license).attr("data-license-url", licenseUrl);
              d = license + " @ " + licenseUrl;
              break;
            }
          } catch (error2) {
            d = jstr;
          }
          p$("#edit-image-license").value = d;
        } else if (col === "taxon_credit_date") {
          if (isNull(d)) {
            today = new Date();
            d = today.toISOString().split("T")[0];
            fieldSelector = "#edit-" + (col.replace(/_/g, "-"));
            p$(fieldSelector).value = d;
          }
        } else {
          fieldSelector = "#edit-" + (col.replace(/_/g, "-"));
          if (col === "deprecated_scientific") {
            try {
              $(fieldSelector).attr("data-json", encode64(JSON.stringify(d)));
            } catch (undefined) {}
            d = JSON.stringify(d).trim().replace(/\\/g, "");
            d = d.replace(/{/, "");
            d = d.replace(/}/, "");
            if (d === '""') {
              d = "";
            }
          }
          try {
            if (typeof d === "string") {
              d = d.unescape();
            }
          } catch (undefined) {}
          textAreas = ["notes", "entry"];
          if (indexOf.call(textAreas, col) < 0) {
            d$(fieldSelector).attr("value", d);
          } else {
            width = $("#modal-taxon-edit").width() * .9;
            d$(fieldSelector).css("width", width + "px");
            textarea = p$(fieldSelector).textarea;
            $(textarea).text(d.unescape());
          }
        }
      }
      modalElement = p$("#modal-taxon-edit");
      $("#modal-taxon-edit").on("iron-overlay-opened", function() {
        var dateFill, entry, len, m, nameFill, notes, origCommonName, ref, region, results;
        p$("#modal-taxon-edit").refit();
        origCommonName = p$("#edit-common-name").value;
        $("#edit-common-name").keyup(function() {
          var name, userValue;
          console.debug("Common name field edited!");
          if (p$(this).value !== origCommonName) {
            name = $.cookie(adminParams.cookieFullName);
            userValue = "user:" + name;
          } else {
            userValue = "iucn";
          }
          p$("#edit-common-name-source").value = userValue;
          return false;
        });
        _asm.updateImageField = function(el) {
          var path, previewImageHtml;
          path = p$(el).value;
          console.log("Should render preview image of ", path);
          if ($("#preview-main-image").exists()) {
            $("#preview-main-image").remove();
          }
          previewImageHtml = "<img id=\"preview-main-image\" class='preview-image' src=\"" + path + "\" />";
          $("#imagehelp").after(previewImageHtml);
          return false;
        };
        $("#edit-image").on("focus", function() {
          var el;
          el = this;
          _asm.updateImageField.debounce(null, null, null, el);
          return false;
        }).on("blur", function() {
          var el;
          el = this;
          _asm.updateImageField.debounce(null, null, null, el);
          return false;
        }).on("keyup", function() {
          var el;
          el = this;
          _asm.updateImageField.debounce(null, null, null, el);
          return false;
        });
        try {
          _asm.updateImageField(p$("#edit-image"));
        } catch (undefined) {}
        nameFill = function(el) {
          var name;
          name = p$(el).value;
          $("#taxon-credit-help .taxon-credit-preview").text(name);
          return name;
        };
        dateFill = function(el) {
          var dateEntry, dateObj, dateString;
          dateEntry = p$(el).value;
          dateObj = new Date(dateEntry);
          dateString = (dateObj.getUTCDate()) + " " + (dateMonthToString(dateObj.getUTCMonth())) + " " + (dateObj.getUTCFullYear());
          $("#taxon-credit-help .taxon-credit-date-preview").text(dateString);
          return dateString;
        };
        $("#edit-taxon-credit").keyup(function() {
          nameFill(this);
          return false;
        });
        $("#edit-taxon-credit-date").keyup(function() {
          dateFill(this);
          return false;
        });
        nameFill(p$("#edit-taxon-credit"));
        dateFill(p$("#edit-taxon-credit-date"));
        entry = $(p$("#edit-entry").textarea).val();
        notes = $(p$("#edit-notes").textarea).val();
        p$("#entry-markdown-preview").markdown = entry;
        p$("#notes-markdown-preview").markdown = notes;
        ref = $(".markdown-region");
        results = [];
        for (m = 0, len = ref.length; m < len; m++) {
          region = ref[m];
          results.push($(p$(region).textarea).keyup(function() {
            var error3, md, target;
            md = $(this).val();
            target = $(this).parents("iron-autogrow-textarea").attr("data-md-field");
            try {
              p$("#" + target).markdown = md;
              return console.debug("Wrote markdown to target '#" + target + "'");
            } catch (error3) {
              e = error3;
              return console.warn("Can't update preview for target '#" + target + "'", $(this).get(0), md);
            }
          }));
        }
        return results;
      });
      safariDialogHelper("#modal-taxon-edit");
      return stopLoad();
    } catch (error3) {
      e = error3;
      stopLoadError("Unable to populate the editor for this taxon - " + e.message);
      console.error("Error populating the taxon popup -- " + e.message);
      return console.warn(e.stack);
    }
  }).fail(function(result, status) {
    return stopLoadError("There was a server error populating this taxon. Please try again.");
  });
  return false;
};

validateCitation = function(citation) {

  /*
   * Check a citation for validity
   */
  var cleanup, doi, isbn10, isbn13, markInvalid, replace, selector;
  markInvalid = false;
  try {
    if ($(citation).exists()) {
      selector = citation;
      if (typeof p$(citation).validate === "function") {
        markInvalid = true;
        citation = p$(selector).value;
      } else {
        citation = $(selector).val();
      }
    }
  } catch (undefined) {}
  cleanup = function(result, replacement) {
    if (markInvalid) {
      if (result === false) {
        p$(selector).errorMessage = "Please enter a valid DOI or ISBN";
      } else {
        if (!isNull(replacement)) {
          p$(selector).value = replacement;
        }
      }
      p$(selector).invalid = !result;
    }
    return result;
  };
  doi = /^(?:doi:|https?:\/\/dx.doi.org\/)?(10.\d{4,9}\/[-._;()\/:A-Z0-9]+|10.1002\/[^\s]+|10.\d{4}\/\d+-\d+X?(\d+)\d+<[\d\w]+:[\d\w]*>\d+.\d+.\w+;\d|10.1207\/[\w\d]+\&\d+_\d+)$/im;
  if (doi.test(citation)) {
    replace = citation.replace(doi, "$1");
    return cleanup(true, replace);
  }
  if (citation.search(/isbn/i) === 0) {
    isbn10 = /^(?:ISBN(?:-10)?:?\ )?(?=[0-9X]{10}$|(?=(?:[0-9]+[-\ ]){3})[-\ 0-9X]{13}$)[0-9]{1,5}[-\ ]?[0-9]+[-\ ]?[0-9]+[-\ ]?[0-9X]$/;
    isbn13 = /^(?:ISBN(?:-13)?:?\ )?(?=[0-9]{13}$|(?=(?:[0-9]+[-\ ]){4})[-\ 0-9]{17}$)97[89][-\ ]?[0-9]{1,5}[-\ ]?[0-9]+[-\ ]?[0-9]+[-\ ]?[0-9]$/;
    return cleanup(isbn10.test(citation) && isbn13.test(citation));
  }
  return cleanup(false);
};

saveEditorEntry = function(performMode) {
  var args, auth, authYearString, authority, authorityA, col, colAsDropdownExists, completionErrorMessage, consoleError, dep, depA, depS, depString, dropdownTentativeSelector, e, err, error, error1, error2, error3, error4, error5, error6, escapeCompletion, examineIds, gYear, hash, id, isTextArea, item, k, keepCase, len, licenseName, licenseUrl, link, m, nullTest, parsedDate, requiredNotEmpty, s64, sYear, saveObject, saveString, secret, selectorSample, spilloverError, taxon, testAuthorityYear, testSelector, trimmedYearString, userVerification, val, valJson, year;
  if (performMode == null) {
    performMode = "save";
  }

  /*
   * Send an editor state along with login credentials,
   * and report the save result back to the user
   */
  examineIds = ["genus", "species", "subspecies", "common-name", "major-type", "major-subtype", "linnean-order", "linnean-family", "simple-linnean-group", "simple-linnean-subgroup", "genus-authority", "species-authority", "notes", "entry", "image", "image-credit", "image-license", "image-caption", "taxon-author", "taxon-credit", "taxon-credit-date", "internal-id", "source", "citation", "species-authority-citation", "genus-authority-citation"];
  saveObject = new Object();
  escapeCompletion = false;
  d$("paper-input").removeAttr("invalid");
  try {
    testAuthorityYear = function(authYearDeepInputSelector, directYear) {
      var altYear, authorityRegex, completionErrorMessage, d, error, linnaeusYear, nextYear, ref, yearString, years;
      if (directYear == null) {
        directYear = false;
      }

      /*
       * Helper function!
       * Take in a deep element selector, then run it through match
       * patterns for the authority year.
       *
       * @param authYearDeepInputSelector -- Selector for a shadow DOM
       *          element, ideally a paper-input.
       */
      if (directYear) {
        yearString = authYearDeepInputSelector;
      } else {
        yearString = d$(authYearDeepInputSelector).val();
      }
      error = void 0;
      linnaeusYear = 1707;
      d = new Date();
      nextYear = d.getUTCFullYear() + 1;
      authorityRegex = /^[1-2][07-9]\d{2}$|^[1-2][07-9]\d{2} (\"|')[1-2][07-9]\d{2}\1$/;
      if (!(isNumber(yearString) && (linnaeusYear < yearString && yearString < nextYear))) {
        if (!authorityRegex.test(yearString)) {
          if (yearString.search(" ") === -1) {
            error = "This must be a valid year between " + linnaeusYear + " and " + nextYear;
          } else {
            error = "Nonstandard years must be of the form: YYYY 'YYYY', eg, 1801 '1802'";
          }
        } else {
          if (yearString.search(" ") === -1) {
            error = "This must be a valid year between " + linnaeusYear + " and " + nextYear;
          } else {
            years = yearString.split(" ");
            if (!((linnaeusYear < (ref = years[0]) && ref < nextYear))) {
              error = "The first year must be a valid year between " + linnaeusYear + " and " + nextYear;
            }
            altYear = years[1].replace(/(\"|')/g, "");
            if (!((linnaeusYear < altYear && altYear < nextYear))) {
              error = "The second year must be a valid year between " + linnaeusYear + " and " + nextYear;
            }
            yearString = yearString.replace(/'/g, '"');
          }
        }
      }
      if (error != null) {
        escapeCompletion = true;
        completionErrorMessage = authYearDeepInputSelector + " failed its validity checks for `" + yearString + "`!";
        console.warn(completionErrorMessage);
        if (!directYear) {
          d$("" + authYearDeepInputSelector).attr("error-message", error).attr("invalid", "invalid");
        } else {
          throw Error(error);
        }
      }
      return yearString;
    };
    try {
      gYear = testAuthorityYear("#edit-gauthyear");
      sYear = testAuthorityYear("#edit-sauthyear");
      console.log("Escape Completion State:", escapeCompletion);
    } catch (error1) {
      e = error1;
      console.error("Unable to parse authority year! " + e.message);
      authYearString = "";
    }
    auth = new Object();
    auth[gYear] = sYear;
    authYearString = JSON.stringify(auth);
  } catch (error2) {
    e = error2;
    console.error("Failed to JSON parse the authority year - " + e.message);
    authYearString = "";
  }
  saveObject["authority_year"] = authYearString;
  try {
    dep = new Object();
    depS = d$("#edit-deprecated-scientific").val();
    if (!isNull(depS)) {
      depA = depS.split('","');
      for (m = 0, len = depA.length; m < len; m++) {
        k = depA[m];
        item = k.split("\":\"");
        dep[item[0].replace(/"/g, "")] = item[1].replace(/"/g, "");
      }
      console.log("Validating", dep);
      for (taxon in dep) {
        authority = dep[taxon];
        authorityA = authority.split(":");
        console.log("Testing " + authority, authorityA);
        if (authorityA.length !== 2) {
          throw Error("Authority string should have an authority and year seperated by a colon.");
        }
        auth = authorityA[0].trim();
        trimmedYearString = authorityA[1].trim();
        if (trimmedYearString.search(",") !== -1) {
          throw Error("Looks like there may be an extra space, or forgotten \", near '" + trimmedYearString + "' ");
        }
        year = testAuthorityYear(trimmedYearString, true);
        console.log("Validated", auth, year);
      }
      depString = JSON.stringify(dep);
      if (depString.replace(/[{}]/g, "") !== depS) {
        throw Error("Badly formatted entry - generated doesn't match read");
      }
    } else {
      depString = "";
    }
  } catch (error3) {
    e = error3;
    console.error("Failed to parse the deprecated scientifics - " + e.message + ". They may be empty.");
    depString = "";
    error = e.message + ". Check your formatting!";
    d$("#edit-deprecated-scientific").attr("error-message", error).attr("invalid", true);
    escapeCompletion = true;
    completionErrorMessage = "There was a problem with your formatting for the deprecated scientifics. Please check it and try again.";
  }
  saveObject["deprecated_scientific"] = depString;
  keepCase = ["notes", "entry", "taxon_credit", "image", "image_credit", "image_license", "image_caption", "species-authority-citation", "species_authority_citation", "genus-authority-citation", "genus_authority_citation", "citation"];
  requiredNotEmpty = ["genus", "species", "major-type", "linnean-order", "genus-authority", "species-authority"];
  if (!isNull(d$("#edit-image").val())) {
    requiredNotEmpty.push("image-credit");
    requiredNotEmpty.push("image-license");
  }
  if (!isNull(d$("#edit-taxon-credit").val())) {
    requiredNotEmpty.push("taxon-credit-date");
  }
  for (k in examineIds) {
    id = examineIds[k];
    if (typeof id !== "string") {
      continue;
    }
    console.log(k, id);
    try {
      col = id.replace(/-/g, "_");
    } catch (error4) {
      console.warn("Unable to test against id '" + id + "'");
      continue;
    }
    testSelector = "#edit-" + (col.replace(/\_/img, "-"));
    colAsDropdownExists = false;
    try {
      dropdownTentativeSelector = testSelector;
      if ($(dropdownTentativeSelector).get(0).tagName.toLowerCase() === "paper-dropdown-menu") {
        colAsDropdownExists = true;
      }
    } catch (undefined) {}
    console.debug("Col editor exists for '" + dropdownTentativeSelector + "'?", colAsDropdownExists);
    if (colAsDropdownExists) {
      val = $(dropdownTentativeSelector).polymerSelected();
    } else {
      if (col === "image_license") {
        valJson = new Object();
        licenseName = $("#edit-image-license").attr("data-license-name");
        licenseUrl = $("#edit-image-license").attr("data-license-url");
        valJson[licenseName] = licenseUrl;
        val = JSON.stringify(valJson);
      } else {
        isTextArea = false;
        try {
          if ($("#edit-" + id).get(0).tagName.toLowerCase() === "iron-autogrow-textarea") {
            isTextArea = true;
          }
        } catch (undefined) {}
        if (!isTextArea) {
          try {
            val = d$("#edit-" + id).val().trim();
          } catch (error5) {
            e = error5;
            val = "";
            err = "Unable to get value for " + id;
            console.warn(err + ": " + e.message);
            toastStatusMessage(err);
          }
        } else {
          val = p$("#edit-" + id).value;
          if (isNull(val)) {
            val = $(p$("#edit-" + id).textarea).val();
          }
          try {
            val = val.trim();
          } catch (undefined) {}
        }
      }
    }
    if (indexOf.call(keepCase, col) < 0) {
      try {
        if (isNumber(val)) {
          if (val === toInt(val).toString()) {
            val = toInt(val);
          } else if (vale === toFloat(val).toString()) {
            val = toFloat(val);
          }
        }
        val = val.toLowerCase();
      } catch (error6) {
        e = error6;
        console.warn("Column '" + col + "' threw error for value '" + val + "': " + e.message);
        if (isNull(val)) {
          val = "";
        }
      }
    }
    switch (id) {
      case "genus":
      case "species":
      case "subspecies":
        error = "This required field must have only letters";
        nullTest = id === "genus" || id === "species" ? isNull(val) : false;
        if (/[^A-Za-z]/m.test(val) || nullTest) {
          d$("#edit-" + id).attr("error-message", error).attr("invalid", "invalid");
          escapeCompletion = true;
          completionErrorMessage = "Invalid Scientific Name";
        }
        break;
      case "major-type":
      case "linnean-order":
      case "genus-authority":
      case "species-authority":
        error = "This cannot be empty";
        if (isNull(val)) {
          $("#edit-" + id).attr("error-message", error).attr("invalid", "invalid");
          escapeCompletion = true;
          completionErrorMessage = "Missing Field";
        }
        break;
      default:
        if (indexOf.call(requiredNotEmpty, id) >= 0) {
          selectorSample = "#edit-" + id;
          spilloverError = "This must not be empty";
          if (selectorSample === "#edit-image-credit" || selectorSample === "#edit-image-license") {
            spilloverError = "This cannot be empty if an image is provided";
          }
          if (selectorSample === "#edit-taxon-credit-date") {
            parsedDate = new Date(val);
            if (parsedDate === "Invalid Date") {
              spilloverError = "We couldn't understand your date format. Please try again.";
              val = null;
            } else {
              val = parsedDate.toISOString().split("T")[0];
              $(selectorSample).attr("value", val);
              spilloverError = "If you have a taxon credit, it also needs a date";
            }
          }
          if (isNull(val)) {
            d$("#edit-" + id).attr("error-message", spilloverError).attr("invalid", "invalid");
            escapeCompletion = true;
            completionErrorMessage = "REQUIRED_FIELD_EMPTY";
          }
        }
    }
    saveObject[col] = val;
  }
  saveObject.id = toInt(d$("#taxon-id").val());
  saveObject.parens_auth_genus = d$("#genus-authority-parens").polymerChecked();
  saveObject.parens_auth_species = d$("#species-authority-parens").polymerChecked();
  saveObject.canonical_sciname = isNull(saveObject.subspecies) ? (saveObject.genus.toTitleCase()) + " " + saveObject.species : (saveObject.genus.toTitleCase()) + " " + saveObject.species + " " + saveObject.subspecies;
  if (escapeCompletion) {
    animateLoad();
    consoleError = completionErrorMessage != null ? completionErrorMessage : "Bad characters in entry. Stopping ...";
    completionErrorMessage = "There was a problem with your entry. Please correct your entry and try again. " + completionErrorMessage;
    stopLoadError(completionErrorMessage);
    console.error(consoleError);
    console.warn("Save object so far:", saveObject);
    return true;
  }
  if (performMode === "save") {
    if (!isNumber(saveObject.id)) {
      animateLoad();
      stopLoadError("The system was unable to generate a valid taxon ID for this entry. Please see the console for more details.");
      console.error("Unable to get a valid, numeric taxon id! We got '" + saveObject.id + "'.");
      console.warn("The total save object so far is:", saveObject);
      return false;
    }
  }
  saveString = JSON.stringify(saveObject);
  s64 = Base64.encodeURI(saveString);
  if (isNull(saveString) || isNull(s64)) {
    animateLoad();
    stopLoadError("The system was unable to parse this entry for the server. Please see the console for more details.");
    console.error("Unable to stringify the JSON!.");
    console.warn("The total save object so far is:", saveObject);
    console.warn("Got the output string", saveSring);
    console.warn("Sending b64 string", s64);
    return true;
  }
  hash = $.cookie(uri.domain + "_auth");
  secret = $.cookie(uri.domain + "_secret");
  link = $.cookie(uri.domain + "_link");
  userVerification = "hash=" + hash + "&secret=" + secret + "&dblink=" + link;
  args = "perform=" + performMode + "&" + userVerification + "&data=" + s64;
  console.log("Going to save", saveObject);
  console.log("Using mode '" + performMode + "'");
  animateLoad();
  return $.post(adminParams.apiTarget, args, "json").done(function(result) {
    if (result.status === true) {
      console.log("Server returned", result);
      if (escapeCompletion) {
        stopLoadError("Warning! The item saved, even though it wasn't supposed to.");
        return false;
      }
      d$("#modal-taxon-edit").get(0).close();
      if (!isNull($("#admin-search").val())) {
        renderAdminSearchResults();
      }
      prefetchEditorDropdowns();
      stopLoad();
      delay(250, function() {
        return stopLoad();
      });
      console.log("Save complete");
      return false;
    }
    stopLoadError(result.human_error);
    console.error(result.error);
    console.warn("Server returned", result);
    console.warn("We sent", "" + uri.urlString + adminParams.apiTarget + "?" + args);
    return false;
  }).fail(function(result, status) {
    stopLoadError("Failed to send the data to the server.");
    console.error("Server error! We sent", "" + uri.urlString + adminParams.apiTarget + "?" + args);
    return false;
  });
};

deleteTaxon = function(taxaId) {
  var args, caller, diff, safetyTimeout, taxon, taxonRaw;
  caller = $(".delete-taxon .delete-taxon-button[data-database-id='" + taxaId + "']");
  taxonRaw = caller.attr("data-taxon").replace(/\+/g, " ");
  taxon = taxonRaw.substr(0, 1).toUpperCase() + taxonRaw.substr(1);
  if (!caller.hasClass("extreme-danger")) {
    window.deleteWatchTimer = Date.now();
    delay(300, function() {
      return delete window.deleteWatchTimer;
    });
    caller.addClass("extreme-danger").attr("icon", "icons:delete-sweep");
    safetyTimeout = 7500;
    delay(safetyTimeout, function() {
      return caller.removeClass("extreme-danger").attr("icon", "icons:delete-forever");
    });
    toastStatusMessage("Click again to confirm deletion of " + taxon + ". This can't be undone.", "", safetyTimeout);
    return false;
  }
  if (window.deleteWatchTimer != null) {
    diff = Date.now() - window.deleteWatchTimer;
    console.warn("The taxon was asked to be deleted " + diff + "ms after the confirmation was prompted. Rejecting ...");
    return false;
  }
  animateLoad();
  args = "perform=delete&id=" + taxaId;
  return $.post(adminParams.apiTarget, args, "json").done(function(result) {
    console.log("Filed delete", adminParams.apiTarget + "?" + args);
    console.log("Server response", result);
    if (result.status === true) {
      caller.parents("tr").remove();
      try {
        p$("#search-status").hide();
      } catch (undefined) {}
      window._metaStatus.isToasting = false;
      delay(250, function() {
        return toastStatusMessage(taxon + " with ID " + taxaId + " has been removed from the database.");
      });
      stopLoad();
    } else {
      stopLoadError(result.human_error);
      console.error(result.error);
      console.warn(result);
    }
    return false;
  }).fail(function(result, status) {
    stopLoadError("Failed to communicate with the server.");
    return false;
  });
};

handleDragDropImage = function(uploadTargetSelector, callback) {
  if (uploadTargetSelector == null) {
    uploadTargetSelector = "#upload-image";
  }

  /*
   * Take a drag-and-dropped image, and save it out to the database.
   * If we trigger this, we need to disable #edit-image
   */
  if (typeof callback !== "function") {
    callback = function(file, result) {
      var e, error1, ext, fileName, fullFile, fullPath;
      if (result.status !== true) {
        if (result.human_error == null) {
          result.human_error = "There was a problem uploading your image.";
        }
        toastStatusMessage(result.human_error);
        console.error("Error uploading!", result);
        return false;
      }
      try {
        fileName = file.name;
        _asm.dropzone.disable();
        ext = fileName.split(".").pop();
        fullFile = (md5(fileName)) + "." + ext;
        fullPath = "species_photos/" + fullFile;
        d$("#edit-image").attr("disabled", "disabled").attr("value", fullPath);
        toastStatusMessage("Upload complete");
      } catch (error1) {
        e = error1;
        console.error("There was a problem with upload post-processing - " + e.message);
        console.warn("Using", fileName, result);
        toastStatusMessage("Your upload completed, but we couldn't post-process it.");
      }
      return false;
    };
  }
  loadJS("bower_components/JavaScript-MD5/js/md5.min.js");
  loadJS("bower_components/dropzone/dist/min/dropzone.min.js", function() {
    var c, defaultText, dragCancel, dropzoneConfig, fileUploadDropzone;
    c = document.createElement("link");
    c.setAttribute("rel", "stylesheet");
    c.setAttribute("type", "text/css");
    c.setAttribute("href", "css/dropzone.min.css");
    document.getElementsByTagName('head')[0].appendChild(c);
    Dropzone.autoDiscover = false;
    defaultText = "Drop a high-resolution image for the taxon here.";
    dragCancel = function() {
      d$(uploadTargetSelector).css("box-shadow", "").css("border", "");
      return d$(uploadTargetSelector + " .dz-message span").text(defaultText);
    };
    dropzoneConfig = {
      url: uri.urlString + "meta.php?do=upload_image",
      acceptedFiles: "image/*",
      autoProcessQueue: true,
      maxFiles: 1,
      dictDefaultMessage: defaultText,
      init: function() {
        this.on("error", function() {
          return toastStatusMessage("An error occured sending your image to the server.");
        });
        this.on("canceled", function() {
          return toastStatusMessage("Upload canceled.");
        });
        this.on("dragover", function() {
          d$(uploadTargetSelector + " .dz-message span").text("Drop here to upload the image");

          /*
           * box-shadow: 0px 0px 15px rgba(15,157,88,.8);
           * border: 1px solid #0F9D58;
           */
          return d$(uploadTargetSelector).css("box-shadow", "0px 0px 15px rgba(15,157,88,.8)").css("border", "1px solid #0F9D58");
        });
        this.on("dragleave", function() {
          return dragCancel();
        });
        this.on("dragend", function() {
          return dragCancel();
        });
        this.on("drop", function() {
          return dragCancel();
        });
        return this.on("success", function(file, result) {
          return callback(file, result);
        });
      }
    };
    if (!d$(uploadTargetSelector).hasClass("dropzone")) {
      d$(uploadTargetSelector).addClass("dropzone");
    }
    fileUploadDropzone = new Dropzone(d$(uploadTargetSelector).get(0), dropzoneConfig);
    return _asm.dropzone = fileUploadDropzone;
  });
  return false;
};

adminPreloadSearch = function() {

  /*
   * Take a fragment with a JSON species and preload a search
   *
   * This is in a different format from the one in the standard search;
   * the standard search uses the verbatim entry of the user, this uses
   * a JSON constructed by the system
   */
  var cleanedArg, fill, fillTimeout, fillWhenReady, k, loadArgs, start, v;
  if (_asm.preloaderBlocked === true) {
    console.debug("Skipping re-running active search preload");
    return false;
  }
  console.debug("Preloader firing");
  _asm.preloaderBlocked = true;
  start = Date.now();
  try {
    uri.query = decodeURIComponent($.url().attr("fragment"));
  } catch (undefined) {}
  if (uri.query === "#" || isNull(uri.query)) {
    return false;
  }
  try {
    loadArgs = Base64.decode(uri.query);
    loadArgs = JSON.parse(loadArgs);
  } catch (undefined) {}
  if (typeof loadArgs === "object") {
    if (isNull(loadArgs.genus) || (loadArgs.species == null)) {
      console.error("Bad taxon format");
      return false;
    }
    for (k in loadArgs) {
      v = loadArgs[k];
      cleanedArg = decodeURIComponent(v);
      cleanedArg = cleanedArg.replace(/(\+|\%20|\s)+/g, " ");
      loadArgs[k] = cleanedArg.trim();
    }
    fill = loadArgs.genus + " " + loadArgs.species;
    if (!isNull(loadArgs.subspecies)) {
      fill += " " + loadArgs.subspecies;
    }
    fillTimeout = 10 * 1000;
    (fillWhenReady = function() {
      var duration, error1, error2, isAttached;
      try {
        isAttached = p$("#admin-search").isAttached;
      } catch (error1) {
        isAttached = false;
      }
      if ((typeof _asm !== "undefined" && _asm !== null ? _asm.polymerReady : void 0) && isAttached) {
        try {
          p$("#admin-search").value = fill;
        } catch (error2) {
          $("#admin-search").val(fill);
        }
        renderAdminSearchResults(loadArgs);
        duration = Date.now() - start;
        console.log("Search preload finished in " + duration + "ms");
        return _asm.preloaderBlocked = false;
      } else {
        duration = Date.now() - start;
        console.debug("NOT READY: Duration @ " + duration + "ms", typeof _asm !== "undefined" && _asm !== null ? _asm.polymerReady : void 0, isAttached, _asm.polymerReady && isAttached);
        if (!(duration > fillTimeout)) {
          return delay(100, function() {
            return fillWhenReady();
          });
        } else {
          console.error("Timeout waiting for polymerReady!! Not filling search.");
          _asm.preloaderBlocked = false;
          return false;
        }
      }
    })();
  } else {
    console.error("Bad fragment: unable to read JSON", loadArgs);
  }
  return false;
};

$(function() {
  var error1, isAdminActive, thisUrl;
  try {
    thisUrl = uri.o.attr("source");
    isAdminActive = /^https?:\/\/(?:.*?\/)+(admin-.*\.(?:php|html)|admin\/)(?:\?(?:&?[\w\-_]+=[\w+\-_%]+)+)?(?:\#[\w\+%\=]+)?$/im.test(thisUrl);
  } catch (error1) {
    isAdminActive = true;
  }
  if ($("#next").exists()) {
    $("#next").unbind().click(function() {
      return openTab(adminParams.adminPageUrl);
    });
  }
  loadJS("bower_components/bootstrap/dist/js/bootstrap.min.js", function() {
    return $("[data-toggle='tooltip']").tooltip();
  });
  if (isAdminActive) {
    try {
      prefetchEditorDropdowns();
    } catch (undefined) {}
    try {
      return adminPreloadSearch();
    } catch (undefined) {}
  } else {
    return console.debug("Not an admin page");
  }
});

//# sourceMappingURL=maps/admin.js.map
