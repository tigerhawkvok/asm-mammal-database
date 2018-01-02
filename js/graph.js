
/*
 * Graph handler
 */
var checkInputTaxon, fireRelationshipSearch, nodeClickEvent, plotRelationships;

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
    var alchemyConf, j, len, node, ref;
    console.debug(result);
    window.alchemyResult = result;
    alchemyConf = {
      dataSource: result,
      directedEdges: true,
      forceLayout: false
    };
    sgraph.graph.read(result);
    ref = sgraph.graph.nodes();
    for (j = 0, len = ref.length; j < len; j++) {
      node = ref[j];
      try {
        if (node.caption !== node.label) {
          node.label = node.caption;
          console.debug("Replaced label");
        } else {
          continue;
        }
        sgraph.graph.addNode(node);
      } catch (undefined) {}
    }
    sgraph.refresh();
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

nodeClickEvent = function(node, data) {
  var args, handleResult, id, idString;
  if (data == null) {
    data = null;
  }

  /*
   *
   */
  handleResult = function(result, baseOffsetX, baseOffsetY) {
    var args, dest, taxon, taxonParts;
    if (baseOffsetX == null) {
      baseOffsetX = 0;
    }
    if (baseOffsetY == null) {
      baseOffsetY = 0;
    }
    console.debug(result);
    if (isNull(result.label)) {
      return false;
    }
    taxon = $(node).find("text").text();
    if (isNull(taxon)) {
      if (!isNull(result.binomial)) {
        taxon = result.binomial;
      } else {
        taxon = result.label;
      }
    }
    if (result.rank.toLowerCase() === "species") {
      taxonParts = taxon.split(" ");
      args = {
        genus: taxonParts[0],
        species: taxonParts[1]
      };
      dest = "species-account.php?" + (buildArgs(args));
      if (!isNull(args.species)) {
        goTo(dest);
        return true;
      }
    }
    args = {
      action: "children",
      taxon: taxon
    };
    console.debug("Finding children", "graphHandler.php?" + (buildArgs(args)));
    $.get("graphHandler.php", buildArgs(args), "json").done(function(result) {
      var edge, i, j, k, len, len1, ref, ref1;
      console.debug("Got result", result);
      i = 0;
      baseOffsetX += 1;
      ref = result.nodes;
      for (j = 0, len = ref.length; j < len; j++) {
        node = ref[j];
        console.debug("Creating node", node);
        try {
          ++i;
          node.x += baseOffsetX + 1.5 * i;
          node.y += baseOffsetY + 0.25 * i;
          console.debug("offsets", node.x, node.y);
          try {
            if (node.caption !== node.label) {
              node.label = node.caption;
              console.debug("Replaced label");
            }
          } catch (undefined) {}
          sgraph.graph.addNode(node);
        } catch (undefined) {}
      }
      ref1 = result.edges;
      for (k = 0, len1 = ref1.length; k < len1; k++) {
        edge = ref1[k];
        console.debug("Creating edge", edge);
        try {
          sgraph.graph.addEdge(edge);
        } catch (undefined) {}
      }
      sgraph.refresh();
      $("g.node").unbind().click(function() {
        return nodeClickEvent(this);
      });
      return false;
    }).error(function(result, status) {
      return false;
    });
    return false;
  };
  if (!isNull(data)) {
    console.debug("Provided data", data);
    handleResult(data.values, data.x, data.y);
    return false;
  }
  idString = $(node).attr("id");
  id = idString.replace("node-", "");
  args = {
    action: "id_details",
    id: id
  };
  $.get("graphHandler.php", buildArgs(args, "json")).done(function(result) {
    handleResult(result);
    return true;
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
  var sigmaSettings;
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
  $("#reset-graph").click(function() {
    $("#alchemy").remove();
    $("#graph-container").html("<div id=\"alchemy\" class=\"alchemy\" style=\"height: 75vh\">\n</div>");
    return false;
  });
  window.sgraph = new sigma("sigma");
  sigmaSettings = {
    edgeColor: "default",
    defaultEdgeColor: "#999",
    minArrowSize: 2,
    skipErrors: true
  };
  sgraph.settings(sigmaSettings);
  sgraph.bind("clickNode", function(data) {
    console.debug("Clicked", data);
    return nodeClickEvent(this, data.data.node);
  });
  sgraph.startForceAtlas2();
  console.info("Sigma ready");
  return $("#do-relationship-search").removeAttr("disabled");
});

//# sourceMappingURL=maps/graph.js.map
