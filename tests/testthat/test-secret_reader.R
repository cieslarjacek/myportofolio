test_that("initialize() stores 'current_env' from argument", {
  withr::local_envvar(
    VAULT_ADDRESS = "https://vault.test",
    VAULT_TOKEN = "test_token"
  )
  test_reader <- SecretReader$new("staging")

  expect_equal(test_reader$current_env, "staging")
})

test_that("initialize() reverts to 'DEPLOYMENT_ENV' when called by default", {
  withr::local_envvar(
    DEPLOYMENT_ENV = "production",
    VAULT_ADDRESS = "https://vault.test",
    VAULT_TOKEN = "test_token"
  )
  test_reader <- SecretReader$new()

  expect_equal(test_reader$current_env, "production")
})

test_that("get_all_secrets() returns data$data on a 200 response", {
  withr::local_envvar(
    VAULT_ADDRESS = "https://vault.test",
    VAULT_TOKEN = "test_token"
  )
  test_secrets <- list(DB_NAME = "mydb", DB_PW = "s3cr3t")
  local_mocked_bindings(
    req_perform = function(...) structure(list(), class = "httr2_response"),
    resp_status = function(...) 200,
    resp_body_json = function(...) list(data = list(data = test_secrets)),
    .package = "httr2"
  )
  test_result <- SecretReader$new("staging")$get_all_secrets()

  expect_equal(test_result, test_secrets)
})

test_that("get_all_secrets() stops with status code on non-200 response", {
  withr::local_envvar(
    VAULT_ADDRESS = "https://vault.test",
    VAULT_TOKEN = "test_token"
  )
  local_mocked_bindings(
    req_perform = function(...) structure(list(), class = "httr2_response"),
    resp_status = function(...) 403,
    resp_body_string = function(...) "Forbidden",
    .package = "httr2"
  )

  expect_error(
    SecretReader$new("staging")$get_all_secrets(),
    "Vault request failed [403]: Forbidden",
    fixed = TRUE
  )
})

test_that("get_secret() returns the value for a known secret name", {
  withr::local_envvar(
    VAULT_ADDRESS = "https://vault.test",
    VAULT_TOKEN = "test_token"
  )
  test_secrets <- list(DB_NAME = "mydb", DB_PW = "s3cr3t")
  local_mocked_bindings(
    req_perform = function(...) structure(list(), class = "httr2_response"),
    resp_status = function(...) 200,
    resp_body_json = function(...) list(data = list(data = test_secrets)),
    .package = "httr2"
  )
  test_result <- SecretReader$new("staging")$get_secret("DB_NAME")

  expect_equal(test_result, "mydb")
})

test_that("get_secret() stops with secret name in error for unknown key", {
  withr::local_envvar(
    VAULT_ADDRESS = "https://vault.test",
    VAULT_TOKEN = "test_token"
  )
  test_secrets <- list(DB_NAME = "mydb", DB_PW = "s3cr3t")
  local_mocked_bindings(
    req_perform = function(...) structure(list(), class = "httr2_response"),
    resp_status = function(...) 200,
    resp_body_json = function(...) list(data = list(data = test_secrets)),
    .package = "httr2"
  )

  expect_error(
    SecretReader$new("staging")$get_secret("MISSING_KEY"),
    "Secret with name 'MISSING_KEY' not found at the vault path"
  )
})
