var getRandomDataColor;

getRandomDataColor = function() {
  var colorString, colors;
  colorString = "rgba(" + (randomInt(0, 255)) + "," + (randomInt(0, 255)) + "," + (randomInt(0, 255));
  colors = {
    border: colorString + ",1)",
    background: colorString + ",0.2)"
  };
  return colors;
};

$(function() {
  var chartConfig, chartCtx, color, hlTaxonData, hlTaxonLabels;
  if ($("#high-level-taxon-data").exists()) {
    console.log("Rendering high level taxon data");
    hlTaxonLabels = Object.toArray(window.hlTaxonLabels);
    hlTaxonData = Object.toArray(window.hlTaxonData);
    color = getRandomDataColor();
    chartConfig = {
      type: "bar",
      data: {
        labels: hlTaxonLabels,
        datasets: [
          {
            label: "Species Count",
            data: hlTaxonData,
            borderColor: color.border,
            backgroundColor: color.background,
            borderWidth: 1
          }
        ]
      },
      options: {
        scales: {
          yAxes: [
            {
              type: 'logarithmic',
              scaleLabel: {
                labelString: "Species",
                display: true
              },
              ticks: {
                min: .75
              }
            }
          ],
          xAxes: [
            {
              scaleLabel: {
                labelString: "Linnean Order",
                display: true
              }
            }
          ]
        }
      }
    };
    chartCtx = $("#high-level-chart");
    if (typeof window._asm !== "object") {
      window._asm = new Object();
    }
    _asm.chart = new Chart(chartCtx, chartConfig);
    console.debug("Config:", chartConfig);
    chartCtx.click(function(e) {
      var data, dataset, elIndex, element, taxon, taxonData, zoomChartConfig, zoomChartCtx;
      dataset = _asm.chart.getDatasetAtEvent(e);
      element = _asm.chart.getElementAtEvent(e);
      console.debug("Dataset", dataset);
      console.debug("Element", element);
      elIndex = element[0]._index;
      data = dataset[elIndex];
      console.debug("Specific data:", data);
      taxon = data._model.label;
      console.debug("Taxon clicked:", taxon);
      taxonData = window.genusData[taxon];
      console.debug("Using data", taxonData);
      $("#zoom-taxon-label").html("<span class='genus'>" + taxon + "</span> Genus Breakdown");
      color = getRandomDataColor();
      zoomChartConfig = {
        type: "bar",
        data: {
          labels: Object.toArray(taxonData.labels),
          datasets: [
            {
              label: "Species Count",
              data: Object.toArray(taxonData.data),
              borderColor: color.border,
              backgroundColor: color.background,
              borderWidth: 1
            }
          ]
        },
        options: {
          scales: {
            yAxes: [
              {
                type: 'logarithmic',
                scaleLabel: {
                  labelString: "Species",
                  display: true
                },
                ticks: {
                  min: .75
                }
              }
            ],
            xAxes: [
              {
                scaleLabel: {
                  labelString: "Genera in " + taxon,
                  display: true
                }
              }
            ]
          }
        }
      };
      zoomChartCtx = $("#taxon-zoom-chart");
      if (_asm.zoomChart != null) {
        _asm.zoomChart.destroy();
      }
      _asm.zoomChart = new Chart(zoomChartCtx, zoomChartConfig);
      return false;
    });
  }
  return false;
});

//# sourceMappingURL=maps/charts.js.map
