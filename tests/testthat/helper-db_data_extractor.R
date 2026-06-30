# Test objects.
test_db_schema <- list(
  country = c(
    "country.country_id", "country.iso2", "country.iso3", "country.label"
  ),
  world_geo = c("world_geo.country_id", "world_geo.geometry"),
  indicator = c(
    "indicator.country_id", "indicator.time_period", "indicator.value"
  )
)

test_db_schema_with_weight <- c(
  test_db_schema,
  list(wb_weight = c(
    "weight.country_id", "weight.time_period", "weight.value"
  ))
)

mock_db_connection <- structure(list(), class = "MockDBIConnection")
mock_db_result <- structure(list(), class = "MockResult")
mock_db_data <- data.frame(
  country_id = c(1, 2, 3), value = c(300, 200, 100)
)
