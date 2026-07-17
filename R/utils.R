# nocov start
#' Create copyright footnote
#'
#' Creates copyright footnote to use across the app.
#'
#' @return A string with a copyright note.
#' @export
create_copyright_note <- function() {
  sprintf(
    "Copyright \u00a9 %s Jacek Cieslar (v%s). All rights reserved.",
    format(Sys.Date(), "%Y"),
    utils::packageVersion("myportfolio")
  )
}
# nocov end

#' Check if object is empty
#'
#' Invalidates provided object.
#'
#' @details
#' It is a modified application of `invalid()` from \pkg{gtools} -
#' \url{https://github.com/r-gregmisc/gtools/blob/master/R/invalid.R}.
#'
#' @param target_object An object/value to be tested.
#' @return A single logical value.
#' @export
is_empty <- function(target_object) {
  if (missing(target_object) || length(target_object) == 0) {
    return(TRUE)
  }

  if (is.list(target_object)) {
    all(sapply(target_object, is_empty))
  } else if (is.vector(target_object)) {
    all(is.na(target_object)) || all(target_object == "")
  } else if (inherits(target_object, "Date")) {
    all(is.na(target_object))
  } else {
    FALSE
  }
}

#' Find a list element that is identical to the given value
#'
#' Checks if actual list contains element that is identical to the expected
#'   value.
#'
#' @param target_list A list of actual elements to check.
#' @param expected_value An expected value. Can be any R object.
#' @return A vector of logical values.
#' @export
sapply_identical <- function(target_list, expected_value) {
  checkmate::assert_list(target_list, unique = TRUE)

  sapply(target_list, identical, expected_value)
}

#' Geometric mean
#'
#' Calculates geometric mean using [base::log()], [base::mean()] and
#'   [base::exp()].
#'
#' @param input_values A numeric or complex vector.
#' @param na.rm A Boolean value. Whether NA values should be stripped before
#'   the computation proceed. Used by [base::mean()].
#' @return A single numeric value.
#' @export
geometric.mean <- function(input_values, na.rm = TRUE) {
  exp(mean(log(input_values), na.rm = na.rm))
}
