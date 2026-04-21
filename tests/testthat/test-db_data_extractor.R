# TODO: ADD MORE TESTS TO INCREASE COVERAGE.
test_that("initialize() stores connection and db_schema", {
  test_connection <- structure(
    list(), class = c("MockDBIConnection", "DBIConnection")
  )
  test_db_schema <- list(
    country = c(
      "country.country_id",    "country.iso2", "country.iso3", "country.label"
    ),
    world_geo = c("world_geo.country_id",  "world_geo.geometry"),
    indicator = c(
      "indicator.country_id",  "indicator.time_period", "indicator.value"
    ),
    weight = c("weight.country_id",     "weight.time_period",    "weight.value")
  )
  test_extractor <- DbDataExtractor$new(
    con = test_connection, db_schema = test_db_schema
  )

  expect_equal(test_extractor$db_schema, test_db_schema)
  expect_true(inherits(test_extractor, "DbDataExtractor"))
  expect_true(inherits(test_extractor, "R6"))
})
