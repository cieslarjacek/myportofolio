# TODO: Add "expect_error" tests.
test_that("extract_dt_list_range() returns correct range without filtering", {
  test_data_list <- list(
    name1 = data.frame(col1 = c(1:5)), name2 = data.frame(col1 = c(4:10))
  )
  test_config <- list("col1")

  expect_equal(extract_dt_list_range(test_data_list, test_config), c(1, 10))
})

test_that("extract_dt_list_range() returns correct range with filtering", {
  test_data_list <- list(
    name1 = data.frame(col1 = c(1:5), time = c(1:5)),
    name2 = data.frame(col1 = c(4:10), time = c(2:8))
  )
  test_config <- list("col1", list("time", c(2:4)))

  expect_equal(extract_dt_list_range(test_data_list, test_config), c(2, 6))
})

test_that("get_dt_range() returns correct range", {
  expect_equal(get_dt_range(data.frame(col1 = c(3:17)), "col1"), c(3, 17))
})

test_that("select_in_dt() returns correct filtered data", {
  test_df <- data.frame(col1 = letters[1:8], col2 = c(1:8))

  expect_equal(
    select_in_dt(test_df, "col2", c(3:7)),
    data.table::data.table(col1 = c("c", "d", "e", "f", "g"), col2 = c(3:7))
  )
})
