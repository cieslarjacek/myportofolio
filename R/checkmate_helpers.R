#' A collection of helper functions for \pkg{checkmate}
#'
#' @details
#' This a collection of helper functions for for \pkg{checkmate}. Most of them
#' exist in pairs - `check` and `assert`.
#' * `check` - returns `TRUE` when the check pass and the error message
#' (as a string) when the check fails.
#' * `assert` - returns checked object when the assertion pass and throws
#' an exception and stops execution (stop()) when the assertion fails.
#'
#' More details about them:
#' * `_with` - run a relevant assertion or check function (e.g. `assert_list()`)
#' on target object (e.g. other function argument) with a given list of
#' arguments (e.g. `list(any.missing = FALSE, unique = TRUE)`).
#' * `_args` - a list of common arguments with default values.
#' * `_named_args` - a list of arguments for named lists or vectors.
#' * `_len2_args` - a list of arguments for lists or vectors of length two.
#' * `_character_args` - a list of arguments for character vectors.
#' * `_named_character_args` - a list of arguments for named character vectors.
#'
#' There are a few special cases:
#' * `assert_polygon_data` - asserts `sf` data frame with polygon country data.
#' * `assert_reactive` - asserts `reactive` class target_object.
#' * `assert_polygon_data` - asserts `reactiveVal` class target_object.
#'
#' @name checkmate-helper
#' @keywords internal
#' @noRd
NULL

# nocov start
#' Internal assert and check helper for \pkg{checkmate}
#'
#' @keywords internal
#' @noRd
check_with <- function(func, target_object, args) {
  tryCatch(
    do.call(func, c(list(target_object), args)),
    error = function(e) stop(e$message, call. = FALSE)
  )
}

#' @keywords internal
#' @noRd
assert_with <- function(func, target_object, args) {
  args <- c(
    list(.var.name = deparse(substitute(target_object))),
    args
  )
  check_with(func, target_object, args)
}

#' Common \pkg{checkmate} arguments
#'
#' @keywords internal
#' @noRd
check_args <- function() {
  list(any.missing = FALSE, all.missing = FALSE, unique = TRUE)
}

#' @keywords internal
#' @noRd
assert_args <- check_args

#' Common \pkg{checkmate} arguments for named lists or vectors
#'
#' @keywords internal
#' @noRd
check_named_args <- function() {
  c(list(names = "named"), check_args())
}

#' @keywords internal
#' @noRd
assert_named_args <- check_named_args

#' Common \pkg{checkmate} arguments for lists or vectors of length two
#'
#' @keywords internal
#' @noRd
check_len2_args <- function() {
  c(list(len = 2), check_args())
}

#' @keywords internal
#' @noRd
assert_len2_args <- check_len2_args

#' Common \pkg{checkmate} arguments for character vectors
#'
#' @keywords internal
#' @noRd
check_character_args <- function() {
  list(any.missing = FALSE, all.missing = FALSE)
}

#' @keywords internal
#' @noRd
assert_character_args <- check_character_args

#' Common \pkg{checkmate} arguments for named character vectors
#'
#' @keywords internal
#' @noRd
check_named_character_args <- function() {
  c(list(names = "named"), check_character_args())
}

#' @keywords internal
#' @noRd
assert_named_character_args <- check_named_character_args

#' Assert `sf` data frame with polygon country data
#'
#' @keywords internal
#' @noRd
assert_polygon_data <- function(target_object) {
  # Assert data class and column names.
  checkmate::assert_class(
    target_object,
    classes = c("sf", "data.frame"),
    null.ok = FALSE
  )
  checkmate::assert_names(
    names(target_object),
    must.include = c("id", "label", "geometry")
  )
  checkmate::assert_data_frame(target_object, any.missing = FALSE, min.rows = 1)
  # Assert column data types.
  checkmate::assert_integerish(target_object$id)
  checkmate::assert_character(target_object$label)
  checkmate::assert_class(
    sf::st_geometry(target_object),
    classes = "sfc_MULTIPOLYGON"
  )

  invisible(TRUE)
}

#' Assert `reactive` class target_object
#'
#' @keywords internal
#' @noRd
assert_reactive <- function(target_object) {
  tryCatch(
    checkmate::assert_class(
      target_object,
      c("reactiveExpr", "reactive", "function"),
      .var.name = deparse(substitute(target_object))
    ),
    error = function(e) stop(e$message, call. = FALSE)
  )
}

#' Assert `reactiveVal` class target_object
#'
#' @keywords internal
#' @noRd
assert_reactiveval <- function(target_object) {
  tryCatch(
    checkmate::assert_class(
      target_object,
      c("reactiveVal", "reactive", "function"),
      .var.name = deparse(substitute(target_object))
    ),
    error = function(e) stop(e$message, call. = FALSE)
  )
}
# nocov end
