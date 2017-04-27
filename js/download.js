var downloadCSVList, downloadHTMLList, showDownloadChooser;

downloadCSVList = function() {

  /*
   * Download a CSV file list
   *
   * See
   * https://github.com/tigerhawkvok/SSAR-species-database/issues/39
   */
  var adjMonth, args, d, dateString, day, month, startTime;
  animateLoad();
  startTime = Date.now();
  args = "q=*";
  d = new Date();
  adjMonth = d.getMonth() + 1;
  month = adjMonth.toString().length === 1 ? "0" + adjMonth : adjMonth;
  day = d.getDate().toString().length === 1 ? "0" + (d.getDate().toString()) : d.getDate();
  dateString = (d.getUTCFullYear()) + "-" + month + "-" + day;
  $.get("" + searchParams.apiPath, args, "json").done(function(result) {
    var e, error, postMessageContent, worker;
    try {
      if (result.status !== true) {
        throw Error("Invalid Result");
      }
      startLoad();
      toastStatusMessage("Please be patient while we create the file for you");
      postMessageContent = {
        action: "render-csv",
        data: result
      };
      worker = new Worker("js/serviceWorker.min.js");
      console.info("Rendering list off-thread");
      worker.addEventListener("message", function(e) {

        /*
         * Service worker callback
         */
        var downloadable, duration, error, fileSizeMiB, html, message;
        console.info("Got message back from service worker", e.data);
        if (e.data.done !== true) {
          if (!isNull(e.data.updateUser)) {
            console.log("Toasting: " + e.data.updateUser);
            toastStatusMessage(e.data.updateUser);
          } else {
            console.log("Just an update");
          }
          return false;
        }
        if (e.data.status !== true) {
          console.warn("Got an error!");
          message = !isNull(e.data.updateUser) ? e.data.updateUser : "Failed to create file";
          stopLoadError(message, "", 10000);
          return false;
        }
        downloadable = e.data.csv;
        try {
          fileSizeMiB = downloadable.length / 1024 / 1024;
        } catch (error) {
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
        stopLoad();
        duration = Date.now() - startTime;
        console.debug("Time elapsed: " + duration + "ms");
        return false;
      });
      worker.postMessage(postMessageContent);
      return false;
    } catch (error) {
      e = error;
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
        $.post(uri.urlString + "pdf/pdfwrapper.php", "html=" + (encodeURIComponent(htmlBody)), "json").done(function(result) {
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
        return false;
      });
      worker.postMessage(postMessageContent);
      return false;
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
