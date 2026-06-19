test_that("make_sql_qualified_columns() returns an 'R6' 'ReactiveValuesManager' object", {
  test_db_schema <- list(
    table_name1 = c("col1", "col2", "col3"),
    table_name2 = c("col1", "col4")
  )
  updt_db_schema <- list(
    table_name1 = c("table_name1.col1", "table_name1.col2", "table_name1.col3"),
    table_name2 = c("table_name2.col1", "table_name2.col4")
  )

  expect_equal(make_sql_qualified_columns(test_db_schema), updt_db_schema)
})

test_that(
  "make_sql_qualified_columns() throws argument type error - 'db_schema'", {
  error_msg <- "Assertion on 'db_schema' failed"

  expect_error(make_sql_qualified_columns(NULL), error_msg)
  expect_error(make_sql_qualified_columns(list()), error_msg)
  expect_error(make_sql_qualified_columns(list("a", "b")), error_msg)
  expect_error(make_sql_qualified_columns(list(n1 = "a", "b")), error_msg)
  expect_error(make_sql_qualified_columns(list(n1 = "a", n2 = NULL)), error_msg)
})

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

test_that("init_objects contains the expected reactive keys", {
  test_manager <- shiny::isolate(ReactiveValuesManager$new())
  test_init_objects <- shiny::isolate(test_manager$init_objects)

  expect_named(test_init_objects, names(get_reactive_values_init()))
})

test_that("get_init() returns correct initial object structure", {
  test_manager <- shiny::isolate(ReactiveValuesManager$new())
  test_result <- test_manager$get_init("chart_active_data_range")

  expect_s3_class(test_result, "reactivevalues")
  test_content <- shiny::isolate(shiny::reactiveValuesToList(test_result))

  expect_mapequal(test_content, list(
    absolute = list(x = NULL, y = NULL),
    current  = list(x = NULL, y = NULL)
  ))
})

test_that("update() modifies object in a correct way", {
  test_manager <- shiny::isolate(ReactiveValuesManager$new())
  test_result <- test_manager$get_init("table_aggregation_params")
  test_result


  test_result(
    test_manager$update("table_aggregation_params")(indicator_id())
  )




  expect_s3_class(test_result, "reactiveVal")
  test_content <- shiny::isolate(shiny::reactiveValuesToList(test_result))

  expect_mapequal(test_content, list(
    absolute = list(x = NULL, y = NULL),
    current  = list(x = NULL, y = NULL)
  ))
})


shiny::reactiveValues(
  absolute = list(x = NULL, y = NULL),
  current = list(x = NULL, y = NULL)
)




