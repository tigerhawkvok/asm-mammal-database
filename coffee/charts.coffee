getRandomDataColor = ->
  colorString = "rgba(#{randomInt(0,255)},#{randomInt(0,255)},#{randomInt(0,255)}"
  # Translucent
  colors =
    border: "#{colorString},1)"
    background: "#{colorString},0.2)"
  colors


updateTaxonomySort = ->
  ###
  # Do an async fetch on the taxonomy order, then re-call renderTaxonData
  ###
  startTime = Date.now()
  startLoad()
  args =
    action: "taxonomy"
  # Get the dropdown value
  try
    isDefault = p$("#default-sort-toggle").checked
  catch
    isDefault = true
  unless isDefault
    # Check the individual dropdowns
    sorts = getChartKeys()
    args.order_sort = sorts.order_sort
    args.genus_sort = sorts.genus_sort
  $.get "#{uri.urlString}api.php", objToArgs args, "json"
  .done (result) ->
    if result.status is true
      window.hlTaxonLabels = Object.toArray result.taxonomy.order.labels
      window.hlTaxonData = Object.toArray result.taxonomy.order.data
      window.genusData = result.taxonomy.genus.data
      elapsed = Date.now() - startTime
      console.debug "Taxon data fetch successful in #{elapsed}ms"
      renderTaxonData.debounce()
      stopLoad()
    false
  .fail (result, status) ->
    console.error result, status
    stopLoadError "There was an error updating the sort of your dataset"
    false
  false



renderTaxonData = ->
  ###
  #
  ###
  if _asm?.chart?
    _asm.chart.destroy()
  tickCallback = (value, index, values) ->
    if (index %% 4) is 0 and toFloat(value.removeExponents()) >= 1
      value.removeExponents()
    else ""
  try
    if p$("#log-scale").checked
      yScaleType = "logarithmic"
    else
      yScaleType = "linear"
      # From the docs
      tickCallback = undefined
  catch
    yScaleType = "logarithmic"
  if $("#high-level-taxon-data").exists()
    console.log "Rendering high level taxon data"
    hlTaxonLabels = Object.toArray window.hlTaxonLabels
    hlTaxonData = Object.toArray window.hlTaxonData
    genusCountData = new Array()
    for order in hlTaxonLabels
      genusList = Object.toArray window.genusData[order].labels
      genusCountData.push genusList.length
    color = getRandomDataColor()
    lineColor = getRandomDataColor()
    chartConfig =
      type: "bar"
      data:
        labels: hlTaxonLabels
        datasets: [
          {
          label: "Species Count"
          type: "bar"
          data: hlTaxonData
          borderColor: color.border
          backgroundColor: color.background
          borderWidth: 1
          }
          {
          label: "Genus Count"
          type: "bar"
          data: genusCountData
          borderColor: lineColor.border
          backgroundColor: lineColor.background
          borderWidth: 1
          }
          ]
      options:
        scales:
          yAxes: [
            type: yScaleType
            scaleLabel:
              labelString: "Species"
              display: true
            ticks:
              min: .75
              #callback: tickCallback
              # beginAtZero: true
            ]
          xAxes: [
            scaleLabel:
              labelString: "Linnean Order"
              display: true
            ]
    if tickCallback?
      chartConfig.options.scales.yAxes[0].ticks.callback = tickCallback
    chartCtx = $("#high-level-chart")
    if typeof window._asm isnt "object"
      window._asm = new Object()
    _asm.chart = new Chart chartCtx, chartConfig
    console.debug "Config:", chartConfig
    chartCtx.click (e) ->
      dataset = _asm.chart.getDatasetAtEvent e
      element = _asm.chart.getElementAtEvent e
      console.debug "Dataset", dataset
      console.debug "Element", element
      elIndex = element[0]._index
      data = dataset[elIndex]
      console.debug "Specific data:", data
      taxon = data._model.label
      console.debug "Taxon clicked:", taxon
      taxonData = window.genusData[taxon]
      console.debug "Using data", taxonData
      $("#zoom-taxon-label").html "<span class='genus'>#{taxon}</span> Genus Breakdown"
      color = getRandomDataColor()
      zoomChartConfig =
        type: "bar"
        data:
          labels: Object.toArray taxonData.labels
          datasets: [
            label: "Species Count"
            data: Object.toArray taxonData.data
            borderColor: color.border
            backgroundColor: color.background
            borderWidth: 1
            ]
        options:
          scales:
            yAxes: [
              type: yScaleType
              scaleLabel:
                labelString: "Species"
                display: true
              ticks:
                min: .75
                # callback: tickCallback
                # beginAtZero: true
              ]
            xAxes: [
              scaleLabel:
                labelString: "Genera in #{taxon}"
                display: true
              ticks:
                fontStyle: "italic"
              ]
      if tickCallback?
        zoomChartConfig.options.scales.yAxes[0].ticks.callback = tickCallback
      zoomChartCtx = $("#taxon-zoom-chart")
      if _asm.zoomChart?
        _asm.zoomChart.destroy()
        # $("#taxon-zoom-chart").empty()
      _asm.zoomChart = new Chart zoomChartCtx, zoomChartConfig
      false
  false


