test_that(
  "make_query_geometry() builds SELECT query with correct identifiers",
  {
    test_result <- make_query_geometry(test_db_schema)

    expect_true(is.character(test_result))
    expect_match(test_result, "SELECT", fixed = TRUE)
    expect_match(test_result, "country.country_id,", fixed = TRUE)
    expect_match(test_result, "country.label,", fixed = TRUE)
    expect_match(
      test_result, "ST_AsText(world_geo.geometry) AS geometry",
      fixed = TRUE
    )
    expect_match(test_result, "FROM country", fixed = TRUE)
    expect_match(test_result, "INNER JOIN world_geo", fixed = TRUE)
    expect_match(
      test_result, "ON country.country_id = world_geo.country_id",
      fixed = TRUE
    )
  }
)

test_that("make_query_geom_clickable() appends WHERE subquery", {
  test_result <- make_query_geom_clickable(test_db_schema)

  expect_true(is.character(test_result))
  expect_match(test_result, "WHERE world_geo.country_id IN (", fixed = TRUE)
  expect_match(test_result, "SELECT DISTINCT country_id", fixed = TRUE)
  expect_match(test_result, "FROM indicator", fixed = TRUE)
  expect_match(test_result, "WHERE country_id > 0", fixed = TRUE)
  expect_match(test_result, ");", fixed = TRUE)
})

test_that("make_query_geom_clickable() rejects non-list 'db_schema'", {
  error_msg <- "Assertion on 'db_schema' failed"

  expect_error(make_query_geom_clickable(NULL), error_msg)
  expect_error(make_query_geom_clickable("not_a_list"), error_msg)
})

test_that("make_query_geom_notclickable() appends LEFT JOIN subquery", {
  test_result <- make_query_geom_notclickable(test_db_schema)

  expect_true(is.character(test_result))
  expect_match(test_result, "LEFT JOIN indicator", fixed = TRUE)
  expect_match(
    test_result, "ON country.country_id = indicator.country_id",
    fixed = TRUE
  )
  expect_match(
    test_result, "WHERE indicator.country_id IS NULL;",
    fixed = TRUE
  )
})

test_that("make_query_geom_notclickable() rejects non-list 'db_schema'", {
  error_msg <- "Assertion on 'db_schema' failed"

  expect_error(make_query_geom_notclickable(NULL), error_msg)
  expect_error(make_query_geom_notclickable("not_a_list"), error_msg)
})

test_that(
  "make_query_values_indicator() builds SELECT query with correct identifiers",
  {
    test_result <- make_query_values_indicator(test_db_schema)

    expect_true(is.character(test_result))
    expect_match(
      test_result,
      "SELECT * FROM indicator WHERE indicator.country_id = ?",
      fixed = TRUE
    )
    expect_match(
      test_result, "ORDER BY indicator.time_period ASC;",
      fixed = TRUE
    )
  }
)

test_that("make_query_values_indicator() rejects non-list 'db_schema'", {
  error_msg <- "Assertion on 'db_schema' failed"

  expect_error(make_query_values_indicator(NULL), error_msg)
  expect_error(make_query_values_indicator("not_a_list"), error_msg)
})

test_that(
  "make_query_values_weight() builds SELECT query with correct identifiers",
  {
    test_result <- make_query_values_weight(test_db_schema_with_weight)

    expect_true(is.character(test_result))
    expect_match(
      test_result,
      "SELECT * FROM wb_weight WHERE weight.country_id = ?",
      fixed = TRUE
    )
    expect_match(
      test_result, "ORDER BY weight.time_period ASC;",
      fixed = TRUE
    )
  }
)

test_that(
  "make_query_values_weight() returns warning and NULL when weight is absent",
  {
    expect_warning(
      test_result <- make_query_values_weight(test_db_schema),
      regexp = "Weight data table name doesn't exist"
    )
    expect_null(test_result)
  }
)

test_that("make_query_values_weight() rejects non-list 'db_schema'", {
  error_msg <- "Assertion on 'db_schema' failed"

  expect_error(make_query_values_weight(NULL), error_msg)
  expect_error(make_query_values_weight("not_a_list"), error_msg)
})

test_that(
  "make_query_country_ids() builds SELECT query with correct identifiers",
  {
    test_result <- make_query_country_ids(test_db_schema)

    expect_true(is.character(test_result))
    expect_match(
      test_result, "SELECT DISTINCT indicator.country_id",
      fixed = TRUE
    )
    expect_match(test_result, "FROM indicator", fixed = TRUE)
    expect_match(test_result, "WHERE indicator.country_id > 0;", fixed = TRUE)
  }
)

