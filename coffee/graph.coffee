###
# Graph handler
###

loadJS "bower_components/d3/d3.min.js", ->
    loadJS "https://cdnjs.cloudflare.com/ajax/libs/lodash.js/4.17.4/lodash.min.js", ->
        loadJS "https://use.fontawesome.com/2b49aeb802.js", ->
            loadJS "bower_components/alchemyjs/dist/alchemy.js", ->
                $("head").append("<link rel='stylesheet' href='bower_components/alchemyjs/dist/alchemy.min.css'>")
                console.info "Alchemy ready"
plotRelationships = (taxon1 = "rhinoceros unicornis", taxon2 = "bradypus tridactylus") ->
    ###
    #
    ###
    args =
        action: "relatedness"
        taxon1: taxon1
        taxon2: taxon2
    passedArgs = buildArgs args
    console.debug "Visiting", "graphHandler.php?#{passedArgs}"
    $.get "graphHandler.php", passedArgs, "json"
    .done (result) ->
        # Plot it
        window.alchemyResult = result
        alchemy.begin({dataSource: result})
        false
    .error (result, status) ->
        false
    false