getChartKeys = ->
  chartOptions = new Object()
  for option in $(".chart-param")
    key = $(option).attr("data-key")
    try
      if p$(option).checked?
        chartOptions[key] = p$(option).checked
      else
        throw "Not Toggle"
    catch
      try
        unless window.debugDrop
          window.debugDrop = new Object()
        console.log "Looking at", option
        window.debugDrop[key] = option
      try
        dropdownVal = $(p$(option).selectedItem).attr "data-value"
      chartOptions[key] = dropdownVal ? p$(option).selectedItemLabel.toLowerCase().replace(" ", "-")
  chartOptions



$ ->
  _asm.hasBoundDropdowns = false
  renderTaxonData()
  try
    $("#log-scale").on "iron-change", ->
      if _asm?.chart?
        _asm.chart.destroy()
      renderTaxonData.debounce()
      false
    $("#default-sort-toggle").on "iron-change", ->
      if p$(this).checked
        try
          for dropdown in $(".sort-options")
            p$(dropdown).disabled = true
        catch
          $(".sort-options").attr "disabled", "disabled"
      else
        try
          for dropdown in $(".sort-options")
            p$(dropdown).disabled = false
        catch
          $(".sort-options").removeAttr "disabled"
      renderTaxonData.debounce()
      false
  try
    delayPolymerBind "paper-dropdown-menu#order-sort", ->
      unless _asm.hasBoundDropdowns
        _asm.hasBoundDropdowns = true
        console.info "Binding events for dropdown"
        # The event itself
        listItemSelectEvent = (element, event) ->
          ###
          # For whatever reason, binding the event breaks the default
          # select. So, we want to mimic the native one.
          ###
          console.debug element, event, event.detail.item
          # Get the dropdown
          dropdown = if element.tagName.toLowerCase() isnt "paper-dropdown-menu" then $(element).parents("paper-dropdown-menu").get(0) else element
          item = if element.tagName.toLowerCase() isnt "paper-item" then event.detail.item ? $(element).find("paper-item").get(0) else element
          console.debug dropdown, item
          # Set the selected item
          p$(dropdown)._setSelectedItem item          
          config = getChartKeys()
          console.debug config
          updateTaxonomySort()
          false
        # Sometimes, one event or the other gets picky, so we'll bind both
        $("paper-dropdown-menu.sort-options paper-listbox")
        .on "iron-select", (e) ->
          console.debug "is event for dropdown"
          listItemSelectEvent.debounce 50, null, null, this, e
          false
        $("paper-dropdown-menu.sort-options paper-listbox paper-item")
        .click (e) ->
          console.debug "Click event for dropdown"
          listItemSelectEvent.debounce 50, null, null, this, e
          false
        console.log "Events bound"
      false
  catch e
    console.warn "Warning: couldn't bind polymer events - #{e.message}"
    console.warn e.stack