test_that("initialize() stores connection and db_schema", {
  test_extractor <- DbDataExtractor$new(
    con = mock_db_connection, db_schema = test_db_schema_with_weight
  )

  expect_equal(test_extractor$db_schema, test_db_schema_with_weight)
  expect_true(inherits(test_extractor, "DbDataExtractor"))
  expect_true(inherits(test_extractor, "R6"))
})

test_that("get_data() calls dbGetQuery() without 'country_id' argument", {
  local_mocked_bindings(
    dbGetQuery = function(...) mock_db_data,
    .package   = "DBI"
  )

  test_result <- DbDataExtractor$new(
    mock_db_connection, test_db_schema
  )$get_data("country_ids")
  expect_equal(test_result, mock_db_data)
})

test_that("get_data() calls dbSendQuery() when 'country_id' is supplied", {
  test_call <- character(0)
  local_mocked_bindings(
    dbSendQuery = function(...) {
      test_call <<- c(test_call, "send")
      mock_db_result
    },
    dbFetch = function(...) {
      test_call <<- c(test_call, "fetch")
      mock_db_data
    },
    dbClearResult = function(...) {
      test_call <<- c(test_call, "clear")
      invisible()
    },
    .package = "DBI"
  )

  test_result <- DbDataExtractor$new(
    mock_db_connection, test_db_schema
  )$get_data("values_indicator", 276)
  expect_equal(test_result, mock_db_data)
  expect_equal(test_call, c("send", "fetch", "clear"))
})

test_that("get_data() returns message and NULL on error", {
  local_mocked_bindings(
    dbGetQuery = function(...) stop("DB unavailable"),
    .package   = "DBI"
  )

  expect_message(
    test_result <- DbDataExtractor$new(
      mock_db_connection, test_db_schema
    )$get_data("country_ids"),
    "'get_data' failed with the error message"
  )
  expect_null(test_result)
})

test_that("get_data() returns message and NULL on warning", {
  expect_message(
    test_result <- DbDataExtractor$new(
      mock_db_connection, test_db_schema
    )$get_data("values_weight"),
    regexp = "'get_data' generated warning"
  )
  expect_null(test_result)
})

test_that("query active binding exposes built SQL and is read-only", {
  local_mocked_bindings(
    dbGetQuery = function(...) mock_db_data,
    .package   = "DBI"
  )

  test_extractor <- DbDataExtractor$new(mock_db_connection, test_db_schema)
  test_result <- test_extractor$get_data("country_ids")

  expect_type(test_extractor$query, "list")
  expect_true(is.character(test_extractor$query$country_ids))
  expect_error(test_extractor$query <- list(), "read only")
})

test_that("disconnect() delegates to dbDisconnect()", {
  called <- FALSE
  local_mocked_bindings(
    dbDisconnect = function(...) {
      called <<- TRUE
      invisible()
    },
    .package = "DBI"
  )

  DbDataExtractor$new(mock_db_connection, test_db_schema)$disconnect()
  expect_true(called)
})

test_that("get_indicator_values() rejects non-integerish 'country_id'", {
  expect_error(
    DbDataExtractor$new(
      mock_db_connection, test_db_schema
    )$get_indicator_values("abc"),
    "Assertion on 'country_id' failed"
  )
})

test_that("get_weight_values() rejects non-integerish 'country_id'", {
  expect_error(
    DbDataExtractor$new(
      mock_db_connection, test_db_schema
    )$get_weight_values("abc"),
    "Assertion on 'country_id' failed"
  )
})

test_that(
  "create_db_connection() calls dbConnect() and returns the connection",
  {
    test_secrets <- c(
      DB_NAME = "mydb",
      DB_HOST = "localhost",
      DB_PORT = "3306",
      DB_USERNAME = "user",
      DB_PW = "pw"
    )
    local_mocked_bindings(
      MariaDB   = function(...) structure(list(), class = "MariaDBDriver"),
      .package  = "RMariaDB"
    )
    local_mocked_bindings(
      dbConnect = function(...) mock_db_connection,
      .package  = "DBI"
    )

    expect_identical(create_db_connection(test_secrets), mock_db_connection)
  }
)

test_that("create_db_connection() rejects an unnamed secrets vector", {
  expect_error(
    create_db_connection(c("mydb", "localhost", "3306", "user", "pw")),
    "Assertion on 'secrets' failed:"
  )
})

test_that("create_db_connection rejects() a non-character secrets argument", {
  expect_error(
    create_db_connection(list(DB_NAME = "mydb")),
    "Assertion on 'secrets' failed:"
  )
})
