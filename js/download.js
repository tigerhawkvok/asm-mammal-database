var downloadCSVList, downloadHTMLList, showDownloadChooser,
  indexOf = [].indexOf || function(item) { for (var i = 0, l = this.length; i < l; i++) { if (i in this && this[i] === item) return i; } return -1; },
  modulo = function(a, b) { return (+a % (b = +b) + b) % b; };

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
    var authorityYears, col, colData, csv, csvBody, csvHeader, csvLiteralRow, csvRow, dirtyCol, dirtyColData, downloadable, e, error, error1, genusYear, html, i, k, makeTitleCase, ref, row, showColumn, speciesYear, tempCol, v;
    try {
      if (result.status !== true) {
        throw Error("Invalid Result");
      }
      csvBody = "      ";
      csvHeader = new Array();
      showColumn = ["genus", "species", "subspecies", "common_name", "image", "image_credit", "image_license", "major_type", "major_common_type", "major_subtype", "minor_type", "linnean_order", "genus_authority", "species_authority", "deprecated_scientific", "notes", "taxon_credit", "taxon_credit_date"];
      makeTitleCase = ["genus", "common_name", "taxon_author", "major_subtype", "linnean_order"];
      i = 0;
      ref = result.result;
      for (k in ref) {
        row = ref[k];
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
              } catch (error) {
                e = error;
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
    } catch (error1) {
      e = error1;
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
  startLoad();
  $.get(uri.urlString + "css/download-inline-bootstrap.css").done(function(importedCSS) {
    var adjMonth, args, d, dateString, day, htmlBody, month;
    d = new Date();
    adjMonth = d.getMonth() + 1;
    month = adjMonth.toString().length === 1 ? "0" + adjMonth : adjMonth;
    day = d.getDate().toString().length === 1 ? "0" + (d.getDate().toString()) : d.getDate();
    dateString = (d.getUTCFullYear()) + "-" + month + "-" + day;
    htmlBody = "<!doctype html>\n<html lang=\"en\">\n  <head>\n    <title>ASM Species Checklist ver. " + dateString + "</title>\n    <meta http-equiv=\"X-UA-Compatible\" content=\"IE=edge\">\n    <meta charset=\"UTF-8\"/>\n    <meta name=\"theme-color\" content=\"#445e14\"/>\n    <meta name=\"viewport\" content=\"width=device-width, initial-scale=1\" />\n    <link href='http://fonts.googleapis.com/css?family=Droid+Serif:400,700,700italic,400italic|Roboto+Slab:400,700' rel='stylesheet' type='text/css' />\n    <style type=\"text/css\" id=\"asm-checklist-inline-stylesheet\">\n      " + importedCSS + "\n    </style>\n  </head>\n  <body>\n    <div class=\"container-fluid\">\n      <article>\n        <h1 class=\"text-center\">ASM Species Checklist ver. " + dateString + "</h1>";
    args = "q=*&order=linnean_order,linnean_family,genus,species,subspecies";
    return $.get("" + searchParams.apiPath, args, "json").done(function(result) {
      var authorityYears, c, dialogHtml, downloadable, e, entryHtml, error, error1, error2, error3, genusAuth, genusYear, hasReadClade, hasReadGenus, hasReadSubClade, htmlCredit, htmlNotes, k, oneOffHtml, ref, ref1, ref2, ref3, row, shortGenus, speciesAuth, speciesYear, split, taxonCreditDate, total, v, year;
      console.debug("Got", result);
      startLoad();
      toastStatusMessage("Please be patient while we create the file for you");
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
            }
          } catch (undefined) {}
          if (isNull(row.genus) || isNull(row.species)) {
            continue;
          }
          try {
            if (typeof row.authority_year !== "object") {
              try {
                authorityYears = JSON.parse(row.authority_year);
              } catch (error) {
                split = row.authority_year.split(":");
                if (split.length > 1) {
                  year = split[1].slice(split[1].search("\"") + 1, -2);
                  year = year.replace(/"/g, "'");
                  split[1] = "\"" + year + "\"}";
                  authorityYears = JSON.parse(split.join(":"));
                } else {
                  if (isNumeric(row.authority_year)) {
                    authorityYears[row.authority_year] = row.authority_year;
                  }
                }
              }
            } else {
              authorityYears = row.authority_year;
            }
            genusYear = "";
            speciesYear = "";
            for (c in authorityYears) {
              v = authorityYears[c];
              genusYear = c.replace(/&#39;/g, "'");
              speciesYear = v.replace(/&#39;/g, "'");
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
          } catch (error1) {
            e = error1;
            console.warn("There was a problem parsing the authority information for _" + row.genus + " " + row.species + " " + row.subspecies + "_ - " + e.message);
            console.warn(e.stack);
            console.warn("Bad parse for authority year -- tried to fix >>" + row.authority_year + "<<", authorityYears, row.authority_year);
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
          if (ref1 = row.linnean_order.trim(), indexOf.call(hasReadClade, ref1) < 0) {
            oneOffHtml += "<h2 class=\"clade-declaration text-capitalize text-center\">" + row.linnean_order + " &#8212; " + row.linnean_family + "</h2>";
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
        console.log("HTML file prepped");
        downloadable = "data:text/html;charset=utf-8," + (encodeURIComponent(htmlBody));
        dialogHtml = "<paper-dialog  modal class=\"download-file\" id=\"download-html-file\">\n  <h2>Your file is ready</h2>\n  <paper-dialog-scrollable class=\"dialog-content\">\n    <p class=\"text-center\">\n      <a href=\"" + downloadable + "\" download=\"asm-species-" + dateString + ".html\" class=\"btn btn-default\"><iron-icon icon=\"file-download\"></iron-icon> Download HTML Now</a>\n    </p>\n  </paper-dialog-scrollable>\n  <div class=\"buttons\">\n    <paper-button dialog-dismiss>Close</paper-button>\n  </div>\n</paper-dialog>";
        if (!$("#download-html-file").exists()) {
          $("body").append(dialogHtml);
        } else {
          $("#download-html-file").replaceWith(dialogHtml);
        }
        $("#download-chooser").get(0).close();
        safariDialogHelper("#download-html-file");
        return $.post("pdf/pdfwrapper.php", "html=" + (encodeURIComponent(htmlBody)), "json").done(function(result) {
          var pdfDownload, pdfDownloadPath;
          console.debug("PDF result", result);
          if (result.status) {
            pdfDownloadPath = "" + uri.urlString + result.file;
            console.debug(pdfDownloadPath);
            pdfDownload = "<a href=\"" + pdfDownloadPath + "\" download=\"asm-species-" + dateString + ".pdf\" class=\"btn btn-default\"><iron-icon icon=\"file-download\"></iron-icon> Download PDF Now</a>";
            $("#download-html-file paper-dialog-scrollable p.text-center a").after(pdfDownload);
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
      stopLoadError("There was a problem communicating with the server. Please try again later.");
      return false;
    });
  }).fail(function() {
    stopLoadError("Unable to fetch styles for printout");
    return false;
  });
  return false;
};

showDownloadChooser = function() {
  var html;
  html = "<paper-dialog id=\"download-chooser\" modal>\n  <h2>Select Download Type</h2>\n  <paper-dialog-scrollable class=\"dialog-content\">\n    <p>\n      Once you select a file type, it will take a moment to prepare your download. Please be patient.\n    </p>\n  </paper-dialog-scrollable>\n  <div class=\"buttons\">\n    <paper-button dialog-dismiss>Cancel</paper-button>\n    <paper-button dialog-confirm id=\"initiate-csv-download\">CSV</paper-button>\n    <paper-button dialog-confirm id=\"initiate-html-download\">HTML/PDF</paper-button>\n  </div>\n</paper-dialog>";
  if (!$("#download-chooser").exists()) {
    $("body").append(html);
  }
  $("#initiate-csv-download").click(function() {
    return downloadCSVList();
  });
  $("#initiate-html-download").click(function() {
    return downloadHTMLList();
  });
  safariDialogHelper("#download-chooser");
  return false;
};

//# sourceMappingURL=maps/download.js.map
