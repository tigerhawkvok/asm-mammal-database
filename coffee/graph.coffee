###
# Graph handler
###

loadJS("bower_components/alchemyjs/dist/alchemy.min.js")
$("head").append("<link rel='stylesheet' href='bower_components/alchemyjs/dist/alchemy.min.css'>")
plotRelationships = (taxon1 = "rhinoceros unicornis", taxon2 = "bradypus tridactylus") ->
    ###
    #
    ###
    args = {action: "relatedness", taxon1, taxon2}
    $.get "graphHandler.php", buildArgs args, "json"
    .done (result) ->
        # Plot it
        alchemy.begin({dataSource: result})
        false
    .error (result, status) ->
        false
    false
