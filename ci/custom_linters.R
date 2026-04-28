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
