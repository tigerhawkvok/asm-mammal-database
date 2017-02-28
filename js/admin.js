
/*
 * The main coffeescript file for administrative stuff
 * Triggered from admin-page.html
 */
var adminParams, createDuplicateTaxon, createNewTaxon, deleteTaxon, handleDragDropImage, loadAdminUi, loadModalTaxonEditor, lookupEditorSpecies, renderAdminSearchResults, saveEditorEntry, verifyLoginCredentials,
  indexOf = [].indexOf || function(item) { for (var i = 0, l = this.length; i < l; i++) { if (i in this && this[i] === item) return i; } return -1; };

adminParams = new Object();

adminParams.apiTarget = "admin_api.php";

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
  try {
    verifyLoginCredentials(function(data) {
      var cookieName, mainHtml, searchForm;
      cookieName = uri.domain + "_name";
      mainHtml = "<h3>\n  Welcome, " + ($.cookie(cookieName)) + "\n  <span id=\"pib-wrapper-settings\" class=\"pib-wrapper\" data-toggle=\"tooltip\" title=\"User Settings\" data-placement=\"bottom\">\n    <paper-icon-button icon='settings-applications' class='click' data-url='" + data.login_url + "'></paper-icon-button>\n  </span>\n  <span id=\"pib-wrapper-exit-to-app\" class=\"pib-wrapper\" data-toggle=\"tooltip\" title=\"Go to SADB app\" data-placement=\"bottom\">\n    <paper-icon-button icon='exit-to-app' class='click' data-url='" + uri.urlString + "' id=\"app-linkout\"></paper-icon-button>\n  </span>\n</h3>\n<div id='admin-actions-block'>\n  <div class='bs-callout bs-callout-info'>\n    <p>Please be patient while the administrative interface loads.</p>\n  </div>\n</div>";
      $("main #main-body").html(mainHtml);
      bindClicks();

      /*
       * Render out the admin UI
       * We want a search box that we pipe through the API
       * and display the table out for editing
       */
      searchForm = "<form id=\"admin-search-form\" onsubmit=\"event.preventDefault()\" class=\"row\">\n  <div>\n    <paper-input label=\"Search for species\" id=\"admin-search\" name=\"admin-search\" required autofocus floatingLabel class=\"col-xs-7 col-sm-8\"></paper-input>\n    <paper-fab id=\"do-admin-search\" icon=\"search\" raisedButton class=\"materialblue\"></paper-fab>\n    <paper-fab id=\"do-admin-add\" icon=\"add\" raisedButton class=\"materialblue\"></paper-fab>\n  </div>\n</form>\n<div id='search-results' class=\"row\"></div>";
      $("#admin-actions-block").html(searchForm);
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
      return false;
    });
  } catch (error1) {
    e = error1;
    $("main #main-body").html("<div class='bs-callout bs-callout-danger'><h4>Application Error</h4><p>There was an error in the application. Please refresh and try again. If this persists, please contact administration.</p></div>");
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
  var args, hash, link, secret;
  hash = $.cookie(uri.domain + "_auth");
  secret = $.cookie(uri.domain + "_secret");
  link = $.cookie(uri.domain + "_link");
  args = "hash=" + hash + "&secret=" + secret + "&dblink=" + link;
  $.post(adminParams.loginApiTarget, args, "json").done(function(result) {
    if (result.status === true) {
      return callback(result);
    } else {
      return goTo(result.login_url);
    }
  }).fail(function(result, status) {
    $("main #main-body").html("<div class='bs-callout-danger bs-callout'><h4>Couldn't verify login</h4><p>There's currently a server problem. Try back again soon.</p>'</div>");
    console.log(result, status);
    return false;
  });
  return false;
};

