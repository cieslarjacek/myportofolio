#' Route page
#'
#' Routes to expected page (UI object) using the Rook environment properties.
#'
#' @details
#' Page (UI object) is selected based on matching URL path presented in the Rook
#' environment.
#'
#' @param route_schema A list of URL paths to target pages (UI objects) mapping.
#' @param default A page (UI object) to which all invalid URL paths
#'   are redirected. Default is "404 Not Found".
#' @param url_path A string with the URL path.
#' @return `shiny.tag` or `shiny.tag.list` class object.
#' @export
route_page <- function(route_schema, default = "404 Not Found") {
  function(rook_env) {
    select_page(rook_env$PATH_INFO, route_schema, default)
  }
}

#' @rdname route_page
select_page <- function(url_path, route_schema, default) {
  checkmate::assert_string(url_path, pattern = "^/")
  checkmate::assert_list(route_schema, names = "named")
  checkmate::assert_string(default)

  if (!(url_path %in% names(route_schema))) {
    return(default)
  }
  route_schema[[url_path]]
}

#' Get or create `uiPattern`
#'
#' Gets general `uiPattern` for [shiny::shinyApp()] that will match every
#'   URL path that starts with "/" or creates regex with exact `uiPattern`.
#'
#' @param url_path A character vector with target URL path(s). URL path
#'   should start with "/".
#' @return A regex string.
#' @export
get_ui_pattern <- function() {
  "/.*$"
}

#' @rdname get_ui_pattern
create_ui_pattern <- function(url_path) {
  checkmate::assert_character(
    url_path,
    pattern = "^/", any.missing = FALSE, all.missing = FALSE, unique = TRUE
  )

  target_regex <- paste0("\\", url_path, collapse = "|")
  paste0("^(", target_regex, ")$")
}
