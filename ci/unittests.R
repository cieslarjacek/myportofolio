# Install and use exact "data.table", "pkgload" and "testthat" version.
if (!requireNamespace("remotes", quietly = TRUE)) {
  install.packages("remotes", repos = Sys.getenv("CRAN_URL"))
}
if (!requireNamespace("data.table", quietly = TRUE)) {
  remotes::install_version(
    "data.table",
    version = "1.18.2.1", repos = Sys.getenv("CRAN_URL")
  )
}
if (!requireNamespace("testthat", quietly = TRUE)) {
  remotes::install_version(
    "testthat",
    version = "3.3.2", repos = Sys.getenv("CRAN_URL")
  )
}

library(data.table)
library(testthat)

# Run check.
print("Running UNIT TESTS check...")
list_reporter <- testthat::ListReporter$new()
try(
  testthat::test_dir("tests/testthat", reporter = list_reporter),
  silent = TRUE
)
out <- data.table::as.data.table(list_reporter$get_results())
issue_count <- sum(out$error) + sum(out$failed)

print(out)
Sys.sleep(1)
message("Number of issues found: ", issue_count)
if (issue_count > 0) {
  quit(status = 1)
}
