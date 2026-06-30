test_that("decadeTableUI() creates expected HTML", {
  expect_snapshot(decadeTableUI("x"))
})

test_that("decadeTableServer() rejects a non-reactiveVal 'render_flag'", {
  expect_error(
    decadeTableServer("test",
      render_flag = TRUE,
      aggregation_input = make_test_aggregation_input()
    ),
    "Assertion on 'render_flag' failed"
  )
})

test_that("decadeTableServer() rejects 'aggregation_input' with wrong length", {
  expect_error(
    decadeTableServer("test",
      render_flag = shiny::reactiveVal(TRUE),
      aggregation_input = list(
        shiny::reactiveVal(NULL), shiny::reactiveVal(NULL)
      )
    ),
    "Assertion on 'aggregation_input' failed:"
  )
})

test_that(
  "decadeTableServer() rejects non-reactiveVal elements in 'aggregation_input'",
  {
    expect_error(
      decadeTableServer("test",
        render_flag = shiny::reactiveVal(TRUE),
        aggregation_input = list(
          shiny::reactiveVal(NULL), "not_reactive", shiny::reactiveVal(NULL)
        )
      ),
      "Assertion on 'X[[i]]' failed",
      fixed = TRUE
    )
  }
)

test_that("'table_description' renders when 'render_flag' is TRUE", {
  shiny::testServer(
    decadeTableServer,
    args = list(
      render_flag = shiny::reactiveVal(TRUE),
      aggregation_input = make_test_aggregation_input("mean")
    ),
    {
      expect_false(is_empty(output$table_description))
    }
  )
})

test_that("'table_description' is suppressed when 'render_flag' is FALSE", {
  shiny::testServer(
    decadeTableServer,
    args = list(
      render_flag = shiny::reactiveVal(FALSE),
      aggregation_input = make_test_aggregation_input()
    ),
    {
      expect_error(output$table_description)
    }
  )
})

test_that("'table_conten't returns NULL when 'column_name' is NULL", {
  pipeline_called <- FALSE
  local_mocked_bindings(
    set_decade_aggregator = function(...) {
      pipeline_called <<- TRUE
      "should_not_run"
    },
    build_decade_table = function(...) {
      pipeline_called <<- TRUE
      "should_not_run"
    }
  )

  agg_input <- make_test_aggregation_input("mean", column_name = NULL)

  shiny::testServer(
    decadeTableServer,
    args = list(
      render_flag = shiny::reactiveVal(TRUE),
      aggregation_input = agg_input
    ),
    {
      expect_no_error(output$table_content)
      expect_false(pipeline_called)
    }
  )
})

test_that("'table_content' skips 'source_weight' when weight data is empty", {
  source_weight_called <- FALSE
  captured_run <- NULL

  local_mocked_bindings(
    source_weight = function(...) {
      source_weight_called <<- TRUE
      NULL
    },
    set_decade_aggregator = function(params) "aggregator_stub",
    run_decade_aggregator = function(aggregator, data) {
      captured_run <<- list(aggregator = aggregator, data = data)
      "decade_dt_stub"
    },
    build_decade_table = function(decade_dt) "table_stub",
    add_js_code = function(table, name) {
      structure(
        list(
          x = list(table = table, name = name)
        ),
        class = c("datatables", "htmlwidget")
      )
    }
  )

  agg_input <- make_test_aggregation_input("mean", column_name = "value")

  shiny::testServer(
    decadeTableServer,
    args = list(
      render_flag       = shiny::reactiveVal(TRUE),
      aggregation_input = agg_input
    ),
    {
      expect_false(is.null(output$table_content))
      expect_false(source_weight_called)
      expect_equal(captured_run$aggregator, "aggregator_stub")
      expect_s3_class(captured_run$data, "data.table")
    }
  )
})

test_that("'table_content' calls 'source_weight' when weight data is present", {
  captured_source_weight <- NULL
  captured_run <- NULL
  weight_dt <- data.table::data.table(country_id = 1, weight = 0.5)
  weighted_stub <- data.table::data.table(country_id = 1, value = 99)

  local_mocked_bindings(
    source_weight = function(args_list) {
      captured_source_weight <<- args_list
      weighted_stub
    },
    set_decade_aggregator = function(params) "aggregator_stub",
    run_decade_aggregator = function(aggregator, data) {
      captured_run <<- list(aggregator = aggregator, data = data)
      "decade_dt_stub"
    },
    build_decade_table = function(decade_dt) "table_stub",
    add_js_code = function(table, name) {
      structure(list(x = list(table = table, name = name)), class = c("datatables", "htmlwidget"))
    }
  )

  agg_input <- list(
    shiny::reactiveVal(list(function_name = "weighted.mean", column_name = "value")),
    shiny::reactiveVal(data.table::data.table(country_id = 1L, value = 10)),
    shiny::reactiveVal(weight_dt)
  )

  shiny::testServer(
    decadeTableServer,
    args = list(
      render_flag = shiny::reactiveVal(TRUE),
      aggregation_input = agg_input
    ),
    {
      invisible(output$table_content)
      expect_length(captured_source_weight, 2)
      expect_equal(captured_source_weight[[2]], weight_dt)
      expect_equal(captured_run$data, weighted_stub)
    }
  )
})

test_that(
  "get_table_description() returns a character vector for every function name",
  {
    for (func_name in c("max", "mean", "geometric.mean", "weighted.mean", "none")) {
      expect_type(get_table_description(func_name), "character")
    }
  }
)

test_that(
  "get_table_description() returns content matching the aggregation function",
  {
    expect_true(
      any(grepl("final year", get_table_description("max")))
    )
    expect_true(
      any(grepl("arithmetic mean", get_table_description("mean")))
    )
    expect_true(
      any(grepl("geometric mean", get_table_description("geometric.mean")))
    )
    expect_true(
      any(grepl("weighted mean", get_table_description("weighted.mean")))
    )
    expect_true(
      any(grepl("not available", get_table_description("none")))
    )
  }
)
