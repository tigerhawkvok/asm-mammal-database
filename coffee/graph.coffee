###
# Graph handler
###

loadJS "bower_components/d3/d3.min.js", ->
    loadJS "https://cdnjs.cloudflare.com/ajax/libs/lodash.js/4.17.4/lodash.min.js", ->
        loadJS "https://use.fontawesome.com/2b49aeb802.js", ->
            loadJS "bower_components/alchemyjs/dist/alchemy.js", ->
                $("head").append("<link rel='stylesheet' href='bower_components/alchemyjs/dist/alchemy.min.css'>")
                console.info "Alchemy ready"
                $("#do-relationship-search").removeAttr("disabled")
plotRelationships = (taxon1 = "rhinoceros unicornis", taxon2 = "bradypus tridactylus") ->
    ###
    #
    ###
    #$("#alchemy").empty()
    args =
        action: "relatedness"
        taxon1: taxon1 ? "rhinoceros unicornis"
        taxon2: taxon2 ? "bradypus tridactylus"
    passedArgs = buildArgs args
    console.debug "Visiting", "graphHandler.php?#{passedArgs}"
    $.get "graphHandler.php", passedArgs, "json"
    .done (result) ->
        # Plot it
        window.alchemyResult = result
        alchemyConf =
            dataSource: result
            directedEdges: true
            forceLayout: false
            # fixNodes: true
        alchemy.begin(alchemyConf)
        delay 500, ->
            $("#alchemy .node.root circle").attr("r", 15)
        # On click do lookup of children
        false
    .error (result, status) ->
        false
    false

$ ->
    $("#do-relationship-search").click ->
        console.debug "Clicked searcher"
        t1 = $("#firstTaxon").val()
        t2 = $("#secondTaxon").val()
        taxon1 = if isNull(t1) then undefined else t1
        taxon2 = if isNull(t2) then undefined else t2
        console.debug "Passing", taxon1, taxon2
        plotRelationships(taxon1, taxon2)
    $("#reset-graph").click ->
        $("#alchemy").empty()
