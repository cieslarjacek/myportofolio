test_that("get_cookie_value() returns the matching value", {
  test_header <- "a=1;b=2;    c=3; d=4"
  expect_equal(get_cookie_value(test_header, "a"), "1")
  expect_equal(get_cookie_value(test_header, "b"), "2")
  expect_equal(get_cookie_value(test_header, "c"), "3")
  expect_equal(get_cookie_value(test_header, "d"), "4")
})

test_that("get_cookie_value() works with a single cookie in the header", {
  expect_equal(get_cookie_value("session=xyz", "session"), "xyz")
})

test_that("get_cookie_value() returns NA when the cookie name is not present", {
  expect_true(is.na(get_cookie_value("a=1; b=2", "z")))
})

test_that("get_cookie_value() returns NA when 'cookie_header' is empty", {
  expect_true(is.na(get_cookie_value(NULL, "a")))
  expect_true(is.na(get_cookie_value(NA_character_, "a")))
  expect_true(is.na(get_cookie_value("", "a")))
})

test_that("get_cookie_value() returns NA when 'cookie_name' is empty", {
  expect_true(is.na(get_cookie_value("a=1; b=2; c=3", NULL)))
  expect_true(is.na(get_cookie_value("a=1; b=2; c=3", NA_character_)))
  expect_true(is.na(get_cookie_value("a=1; b=2; c=3", "")))
})

test_that("get_cookie_value() throws argument type error - 'cookie_header", {
  error_msg <- "Assertion on 'cookie_header' failed"

  expect_error(get_cookie_value(123, "a"), error_msg)
  expect_error(get_cookie_value(c("a=1", "b=2"), "a"))
})

test_that("get_cookie_value() throws argument type error - 'cookie_name", {
  error_msg <- "Assertion on 'cookie_name' failed"

  expect_error(get_cookie_value("a=1", 123))
})

test_that(
  "get_cookie_value() does not match a cookie name with a leading space",
  {
    expect_true(is.na(get_cookie_value(" a=1; b=2", "a")))
  }
)

test_that("get_cookie_value() truncates a value that itself contains '='", {
  expect_equal(get_cookie_value("auth=abc=def", "auth"), "abc")
})

test_that("get_cookie_value() returns NA for a value-less cookie entry", {
  expect_true(is.na(get_cookie_value("flag_only; b=2", "flag_only")))
})

test_that("check_cookie_value() returns the value unchanged when non-empty", {
  expect_equal(check_cookie_value("abc123"), "abc123")
})

test_that("check_cookie_value() returns 'unknown' for empty value", {
  expect_equal(check_cookie_value(NULL), "unknown")
  expect_equal(check_cookie_value(NA_character_), "unknown")
  expect_equal(check_cookie_value(""), "unknown")
})
