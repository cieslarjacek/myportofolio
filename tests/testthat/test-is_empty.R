test_that("is_empty() returns expected results", {
  expect_true(is_empty(NULL))
  expect_false(is_empty(function() NULL))
})

test_that("is_empty() returns expected results for a list", {
  expect_true(is_empty(list(a = NA, b = NA)))
  expect_true(is_empty(vector("list", 5)))
  expect_true(is_empty(list()))
  expect_false(is_empty(list(a = NA, b = 1)))
})

test_that("is_empty() returns expected results for a single element vector", {
  expect_true(is_empty(NA))
  expect_true(is_empty(NaN))
  expect_true(is_empty(numeric(0)))
  expect_true(is_empty(character(0)))
  expect_false(is_empty(1))
  expect_false(is_empty("x"))
})

test_that("is_empty() returns expected results for a multi-element vector", {
  expect_true(is_empty(c(NA, NA, NA)))
  expect_true(is_empty(c(NaN, NaN, NaN)))
  expect_true(is_empty(c("", "", "")))
  expect_false(is_empty(c(NA, NA, 1)))
  expect_false(is_empty(c(NaN, "x", NaN)))
  expect_false(is_empty(c("", "x", NaN)))
})

test_that("is_empty() returns expected results for a date", {
  expect_true(is_empty(as.Date(NA)))
  expect_true(is_empty(as.Date(NA, NA, NA)))
  expect_false(
    is_empty(as.Date(c("2019-02-28", "2019-03-31"), format = "%Y-%m-%d"))
  )
  expect_false(is_empty(as.Date(c("2019-02-28", NA), format = "%Y-%m-%d")))
})
