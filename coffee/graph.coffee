###
# Graph handler
###

plotRelationships = (taxon1 = "rhinoceros unicornis", taxon2 = "bradypus tridactylus") ->
    ###
    #
    ###
    args =
        action: "relatedness"
        taxon1: taxon1 ? "rhinoceros unicornis"
        taxon2: taxon2 ? "bradypus tridactylus"
    passedArgs = buildArgs args
    console.debug "Visiting", "graphHandler.php?#{passedArgs}"
    $.get "graphHandler.php", passedArgs, "json"
    .done (result) ->
        # Plot
        console.debug result
        window.alchemyResult = result
        alchemyConf =
            dataSource: result
            directedEdges: true
            forceLayout: false
            # fixNodes: true
        #alchemy.begin(alchemyConf)
        sgraph.graph.read(result)
        for node in sgraph.graph.nodes()
            try
                if node.caption isnt node.label
                    node.label = node.caption
                    console.debug "Replaced label"
                else
                    continue
                sgraph.graph.addNode node
        # for edge in result.directedEdges
        #     sgraph.graph.addEdge edge
        sgraph.refresh()
        delay 500, ->
            $("#alchemy .node.root circle").attr("r", 15)
        # On click do lookup of children
        $("g.node")
        .unbind()
        .click ->
            nodeClickEvent(this)
        false
    .error (result, status) ->
        false
    false


nodeClickEvent = (node, data = null) ->
    ###
    #
    ###
    # Helper
    handleResult = (result, baseOffsetX = 0, baseOffsetY = 0) ->
        console.debug result
        if isNull result.label
            return false
        taxon = $(node).find("text").text()
        if isNull taxon
            if not isNull result.binomial
                taxon = result.binomial
            else
                taxon = result.label
        # If the rank is species, navigate there
        if result.rank.toLowerCase() is "species"
            # Go there
            taxonParts = taxon.split(" ")
            args =
                genus: taxonParts[0]
                species: taxonParts[1]
            dest = "species-account.php?#{buildArgs args}"
            if not isNull args.species
                goTo dest
                return true
        # Otherwise, fetch child nodes and render them
        args =
            action: "children"
            taxon: taxon
        console.debug "Finding children", "graphHandler.php?#{buildArgs(args)}"
        $.get "graphHandler.php", buildArgs(args), "json"
        .done (result) ->
            console.debug "Got result", result
            # append =
            #     dataSource: result
            # alchemy.begin append
            # sgraph.graph.read(result)
            i = 0
            baseOffsetX += 1
            for node in result.nodes
                console.debug "Creating node", node
                #alchemy.create.nodes node
                try
                    ++i
                    node.x += baseOffsetX + 1.5*i
                    node.y += baseOffsetY + 0.25*i
                    console.debug "offsets", node.x, node.y
                    try
                        if node.caption isnt node.label
                            node.label = node.caption
                            console.debug "Replaced label"
                    sgraph.graph.addNode node
            for edge in result.edges
                console.debug "Creating edge", edge
                #alchemy.create.edges edge
                try
                    sgraph.graph.addEdge edge
            sgraph.refresh()
            $("g.node")
            .unbind()
            .click ->
                nodeClickEvent(this)
            false
        .error (result, status) ->
            false
        false
    if not isNull data
        console.debug "Provided data", data
        handleResult data.values, data.x, data.y
        return false
    # Fetch it from the ID
    idString = $(node).attr("id")
    id = idString.replace("node-", "")
    # Do a cypher fetch of the clade name and rank via the php endpoint
    args =
        action: "id_details"
        id: id
    $.get "graphHandler.php", buildArgs args, "json"
    .done (result) ->
        handleResult(result)
        true
    .error (result, status) ->
        false
    false


checkInputTaxon = (selector  = "#firstTaxon", callback) ->
    ###
    #
    ###
    console.debug "About to check taxon..."
    if not $(selector).exists()
        console.error "Invalid selector"
        return false
    invalidTaxonHelper = (text) ->
        ###
        # Do the error handling
        ###
        bsAlert text, "danger"
        $(selector).parent()
        .addClass("has-error")
        .addClass("has-feedback")
        $(selector).after("""<span class="glyphicon glyphicon-remove form-control-feedback" aria-hidden="true"></span>""")
        false
    # Remove any pre-existing labels
    $(selector).parent()
    .removeClass("has-error")
    .removeClass("has-feedback")
    $(selector).parent().find(".form-control-feedback").remove()
    taxonToCheck = $(selector).val()
    if isNull(taxonToCheck)
        console.error "Blank taxon error"
        invalidTaxonHelper("Blank taxon provided. Please make sure all taxon fields are filled.")
        return false
    args =
        q: taxonToCheck
        strict: true
    console.debug "About to ping api for taxon", taxonToCheck
    $.get "api.php", buildArgs(args), "json"
    .done (result) ->
        console.debug "Got result"
        if result.status is true and result.count > 0
            if typeof callback is "function"
                callback()
            return true
        invalidTaxonHelper("Invalid taxon: '#{taxonToCheck}'")
        return false
    .fail (result, error) ->
        console.error "Unable to ping the server"
    false



fireRelationshipSearch = ->
    console.debug "Clicked searcher"
    t1 = $("#firstTaxon").val()
    t2 = $("#secondTaxon").val()
    taxon1 = if isNull(t1) then undefined else t1.trim()
    taxon2 = if isNull(t2) then undefined else t2.trim()
    checkInputTaxon "#firstTaxon", ->
        checkInputTaxon "#secondTaxon", ->
            $("#bs-alert").remove()
            console.debug "Passing", taxon1, taxon2
            plotRelationships(taxon1, taxon2)
    false

$ ->
    $("#do-relationship-search").click ->
        fireRelationshipSearch()
        false
    $(".taxon-entry").keyup (e) ->
        kc = if e.keyCode then e.keyCode else e.which
        console.debug("Keycode", kc)
        if kc is 13
            fireRelationshipSearch()
        false
    $("#reset-graph").click ->
        $("#alchemy").remove()
        $("#graph-container").html("""<div id="alchemy" class="alchemy" style="height: 75vh">
        </div>""")
        return false
    window.sgraph = new sigma("sigma")
    sigmaSettings =
        edgeColor: "default"
        defaultEdgeColor: "#999"
        minArrowSize: 2
        skipErrors: true
    sgraph.settings(sigmaSettings)
    sgraph.bind "clickNode", (data) ->
        console.debug "Clicked", data
        nodeClickEvent(this, data.data.node)
    sgraph.startForceAtlas2()
    console.info "Sigma ready"
    $("#do-relationship-search").removeAttr("disabled")

