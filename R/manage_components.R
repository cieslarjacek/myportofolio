#' Find all, UI, server or other component files
#'
#' Finds app all, UI, server or other (than UI and server) component files
#'   in the relevant directories.
#'
#' @param sub_dir A character vector of component sub-directories used in
#'   the app. Default values are provided by [set_app_components()].
#' @param main_dir Main component directory. Defaults to `"components"`.
#' @return A character vector with component file paths.
#' @export
find_all_components <- function(sub_dir, main_dir) {
  assert_with(checkmate::assert_character, sub_dir, assert_character_args())
  checkmate::assert_string(main_dir)

  paste(main_dir, sub_dir, sep = "/") %>%
    lapply(function(component) {
      list.files(
        component,
        pattern = "\\.R$", full.names = TRUE, include.dirs = FALSE
      )
    }) %>%
    unlist()
}

#' @rdname find_all_components
#' @export
find_ui_components <- function(
  sub_dir = set_app_components(), main_dir = "components"
) {
  find_all_components(sub_dir, main_dir) %>%
    .[grepl("ui_", .)]
}

#' @rdname find_all_components
#' @export
find_server_components <- function(
  sub_dir = set_app_components(), main_dir = "components"
) {
  find_all_components(sub_dir, main_dir) %>%
    .[grepl("server_", .)]
}

#' @rdname find_all_components
#' @export
find_other_components <- function(
  sub_dir = set_app_components(), main_dir = "components"
) {
  find_all_components(sub_dir, main_dir) %>%
    .[!grepl("ui_|server_", .)]
}

#' Source component files
#'
#' Sources each file in `component_paths` set using [base::source()].
#'
#' @param component_paths A character vector with component file paths.
#' @param evalutation_env Environment in which the parsed expressions are
#'   evaluated. Passed to [base::source()] as `local` parameter. Default is
#'   `globalenv()`.
#' @export
source_components <- function(component_paths, evalutation_env = globalenv()) {
  assert_with(
    checkmate::assert_character, component_paths, assert_character_args()
  )
  checkmate::assert(
    checkmate::check_logical(evalutation_env, any.missing = FALSE, len = 1),
    checkmate::check_environment(evalutation_env)
  )

  sapply(component_paths, source, local = evalutation_env)
}
