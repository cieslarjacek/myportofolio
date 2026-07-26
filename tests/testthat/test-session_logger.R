test_that("initialize() sets expected values for private fields", {
  test_logger <- SessionLogger$new()
  expect_match(test_logger$time_stamp, "^[0-9]{8}_[0-9]{6}$")
  expect_equal(
    test_logger$log_file_name, paste0(test_logger$time_stamp, ".log")
  )
  expect_equal(
    test_logger$log_file_path, file.path("logs", test_logger$log_file_name)
  )
  expect_null(test_logger$log_file_con)
  expect_equal(test_logger$current_session_token, list())
})

test_that("active binding fields are all read-only", {
  test_logger <- SessionLogger$new()
  for (field in c(
    "time_stamp", "log_file_dir", "log_file_name",
    "log_file_path", "log_file_con", "current_session_token"
  )) {
    expect_error(
      test_logger[[field]] <- "x",
      regexp = sprintf("'%s' is read-only", field)
    )
  }
})

test_that("start() creates the log directory if it doesn't exist", {
  withr::local_tempdir() %>% setwd()
  test_logger <- SessionLogger$new()
  test_logger$start()
  on.exit(test_logger$stop(), add = TRUE)

  expect_true(dir.exists("logs"))
})

test_that("start() opens a writable file connection stored in log_file_con", {
  withr::local_tempdir() %>% setwd()
  test_logger <- SessionLogger$new()
  test_logger$start()
  on.exit(test_logger$stop(), add = TRUE)

  expect_true(inherits(test_logger$log_file_con, "connection"))
  expect_true(isOpen(test_logger$log_file_con, "write"))
})

test_that("start() redirects stdout to the log file", {
  withr::local_tempdir() %>% setwd()
  test_logger <- SessionLogger$new()
  test_logger$start()
  cat("unit_test_stdout_marker\n")
  test_logger$stop()

  test_log_lines <- readLines(test_logger$log_file_path)
  expect_true(
    any(grepl("unit_test_stdout_marker", test_log_lines, fixed = TRUE))
  )
})

test_that("start() redirects messages to the log file", {
  withr::local_tempdir() %>% setwd()
  test_logger <- SessionLogger$new()
  test_logger$start()
  message("unit_test_message_marker")
  test_logger$stop()

  test_log_lines <- readLines(test_logger$log_file_path, warn = FALSE)
  expect_true(
    any(grepl("unit_test_message_marker", test_log_lines, fixed = TRUE))
  )
})

test_that("stop() closes the file connection", {
  withr::local_tempdir() %>% setwd()
  test_logger <- SessionLogger$new()
  test_logger$start()
  test_con <- test_logger$log_file_con
  test_logger$stop()

  expect_error(isOpen(test_con), "invalid connection")
})

test_that("put() calls s3write_using with the correct object path and bucket", {
  withr::local_tempdir() %>% setwd()
  test_logger <- SessionLogger$new()
  test_logger$start()
  test_logger$stop()

  captured <- NULL
  local_mocked_bindings(
    s3write_using = function(x, FUN, object, bucket, opts) {
      captured <<- list(x = x, object = object, bucket = bucket, opts = opts)
    },
    .package = "aws.s3"
  )

  test_storage_con <- list(
    bucket = "test-bucket", key = "ak", secret = "sk",
    region = "", base_url = "minio.test", use_https = FALSE
  )
  test_logger$put(test_storage_con)

  expect_equal(captured$object, test_logger$log_file_path)
  expect_equal(captured$bucket, "test-bucket")
  expect_false("bucket" %in% names(captured$opts))
})

test_that(
  "put() strips ANSI escape sequences from log content before uploading",
  {
    withr::local_tempdir() %>% setwd()
    test_logger <- SessionLogger$new()
    test_logger$start()
    cat("\033G3;green text\033g")
    test_logger$stop()

    captured_x <- NULL
    local_mocked_bindings(
      s3write_using = function(x, FUN, object, bucket, opts) {
        captured_x <<- x
      },
      .package = "aws.s3"
    )
    test_logger$put(list(
      bucket = "b", key = "k", secret = "s",
      region = "", base_url = "m", use_https = FALSE
    ))

    expect_false(any(grepl("\033", captured_x, fixed = TRUE)))
    expect_true(any(grepl("green text", captured_x, fixed = TRUE)))
  }
)

test_that("log_session_event() logs a correct message", {
  test_logger <- SessionLogger$new()
  test_session <- make_test_session()

  test_msgs <- testthat::capture_messages(
    test_logger$log_session_event("START", test_session)
  )

  expect_true(any(grepl("SESSION START", test_msgs, fixed = TRUE)))
  expect_true(any(grepl("path=/some/path", test_msgs, fixed = TRUE)))
  expect_true(any(grepl("visit_id=abc123", test_msgs, fixed = TRUE)))
  expect_true(any(grepl("session_token=tok_xyz", test_msgs, fixed = TRUE)))
})

