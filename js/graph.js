
/*
 * Graph handler
 */
var checkInputTaxon, fireRelationshipSearch, nodeClickEvent, plotRelationships;

loadJS("bower_components/d3/d3.min.js", function() {
  return loadJS("https://cdnjs.cloudflare.com/ajax/libs/lodash.js/4.17.4/lodash.min.js", function() {
    return loadJS("bower_components/alchemyjs/dist/alchemy.js", function() {
      $("head").append("<link rel='stylesheet' href='bower_components/alchemyjs/dist/alchemy.min.css'>");
      console.info("Alchemy ready");
      return $("#do-relationship-search").removeAttr("disabled");
    });
  });
});

plotRelationships = function(taxon1, taxon2) {
  var args, passedArgs;
  if (taxon1 == null) {
    taxon1 = "rhinoceros unicornis";
  }
  if (taxon2 == null) {
    taxon2 = "bradypus tridactylus";
  }

  /*
   *
   */
  args = {
    action: "relatedness",
    taxon1: taxon1 != null ? taxon1 : "rhinoceros unicornis",
    taxon2: taxon2 != null ? taxon2 : "bradypus tridactylus"
  };
  passedArgs = buildArgs(args);
  console.debug("Visiting", "graphHandler.php?" + passedArgs);
  $.get("graphHandler.php", passedArgs, "json").done(function(result) {
    var alchemyConf;
    window.alchemyResult = result;
    alchemyConf = {
      dataSource: result,
      directedEdges: true,
      forceLayout: false
    };
    alchemy.begin(alchemyConf);
    delay(500, function() {
      return $("#alchemy .node.root circle").attr("r", 15);
    });
    $("g.node").unbind().click(function() {
      return nodeClickEvent(this);
    });
    return false;
  }).error(function(result, status) {
    return false;
  });
  return false;
};

nodeClickEvent = function(node) {

  /*
   *
   */
  var args, id, idString;
  idString = $(node).attr("id");
  id = idString.replace("node-", "");
  args = {
    action: "id_details",
    id: id
  };
  $.get("graphHandler.php", buildArgs(args, "json")).done(function(result) {
    var dest, taxon, taxonParts;
    console.debug(result);
    if (isNull(result.label)) {
      return false;
    }
    if (result.rank.toLowerCase() === "species") {
      taxon = $(node).find("text").text();
      taxonParts = taxon.split(" ");
      args = {
        genus: taxonParts[0],
        species: taxonParts[1]
      };
      dest = "species-account.php?" + (buildArgs(args));
      goTo(dest);
      return true;
    } else {
      return true;
    }
  }).error(function(result, status) {
    return false;
  });
  return false;
};

checkInputTaxon = function(selector, callback) {
  var args, invalidTaxonHelper, taxonToCheck;
  if (selector == null) {
    selector = "#firstTaxon";
  }

  /*
   *
   */
  console.debug("About to check taxon...");
  if (!$(selector).exists()) {
    console.error("Invalid selector");
    return false;
  }
  invalidTaxonHelper = function(text) {

    /*
     * Do the error handling
     */
    bsAlert(text, "danger");
    $(selector).parent().addClass("has-error").addClass("has-feedback");
    $(selector).after("<span class=\"glyphicon glyphicon-remove form-control-feedback\" aria-hidden=\"true\"></span>");
    return false;
  };
  $(selector).parent().removeClass("has-error").removeClass("has-feedback");
  $(selector).parent().find(".form-control-feedback").remove();
  taxonToCheck = $(selector).val();
  if (isNull(taxonToCheck)) {
    console.error("Blank taxon error");
    invalidTaxonHelper("Blank taxon provided. Please make sure all taxon fields are filled.");
    return false;
  }
  args = {
    q: taxonToCheck,
    strict: true
  };
  console.debug("About to ping api for taxon", taxonToCheck);
  $.get("api.php", buildArgs(args), "json").done(function(result) {
    console.debug("Got result");
    if (result.status === true && result.count > 0) {
      if (typeof callback === "function") {
        callback();
      }
      return true;
    }
    invalidTaxonHelper("Invalid taxon: '" + taxonToCheck + "'");
    return false;
  }).fail(function(result, error) {
    return console.error("Unable to ping the server");
  });
  return false;
};

fireRelationshipSearch = function() {
  var t1, t2, taxon1, taxon2;
  console.debug("Clicked searcher");
  t1 = $("#firstTaxon").val();
  t2 = $("#secondTaxon").val();
  taxon1 = isNull(t1) ? void 0 : t1.trim();
  taxon2 = isNull(t2) ? void 0 : t2.trim();
  checkInputTaxon("#firstTaxon", function() {
    return checkInputTaxon("#secondTaxon", function() {
      $("#bs-alert").remove();
      console.debug("Passing", taxon1, taxon2);
      return plotRelationships(taxon1, taxon2);
    });
  });
  return false;
};

$(function() {
  $("#do-relationship-search").click(function() {
    fireRelationshipSearch();
    return false;
  });
  $(".taxon-entry").keyup(function(e) {
    var kc;
    kc = e.keyCode ? e.keyCode : e.which;
    console.debug("Keycode", kc);
    if (kc === 13) {
      fireRelationshipSearch();
    }
    return false;
  });
  return $("#reset-graph").click(function() {
    $("#alchemy").remove();
    $("#alchemy-container").html("<div id=\"alchemy\" class=\"alchemy\" style=\"height: 75vh\">\n</div>");
    return false;
  });
});

//# sourceMappingURL=maps/graph.js.map