renderAdminSearchResults = function(containerSelector) {
  var args, b64s, newLink, s;
  if (containerSelector == null) {
    containerSelector = "#search-results";
  }

  /*
   * Takes parts of performSearch() but only in the admin context
   */
  s = $("#admin-search").val();
  if (isNull(s)) {
    toastStatusMessage("Please enter a search term");
    return false;
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
    var bootstrapColCount, colClass, data, html, htmlClose, htmlHead, targetCount;
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
    htmlHead = "<table id='cndb-result-list' class='table table-striped table-hover'>\n\t<tr class='cndb-row-headers'>";
    htmlClose = "</table>";
    targetCount = toInt(result.count) - 1;
    colClass = null;
    bootstrapColCount = 0;
    return $.each(data, function(i, row) {
      var htmlRow, j, l, taxonQuery;
      if (toInt(i) === 0) {
        j = 0;
        htmlHead += "\n<!-- Table Headers - " + (Object.size(row)) + " entries -->";
        $.each(row, function(k, v) {
          var bootstrapColSize, niceKey;
          niceKey = k.replace(/_/g, " ");
          if (k === "genus" || k === "species" || k === "subspecies") {
            htmlHead += "\n\t\t<th class='text-center'>" + niceKey + "</th>";
            bootstrapColCount++;
          }
          j++;
          if (j === Object.size(row)) {
            htmlHead += "\n\t\t<th class='text-center'>Edit</th>";
            bootstrapColCount++;
            htmlHead += "\n\t\t<th class='text-center'>Delete</th>\n\t</tr>";
            bootstrapColCount++;
            htmlHead += "\n<!-- End Table Headers -->";
            console.log("Got " + bootstrapColCount + " display columns.");
            bootstrapColSize = roundNumber(12 / bootstrapColCount, 0);
            return colClass = "col-md-" + bootstrapColSize;
          }
        });
      }
      taxonQuery = (row.genus.trim()) + "+" + (row.species.trim());
      if (!isNull(row.subspecies)) {
        taxonQuery = taxonQuery + "+" + (row.subspecies.trim());
      }
      htmlRow = "\n\t<tr id='cndb-row" + i + "' class='cndb-result-entry' data-taxon=\"" + taxonQuery + "\">";
      l = 0;
      $.each(row, function(k, col) {
        if (isNull(row.genus)) {
          return true;
        }
        if (k === "genus" || k === "species" || k === "subspecies") {
          htmlRow += "\n\t\t<td id='" + k + "-" + i + "' class='" + k + " " + colClass + "'>" + col + "</td>";
        }
        l++;
        if (l === Object.size(row)) {
          htmlRow += "\n\t\t<td id='edit-" + i + "' class='edit-taxon " + colClass + " text-center'><paper-icon-button icon='image:edit' class='edit' data-taxon='" + taxonQuery + "'></paper-icon-button></td>";
          htmlRow += "\n\t\t<td id='delete-" + i + "' class='delete-taxon " + colClass + " text-center'><paper-icon-button icon='delete' class='delete-taxon-button fadebg' data-taxon='" + taxonQuery + "' data-database-id='" + row.id + "'></paper-icon-button></td>";
          htmlRow += "\n\t</tr>";
          return html += htmlRow;
        }
      });
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
        return stopLoad();
      }
    });
  }).fail(function(result, status) {
    var error;
    console.error("There was an error performing the search");
    console.warn(result, error, result.statusText);
    error = result.status + " - " + result.statusText;
    $("#search-status").attr("text", "Couldn't execute the search - " + error);
    $("#search-status")[0].show();
    return stopLoadError();
  });
};

