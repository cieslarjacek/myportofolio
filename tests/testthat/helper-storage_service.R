# Test objects.
mock_storage_connection <- list(
  bucket    = "test-bucket",
  key       = "access-key",
  secret    = "secret-key",
  region    = "",
  base_url  = "minio.test",
  use_https = FALSE
)
mock_storage_data <- data.frame(country_id = 1L, geometry = "POINT(0 0)")
