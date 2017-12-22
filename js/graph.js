
/*
 * Graph handler
 */
var plotRelationships;

loadJS("bower_components/d3/d3.min.js", function() {
  return loadJS("https://cdnjs.cloudflare.com/ajax/libs/lodash.js/4.17.4/lodash.min.js", function() {
    return loadJS("https://use.fontawesome.com/2b49aeb802.js", function() {
      return loadJS("bower_components/alchemyjs/dist/alchemy.js", function() {
        $("head").append("<link rel='stylesheet' href='bower_components/alchemyjs/dist/alchemy.min.css'>");
        return console.info("Alchemy ready");
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
    taxon1: taxon1,
    taxon2: taxon2
  };
  passedArgs = buildArgs(args);
  console.debug("Visiting", "graphHandler.php?" + passedArgs);
  $.get("graphHandler.php", passedArgs, "json").done(function(result) {
    var alchemyConf;
    window.alchemyResult = result;
    alchemyConf = {
      dataSource: result,
      directedEdges: true
    };
    alchemy.begin({
      dataSource: result
    });
    return false;
  }).error(function(result, status) {
    return false;
  });
  return false;
};

//# sourceMappingURL=maps/graph.js.map
