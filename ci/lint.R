# Install exact "lintr" version.
if (!requireNamespace("remotes", quietly = TRUE)) {
  install.packages("remotes", repos = Sys.getenv("CRAN_URL"))
}
remotes::install_version("lintr", version = "3.3.0-1", repos = Sys.getenv("CRAN_URL"))

# Run test.
library(lintr)
out <- lintr::lint_package()
issue_num <- length(out)

if (issue_num > 0) {
  print(out)
  print(paste0(
    "Number of issues found: ", issue_num
  ))
  quit(status = 1)
}