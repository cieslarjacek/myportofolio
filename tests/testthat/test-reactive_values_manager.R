# TODO: ADD MORE TESTS TO INCREASE COVERAGE.
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
