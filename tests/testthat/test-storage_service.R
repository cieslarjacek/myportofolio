test_that("get_data() returns the object fetched from storage", {
  local_mocked_bindings(
    s3readRDS = function(...) mock_storage_data,
    .package  = "aws.s3"
  )
  test_result <- StorageService$new(
    mock_storage_connection
  )$get_data("geometry_all")

  expect_equal(test_result, mock_storage_data)
})

test_that("get_data() returns message and NULL on error", {
  local_mocked_bindings(
    s3readRDS = function(...) stop("connection refused"),
    .package  = "aws.s3"
  )

  expect_message(
    test_result <- StorageService$new(
      mock_storage_connection
    )$get_data("geometry_all"),
    "'get_data' failed with the error message"
  )
  expect_null(test_result)
})

test_that("get_data returns messages and NULL on warning", {
  local_mocked_bindings(
    s3readRDS = function(...) warning("checksum mismatch"),
    .package  = "aws.s3"
  )

  expect_message(
    test_result <- StorageService$new(
      mock_storage_connection
    )$get_data("geometry_all"),
    "'get_data' generated warning"
  )
  expect_null(test_result)
})

test_that("get_geometry_all() delegates to get_data('geometry_all')", {
  local_mocked_bindings(
    s3readRDS = function(...) mock_storage_data,
    .package  = "aws.s3"
  )

  expect_equal(
    StorageService$new(mock_storage_connection)$get_geometry_all(),
    mock_storage_data
  )
})

test_that("put_data() passes 'source_object' to s3saveRDS()", {
  saved <- NULL
  local_mocked_bindings(
    s3saveRDS = function(x, ...) {
      saved <<- x
      invisible(TRUE)
    },
    .package = "aws.s3"
  )
  test_service <- StorageService$new(mock_storage_connection)$put_data(
    "geometry_all", mock_storage_data
  )

  expect_equal(saved, mock_storage_data)
})

test_that("put_data() message and NULL on error", {
  local_mocked_bindings(
    s3saveRDS = function(...) stop("write failed"),
    .package  = "aws.s3"
  )

  expect_message(
    test_result <- StorageService$new(mock_storage_connection)$put_data(
      "geometry_all", mock_storage_data
    ),
    "'put_data' failed with the error message"
  )
  expect_null(test_result)
})

test_that("put_data returns message and NULL on warning", {
  local_mocked_bindings(
    s3saveRDS = function(...) warning("slow upload"),
    .package  = "aws.s3"
  )

  expect_message(
    test_result <- StorageService$new(mock_storage_connection)$put_data(
      "geometry_all", mock_storage_data
    ),
    "'put_data' generated warning"
  )
  expect_null(test_result)
})

test_that("put_geometry_all() delegates to put_data('geometry_all')", {
  saved <- NULL
  local_mocked_bindings(
    s3saveRDS = function(x, ...) {
      saved <<- x
      invisible(TRUE)
    },
    .package = "aws.s3"
  )
  test_service <- StorageService$new(mock_storage_connection)$put_geometry_all(
    mock_storage_data
  )

  expect_equal(saved, mock_storage_data)
})

test_that("get_storage_connection() returns correct list from valid secrets", {
  withr::local_envvar(DEPLOYMENT_ENV = "staging")
  withr::local_envvar(APP_NAME = "myapp")
  test_secrets <- c(
    MINIO_ACCESS_KEY = "ak",
    MINIO_SECRET_KEY = "sk",
    MINIO_ENDPOINT   = "https://minio.example.com"
  )
  test_result <- get_storage_connection(test_secrets)

  expect_equal(test_result$bucket, "myapp-staging")
  expect_equal(test_result$key, "ak")
  expect_equal(test_result$secret, "sk")
  expect_equal(test_result$region, "")
  expect_equal(test_result$base_url, "minio.example.com")
  expect_false(test_result$use_https)
})

test_that("get_storage_connection() rejects an unnamed secrets vector", {
  expect_error(
    get_storage_connection(c("ak", "sk", "https://minio.example.com")),
    "Assertion on 'secrets' failed"
  )
})

test_that("get_storage_connection rejects an unnamed secrets argument", {
  expect_error(
    get_storage_connection(list("ak", "zc")), "Assertion on 'secrets' failed"
  )
  expect_error(
    get_storage_connection(c("ak", "zc")), "Assertion on 'secrets' failed"
  )
})
