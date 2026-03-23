print("Running UNIT TESTS check...")
# Install and use exact "data.table", "pkgload" and"testthat" version.
if (!requireNamespace("remotes", quietly = TRUE)) {
  install.packages("remotes", repos = Sys.getenv("CRAN_URL"))
}
if (!requireNamespace("data.table", quietly = TRUE)) {
  remotes::install_version(
    "data.table", version = "1.18.2.1", repos = Sys.getenv("CRAN_URL")
  )
}
if (!requireNamespace("pkgload", quietly = TRUE)) {
  remotes::install_version(
    "pkgload", version = "1.4.1", repos = Sys.getenv("CRAN_URL")
  )
}
if (!requireNamespace("testthat", quietly = TRUE)) {
  remotes::install_version(
    "testthat", version = "3.3.2", repos = Sys.getenv("CRAN_URL")
  )
}

library(data.table)
library(pkgload)
library(testthat)
pkgload::load_all()

# Run check.
list_reporter <- testthat::ListReporter$new()
try(
  testthat::test_dir("tests/testthat", reporter = list_reporter),
  silent = TRUE
)
out <- data.table::as.data.table(list_reporter$get_results())
issue_count <- sum(out$error) + sum(out$failed)

if (issue_count > 0) {
  print(out)
  Sys.sleep(1)
  print(paste0(
    "Number of issues found: ", issue_count
  ))
  quit(status = 1)
}
