message("Dependency vulnerability scan (oysteR)...")
audit <- oysteR::audit_renv_lock()
out <- oysteR::get_vulnerabilities(audit)
issue_count <- nrow(out)

print(out)
Sys.sleep(1)
message("Number of vulnerabilities found: ", issue_count)
if (issue_count > 0) {
    quit(status = 1)
}
