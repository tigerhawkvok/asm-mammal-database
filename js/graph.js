
/*
 * Graph handler
 */
var plotRelationships;

loadJS("bower_components/alchemyjs/dist/alchemy.min.js");

$("head").append("<link rel='stylesheet' href='bower_components/alchemyjs/dist/alchemy.min.css'>");

plotRelationships = function(taxon1, taxon2) {
  var args;
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
  $.get("graphHandler.php", buildArgs(args, "json")).done(function(result) {
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
