var downloadCSVList, downloadHTMLList, showDownloadChooser,
  indexOf = [].indexOf || function(item) { for (var i = 0, l = this.length; i < l; i++) { if (i in this && this[i] === item) return i; } return -1; };

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
    var authorityYears, c, col, colData, csv, csvBody, csvHeader, csvLiteralRow, csvRow, dirtyCol, dirtyColData, downloadable, e, error, error1, error2, error3, error4, error5, fileSizeMiB, genusYear, html, i, k, makeTitleCase, ref, row, showColumn, speciesYear, split, tempCol, v, year;
    try {
      if (result.status !== true) {
        throw Error("Invalid Result");
      }
      csvBody = "      ";
      csvHeader = new Array();
      showColumn = ["genus", "species", "subspecies", "canonical_sciname", "common_name", "common_name_source", "image", "image_caption", "image_credit", "image_license", "major_type", "major_subtype", "simple_linnean_group", "simple_linnean_subgroup", "linnean_order", "linnean_family", "genus_authority", "parens_auth_genus", "species_authority", "parens_auth_species", "authority_year", "deprecated_scientific", "notes", "entry", "taxon_credit", "taxon_credit_date", "taxon_author", "citation", "source", "internal_id"];
      makeTitleCase = ["genus", "common_name", "taxon_credit", "linnean_order", "linnean_family", "genus_authority", "species_authority"];
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
          try {
            colData = dirtyColData.replace(/"/g, '\"\"').replace(/&#39;/g, "'");
          } catch (error) {
            colData = "";
          }
          if (i === 0) {
            if (indexOf.call(showColumn, col) >= 0) {
              csvHeader.push(col.replace(/_/g, " ").toTitleCase());
            }
          }
          if (indexOf.call(showColumn, col) >= 0) {
            if (/[a-z]+_authority/.test(col)) {
              try {
                if (typeof row.authority_year !== "object") {
                  authorityYears = new Object();
                  try {
                    if (isNumber(row.authority_year)) {
                      authorityYears[row.authority_year] = row.authority_year;
                    } else if (isNull(row.authority_year)) {
                      row.species_authority = row.species_authority.replace(/(<\/|<|&lt;|&lt;\/).*?(>|&gt;)/img, "");
                      if (/^\(? *((['"])? *([\w\u00C0-\u017F\. \-\&;\[\]]+(,|&|&amp;|&amp;amp;|&#[\w0-9]+;)?)+ *\2) *, *([0-9]{4}) *\)?/im.test(row.species_authority)) {
                        year = row.species_authority.replace(/^\(? *((['"])? *([\w\u00C0-\u017F\.\-\&; \[\]]+(,|&|&amp;|&amp;amp;|&#[\w0-9]+;)?)+ *\2) *, *([0-9]{4}) *\)?/ig, "$5");
                        row.species_authority = row.species_authority.replace(/^\(? *((['"])? *([\w\u00C0-\u017F\.\-\&; \[\]]+(,|&|&amp;|&amp;amp;|&#[\w0-9]+;)?)+ *\2) *, *([0-9]{4}) *\)?/ig, "$1");
                        authorityYears[year] = year;
                        row.authority_year = authorityYears;
                      } else {
                        if (!isNull(row.species_authority)) {
                          console.warn("Failed a match on authority '" + row.species_authority + "'");
                        }
                        authorityYears["Unknown"] = "Unknown";
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
              } catch (error3) {
                e = error3;
              }
            }
            if (indexOf.call(makeTitleCase, col) >= 0) {
              colData = colData.toTitleCase();
            }
            if (col === "image" && !isNull(colData)) {
              colData = "" + uri.urlString + colData;
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
      try {
        fileSizeMiB = downloadable.length / 1024 / 1024;
      } catch (error4) {
        fileSizeMiB = 0;
      }
      console.log("Downloadable size: " + fileSizeMiB + " MiB");
      html = "<paper-dialog class=\"download-file\" id=\"download-csv-file\" modal>\n  <h2>Your files are ready</h2>\n  <paper-dialog-scrollable class=\"dialog-content\">\n    <h3>Need data analysis?</h3>\n    <p>\n      api explanation link blurb\n    </p>\n    <h3>Which file type do I want?</h3>\n    <p>\n      A CSV file is readily opened by consumer-grade programs, such as Microsoft Excel or Google Spreadsheets.\n      However, if you wish to replicate the whole database and perform queries, the SQL file is machine-readable,\n      ready for import into a MySQL or MariaDB database by running the <code>source asm-species-" + dateString + ".sql;</code> in their\n      interactive shell prompts when run from your download directory.\n    </p>\n    <h3>Excel Important Note</h3>\n    <p>\n      Please note that some special characters in names may be decoded incorrectly by Microsoft Excel. If this is a problem, following the steps in <a href=\"https://github.com/SSARHERPS/SSAR-species-database/blob/master/meta/excel_unicode_readme.md\"  onclick='window.open(this.href); return false;' onkeypress='window.open(this.href); return false;'>this README <iron-icon icon=\"launch\"></iron-icon></a> to force Excel to format it correctly.\n    </p>\n    <p class=\"text-center\">\n      <a href=\"" + downloadable + "\" download=\"asm-species-" + dateString + ".csv\" class=\"btn btn-default\" id=\"download-csv-summary\"><iron-icon icon=\"file-download\"></iron-icon> Download CSV</a>\n      <a href=\"#\" download=\"asm-species-" + dateString + ".sql\" class=\"btn btn-default\" id=\"download-sql-summary\" disabled><iron-icon icon=\"file-download\"></iron-icon> Download SQL</a>\n    </p>\n  </paper-dialog-scrollable>\n  <div class=\"buttons\">\n    <paper-button dialog-dismiss>Close</paper-button>\n  </div>\n</paper-dialog>";
      if (!$("#download-csv-file").exists()) {
        $("body").append(html);
      } else {
        $("#download-csv-file").replaceWith(html);
      }
      p$("#download-chooser").close();
      if (fileSizeMiB >= 2) {
        console.debug("Large file size triggering blob creation");
        downloadDataUriAsBlob("#download-csv-summary");
      } else {
        console.debug("File size is small enough to use a data-uri");
      }
      safariDialogHelper("#download-csv-file");
      return stopLoad();
    } catch (error5) {
      e = error5;
      stopLoadError("There was a problem creating the CSV file. Please try again later.");
      console.error("Exception in downloadCSVList ) - " + e.message);
      console.warn(e.stack);
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
      var postMessageContent, worker;
      startLoad();
      toastStatusMessage("Please be patient while we create the file for you");
      postMessageContent = {
        action: "render-html",
        data: result,
        htmlHeader: htmlBody
      };
      worker = new Worker("js/serviceWorker.min.js");
      console.info("Rendering list off-thread");
      worker.addEventListener("message", function(e) {

        /*
         * Service worker callback
         */
        var dialogHtml, downloadable, error, fileSizeMiB, message, pdfError;
        console.info("Got message back from service worker", e.data);
        if (e.data.done !== true) {
          console.log("Just an update");
          if (!isNull(e.data.updateUser)) {
            toastStatusMessage(e.data.updateUser);
          }
          return false;
        }
        if (e.data.status !== true) {
          console.warn("Got an error!");
          message = !isNull(e.data.updateUser) ? e.data.updateUser : "Failed to create file";
          stopLoadError(message, "", 10000);
          return false;
        }
        htmlBody = e.data.html;
        downloadable = "data:text/html;charset=utf-8," + (encodeURIComponent(htmlBody));
        try {
          fileSizeMiB = downloadable.length / 1024 / 1024;
        } catch (error) {
          fileSizeMiB = 0;
        }
        console.log("Downloadable size: " + fileSizeMiB + " MiB");
        dialogHtml = "<paper-dialog  modal class=\"download-file\" id=\"download-html-file\">\n  <h2>Your file is ready</h2>\n  <paper-dialog-scrollable class=\"dialog-content\">\n    <p class=\"text-center\">\n      <a href=\"" + downloadable + "\" download=\"asm-species-" + dateString + ".html\" class=\"btn btn-default\" id=\"download-html-summary\"><iron-icon icon=\"file-download\"></iron-icon> Download HTML</a>\n      <div id=\"pdf-download-placeholder\">\n        <paper-spinner active></paper-spinner> Please wait while your PDF creation finishes ...\n      </div>\n    </p>\n  </paper-dialog-scrollable>\n  <div class=\"buttons\">\n    <paper-button dialog-dismiss>Close</paper-button>\n  </div>\n</paper-dialog>";
        if (!$("#download-html-file").exists()) {
          $("body").append(dialogHtml);
        } else {
          $("#download-html-file").replaceWith(dialogHtml);
        }
        try {
          p$("#download-chooser").close();
        } catch (undefined) {}
        if (fileSizeMiB >= 2) {
          console.debug("Large file size triggering blob creation");
          downloadDataUriAsBlob("#download-html-summary");
        } else {
          console.debug("File size is small enough to use a data-uri");
        }
        safariDialogHelper("#download-html-file");
        stopLoad();
        toastStatusMessage("Please wait while we prepare your PDF file...", "", 7000);
        pdfError = "<a href=\"#\" disabled class=\"btn btn-default\" id=\"download-pdf-summary\">PDF Creation Failed</a>";
        console.debug("Posting for PDF");
        return $.post(uri.urlString + "pdf/pdfwrapper.php", "html=" + (encodeURIComponent(htmlBody)), "json").done(function(result) {
          var pdfDownload, pdfDownloadPath;
          console.debug("PDF result", result);
          if (result.status) {
            pdfDownloadPath = "" + uri.urlString + result.file;
            console.debug(pdfDownloadPath);
            pdfDownload = "<a href=\"" + pdfDownloadPath + "\" download=\"asm-species-" + dateString + ".pdf\" class=\"btn btn-default\" id=\"download-pdf-summary\"><iron-icon icon=\"file-download\"></iron-icon> Download PDF</a>";
            return $("#download-html-file #download-html-summary").after(pdfDownload);
          } else {
            console.error("Couldn't make PDF file");
            return $("#download-html-file #download-html-summary").after(pdfError);
          }
        }).error(function(result, status) {
          console.error("Wasn't able to fetch PDF");
          return $("#download-html-file #download-html-summary").after(pdfError);
        }).always(function() {
          try {
            return $("#download-html-file #pdf-download-placeholder").remove();
          } catch (undefined) {}
        });
      });
      return worker.postMessage(postMessageContent);
    }).fail(function() {
      return stopLoadError("There was a problem communicating with the server. Please try again later.");
    });
  }).fail(function() {
    stopLoadError("Unable to fetch styles for printout");
    return false;
  });
  return false;
};

showDownloadChooser = function() {
  var html;
  html = "<paper-dialog id=\"download-chooser\" modal>\n  <h2>Select Download Type</h2>\n  <paper-dialog-scrollable class=\"dialog-content\">\n    <p>\n      Once you select a file type, it will take a moment to prepare your download. Please be patient.\n    </p>\n  </paper-dialog-scrollable>\n  <div class=\"buttons\">\n    <paper-button dialog-dismiss>Cancel</paper-button>\n    <paper-button dialog-confirm id=\"initiate-csv-download\">CSV/SQL</paper-button>\n    <paper-button dialog-confirm id=\"initiate-html-download\">HTML/PDF</paper-button>\n  </div>\n</paper-dialog>";
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
