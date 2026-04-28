# Install and use exact "lintr" version.
if (!requireNamespace("remotes", quietly = TRUE)) {
  install.packages("remotes", repos = Sys.getenv("CRAN_URL"))
}
if (!requireNamespace("lintr", quietly = TRUE)) {
  remotes::install_version(
    "lintr",
    version = "3.3.0-1", repos = Sys.getenv("CRAN_URL")
  )
}

library(lintr)

# Run check.
message("Running LINT check...")
out <- lintr::lint_package()
issue_count <- length(out)

print(out)
Sys.sleep(1)
message("Number of issues found: ", issue_count)
if (issue_count > 0) {
  quit(status = 1)
}
