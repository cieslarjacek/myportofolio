# Install exact version of packages needed in CI pipeline.
pkg_list <- list(
    covr = "3.6.5",
    lintr = "3.3.0-1",
    oysteR = "0.1.4",
    testthat = "3.3.2"
)

for (pkg_name in names(pkg_list)) {
    remotes::install_version(
        pkg_name,
        version = pkg_list[[pkg_name]], repos = Sys.getenv("CRAN_URL")
    )
}
