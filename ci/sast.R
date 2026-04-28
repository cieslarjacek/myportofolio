# Install and use exact "lintr" version.
if (!requireNamespace("remotes", quietly = TRUE)) {
    install.packages("remotes", repos = Sys.getenv("CRAN_URL"))
}
if (!requireNamespace("oysteR", quietly = TRUE)) {
    remotes::install_version(
        "oysteR",
        version = "0.1.4", repos = Sys.getenv("CRAN_URL")
    )
}

library(oysteR)

# Run check.
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
