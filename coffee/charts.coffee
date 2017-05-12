getRandomDataColor = ->
  colorString = "rgba(#{randomInt(0,255)},#{randomInt(0,255)},#{randomInt(0,255)}"
  # Translucent
  colors =
    border: "#{colorString},1)"
    background: "#{colorString},0.2)"
  colors


renderTaxonData = ->
  ###
  #
  ###
  if _asm?.chart?
    _asm.chart.destroy()
  tickCallback = (value, index, values) ->
    if (index %% 4) is 0 and toFloat(value.noExponents()) >= 1
      value.noExponents()
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
          type: "line"
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


$ ->
  renderTaxonData()
  try
    $("#log-scale").on "iron-change", ->
      if _asm?.chart?
        _asm.chart.destroy()
      renderTaxonData.debounce()
