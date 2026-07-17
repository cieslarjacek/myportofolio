test_that("make_ui_pattern() builds expected regex pattern", {
  expect_equal(
    make_ui_pattern(c("/", "/page1", "/test#page", "/page.html")),
    "^(\\/|\\/page1|\\/test#page|\\/page.html)$"
  )
})

test_that("make_ui_pattern() throws argument type error - pattern", {
  expect_error(
    make_ui_pattern(c("/", "/page1", "test#page", "/page.html")),
    "Assertion on 'url_path' failed: Must comply to pattern '^/'.",
    fixed = TRUE
  )
})

test_that("make_ui_pattern() throws argument type error - unique", {
  expect_error(
    make_ui_pattern(c("/", "/page1", "/page1")),
    "Assertion on 'url_path' failed: Contains duplicated values, position 3."
  )
})

test_that("select_page() returns default value", {
  test_default <- "404_default"
  expect_equal(select_page("/x", list(), test_default), test_default)
})

test_that("select_page() returns value from the route schema", {
  test_tags1 <- shiny::tags$p("Test Text")
  test_tags2 <- shiny::tagList(
    shiny::tags$h1("Test Title"),
    shiny::tags$h2("Test Header", style = "color: red;"),
    shiny::tags$p("Test Text")
  )
  test_route_schema <- list("/" = test_tags1, "/x" = test_tags2)

  expect_equal(select_page("/x", test_route_schema, "test_default"), test_tags2)
})

test_that("select_page() throws argument type error - 'url_path'", {
  error_msg <- "Assertion on 'url_path' failed"

  expect_error(select_page("x", list(), "a"), error_msg)
  expect_error(select_page(1, list(), "a"), error_msg)
  expect_error(select_page(TRUE, list(), "a"), error_msg)
  expect_error(select_page(NULL, list(), "a"), error_msg)
  expect_error(select_page(NA, list(), "a"), error_msg)
  expect_error(select_page(character(0), list(), "a"), error_msg)
})

test_that("select_page() throws argument type error - 'route_schema'", {
  error_msg <- "Assertion on 'route_schema' failed"

  expect_error(select_page("/x", c(), "a"), error_msg)
  expect_error(select_page("/x", 1, "a"), error_msg)
  expect_error(select_page("/x", TRUE, "a"), error_msg)
  expect_error(select_page("/x", NULL, "a"), error_msg)
  expect_error(select_page("/x", NA, "a"), error_msg)
  expect_error(select_page("/x", character(0), "a"), error_msg)
})

test_that("select_page() throws argument type error - 'default_ui'", {
  error_msg <- "Assertion on 'default_ui' failed"

  expect_error(select_page("/x", list(), 1), error_msg)
  expect_error(select_page("/x", list(), TRUE), error_msg)
  expect_error(select_page("/x", list(), NULL), error_msg)
  expect_error(select_page("/x", list(), NA), error_msg)
  expect_error(select_page("/x", list(), character(0)), error_msg)
})

test_that("route_page() returns expected page based on the provided path", {
  test_route_schema <- list(
    "/"      = shiny::tags$div("Home"),
    "/about" = shiny::tags$div("About")
  )
  test_handler <- route_page(test_route_schema)

  expect_equal(
    test_handler(list(PATH_INFO = "/about")), shiny::tags$div("About")
  )
  expect_equal(test_handler(list(PATH_INFO = "/")), shiny::tags$div("Home"))
  expect_equal(test_handler(list(PATH_INFO = "/dummy")), "404 Not Found")
})

test_that("route_page() throws argument type error - 'url_path'", {
  test_route_schema <- list(
    "/"      = shiny::tags$div("Home"),
    "/about" = shiny::tags$div("About")
  )
  test_handler <- route_page(test_route_schema)
  error_msg <- "Assertion on 'url_path' failed"

  expect_error(test_handler(list()), error_msg)
})
