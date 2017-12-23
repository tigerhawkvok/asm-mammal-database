
/*
 * Graph handler
 */
var plotRelationships;

loadJS("bower_components/d3/d3.min.js", function() {
  return loadJS("https://cdnjs.cloudflare.com/ajax/libs/lodash.js/4.17.4/lodash.min.js", function() {
    return loadJS("https://use.fontawesome.com/2b49aeb802.js", function() {
      return loadJS("bower_components/alchemyjs/dist/alchemy.js", function() {
        $("head").append("<link rel='stylesheet' href='bower_components/alchemyjs/dist/alchemy.min.css'>");
        console.info("Alchemy ready");
        return $("#do-relationship-search").removeAttr("disabled");
      });
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
    return false;
  }).error(function(result, status) {
    return false;
  });
  return false;
};

$(function() {
  $("#do-relationship-search").click(function() {
    var t1, t2, taxon1, taxon2;
    console.debug("Clicked searcher");
    t1 = $("#firstTaxon").val();
    t2 = $("#secondTaxon").val();
    taxon1 = isNull(t1) ? void 0 : t1;
    taxon2 = isNull(t2) ? void 0 : t2;
    console.debug("Passing", taxon1, taxon2);
    return plotRelationships(taxon1, taxon2);
  });
  return $("#reset-graph").click(function() {
    return $("#alchemy").empty();
  });
});

//# sourceMappingURL=maps/graph.js.map
