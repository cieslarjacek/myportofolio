test_that(
  "make_sql_qualified_columns() returns an 'R6' 'ReactiveValuesManager' object",
  {
    test_db_schema <- list(
      table_name1 = c("col1", "col2", "col3"),
      table_name2 = c("col1", "col4")
    )
    updt_db_schema <- list(
      table_name1 = c(
        "table_name1.col1", "table_name1.col2", "table_name1.col3"
      ),
      table_name2 = c("table_name2.col1", "table_name2.col4")
    )

    expect_equal(make_sql_qualified_columns(test_db_schema), updt_db_schema)
  }
)

test_that(
  "make_sql_qualified_columns() throws argument type error - 'db_schema'",
  {
    error_msg <- "Assertion on 'db_schema' failed"

    expect_error(make_sql_qualified_columns(NULL), error_msg)
    expect_error(make_sql_qualified_columns(list()), error_msg)
    expect_error(make_sql_qualified_columns(list("a", "b")), error_msg)
    expect_error(make_sql_qualified_columns(list(n1 = "a", "b")), error_msg)
    expect_error(
      make_sql_qualified_columns(list(n1 = "a", n2 = NULL)), error_msg
    )
  }
)

test_that("new() returns an 'R6' 'ReactiveValuesManager' object", {
  test_manager <- shiny::isolate(ReactiveValuesManager$new())

  expect_true(inherits(test_manager, "ReactiveValuesManager"))
  expect_true(inherits(test_manager, "R6"))
})

test_that("init_objects active binding is populated after initialize()", {
  test_manager <- shiny::isolate(ReactiveValuesManager$new())
  test_init_objects <- shiny::isolate(test_manager$init_objects)

  expect_type(test_init_objects, "list")
  expect_length(test_init_objects, length(get_reactive_values_init()))
})

test_that("init_objects contains the expected keys and elements", {
  test_manager <- shiny::isolate(ReactiveValuesManager$new())
  test_init_objects <- shiny::isolate(test_manager$init_objects)

  expect_named(test_init_objects, names(get_reactive_values_init()))
  expect_equal(
    sapply(test_init_objects, class), sapply(get_reactive_values_init(), class)
  )
})

test_that(
  "get_init() returns correct initial object structure for 'reactiveValues'",
  {
    test_manager <- shiny::isolate(ReactiveValuesManager$new())
    test_result <- test_manager$get_init("chart_active_data_range")
    expect_mapequal(
      shiny::isolate(shiny::reactiveValuesToList(test_result)),
      list(
        absolute = list(x = NULL, y = NULL), current = list(x = NULL, y = NULL)
      )
    )

    test_manager <- shiny::isolate(ReactiveValuesManager$new())
    test_result <- test_manager$get_init("map_click_registry")
    expect_mapequal(
      shiny::isolate(shiny::reactiveValuesToList(test_result)),
      list(active = list(), add = list(), remove = list())
    )
  }
)

test_that(
  "get_init() returns correct initial object structure for 'reactiveVal'",
  {
    expected_init_values <- get_reactive_values_init() %>%
      .[!names(.) %in% c("chart_active_data_range", "map_click_registry")]

    for (test_name in names(expected_init_values)) {
      test_manager <- shiny::isolate(ReactiveValuesManager$new())
      test_result <- test_manager$get_init(test_name)

      expect_s3_class(test_result, "reactiveVal")
      expect_equal(
        shiny::isolate(expected_init_values[[test_name]]()),
        shiny::isolate(test_result())
      )
    }
  }
)

test_that("update() modifies 'table_aggregation_params' in a correct way", {
  test_manager <- shiny::isolate(ReactiveValuesManager$new())
  test_result <- test_manager$get_init("table_aggregation_params")
  test_result(
    test_manager$update("table_aggregation_params")("wb_wdi_ny_gdp_mktp_cd")
  )
  expect_mapequal(
    shiny::isolate(test_result()),
    list(function_name = "mean", column_name = "value")
  )

  test_manager <- shiny::isolate(ReactiveValuesManager$new())
  test_result <- test_manager$get_init("table_aggregation_params")
  test_result(
    test_manager$update("table_aggregation_params")("wb_wdi_sh_med_phys_zs")
  )
  expect_mapequal(
    shiny::isolate(test_result()),
    list(
      function_name = "weighted.mean",
      column_name = "value",
      weight_source = "wb_wdi_sp_pop_totl"
    )
  )
})