loadModalTaxonEditor = function(extraHtml, affirmativeText) {
  var editHtml, html;
  if (extraHtml == null) {
    extraHtml = "";
  }
  if (affirmativeText == null) {
    affirmativeText = "Save";
  }

  /*
   * Load a modal taxon editor
   */
  editHtml = "<paper-input label=\"Genus\" id=\"edit-genus\" name=\"edit-genus\" class=\"genus\" floatingLabel></paper-input>\n<paper-input label=\"Species\" id=\"edit-species\" name=\"edit-species\" class=\"species\" floatingLabel></paper-input>\n<paper-input label=\"Subspecies\" id=\"edit-subspecies\" name=\"edit-subspecies\" class=\"subspecies\" floatingLabel></paper-input>\n<iron-label>\n  Alien species?\n  <paper-toggle-button id=\"is-alien\"  checked=\"false\"></paper-toggle-button>\n</iron-label>\n<paper-input label=\"Common Name\" id=\"edit-common-name\" name=\"edit-common-name\"  class=\"common_name\" floatingLabel></paper-input>\n<paper-input label=\"Deprecated Scientific Names\" id=\"edit-deprecated-scientific\" name=\"edit-depreated-scientific\" floatingLabel aria-describedby=\"deprecatedHelp\"></paper-input>\n  <span class=\"help-block\" id=\"deprecatedHelp\">List names here in the form <span class=\"code\">\"Genus species\":\"Authority: year\",\"Genus species\":\"Authority: year\",[...]</span>.<br/>There should be no spaces between the quotes and comma or colon. If there are, it may not save correctly.</span>\n<paper-input label=\"Clade\" class=\"capitalize\" id=\"edit-major-type\" name=\"edit-major-type\" floatingLabel></paper-input>\n<paper-input label=\"Subtype\" class=\"capitalize\" id=\"edit-major-subtype\" name=\"edit-major-subtype\" floatingLabel></paper-input>\n<paper-input label=\"Minor clade / 'Family'\" id=\"edit-minor-type\" name=\"edit-minor-type\" floatingLabel></paper-input>\n<paper-input label=\"Linnean Order\" id=\"edit-linnean-order\" name=\"edit-linnean-order\" class=\"linnean_order\" floatingLabel></paper-input>\n<paper-input label=\"Common Type (eg., 'lizard')\" id=\"edit-major-common-type\" name=\"edit-major-common-type\" class=\"major_common_type\" floatingLabel></paper-input>\n<paper-input label=\"Genus authority\" id=\"edit-genus-authority\" name=\"edit-genus-authority\" class=\"genus_authority\" floatingLabel></paper-input>\n<paper-input label=\"Genus authority year\" id=\"edit-gauthyear\" name=\"edit-gauthyear\" floatingLabel></paper-input>\n<iron-label>\n  Use Parenthesis for Genus Authority\n  <paper-toggle-button id=\"genus-authority-parens\"  checked=\"false\"></paper-toggle-button>\n</iron-label>\n<paper-input label=\"Species authority\" id=\"edit-species-authority\" name=\"edit-species-authority\" class=\"species_authority\" floatingLabel></paper-input>\n<paper-input label=\"Species authority year\" id=\"edit-sauthyear\" name=\"edit-sauthyear\" floatingLabel></paper-input>\n<iron-label>\n  Use Parenthesis for Species Authority\n  <paper-toggle-button id=\"species-authority-parens\" checked=\"false\"></paper-toggle-button>\n</iron-label>\n<br/><br/>\n<iron-autogrow-textarea id=\"edit-notes\" rows=\"5\" aria-describedby=\"notes-help\" placeholder=\"Notes\">\n  <textarea placeholder=\"Notes\" id=\"edit-notes-textarea\" name=\"edit-notes-textarea\" aria-describedby=\"notes-help\" rows=\"5\"></textarea>\n</iron-autogrow-textarea>\n<span class=\"help-block\" id=\"notes-help\">You can write your notes in Markdown. (<a href=\"https://daringfireball.net/projects/markdown/syntax\" \"onclick='window.open(this.href); return false;' onkeypress='window.open(this.href); return false;'\">Official Full Syntax Guide</a>)</span>\n<div id=\"upload-image\"></div>\n<span class=\"help-block\" id=\"upload-image-help\">You can drag and drop an image above, or enter its server path below.</span>\n<paper-input label=\"Image\" id=\"edit-image\" name=\"edit-image\" floatingLabel aria-describedby=\"imagehelp\"></paper-input>\n  <span class=\"help-block\" id=\"imagehelp\">The image path here should be relative to the <span class=\"code\">public_html/</span> directory.</span>\n<paper-input label=\"Image Credit\" id=\"edit-image-credit\" name=\"edit-image-credit\" floatingLabel></paper-input>\n<paper-input label=\"Image License\" id=\"edit-image-license\" name=\"edit-image-license\" floatingLabel></paper-input>\n<paper-input label=\"Taxon Credit\" id=\"edit-taxon-credit\" name=\"edit-taxon-credit\" floatingLabel aria-describedby=\"taxon-credit-help\"></paper-input>\n  <span class=\"help-block\" id=\"taxon-credit-help\">This will be displayed as \"Taxon information by [your entry].\"</span>\n<paper-input label=\"Taxon Credit Date\" id=\"edit-taxon-credit-date\" name=\"edit-taxon-credit-date\" floatingLabel></paper-input>\n" + extraHtml + "\n<input type=\"hidden\" name=\"edit-taxon-author\" id=\"edit-taxon-author\" value=\"\" />";
  html = "<paper-dialog modal id='modal-taxon-edit' entry-animation=\"scale-up-animation\" exit-animation=\"fade-out-animation\">\n  <h2 id=\"editor-title\">Taxon Editor</h2>\n  <paper-dialog-scrollable id='modal-taxon-editor'>\n    " + editHtml + "\n  </paper-dialog-scrollable>\n  <div class=\"buttons\">\n    <paper-button id='close-editor' dialog-dismiss>Cancel</paper-button>\n    <paper-button id='duplicate-taxon'>Duplicate</paper-button>\n    <paper-button id='save-editor'>" + affirmativeText + "</paper-button>\n  </div>\n</paper-dialog>";
  if ($("#modal-taxon-edit").exists()) {
    $("#modal-taxon-edit").remove();
  }
  $("#search-results").after(html);
  handleDragDropImage();
  $("#modal-taxon-edit").unbind();
  d$("#save-editor").unbind();
  return d$("#duplicate-taxon").unbind().click(function() {
    return createDuplicateTaxon();
  });
};

