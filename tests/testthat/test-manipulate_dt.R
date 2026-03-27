# TODO: Add "expect_error" to test assertions.
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

test_that("select_in_dt() returns correct filtered data table", {
  test_df <- data.frame(col1 = letters[1:8], col2 = c(1:8))

  expect_equal(
    select_in_dt(test_df, "col2", c(3:7)),
    data.table::data.table(col1 = c("c", "d", "e", "f", "g"), col2 = c(3:7))
  )
})

test_that("extract_trends_chart_dt() returns correct data table", {
  test_data_list <- list(
    name1 = data.frame(col1 = c(1:5), time = c(1:5)),
    name2 = data.frame(col1 = c(4:10), time = c(2:8))
  )
  test_config <- list("name_col", list("time", c(2:4)))

  expected <- data.table::data.table(
    name_col = c(rep("name1", 3), rep("name2", 3)),
    col1 = c(2, 3, 4, 4, 5, 6),
    time = rep(c(2, 3, 4), 2)
  )

  expect_equal(extract_trends_chart_dt(test_data_list, test_config), expected)
})

test_that("convert_dt_to_string() returns correct string", {
  test_df <- data.frame(
    name_col = c(rep("name1", 3), rep("name2", 3)),
    col1 = c(2, 3, 4, 4, 5, 6),
    time = rep(c(2, 3, 4), 2)
  )
  expected <- capture.output(
    write.csv(test_df, row.names = FALSE, na = "", quote = TRUE)
  ) %>% paste(collapse = "\n")

  expect_equal(convert_dt_to_string(test_df), expected)
})

test_that("convert_dt_to_json() returns correct JSON object", {
  test_df <- data.frame(
    name_col = c(rep("name1", 3), rep("name2", 3)),
    col1 = c(2, 3, 4, 4, 5, 6),
    time = rep(c(2, 3, 4), 2)
  )
  expected <- jsonlite::toJSON(
    test_df, dataframe = "rows", pretty = FALSE, auto_unbox = TRUE, na = "null"
  )

  expect_equal(convert_dt_to_json(test_df), expected)
})

test_that("source_weight() returns correct weighted data table", {
  test_indicator_df1 <- data.table::data.table(
    country_id = 1,
    time_period = c(1:7),
    value = c(1:7) * 100
  )
  test_weight_df1 <- data.table::data.table(
    country_id = 1,
    time_period = c(2:10),
    value = c(2:10) * 10
  )

  test_indicator_df2 <- data.table::data.table(
    country_id = 63,
    time_period = c(1:10),
    value = c(1:10) * 10
  )
  test_weight_df2 <- data.table::data.table(
    country_id = 63,
    time_period = c(3:8),
    value = c(3:8) * 100
  )

  test_indicator_df_list <- list(
    name1 = test_indicator_df1, name2 = test_indicator_df2
  )
  test_weight_df_list <- list(
    name1 = test_weight_df1, name2 = test_weight_df2
  )

  expected <- list(
    name1 = data.table::setkey(data.table::merge.data.table(
      test_indicator_df1,
      test_weight_df1,
      by = c("country_id", "time_period")
    ), NULL),
    name2 = data.table::setkey(data.table::merge.data.table(
      test_indicator_df2,
      test_weight_df2,
      by = c("country_id", "time_period")
    ), NULL)
  )
  names(expected$name1) <- c("country_id", "time_period", "value", "weight")
  names(expected$name2) <- c("country_id", "time_period", "value", "weight")

  expect_equal(
    source_weight(list(test_indicator_df_list, test_weight_df_list)),
    expected
  )
})


