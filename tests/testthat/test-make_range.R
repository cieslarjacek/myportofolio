test_that("make_xrange() creates correct range pair", {
  expect_equal(make_xrange(c(1, 10)), c(1, 10))
  expect_equal(make_xrange(c(1.1, 10.9)), c(2, 10))
  expect_equal(make_xrange(c(1.9, 10.1)), c(2, 10))
})

test_that("make_xrange() throws argument type error", {
  error_msg <- "Assertion on 'initial_range' failed"

  expect_error(make_xrange(1), error_msg)
  expect_error(make_xrange(NULL), error_msg)
  expect_error(make_xrange(c("1", "2")), error_msg)
  expect_error(make_xrange(list(1, 10)), error_msg)
})

test_that("make_yrange() creates correct range pair", {
  test_range <- c(2.456, 9.763)
  test_padding <- (test_range[2] - test_range[1]) / 16

  expect_equal(
    make_yrange(test_range),
    test_range + c(test_padding * (-1), test_padding)
  )
})

test_that("make_yrange() throws argument type error", {
  error_msg <- "Assertion on 'initial_range' failed"

  expect_error(make_yrange(1), error_msg)
  expect_error(make_yrange(NULL), error_msg)
  expect_error(make_yrange(c("1", "2")), error_msg)
  expect_error(make_yrange(list(1, 10)), error_msg)
})

test_that("select_range() returns expected range pair", {
  expect_equal(select_range(list(c(1.1, 10.9), c(20.9, 30.1))), c(2, 10))
  expect_equal(select_range(list(NULL, c(20.9, 30.1))), c(20.9, 30.1))
  expect_equal(select_range(list(c(1.1, 10.9), NULL)), c(2, 10))
})

test_that("select_range() throws argument type error", {
  error_msg <- "Assertion on 'range_pair' failed"

  expect_error(select_range(1), error_msg)
  expect_error(select_range(NULL), error_msg)
  expect_error(select_range(c("1", "2")), error_msg)
  expect_error(select_range(list(NULL, NULL)), error_msg)
})