test_that("update() modifies 'sql_db_schema' in a correct way", {
  test_manager <- shiny::isolate(ReactiveValuesManager$new())
  test_result <- test_manager$get_init("sql_db_schema")

  test_result(
    test_manager$update("sql_db_schema")("wb_wdi_sp_dyn_le00_in")
  )

  expect_mapequal(
    shiny::isolate(test_result()),
    list(
      country = c(
        "country.id", "country.name", "country.iso_a3", "country.label"
      ),
      world_geo = c("world_geo.country_id", "world_geo.geometry"),
      wb_wdi_sp_dyn_le00_in = c(
        "wb_wdi_sp_dyn_le00_in.country_id",
        "wb_wdi_sp_dyn_le00_in.time_period",
        "wb_wdi_sp_dyn_le00_in.value"
      )
    )
  )
})

test_that(
  "get_init() returns correct initial object structure for 'reactiveValues'",
  {
    test_manager <- shiny::isolate(ReactiveValuesManager$new())
    test_result <- test_manager$get_init("chart_active_data_range")
    shiny::isolate({
      for (name in names(test_result)) {
        test_result[[name]] <- list(x = "test_value", y = "test_value")
      }
    })
    shiny::isolate({
      for (name in names(test_result)) {
        test_result[[name]] <- test_manager$reset("chart_active_data_range")
      }
    })
    expect_mapequal(
      shiny::isolate(shiny::reactiveValuesToList(test_result)),
      list(
        absolute = list(x = NULL, y = NULL), current = list(x = NULL, y = NULL)
      )
    )

    test_manager <- shiny::isolate(ReactiveValuesManager$new())
    test_result <- test_manager$get_init("map_click_registry")
    shiny::isolate({
      for (name in names(test_result)) {
        test_result[[name]] <- "test_value"
      }
    })
    shiny::isolate({
      for (name in names(test_result)) {
        test_result[[name]] <- test_manager$reset("map_click_registry")
      }
    })
    expect_mapequal(
      shiny::isolate(shiny::reactiveValuesToList(test_result)),
      list(active = list(), add = list(), remove = list())
    )
  }
)

test_that(
  "reset() returns correct initial object structure for 'reactiveVal'",
  {
    expected_reset_values <- get_reactive_values_reset() %>%
      .[!names(.) %in% c("chart_active_data_range", "map_click_registry")]

    for (test_name in names(expected_reset_values)) {
      test_manager <- shiny::isolate(ReactiveValuesManager$new())
      test_result <- test_manager$get_init(test_name)
      test_result("test_value")
      test_result(test_manager$reset(test_name))

      expect_s3_class(test_result, "reactiveVal")
      expect_equal(
        shiny::isolate(expected_reset_values[[test_name]]),
        shiny::isolate(test_result())
      )
    }
  }
)

test_that("remove_list_elem() returns correctly modified list", {
  test_list <- list(
    name1 = c("col1", "col2", "col3"),
    name2 = c("col1", "col4"),
    name3 = c(1, 2, 3)
  )

  expect_equal(
    remove_list_elem(test_list, "name2"),
    list(name1 = c("col1", "col2", "col3"), name3 = c(1, 2, 3))
  )
})

test_that("remove_list_elem() throws argument type error - 'list_object'", {
  error_msg <- "Assertion on 'list_object' failed"

  expect_error(remove_list_elem(NULL, "name2"), error_msg)
  expect_error(remove_list_elem(list(), "name2"), error_msg)
  expect_error(remove_list_elem(list("a", "b"), "name2"), error_msg)
  expect_error(
    remove_list_elem(list(name1 = NULL, name2 = 2), "name1"), error_msg
  )
})

test_that("remove_list_elem() throws argument type error - 'elem_name'", {
  error_msg <- "Assertion on 'elem_name' failed"

  expect_error(remove_list_elem(list(name1 = 1), NULL), error_msg)
  expect_error(remove_list_elem(list(name1 = 1), 1), error_msg)
})
