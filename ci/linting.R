message("Running LINT check...")
out <- lintr::lint_package()
issue_count <- length(out)

print(out)
Sys.sleep(1)
message("Number of issues found: ", issue_count)
if (issue_count > 0) {
  quit(status = 1)
}
