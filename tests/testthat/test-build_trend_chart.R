test_that("make_download_file_name() creates correct name", {
  test_root <- "abc_xyz"
  test_date <- "20260323"

  expect_equal(
    make_download_file_name(test_root, test_date),
    paste0(test_date, "_", test_root)
  )
})

test_that("make_download_file_name() throws argument type error - 'name_root'",
  {
    error_msg <- "Assertion on 'name_root' failed"

    expect_error(make_download_file_name(numeric()), error_msg)
    expect_error(make_download_file_name(logical()), error_msg)
    expect_error(make_download_file_name(""), error_msg)
    expect_error(make_download_file_name(NULL), error_msg)
  }
)

test_that("extract_download_btn_click() returns correct button name", {
  new_test_clicks <- setNames(c(3, 2, 4), c("btn1", "btn2", "btn3"))
  old_test_clicks <- setNames(c(3, 2, 3), c("btn1", "btn2", "btn3"))

  expect_equal(
    extract_download_btn_click(list(new_test_clicks, old_test_clicks)),
    "btn3"
  )
})

test_that(
  "extract_download_btn_click() throws argument type error - 'click_set'",
  {
    error_msg <- "Assertion on 'click_set' failed"

    expect_error(extract_download_btn_click(c(1, 2)), error_msg)
    expect_error(extract_download_btn_click(c("bt1", "btn2")), error_msg)
    expect_error(extract_download_btn_click(list()), error_msg)
    expect_error(extract_download_btn_click(list("a", "b", "c")), error_msg)
    expect_error(extract_download_btn_click(list(c("a", "b", "c"))), error_msg)
  }
)

test_that("make_chart_config() returns correct config data", {
  test_id <- "wb_wdi_si_dst_10th_10"
  test_range <- c(1, 10)

  expected <- list(
    title = "Income share held by highest 10%",
    yrange = c(1, 10)
  )

  expect_equal(
    make_chart_config(test_id, test_range), expected
  )
})

test_that("make_chart_color_theme() returns correct color data", {
  test_series_color <- "blue"
  test_legend_color <- "green"

  expected <- list(
    series = test_series_color,
    legend = test_legend_color
  )

  expect_equal(
    make_chart_color_theme(test_series_color, test_legend_color), expected
  )
})

test_that("build_trend_chart() creates right chart", {
  expected <- create_base_chart() %>%
    add_series(test_dt_list, test_chart_color_theme$series) %>%
    add_layout(test_chart_config, test_chart_color_theme$legend) %>%
    add_config() %>%
    add_event_register()

  expect_equal(
    standarize_chart(
      build_trend_chart(
        test_dt_list, test_chart_color_theme, test_chart_config
      )
    ),
    standarize_chart(expected)
  )
})

test_that("build_trend_chart() throws argument type error - 'dt_list'",
  {
    error_msg <- "Assertion on 'dt_list' failed"

    expect_error(
      build_trend_chart(1, test_chart_color_theme, test_chart_config),
      error_msg
    )
    expect_error(
      build_trend_chart(list(), test_chart_color_theme, test_chart_config),
      error_msg
    )
    expect_error(
      build_trend_chart(
        unname(test_dt_list), test_chart_color_theme, test_chart_config
      ),
      error_msg
    )
    expect_error(
      build_trend_chart(
        test_chart_color_theme, test_chart_color_theme, test_chart_config
      ),
      error_msg
    )
  }
)

test_that("build_trend_chart() throws argument type error - 'color_theme'",
  {
    error_msg <- "Assertion on 'color_theme' failed"

    expect_error(
      build_trend_chart(test_dt_list, "a", test_chart_config),
      error_msg
    )
    expect_error(
      build_trend_chart(test_dt_list, list(), test_chart_config),
      error_msg
    )
    expect_error(
      build_trend_chart(
        test_dt_list, unname(test_chart_color_theme), test_chart_config
      ),
      error_msg
    )
    expect_error(
      build_trend_chart(test_dt_list, test_dt_list, test_chart_config),
      error_msg
    )
  }
)

test_that(
  "build_trend_chart() throws argument type error - 'names(color_theme)'",
  {
    names(test_chart_color_theme) <- c("name1", "name2")
    error_msg <- "Assertion on 'names\\(color_theme\\)' failed"
    expect_error(
      build_trend_chart(
        test_dt_list, test_chart_color_theme, test_chart_config
      ),
      error_msg
    )
  }
)

test_that("build_trend_chart() throws argument type error - 'layout_config'",
  {
    error_msg <- "Assertion on 'layout_config' failed"

    expect_error(
      build_trend_chart(test_dt_list, test_chart_color_theme, 1),
      error_msg
    )
    expect_error(
      build_trend_chart(test_dt_list, test_chart_color_theme, list()),
      error_msg
    )
    expect_error(
      build_trend_chart(
        test_dt_list, test_chart_color_theme, unname(test_chart_config)
      ),
      error_msg
    )
    expect_error(
      build_trend_chart(test_dt_list, test_chart_color_theme, test_dt_list),
      error_msg
    )
  }
)

test_that(
  "build_trend_chart() throws argument type error - 'names(layout_config)'",
  {
    error_msg <- "Assertion on 'names\\(layout_config\\)' failed"

    names(test_chart_config) <- c("name1", "name2")
    expect_error(
      build_trend_chart(
        test_dt_list, test_chart_color_theme, test_chart_config
      ),
      error_msg
    )
  }
)
