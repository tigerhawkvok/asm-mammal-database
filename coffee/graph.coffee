###
# Graph handler
###

loadJS "bower_components/d3/d3.min.js", ->
    loadJS "https://cdnjs.cloudflare.com/ajax/libs/lodash.js/4.17.4/lodash.min.js", ->
        loadJS "bower_components/alchemyjs/dist/alchemy.js", ->
            $("head").append("<link rel='stylesheet' href='bower_components/alchemyjs/dist/alchemy.min.css'>")
            console.info "Alchemy ready"
            $("#do-relationship-search").removeAttr("disabled")
# loadJS "bower_components/sigma.js-1.2.1/build/" ## npm run build via https://github.com/jacomyal/sigma.js#how-to-use-it
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
        # TODO On click do lookup of children
        $("g.node")
        .unbind()
        .click ->
            nodeClickEvent(this)
        false
    .error (result, status) ->
        false
    false


nodeClickEvent = (node) ->
    ###
    #
    ###
    idString = $(node).attr("id")
    id = idString.replace("node-", "")
    # Do a cypher fetch of the clade name and rank via the php endpoint
    args =
        action: "id_details"
        id: id
    $.get "graphHandler.php", buildArgs args, "json"
    .done (result) ->
        console.debug result
        if isNull result.label
            return false
        # If the rank is species, navigate there
        if result.rank.toLowerCase() is "species"
            # TODO Go there
            taxon = $(node).find("text").text()
            taxonParts = taxon.split(" ")
            args =
                genus: taxonParts[0]
                species: taxonParts[1]
            dest = "species-account.php?#{buildArgs args}"
            console.debug dest
            true
        # Otherwise, fetch child nodes and render them
        else
            # TODO Render it
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
        $("#alchemy-container").html("""<div id="alchemy" class="alchemy" style="height: 75vh">
        </div>""")
        return false