createNewTaxon = function() {

  /*
   * Load a blank modal taxon editor, ready to make a new one
   */
  var whoEdited, windowHeight;
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
  $("#modal-taxon-edit").get(0).open();
  return stopLoad();
};

createDuplicateTaxon = function() {

  /*
   * Accessed from an existing taxon modal editor.
   *
   * Remove the edited notes, remove the duplicate button, and change
   * the bidings so a new entry is created.
   */
  var e, error1, newButton;
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
    var category, col, colSplit, d, data, e, error1, error2, error3, error4, fieldSelector, modalElement, speciesString, tempSelector, textarea, toggleColumns, whoEdited, width, year;
    try {
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
      toggleColumns = ["parens_auth_genus", "parens_auth_species", "is_alien"];
      for (col in data) {
        d = data[col];
        try {
          if (typeof d === "string") {
            d = d.trim();
          }
        } catch (error2) {
          e = error2;
        }
        if (col === "id") {
          $("#taxon-id").attr("value", d);
        }
        if (col === "authority_year") {
          year = parseTaxonYear(d);
          $("#edit-gauthyear").attr("value", year.genus);
          $("#edit-sauthyear").attr("value", year.species);
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
        } else {
          fieldSelector = "#edit-" + (col.replace(/_/g, "-"));
          if (col === "deprecated_scientific") {
            d = JSON.stringify(d).trim().replace(/\\/g, "");
            d = d.replace(/{/, "");
            d = d.replace(/}/, "");
            if (d === '""') {
              d = "";
            }
          }
          if (col !== "notes") {
            d$(fieldSelector).attr("value", d);
          } else {
            width = $("#modal-taxon-edit").width() * .9;
            d$(fieldSelector).css("width", width + "px");
            textarea = d$(fieldSelector).get(0).textarea;
            $(textarea).text(d);
            try {
              d$(fieldSelector).get(0)._update();
            } catch (error3) {
              e = error3;
              console.warn("Couldn't update the textarea! See", "https://github.com/PolymerElements/iron-autogrow-textarea/issues/24");
            }
          }
        }
      }
      modalElement = $("#modal-taxon-edit")[0];
      $("#modal-taxon-edit").on("iron-overlay-opened", function() {
        modalElement.fit();
        modalElement.scrollTop = 0;
        if (toFloat($(modalElement).css("top").slice(0, -2)) > $(window).height()) {
          $(modalElement).css("top", "12.5vh");
        }
        return delay(250, function() {
          return modalElement.fit();
        });
      });
      modalElement.sizingTarget = d$("#modal-taxon-editor")[0];
      safariDialogHelper("#modal-taxon-edit");
      return stopLoad();
    } catch (error4) {
      e = error4;
      return stopLoadError("Unable to populate the editor for this taxon - " + e.message);
    }
  }).fail(function(result, status) {
    return stopLoadError("There was a server error populating this taxon. Please try again.");
  });
  return false;
};

