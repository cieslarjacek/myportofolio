message("Running COVERAGE check...")
out <- covr::package_coverage()
actual_coverage <- covr::percent_coverage(out)
expected_coverage <- 80

print(out)
Sys.sleep(1)
if (actual_coverage < expected_coverage) {
  message("Coverage BELOW threshold: ", expected_coverage, "%")
  quit(status = 1)
}
message("Coverage ABOVE threshold: ", expected_coverage, "%")
