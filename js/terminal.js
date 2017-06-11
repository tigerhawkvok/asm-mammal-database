
/*
 * Primary handler for SQL Live Query Input
 *
 * See issue
 * https://github.com/tigerhawkvok/asm-mammal-database/issues/20
 * https://github.com/tigerhawkvok/asm-mammal-database/projects/2
 *
 * @author Philip Kahn
 */
var executeQuery, getTerminalDependencies, loadTerminalDialog, parseQuery,
  slice = [].slice;

loadTerminalDialog = function(reinit) {
  if (reinit == null) {
    reinit = false;
  }
  getTerminalDependencies(function() {
    var html;
    if (!($("#sql-query-dialog").exists() || reinit)) {
      html = "<paper-dialog id=\"sql-query-dialog\" modal>\n  <paper-dialog-scrollable>\n    <div class=\"row query-container\">\n      <form class=\"form\">\n        <div class=\"form-group\">\n          <textarea id=\"sql-input\"\n                    rows=\"5\"\n                    class=\"form-control\"\n                    placeholder=\"SQL query here\"\n                    autofocus></textarea>\n          <p class=\"text-muted\">\n            <strong>Tip:</strong> Use <kbd>@@</kbd> to represent the database table and <kbd>!@</kbd> to represent <code class=\"language-null\">SELECT * FROM table</code>. You can search columns using DarwinCore or columns specified in Github.\n          </p>\n        </div>\n      </form>\n      <p class=\"col-xs-12\">Interpreted Query:</p>\n      <code class=\"language-sql col-xs-11 col-xs-offset-1\" id=\"interpreted-sql\"></code>\n    </div>\n  </paper-dialog-scrollable>\n  <div class=\"buttons\">\n    <paper-button id=\"clear-sql-results\">Clear Results</paper-button>\n    <paper-button dialog-dismiss>Close</paper-button>\n  </div>\n</paper-dialog>";
      $("body").append(html);
      $("#sql-query-dialog").find("form").submit(function(e) {
        e.preventDefault();
        executeQuery();
        return false;
      });
      $("#sql-input").keydown(function(e) {
        var kc;
        kc = e.keyCode ? e.keyCode : e.which;
        if (kc === 13) {
          e.preventDefault();
          executeQuery();
          return false;
        }
      });
      $("#sql-input").keyup(function(e) {
        var kc;
        kc = e.keyCode ? e.keyCode : e.which;
        if (kc !== 13) {
          parseQuery(this);
        }
        return true;
      });
      $("#clear-sql-results").click(function() {
        $("#sql-results").remove();
        return false;
      });
    }
    return p$("#sql-query-dialog").open();
  });
  return false;
};

getTerminalDependencies = function() {
  var args, callback, checkDependencies, dependencies, naclCallback;
  callback = arguments[0], args = 2 <= arguments.length ? slice.call(arguments, 1) : [];

  /*
   *
   */
  if (_asm.terminalDependencies === true) {
    console.log("Dependencies are already loaded, executing immediately");
    if (typeof callback === "function") {
      callback.apply(null, args);
    }
  }
  dependencies = {
    nacl: false,
    prism: false
  };
  _asm.terminalDependencies = false;
  _asm.terminalDependenciesChecking = false;
  checkDependencies = function() {
    var lib, ready, status;
    if (_asm.terminalDependencies === true) {
      return true;
    }
    if (_asm.terminalDependenciesChecking) {
      delay(50, function() {
        return checkDependencies();
      });
      return false;
    }
    _asm.terminalDependenciesChecking = true;
    ready = true;
    for (lib in dependencies) {
      status = dependencies[lib];
      ready = ready && status;
      if (!ready) {
        console.log("Library " + lib + " isn't yet ready...");
        break;
      }
    }
    _asm.terminalDependencies = ready;
    _asm.terminalDependenciesChecking = false;
    if (ready) {
      console.log("Dependencies loaded");
      if (typeof callback === "function") {
        callback.apply(null, args);
      }
    }
    return ready;
  };
  naclCallback = function() {
    return nacl_factory.instantiate(function(nacl) {
      _asm.nacl = nacl;
      dependencies.nacl = true;
      return checkDependencies();
    });
  };
  if (typeof nacl_factory === "undefined" || nacl_factory === null) {
    loadJS("bower_components/js-nacl/lib/nacl_factory.js", function() {
      return naclCallback();
    });
  } else {
    naclCallback();
  }
  loadJS("bower_components/prism/prism.js", function() {
    loadJS("bower_components/prism/components/prism-sql.js", function() {
      dependencies.prism = true;
      loadJS("bower_components/prism/components/prism-json.js");
      checkDependencies();
      return false;
    });
    return $("head").append("<link href=\"bower_components/prism/themes/prism.css\" rel=\"stylesheet\" />");
  });
  return false;
};

parseQuery = function(selector, codeBoxSelector) {
  var codeBox, sql;
  if (selector == null) {
    selector = "#sql-input";
  }
  if (codeBoxSelector == null) {
    codeBoxSelector = "#interpreted-sql";
  }
  sql = $(selector).val().trim();
  sql = sql.replace(/@@/mig, "`mammal_diversity_database`");
  sql = sql.replace(/!@/mig, "SELECT * FROM `mammal_diversity_database`");
  codeBox = $(codeBoxSelector).get(0);
  $(codeBox).text(sql);
  Prism.highlightElement(codeBox);
  return sql;
};

