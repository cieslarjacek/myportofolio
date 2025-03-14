// Toggle reset button for world trends map country selection.
// TODO: ADD TO "renderEvents" IF POSSIBLE.
Shiny.addCustomMessageHandler('toggleWorldMapResetBtn', function (message) {
  // Find the button with matching "id".
  let resetBtn = document.getElementById('world_trends-map_reset_btn')

  if (!resetBtn) return
  if (message) {
    resetBtn.classList.remove('disabled')
  } else {
    resetBtn.classList.add('disabled')
  }
})

// Toggle export button for world trends chart data.
Shiny.addCustomMessageHandler('toggleTrendChartExportBtn', function (message) {
  // Find the button with matching "id".
  let exportBtn = document.getElementById('world_trends-chart_export')

  if (!exportBtn) return
  if (message) {
    exportBtn.classList.remove('disabled')
  } else {
    exportBtn.classList.add('disabled')
  }
})

// Export world trends chart data as PNG, CSV or JSON.
Shiny.addCustomMessageHandler('exportTrendChartData', function (message) {
  var data = message.data
  var format = message.format
  var filename = message.filename

  if (format == 'png') {
    // Find the plot with matching "id".
    let target_plot = document.getElementById(data)

    if (target_plot) {
      Plotly.downloadImage(target_plot, {
        format: format,
        filename: filename,
        height: 800,
        width: 1200,
        scale: 2
      })
    }
  } else {
    // Put the data in the blob with the proper specification.
    var targetEcoding = 'utf-8'
    let mime, blob

    if (format == 'csv') {
      mime = `text/csv;charset=${targetEcoding};`
      blob = new Blob([data], { type: mime })
    } else {
      mime = `application/json;charset=${targetEcoding};`
      blob = new Blob([JSON.stringify(data, null, 2)], { type: mime })
    }

    // Create link to the data then click it and delete it.
    let filenameExtd = filename + '.' + format
    let tempLink = document.createElement('a')

    tempLink.href = URL.createObjectURL(blob)
    tempLink.download = filenameExtd
    document.body.appendChild(tempLink)
    tempLink.click()
    tempLink.remove()
    URL.revokeObjectURL(tempLink.href)
  }
})

// List of JavaScript events for "onRender()" function attached to UI elements.
window.renderEvents = {
  worldTrendsMap: function (el, x) {
    // 1. Disable "resetBtn" at the beginning.
    document
      .getElementById('world_trends-map_reset_btn')
      .classList.add('disabled')

    // 2. Recolor map selection.
    // Find the map with matching "id".
    let elemId = el.getAttribute('id')
    let target_map = window.HTMLWidgets.find('#'.concat(elemId)).getMap()

    Shiny.addCustomMessageHandler('recolorLayer', function (message) {
      for (let indx in message) {
        let click_id = message[indx][0]
        let target_color = message[indx][1]

        // Find the layer with matching "layerId".
        target_map.eachLayer(function (layer) {
          // Polygon layers created by "addPolygons" have "options.layerId".
          if (layer.options.layerId == click_id) {
            // Send not-base color back.
            let current_color = layer.options.fillColor
            if (current_color.startsWith('#')) {
              Shiny.setInputValue('color_return', current_color, {
                priority: 'event'
              })
            }

            // Set new "fillColor" for selected polygon.
            layer.setStyle({ fillColor: target_color })
          }
        })
      }
    })
  },
  worldTrendsChart: function (el, plotlyObject) {
    // 1. Enable "export_btn" at the beginning.
    document
      .getElementById('world_trends-chart_export')
      .classList.remove('disabled')

    // 2. Remove data trace (series) from the plot.
    // Find the chart with matching "id".
    let elemId = el.getAttribute('id')

    Shiny.addCustomMessageHandler('removeTraces', function (message) {
      let traceName = message

      // Find the trace with matching "name".
      plotlyObject.data.forEach(function (trace, traceIndex) {
        if (trace.name == traceName) {
          // Remove the trace by "traceIndex".
          Plotly.deleteTraces(elemId, traceIndex)
        }
      })
    })
  },
  worldTrendsTable: function (el, x) {
    var formatNumbers = function () {
      // Skip the first column.
      $(el)
        .find('td:not(:first-child)')
        .each(function () {
          // Remove any initial spaces.
          var rawValue = parseFloat($(this).text().replace(/\s/g, ''))

          if (!isNaN(rawValue)) {
            // Round only if necessary.
            var roundedValue = Math.round(rawValue * 100) / 100
            // Add space as thousands separator.
            var numberParts = roundedValue.toString().split('.')
            numberParts[0] = numberParts[0].replace(
              /\B(?=(\d{3})+(?!\d))/g,
              ' '
            )
            // Send updated number back to the table.
            $(this).text(numberParts.join('.'))
          }
        })
    }

    // Run once immediately (for initial draw).
    formatNumbers()
    // Run on every redraw (paging, sorting, filtering).
    $(el).on('draw.dt', function () {
      formatNumbers()
    })
  }
}
