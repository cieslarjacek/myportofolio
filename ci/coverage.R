print("Running COVERAGE check...")
# Install and use exact "covr" version.
if (!requireNamespace("remotes", quietly = TRUE)) {
  install.packages("remotes", repos = Sys.getenv("CRAN_URL"))
}
if (!requireNamespace("covr", quietly = TRUE)) {
  remotes::install_version(
    "covr",
    version = "3.6.5", repos = Sys.getenv("CRAN_URL")
  )
}

library(covr)

# Run check.
out <- covr::package_coverage()
actual_coverage <- covr::percent_coverage(out)
expected_coverage <- 60 # TODO: MAKE IT 80.

print(out)
Sys.sleep(1)
if (actual_coverage < expected_coverage) {
  print(paste0(
    "Coverage below threshold: ", expected_coverage, "%"
  ))
  quit(status = 1)
}
print(paste0(
  "Coverage above threshold: ", expected_coverage, "%"
))
