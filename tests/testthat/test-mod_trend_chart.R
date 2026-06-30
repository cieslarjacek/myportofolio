test_that("trendChartUI() creates expected HTML", {
  expect_snapshot(trendChartUI("x"))
})

test_that(
  "trendChartServer() returns validation message when render_flag() is FALSE
  and base_chart() is NULL",
  {
    shiny::testServer(
      trendChartServer,
      args = list(
        id = "world_trends",
        render_flag = shiny::reactiveVal(FALSE),
        base_chart = shiny::reactiveVal()
      ),
      {
        expect_error(
          output$chart,
          "Please click the country on the map to plot relevant indicator data",
          class = "shiny.silent.error"
        )
      }
    )
  }
)

test_that(
  "trendChartServer() is not rendered when render_flag() is TRUE
  and base_chart() is NULL",
  {
    shiny::testServer(
      trendChartServer,
      args = list(
        id = "world_trends",
        render_flag = shiny::reactiveVal(TRUE),
        base_chart = shiny::reactiveVal()
      ),
      {
        expect_error(output$chart, class = "shiny.silent.error")
      }
    )
  }
)

test_that(
  "trendChartServer() renders 'plotly' chart with one series",
  {
    shiny::testServer(
      trendChartServer,
      args = list(
        id = "world_trends",
        render_flag = shiny::reactiveVal(TRUE),
        base_chart = shiny::reactiveVal(build_trend_chart(
          test_chart_dt_list, test_chart_color_theme, test_chart_config
        ))
      ),
      {
        raw_chart <- output$chart
        expect_type(raw_chart, "character")
        expect_true(jsonlite::validate(raw_chart))

        raw_chart_list <- jsonlite::fromJSON(raw_chart)
        expect_length(raw_chart_list$x$data$y, 1)
        expect_equal(
          raw_chart_list$x$data$name, names(test_chart_dt_list)
        )
        expect_equal(
          raw_chart_list$x$data$y[[1]], test_chart_dt_list$countryX$value
        )
        expect_false(is_empty(raw_chart_list$jsHooks$render$code))
        expect_true(any(grepl("plotly", raw_chart_list$deps$name)))
      }
    )
  }
)

test_that(
  "updtTrendChartYaxisServer() sends a single correct 'relayout' proxy command",
  {
    captured_proxy_id <- NULL
    captured_invoke <- NULL

    local_mocked_bindings(
      plotlyProxy = function(outputId, session) {
        captured_proxy_id <<- outputId
        "proxy_stub"
      },
      plotlyProxyInvoke = function(p, method, msg) {
        captured_invoke <<- list(p = p, method = method, msg = msg)
        "invoke_result_stub"
      },
      .package = "plotly"
    )

    shiny::testServer(
      updtTrendChartYaxisServer,
      args = list(id = "test", new_yrange = c(10, 90)),
      {
        expect_equal(captured_proxy_id, "chart")
        expect_equal(captured_invoke$p, "proxy_stub")
        expect_equal(captured_invoke$method, "relayout")
        expect_equal(
          captured_invoke$msg,
          list(yaxis = list(range = make_yrange(c(10, 90))))
        )
      }
    )
  }
)

test_that(
  "addTrendChartSeriesServer() rejects 'new_series' with the wrong length",
  {
    expect_error(
      addTrendChartSeriesServer("test",
        new_series = list(dt_list = list(countryX = data.frame(value = 1))),
        new_yrange = c(0, 100)
      )
    )
  }
)

test_that(
  "addTrendChartSeriesServer() invokes correct 'addTraces' proxy command",
  {
    captured_proxy_id <- NULL
    captured_invokes <- list()
    captured_series_args_input <- NULL

    local_mocked_bindings(
      plotlyProxy = function(outputId, session) {
        captured_proxy_id <<- outputId
        "proxy_stub"
      },
      plotlyProxyInvoke = function(p, method, msg) {
        captured_invokes[[length(captured_invokes) + 1]] <<- list(
          p = p, method = method, msg = msg
        )
        paste0("invoke_result_", method)
      },
      .package = "plotly"
    )
    local_mocked_bindings(
      get_series_args = function(dt_list, color) {
        captured_series_args_input <<- list(dt_list = dt_list, color = color)
        "series_args_stub"
      }
    )

    test_series <- list(
      dt_list = list(countryX = data.frame(value = c(1, 2, 3))),
      color   = "#FF0000"
    )

    shiny::testServer(
      addTrendChartSeriesServer,
      args = list(
        id = "test", new_series = test_series, new_yrange = c(0, 100)
      ),
      {
        expect_equal(captured_proxy_id, "chart")
        expect_length(captured_invokes, 2)

        expect_equal(captured_invokes[[1]]$method, "relayout")
        expect_equal(
          captured_invokes[[1]]$msg,
          list(yaxis = list(range = make_yrange(c(0, 100))))
        )

        expect_equal(captured_invokes[[2]]$method, "addTraces")
        expect_equal(captured_invokes[[2]]$p, "invoke_result_relayout")
        expect_equal(captured_invokes[[2]]$msg, "series_args_stub")

        expect_equal(captured_series_args_input$dt_list, test_series$dt_list)
        expect_equal(captured_series_args_input$color, test_series$color)
      }
    )
  }
)

test_that(
  "removeTrendChartSeriesServer() rejects a non-string 'series_label'",
  {
    expect_error(
      removeTrendChartSeriesServer(
        "test",
        series_label = 123, new_yrange = c(0, 100)
      )
    )
  }
)

test_that(
  "removeTrendChartSeriesServer() sends 'removeTraces' custom message",
  {
    captured_message <- NULL
    mock_session <- shiny::MockShinySession$new()
    mock_session$sendCustomMessage <- function(type, message) {
      captured_message <<- list(type = type, message = message)
    }

    captured_proxy_id <- NULL
    captured_invoke <- NULL
    local_mocked_bindings(
      plotlyProxy = function(outputId, session) {
        captured_proxy_id <<- outputId
        "proxy_stub"
      },
      plotlyProxyInvoke = function(p, method, msg) {
        captured_invoke <<- list(p = p, method = method, msg = msg)
        "invoke_result_stub"
      },
      .package = "plotly"
    )

    shiny::testServer(
      removeTrendChartSeriesServer,
      args = list(
        id = "test", series_label = "countryX", new_yrange = c(0, 100)
      ),
      session = mock_session,
      {
        expect_equal(captured_message$type, "removeTraces")
        expect_equal(captured_message$message, "countryX")

        expect_equal(captured_proxy_id, "chart")
        expect_equal(captured_invoke$method, "relayout")
        expect_equal(
          captured_invoke$msg,
          list(yaxis = list(range = make_yrange(c(0, 100))))
        )
      }
    )
  }
)

test_that("trendChartExportBtnUI() creates expected HTML", {
  expect_snapshot(trendChartExportBtnUI("y"))
})

test_that(
  "trendChartExportBtnServer() renders a download link for each export type",
  {
    test_export_types <- c(png = "PNG image", csv = "CSV data")

    shiny::testServer(
      trendChartExportBtnServer,
      args = list(id = "test", export_types = test_export_types),
      {
        html_str <- as.character(output$chart_export$html)

        expect_true(grepl("chart_download_png", html_str, fixed = TRUE))
        expect_true(grepl("PNG image", html_str, fixed = TRUE))
        expect_true(grepl("chart_download_csv", html_str, fixed = TRUE))
        expect_true(grepl("CSV data", html_str, fixed = TRUE))
      }
    )
  }
)
