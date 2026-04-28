# TODO: ADD MORE TESTS TO INCREASE COVERAGE.
# Chart.
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

# Export button.
test_that("trendChartExportBtnUI() creates expected HTML", {
  expect_snapshot(trendChartExportBtnUI("y"))
})
