#' Build a named list of read-only active bindings for an R6 fields
#'
#' Convenience wrapper that applies [make_active_field()] to each of field names
#' and returns them as a named list, ready to be dropped into the `active`
#' argument of an [R6::R6Class] definition.
#'
#' @details
#' [make_active_field()] generates a function suitable for use as an active
#' binding in an [R6::R6Class] definition. The returned function exposes the
#' private field `private$.<field_name>` for reading and raises an error on
#' any attempt to assign to it.
#'
#' @param field_names A character vector of private field or method names.
#' @param field_name A single character string naming the active field.
#'   The corresponding private field or method is expected at
#'   `private$.<field_name>` following the common R6 convention.
#'
#' @return
#' * `make_active_field_wrapper()` returns a named list of active-binding
#'   functions. One per element of`field_names` and with names equal to
#'   `field_names`.
#' * `make_active_field()` returns a function with a one optional argument
#'   `value`. Called with no argument (e.g. `obj$field`) it returns
#'   `private$.<field_name>`. Called with a value (e.g. `obj$field <- x`) it
#'   stops with a "read-only" error.
#' @examples
#' \dontrun{
#' PointClass <- R6::R6Class(
#'   "PointClass",
#'   private = list(.x = 0),
#'   active  = list(x = make_active_field("x"))
#' )
#' p <- PointClass$new()
#' p$x # reads 'private$.x' value
#' p$x <- 5 # Error: 'x' is read-only
#'
#' RecordClass <- R6::R6Class(
#'   "RecordClass",
#'   private = list(.id = 109, .created = "2021-09-14"),
#'   active  = make_active_field_wrapper(c("id", "created"))
#' )
#' r <- Record$new()
#' r$id # reads 'private$.id' value
#' r$created # reads 'private$.created' value
#' r$id <- 10 # Error: 'id' is read-only
#' r$created <- "2023-01-01" # Error: 'created' is read-only
#' }
make_active_field_wrapper <- function(field_names) {
  setNames(lapply(field_names, make_active_field), field_names)
}

#' @rdname make_active_field_wrapper
make_active_field <- function(field_name) {
  eval(bquote(function(value) {
    if (missing(value)) {
      private[[.(paste0(".", field_name))]]
    } else {
      stop(sprintf("'%s' is read-only", .(field_name)), call. = FALSE)
    }
  }))
}