executeQuery = function() {

  /*
   *
   */
  var args, darwinCoreOnly, handleSqlError, query;
  handleSqlError = function(errorMessage) {
    var alertId, e, error1, html;
    if (errorMessage == null) {
      errorMessage = "Error";
    }
    try {
      alertId = _asm.nacl.decode_utf8(_asm.nacl.crypto_hash_string(errorMessage + Date.now()));
    } catch (error1) {
      e = error1;
      console.warn(e.message);
      console.warn(e.stack);
      alertId = "sql-query-alert";
    }
    html = "<div class=\"alert alert-danger alert-dismissable col-xs-8 col-offset-xs-2 center-block clear clearfix\" role=\"alert\" id=\"" + alertId + "\">\n  <button type=\"button\" class=\"close\" data-dismiss=\"alert\" aria-label=\"Close\"><span aria-hidden=\"true\">&times;</span></button>\n  <div class=\"alert-message\">" + errorMessage + "</div>\n</div>";
    $("#sql-input").parents("paper-dialog").find(".alert").remove();
    $("#sql-input").parents("form").after(html);
    stopLoadError();
    return false;
  };
  try {
    darwinCoreOnly = p$("#dwc-only").checked;
  } catch (undefined) {}
  query = parseQuery();
  if (isNull(query)) {
    return handleSqlError("Sorry, you can't use an empty query");
  }
  args = {
    sql_query: post64(query),
    action: "query",
    dwc: darwinCoreOnly != null ? darwinCoreOnly : false
  };
  console.debug("Posting to target", uri.urlString + "api.php?" + (buildQuery(args)));
  $.post(uri.urlString + "api.php", buildQuery(args, "json")).done(function(result) {
    var error, error1, errorMessage, html, i, j, k, l, language, len, len1, len2, m, ref, ref1, results, row, rowData, rowHtml, rows, statement, statements;
    console.log("Got result", result);
    $("#sql-results").remove();
    try {
      if (result.statements != null) {
        statements = Object.toArray(result.statements);
      }
    } catch (undefined) {}
    if (result.status !== true) {
      if (isNull(result.statement_count)) {
        error = (ref = (ref1 = result.error) != null ? ref1 : result.human_error) != null ? ref : "UNKNOWN_ERROR";
        return handleSqlError(error);
      }
      for (j = 0, len = statements.length; j < len; j++) {
        statement = statements[j];
        if (statement.result === "ERROR") {
          errorMessage = "Your query <code class='language-sql'>" + statement.provided + "</code> ";
          if (statement.error.safety_check !== true) {
            errorMessage += "failed a safety check.";
          } else if (statement.error.sql_response === false) {
            errorMessage += "has or generated during parsing a syntax error.<br/><br/>If you believe your syntax to be valid, try simplifying it as we strictly limit the types of queries accessible here.";
          } else if (statement.error.was_server_exception) {
            errorMessage += "generated a problem on the server and was refused to be executed. Please report this.";
          } else {
            errorMessage += "gave <code>UNKNOWN_QUERY_ERROR</code>";
          }
          errorMessage += "<br/><br/>Execution of your query was halted here.";
          return handleSqlError(errorMessage);
        }
      }
    }
    $("#sql-input").parents("paper-dialog").find(".alert").remove();
    html = "<div id=\"sql-results\" class=\"sql-results col-xs-12\">\n</div>";
    if ($("#interpreted-sql").exists()) {
      $("#interpreted-sql").after(html);
    } else {
      $("#sql-input").parents("form").after(html);
    }
    rows = new Array();
    i = 0;
    for (l = 0, len1 = statements.length; l < len1; l++) {
      statement = statements[l];
      results = Object.toArray(statement.result);
      if (results.length === 0) {
        rowHtml = "<code>ZERO_RESULTS</code>";
        rows.push(rowHtml);
      } else {
        ++i;
        k = 0;
        for (m = 0, len2 = results.length; m < len2; m++) {
          row = results[m];
          ++k;
          try {
            rowData = JSON.stringify(row);
            rowData = rowData.replace(/,"/mig, ", \"");
            language = "json";
          } catch (error1) {
            rowData = "Unable to parse row";
            language = "text";
          }
          rowHtml = "<div>\n  " + i + "." + k + ":\n  <code class=\"language-" + language + "\">" + rowData + "</code>\n</div>";
          rows.push(rowHtml);
        }
      }
    }
    $("#sql-results").html(rows.join("<br/><br/>"));
    Prism.highlightAll();
    return false;
  }).fail(function(result, status) {
    console.error(result, status);
    console.warn("Couldn't hit target");
    handleSqlError("Problem talking to the server, please try again");
    return false;
  });
  return false;
};

$(function() {
  var html;
  html = "<paper-icon-button icon=\"icons:code\" id=\"launch-term\" title=\"Directly Query Database\" data-toggle=\"tooltip\">\n</paper-icon-button>";
  $("#git-footer").append(html);
  $("#launch-term").click(function() {
    return loadTerminalDialog.debounce();
  });
  return false;
});

//# sourceMappingURL=maps/terminal.js.map