saveEditorEntry = function(performMode) {
  var args, auth, authYearString, authority, authorityA, col, completionErrorMessage, consoleError, dep, depA, depS, depString, e, error, error1, error2, error3, escapeCompletion, examineIds, gYear, hash, id, item, k, keepCase, len, link, m, nullTest, requiredNotEmpty, s64, sYear, saveObject, saveString, secret, selectorSample, spilloverError, taxon, testAuthorityYear, trimmedYearString, userVerification, val, year;
  if (performMode == null) {
    performMode = "save";
  }

  /*
   * Send an editor state along with login credentials,
   * and report the save result back to the user
   */
  examineIds = ["genus", "species", "subspecies", "common-name", "major-type", "major-common-type", "major-subtype", "minor-type", "linnean-order", "genus-authority", "species-authority", "notes", "image", "image-credit", "image-license", "taxon-author", "taxon-credit", "taxon-credit-date"];
  saveObject = new Object();
  escapeCompletion = false;
  d$("paper-input").removeAttr("invalid");
  try {
    testAuthorityYear = function(authYearDeepInputSelector, directYear) {
      var altYear, authorityRegex, d, error, linnaeusYear, nextYear, ref, yearString, years;
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
        console.warn(authYearDeepInputSelector + " failed its validity checks for " + yearString + "!");
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
          throw Error("Looks like there may be an extra space, or forgotten \", near '" + trimmedYearString + "'");
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
  keepCase = ["notes", "taxon_credit", "image", "image_credit", "image_license"];
  requiredNotEmpty = ["common-name", "major-type", "linnean-order", "genus-authority", "species-authority"];
  if (!isNull(d$("#edit-image").val())) {
    requiredNotEmpty.push("image-credit");
    requiredNotEmpty.push("image-license");
  }
  if (!isNull(d$("#edit-taxon-credit").val())) {
    requiredNotEmpty.push("taxon-credit-date");
  }
  for (k in examineIds) {
    id = examineIds[k];
    col = id.replace(/-/g, "_");
    if (col !== "notes") {
      val = d$("#edit-" + id).val().trim();
    } else {
      val = d$("#edit-notes").get(0).textarea.value;
    }
    if (indexOf.call(keepCase, col) < 0) {
      val = val.toLowerCase();
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
        }
        break;
      case "common-name":
      case "major-type":
      case "linnean-order":
      case "genus-authority":
      case "species-authority":
        error = "This cannot be empty";
        if (isNull(val)) {
          $("#edit-" + id).attr("error-message", error).attr("invalid", "invalid");
          escapeCompletion = true;
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
            spilloverError = "If you have a taxon credit, it also needs a date";
          }
          if (isNull(val)) {
            d$("#edit-" + id).attr("error-message", spilloverError).attr("invalid", "invalid");
            escapeCompletion = true;
          }
        }
    }
    saveObject[col] = val;
  }
  if (escapeCompletion) {
    animateLoad();
    consoleError = completionErrorMessage != null ? completionErrorMessage : "Bad characters in entry. Stopping ...";
    if (completionErrorMessage == null) {
      completionErrorMessage = "There was a problem with your entry. Please correct your entry and try again.";
    }
    stopLoadError(completionErrorMessage);
    console.error(consoleError);
    return true;
  }
  saveObject.id = d$("#taxon-id").val();
  saveObject.parens_auth_genus = d$("#genus-authority-parens").polymerChecked();
  saveObject.parens_auth_species = d$("#species-authority-parens").polymerChecked();
  saveObject.is_alien = d$("#is-alien").polymerChecked();
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
        console.error("Warning! The item saved, even though it wasn't supposed to.");
        return false;
      }
      d$("#modal-taxon-edit").get(0).close();
      if (!isNull($("#admin-search").val())) {
        renderAdminSearchResults();
      }
      return false;
    }
    stopLoadError();
    toastStatusMessage(result.human_error);
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
  var args, caller, diff, taxon, taxonRaw;
  caller = $(".delete-taxon .delete-taxon-button[data-database-id='" + taxaId + "']");
  taxonRaw = caller.attr("data-taxon").replace(/\+/g, " ");
  taxon = taxonRaw.substr(0, 1).toUpperCase() + taxonRaw.substr(1);
  if (!caller.hasClass("extreme-danger")) {
    window.deleteWatchTimer = Date.now();
    delay(300, function() {
      return delete window.deleteWatchTimer;
    });
    caller.addClass("extreme-danger");
    delay(7500, function() {
      return caller.removeClass("extreme-danger");
    });
    toastStatusMessage("Click again to confirm deletion of " + taxon);
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
    if (result.status === true) {
      caller.parents("tr").remove();
      toastStatusMessage(taxon + " with ID " + taxaId + " has been removed from the database.");
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
        asm.dropzone.disable();
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
    return asm.dropzone = fileUploadDropzone;
  });
  return false;
};

$(function() {
  if ($("#next").exists()) {
    $("#next").unbind().click(function() {
      return openTab(adminParams.adminPageUrl);
    });
  }
  return loadJS("bower_components/bootstrap/dist/js/bootstrap.min.js", function() {
    return $("[data-toggle='tooltip']").tooltip();
  });
});

//# sourceMappingURL=maps/admin.js.map
