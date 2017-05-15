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
  var args, error, isDefault, sorts, startTime;
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
    sorts = getChartKeys();
    args.order_sort = sorts.order_sort;
    args.genus_sort = sorts.genus_sort;
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
  var chartOptions, dropdownVal, error, i, key, len, option, ref;
  chartOptions = new Object();
  ref = $(".chart-param");
  for (i = 0, len = ref.length; i < len; i++) {
    option = ref[i];
    key = $(option).attr("data-key");
    try {
      if (p$(option).checked != null) {
        chartOptions[key] = p$(option).checked;
      } else {
        throw "Not Toggle";
      }
    } catch (error) {
      try {
        if (!window.debugDrop) {
          window.debugDrop = new Object();
        }
        console.log("Looking at", option);
        window.debugDrop[key] = option;
      } catch (undefined) {}
      try {
        dropdownVal = $(p$(option).selectedItem).attr("data-value");
      } catch (undefined) {}
      chartOptions[key] = dropdownVal != null ? dropdownVal : p$(option).selectedItemLabel.toLowerCase().replace(" ", "-");
    }
  }
  return chartOptions;
};

$(function() {
  var e, error;
  _asm.hasBoundDropdowns = false;
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
      var dropdown, error, error1, i, j, len, len1, ref, ref1;
      if (p$(this).checked) {
        try {
          ref = $(".sort-options");
          for (i = 0, len = ref.length; i < len; i++) {
            dropdown = ref[i];
            p$(dropdown).disabled = true;
          }
        } catch (error) {
          $(".sort-options").attr("disabled", "disabled");
        }
      } else {
        try {
          ref1 = $(".sort-options");
          for (j = 0, len1 = ref1.length; j < len1; j++) {
            dropdown = ref1[j];
            p$(dropdown).disabled = false;
          }
        } catch (error1) {
          $(".sort-options").removeAttr("disabled");
        }
      }
      renderTaxonData.debounce();
      return false;
    });
  } catch (undefined) {}
  try {
    return delayPolymerBind("paper-dropdown-menu#order-sort", function() {
      var listItemSelectEvent;
      if (!_asm.hasBoundDropdowns) {
        _asm.hasBoundDropdowns = true;
        console.info("Binding events for dropdown");
        listItemSelectEvent = function(element, event) {

          /*
           * For whatever reason, binding the event breaks the default
           * select. So, we want to mimic the native one.
           */
          var config, dropdown, item, ref;
          console.debug(element, event, event.detail.item);
          dropdown = element.tagName.toLowerCase() !== "paper-dropdown-menu" ? $(element).parents("paper-dropdown-menu").get(0) : element;
          item = element.tagName.toLowerCase() !== "paper-item" ? (ref = event.detail.item) != null ? ref : $(element).find("paper-item").get(0) : element;
          console.debug(dropdown, item);
          p$(dropdown)._setSelectedItem(item);
          config = getChartKeys();
          console.debug(config);
          updateTaxonomySort();
          return false;
        };
        $("paper-dropdown-menu.sort-options paper-listbox").on("iron-select", function(e) {
          console.debug("is event for dropdown");
          listItemSelectEvent.debounce(50, null, null, this, e);
          return false;
        });
        $("paper-dropdown-menu.sort-options paper-listbox paper-item").click(function(e) {
          console.debug("Click event for dropdown");
          listItemSelectEvent.debounce(50, null, null, this, e);
          return false;
        });
        console.log("Events bound");
      }
      return false;
    });
  } catch (error) {
    e = error;
    console.warn("Warning: couldn't bind polymer events - " + e.message);
    return console.warn(e.stack);
  }
});

//# sourceMappingURL=maps/charts.js.map