test_that("log_session_event() falls back to NA for 'visit_id'", {
  test_logger <- SessionLogger$new()
  test_session <- make_test_session(cookie = "other=1")

  test_msgs <- testthat::capture_messages(
    test_logger$log_session_event("START", test_session)
  )

  expect_true(any(grepl("visit_id=NA", test_msgs, fixed = TRUE)))
})

# --- set_session_token() -------------------------------------------------------
# This is where token-registration logic now lives (moved out of
# log_session_start(), which used to set the token as a side effect of
# logging - it no longer does).

test_that("set_session_token() registers the token under the visit_id cookie value", {
  test_logger <- SessionLogger$new()
  test_session <- make_test_session(cookie = "visit_id=visitor42", token = "tok1")

  test_logger$set_session_token(test_session)

  expect_equal(test_logger$current_session_token[["visitor42"]], "tok1")
})

test_that("set_session_token() registers under 'unknown' when the visit_id cookie is absent", {
  test_logger <- SessionLogger$new()
  test_session <- make_test_session(cookie = "other=1", token = "tok2")

  test_logger$set_session_token(test_session)

  expect_equal(test_logger$current_session_token[["unknown"]], "tok2")
})

test_that("set_session_token() overwrites the token for a repeated visit_id", {
  test_logger <- SessionLogger$new()
  first_session <- make_test_session(cookie = "visit_id=visitorA", token = "tok_old")
  second_session <- make_test_session(cookie = "visit_id=visitorA", token = "tok_new")

  test_logger$set_session_token(first_session)
  test_logger$set_session_token(second_session)

  expect_equal(test_logger$current_session_token[["visitorA"]], "tok_new")
})

test_that("set_session_token() tracks separate tokens for separate visit_ids", {
  test_logger <- SessionLogger$new()
  session_a <- make_test_session(cookie = "visit_id=visitorA", token = "tokA")
  session_b <- make_test_session(cookie = "visit_id=visitorB", token = "tokB")

  test_logger$set_session_token(session_a)
  test_logger$set_session_token(session_b)

  expect_equal(test_logger$current_session_token[["visitorA"]], "tokA")
  expect_equal(test_logger$current_session_token[["visitorB"]], "tokB")
})

# --- get_session_token() -------------------------------------------------------

test_that("get_session_token() returns the token previously set for that visit_id", {
  test_logger <- SessionLogger$new()
  test_session <- make_test_session(cookie = "visit_id=visitor42", token = "tok1")

  test_logger$set_session_token(test_session)

  expect_equal(test_logger$get_session_token(test_session), "tok1")
})

test_that("get_session_token() returns NULL when no token was registered for that visit_id", {
  test_logger <- SessionLogger$new()
  test_session <- make_test_session(cookie = "visit_id=never_registered")

  expect_null(test_logger$get_session_token(test_session))
})

test_that("get_session_token() resolves the same 'unknown' key as set_session_token() when the cookie is absent", {
  # both methods pipe get_cookie_value() through check_cookie_value(), so
  # this only holds if that resolution stays consistent between the two -
  # worth pinning down explicitly since they duplicate the same lookup logic.
  test_logger <- SessionLogger$new()
  set_session <- make_test_session(cookie = "other=1", token = "tok3")
  lookup_session <- make_test_session(cookie = "other=2") # different cookie value, still no visit_id

  test_logger$set_session_token(set_session)

  expect_equal(test_logger$get_session_token(lookup_session), "tok3")
})

# --- log_session_start() --------------------------------------------------------
# Now purely a logging call - it no longer touches current_session_token
# (see set_session_token() above for that responsibility).

test_that("log_session_start() logs a START event", {
  test_logger <- SessionLogger$new()
  test_session <- make_test_session()

  test_msgs <- testthat::capture_messages(test_logger$log_session_start(test_session))

  expect_true(any(grepl("SESSION START", test_msgs, fixed = TRUE)))
})

test_that("log_session_start() does not modify current_session_token", {
  test_logger <- SessionLogger$new()
  test_session <- make_test_session(cookie = "visit_id=visitorA", token = "tokA")

  testthat::capture_messages(test_logger$log_session_start(test_session))

  expect_equal(test_logger$current_session_token, list())
})

test_that("log_session_end() logs an END event", {
  test_logger <- SessionLogger$new()
  test_session <- make_test_session()

  test_msgs <- testthat::capture_messages(
    test_logger$log_session_end(test_session)
  )

  expect_true(any(grepl("SESSION END", test_msgs, fixed = TRUE)))
})

test_that("log_session_end() does not modify 'current_session_token'", {
  test_logger <- SessionLogger$new()
  start_session <- make_test_session(
    cookie = "visit_id=visitorA", token = "tokA"
  )
  end_session <- make_test_session(
    cookie = "visit_id=visitorA", token = "tokA"
  )

  test_logger$set_session_token(start_session)
  testthat::capture_messages(test_logger$log_session_end(end_session))

  expect_equal(test_logger$current_session_token[["visitorA"]], "tokA")
  expect_length(test_logger$current_session_token, 1)
})
