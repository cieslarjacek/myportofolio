print("Running LINT check...")
# Install and use exact "lintr" version.
if (!requireNamespace("remotes", quietly = TRUE)) {
  install.packages("remotes", repos = Sys.getenv("CRAN_URL"))
}
if (!requireNamespace("lintr", quietly = TRUE)) {
  remotes::install_version(
    "lintr", version = "3.3.0-1", repos = Sys.getenv("CRAN_URL")
  )
}

library(lintr)

# Prepare basic custom security linters.
regex_linter <- function(pattern, message) {
  lintr::Linter(function(source_file) {
    lapply(seq_along(source_file$lines), function(line_indx) {
      target_line <- source_file$lines[[line_indx]]
      
      if (grepl(pattern, target_line, ignore.case = TRUE, perl = TRUE)) {
        lintr::Lint(
          filename = source_file$filename,
          line_number = line_indx,
          column_number = regexpr(pattern, target_line, perl = TRUE),
          type = "warning",
          message = message,
          line = target_line
        )
      }
    })
  })
}

system_call_linter <- regex_linter(
  "system\\(",
  "Avoid system() calls (command injection risk)."
)

system2_call_linter <- regex_linter(
  "system2\\(",
  "Review system2() usage for security issues."
)

eval_parse_linter <- regex_linter(
  "eval\\(parse",
  "Avoid eval(parse()) - high risk of code injection."
)

sql_paste_linter <- regex_linter(
  "paste0?\\([^)]*(SELECT|INSERT|UPDATE|DELETE)",
  "Possible SQL injection risk - avoid building SQL queries with 'paste'."
)

hardcoded_secret_linter <- regex_linter(
  "(password|api_key|secret)\\s*<-",
  "Hardcoded secret detected."
)

# Run check.
out <- lintr::lint_package()
issue_count <- length(out)

if (issue_count > 0) {
  print(out)
  Sys.sleep(1)
  print(paste0(
    "Number of issues found: ", issue_count
  ))
  quit(status = 1)
}