test_that("set_base_options() returns correct settings", {
  expected <- list(
    searching = FALSE,
    lengthChange = FALSE,
    info = FALSE,
    paging = FALSE,
    columnDefs = list(
      list(className = "dt-tcontent-center", targets = "_all")
    )
  )

  expect_equal(set_base_options(), expected)
})

test_that("create_base_table() returns right table", {
  test_data <- data.frame(col1 = c(1, 2, 3), col2 = c("a", "b", "c"))

  expected <- DT::datatable(
    test_data,
    rownames = FALSE,
    escape = FALSE,
    options = set_base_options()
  )

  expect_equal(create_base_table(test_data), expected)
})

test_that("add_format_style() applies right style", {
  test_data <- data.frame(Decade = c(1, 2, 3), col2 = c("a", "b", "c"))
  test_table <- create_base_table(test_data)

  expect_equal(
    add_format_style(test_table),
    DT::formatStyle(test_table, "Decade", fontWeight = "bold")
  )
})

test_that("build_decade_table() creates right table", {
  test_data <- data.frame(Decade = c(1, 2, 3), col2 = c("a", "b", "c"))
  test_table <- create_base_table(test_data)

  expected <- DT::datatable(
    test_data,
    rownames = FALSE,
    escape = FALSE,
    options = set_base_options()
  ) %>%
    DT::formatStyle("Decade", fontWeight = "bold")

  expect_equal(build_decade_table(test_data), expected)
})
