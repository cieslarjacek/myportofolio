message("Running UNIT TESTS check...")
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
