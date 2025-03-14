test_that("is_empty() returns expected results", {
  expect_equal(is_empty(NULL), TRUE)
})

test_that("is_empty() returns expected results for a list", {
  expect_equal(is_empty(list(a = NA, b = NA)), TRUE)
  expect_equal(is_empty(vector("list", 5)), TRUE)
  expect_equal(is_empty(list()), TRUE)
  expect_equal(is_empty(list(a = NA, b = 1)), FALSE)
})

test_that("is_empty() returns expected results for a single element vector", {
  expect_equal(is_empty(NA), TRUE)
  expect_equal(is_empty(NaN), TRUE)
  expect_equal(is_empty(numeric(0)), TRUE)
  expect_equal(is_empty(character(0)), TRUE)
  expect_equal(is_empty(1), FALSE)
  expect_equal(is_empty("x"), FALSE)
})

test_that("is_empty() returns expected results for a multi-element vector", {
  expect_equal(is_empty(c(NA, NA, NA)), TRUE)
  expect_equal(is_empty(c(NaN, NaN, NaN)), TRUE)
  expect_equal(is_empty(c("", "", "")), TRUE)
  expect_equal(is_empty(c(NA, NA, 1)), FALSE)
  expect_equal(is_empty(c(NaN, "x", NaN)), FALSE)
  expect_equal(is_empty(c("", "x", NaN)), FALSE)
})

test_that("is_empty() returns expected results for a date", {
  expect_equal(is_empty(as.Date(NA)), TRUE)
  expect_equal(is_empty(as.Date(NA, NA, NA)), TRUE)
  expect_equal(
    is_empty(as.Date(c("2019-02-28", "2019-03-31"), format = "%Y-%m-%d")),
    FALSE
  )
  expect_equal(
    is_empty(as.Date(c("2019-02-28", NA), format = "%Y-%m-%d")),
    FALSE
  )
})
