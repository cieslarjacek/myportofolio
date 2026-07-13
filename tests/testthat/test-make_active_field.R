test_that("make_active_field() returns a function", {
  expect_type(make_active_field("alpha"), "closure")
})

test_that("make_active_field() reads the correct private field", {
  test_obj <- TestR6Class$new()
  expect_equal(test_obj$alpha, "hello")
})

test_that("make_active_field() raises a read-only error on assignment", {
  test_obj <- TestR6Class$new()
  expect_error(test_obj$alpha <- "world", regexp = "'alpha' is read-only")
  expect_error(test_obj$gamma <- FALSE, regexp = "'gamma' is read-only")
})

test_that("make_active_field_wrapper() returns a named list with a functions", {
  test_result <- make_active_field_wrapper(c("gamma", "beta", "alpha"))
  expect_type(test_result, "list")
  expect_named(test_result, c("gamma", "beta", "alpha"))
  expect_type(test_result$alpha, "closure")
  expect_type(test_result$beta, "closure")
})

test_that("make_active_field_wrapper() reads private fields correctly", {
  test_obj <- TestR6Class$new()
  expect_equal(test_obj$beta, 42)
  expect_equal(test_obj$epsilon, "bye")
})

test_that(
  "make_active_field_wrapper() raises a read-only error for each wrapped field",
  {
    test_obj <- TestR6Class$new()
    expect_error(test_obj$beta <- 0, regexp = "'beta' is read-only")
    expect_error(test_obj$epsilon <- "you", regexp = "'epsilon' is read-only")
  }
)
