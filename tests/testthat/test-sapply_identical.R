test_that("sapply_identical() finds identical objects as expected", {
  test_list <- list("abcd", c(5, 6, 7), data.frame(a = c(1, 2, 3, 4)))

  expect_equal(sapply_identical(test_list, "abcd"), c(TRUE, FALSE, FALSE))
  expect_equal(sapply_identical(test_list, c(5, 6, 7)), c(FALSE, TRUE, FALSE))
  expect_equal(
    sapply_identical(test_list, data.frame(a = c(1, 2, 3, 4))),
    c(FALSE, FALSE, TRUE)
  )
})

test_that("sapply_identical() returns empty list for empty list", {
  expect_equal(sapply_identical(list(), "abcd"), list())
})

test_that("sapply_identical() throws argument type error - 'target_list'", {
  error_msg <- "Assertion on 'target_list' failed"

  expect_error(sapply_identical(NULL, 1), error_msg)
  expect_error(sapply_identical("abcd", 1), error_msg)
  expect_error(sapply_identical(list(1, 1), 1), error_msg)
})
