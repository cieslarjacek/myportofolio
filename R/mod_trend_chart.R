#' Trends chart Shiny module
#'
#' Provides UI and server logic for the `plotly` class trends chart.
#' .
#' @details
#' **`new_series`** vector needs to have two elements:
#' * "dt_list" - a single-element, named list that contains a data table with
#' a values to plot. The name of the element is a country label (name).
#' * "color" - a string with a line and marker color for the trend chart
#' series.
#'
#' @param id Module ID. Check [shiny::NS()] for more details.
#' @param render_flag A `reactiveVal` object containing Boolean value.
#' @param base_chart An HTML Widget object containing `plotly` chart.
#' @param new_yrange A pair of integers - current real (no extra padding)
#'   minimum and maximum values of y-axis.
#' @param new_series A two element vector containing new series data and color
#'   (see Details).
#' @param series_label A string containing the name of one of the data series
#'   already present on the trend chart.
#' @export
trendChartUI <- function(id) {
  plotly::plotlyOutput(shiny::NS(id, "chart"))
}

#' @rdname trendChartUI
#' @export
trendChartServer <- function(id, render_flag, base_chart) {
  assert_reactiveval(render_flag)
  assert_reactiveval(base_chart)

  shiny::moduleServer(id, function(input, output, session) {
    output$chart <- plotly::renderPlotly({
      run_validate_need(render_flag())
      shiny::req(base_chart())

      base_chart() %>%
        add_js_code(shiny::getCurrentOutputInfo()$name)
    })
  })
}

#' @rdname trendChartUI
#' @export
updtTrendChartYaxisServer <- function(id, new_yrange) {
  shiny::moduleServer(id, function(input, output, session) {
    plotly::plotlyProxy("chart", session) %>%
      plotly::plotlyProxyInvoke("relayout", list(
        yaxis = list(range = make_yrange(new_yrange))
      ))
  })
}

#' @rdname trendChartUI
#' @export
addTrendChartSeriesServer <- function(id, new_series, new_yrange) {
  assert_with(
    checkmate::assert_vector, new_series, assert_len2_args()
  )

  shiny::moduleServer(id, function(input, output, session) {
    updtTrendChartYaxisServer(NULL, new_yrange) %>%
      plotly::plotlyProxyInvoke(
        ., "addTraces", get_series_args(new_series$dt_list, new_series$color)
      )
  })
}

#' @rdname trendChartUI
#' @export
removeTrendChartSeriesServer <- function(id, series_label, new_yrange) {
  checkmate::assert_string(series_label)

  shiny::moduleServer(id, function(input, output, session) {
    session$sendCustomMessage("removeTraces", series_label)

    updtTrendChartYaxisServer(NULL, new_yrange)
  })
}

#' Trends chart export button Shiny module
#'
#' Provides UI and server logic for the data export button for the trends chart.
#'
#' @param id Module ID. Check [shiny::NS()] for more details.
#' @param export_types A named character vector where the element names are
#'   data export format types (e.g. png, csv, json) and the elements are
#'   the button/link labels (e.g. "CSV data"),
#' @export
trendChartExportBtnUI <- function(id) {
  shiny::uiOutput(shiny::NS(id, "chart_export"), class = "disabled")
}

#' @rdname trendChartExportBtnUI
#' @export
trendChartExportBtnServer <- function(id, export_types = set_export_types()) {
  shiny::moduleServer(id, function(input, output, session) {
    output$chart_export <- shiny::renderUI({
      shinyWidgets::dropdownButton(
        inputId = shiny::NS(id, "chart_export_btn"),
        label = "Export",
        icon = shiny::icon("download"),
        circle = FALSE,
        status = "primary",
        shiny::div(
          class = shiny::NS(id, "chart_export_list"),
          mapply(function(elem_value, elem_name) {
            shiny::actionLink(
              shiny::NS(id, paste0("chart_download_", elem_name)), elem_value
            )
          }, export_types, names(export_types), SIMPLIFY = FALSE)
        )
      )
    })
  })
}
