getRandomDataColor = ->
  colorString = "rgba(#{randomInt(0,255)},#{randomInt(0,255)},#{randomInt(0,255)}"
  # Translucent
  colors =
    border: "#{colorString},1)"
    background: "#{colorString},0.2)"
  colors


$ ->
  if $("#high-level-taxon-data").exists()
    console.log "Rendering high level taxon data"
    hlTaxonLabels = Object.toArray window.hlTaxonLabels
    hlTaxonData = Object.toArray window.hlTaxonData
    color = getRandomDataColor()
    chartConfig =
      type: "bar"
      data:
        labels: hlTaxonLabels
        datasets: [
          label: "Species Count"
          data: hlTaxonData
          borderColor: color.border
          backgroundColor: color.background
          borderWidth: 1
          ]
      options:
        scales:
          yAxes: [
            type: 'logarithmic'
            scaleLabel:
              labelString: "Species"
              display: true
            ticks:
              min: .75
              # beginAtZero: true
            ]
          xAxes: [
            scaleLabel:
              labelString: "Linnean Order"
              display: true
            ]
    chartCtx = $("#high-level-chart")
    if typeof window._asm isnt "object"
      window._asm = new Object()
    _asm.chart = new Chart chartCtx, chartConfig
    console.debug "Config:", chartConfig
    chartCtx.click (e) ->
      dataset = _asm.chart.getDatasetAtEvent e
      console.debug "Dataset", dataset
      false
  false
