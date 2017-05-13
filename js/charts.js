var getChartKeys, getRandomDataColor, renderTaxonData, updateTaxonomySort,
  modulo = function(a, b) { return (+a % (b = +b) + b) % b; };

getRandomDataColor = function() {
  var colorString, colors;
  colorString = "rgba(" + (randomInt(0, 255)) + "," + (randomInt(0, 255)) + "," + (randomInt(0, 255));
  colors = {
    border: colorString + ",1)",
    background: colorString + ",0.2)"
  };
  return colors;
};

updateTaxonomySort = function() {

  /*
   * Do an async fetch on the taxonomy order, then re-call renderTaxonData
   */
  var args, error, isDefault, startTime;
  startTime = Date.now();
  startLoad();
  args = {
    action: "taxonomy"
  };
  try {
    isDefault = p$("#default-sort-toggle").checked;
  } catch (error) {
    isDefault = true;
  }
  if (!isDefault) {
    args.order_sort = orderSortVal;
    args.genus_sort = genusSortVal;
  }
  $.get(uri.urlString + "api.php", objToArgs(args, "json")).done(function(result) {
    var elapsed;
    if (result.status === true) {
      window.hlTaxonLabels = Object.toArray(result.taxonomy.order.labels);
      window.hlTaxonData = Object.toArray(result.taxonomy.order.data);
      window.genusData = result.taxonomy.genus.data;
      elapsed = Date.now() - startTime;
      console.debug("Taxon data fetch successful in " + elapsed + "ms");
      renderTaxonData.debounce();
      stopLoad();
    }
    return false;
  }).fail(function(result, status) {
    console.error(result, status);
    stopLoadError("There was an error updating the sort of your dataset");
    return false;
  });
  return false;
};

renderTaxonData = function() {

  /*
   *
   */
  var chartConfig, chartCtx, color, error, genusCountData, genusList, hlTaxonData, hlTaxonLabels, i, len, lineColor, order, tickCallback, yScaleType;
  if ((typeof _asm !== "undefined" && _asm !== null ? _asm.chart : void 0) != null) {
    _asm.chart.destroy();
  }
  tickCallback = function(value, index, values) {
    if ((modulo(index, 4)) === 0 && toFloat(value.noExponents()) >= 1) {
      return value.noExponents();
    } else {
      return "";
    }
  };
  try {
    if (p$("#log-scale").checked) {
      yScaleType = "logarithmic";
    } else {
      yScaleType = "linear";
      tickCallback = void 0;
    }
  } catch (error) {
    yScaleType = "logarithmic";
  }
  if ($("#high-level-taxon-data").exists()) {
    console.log("Rendering high level taxon data");
    hlTaxonLabels = Object.toArray(window.hlTaxonLabels);
    hlTaxonData = Object.toArray(window.hlTaxonData);
    genusCountData = new Array();
    for (i = 0, len = hlTaxonLabels.length; i < len; i++) {
      order = hlTaxonLabels[i];
      genusList = Object.toArray(window.genusData[order].labels);
      genusCountData.push(genusList.length);
    }
    color = getRandomDataColor();
    lineColor = getRandomDataColor();
    chartConfig = {
      type: "bar",
      data: {
        labels: hlTaxonLabels,
        datasets: [
          {
            label: "Species Count",
            type: "bar",
            data: hlTaxonData,
            borderColor: color.border,
            backgroundColor: color.background,
            borderWidth: 1
          }, {
            label: "Genus Count",
            type: "line",
            data: genusCountData,
            borderColor: lineColor.border,
            backgroundColor: lineColor.background,
            borderWidth: 1
          }
        ]
      },
      options: {
        scales: {
          yAxes: [
            {
              type: yScaleType,
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
    if (tickCallback != null) {
      chartConfig.options.scales.yAxes[0].ticks.callback = tickCallback;
    }
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
                type: yScaleType,
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
                },
                ticks: {
                  fontStyle: "italic"
                }
              }
            ]
          }
        }
      };
      if (tickCallback != null) {
        zoomChartConfig.options.scales.yAxes[0].ticks.callback = tickCallback;
      }
      zoomChartCtx = $("#taxon-zoom-chart");
      if (_asm.zoomChart != null) {
        _asm.zoomChart.destroy();
      }
      _asm.zoomChart = new Chart(zoomChartCtx, zoomChartConfig);
      return false;
    });
  }
  return false;
};

getChartKeys = function() {
  var chartOptions, dropdownVal, error, i, key, len, option, ref, results;
  chartOptions = new Object();
  ref = $(".chart-param");
  results = [];
  for (i = 0, len = ref.length; i < len; i++) {
    option = ref[i];
    key = $(option).attr("data-key");
    try {
      if (p$(option).checked != null) {
        results.push(chartOptions[key] = p$(option).checked);
      } else {
        throw "Not Toggle";
      }
    } catch (error) {
      try {
        dropdownVal = $(p$(option).selectedItem).attr("data-value");
      } catch (undefined) {}
      results.push(chartOptions[key] = dropdownVal != null ? dropdownVal : p$(option).selectedItemLabel.toLowerCase().replace(" ", "-"));
    }
  }
  return results;
};

$(function() {
  renderTaxonData();
  try {
    $("#log-scale").on("iron-change", function() {
      if ((typeof _asm !== "undefined" && _asm !== null ? _asm.chart : void 0) != null) {
        _asm.chart.destroy();
      }
      renderTaxonData.debounce();
      return false;
    });
    $("#default-sort-toggle").on("iron-change", function() {
      if (p$(this).checked) {
        $(".sort-options").attr("disabled", "disabled");
      } else {
        $(".sort-options").removeAttr("disabled");
      }
      renderTaxonData.debounce();
      return false;
    });
  } catch (undefined) {}
  try {
    return delayPolymerBind("paper-dropdown-menu#order-sort", function() {
      return $("paper-dropdown-menu#order-sort paper-listbox").on("iron-select", function() {
        console.debug(getChartKeys());
        return false;
      });
    });
  } catch (undefined) {}
});

//# sourceMappingURL=maps/charts.js.map
