#' A collection of helper functions that are responsible for manipulating
#'   strings in a character vector
#'
#' @param string A character vector.
#' @param replacement A string to use as a replacement.
#' @return A character vector with converted strings. It should have the same
#'   number of elements as the input vector.
#' @name manipulate_str
#' @keywords internal
#' @noRd
NULL

#' @describeIn manipulate_str Convert all characters to ASCII
#'
#' @keywords internal
#' @noRd
str_to_ascii <- function(string) {
  iconv(string, to = "ASCII//TRANSLIT")
}

#' @describeIn manipulate_str Remove all non-alphanumeric characters from
#'   the start and the end
#'
#' @keywords internal
#' @noRd
str_trim_nonalnum_edges <- function(string) {
  gsub("^[^[:alnum:]]+|[^[:alnum:]]+$", "", string)
}

#' @describeIn manipulate_str Replace any sequence of non-alphanumeric
#' characters with a given replacement
#'
#' @keywords internal
#' @noRd
str_replace_nonalnum <- function(string, replacement) {
  gsub("[^[:alnum:]]+", replacement, string)
}

#' @describeIn manipulate_str Convert string to "kebab-case" format
#'
#' @keywords internal
#' @noRd
#' @examples
#' \dontrun{
#' str_to_kebab_case(c("Niće näme", "B#ig?, trée!"))
#' [1] "nice-name" "b-ig-tree"
#' }
str_to_kebab_case <- function(string) {
  checkmate::assert_character(string)

  str_to_ascii(string) %>%
    tolower() %>%
    str_trim_nonalnum_edges() %>%
    str_replace_nonalnum("-")
}

#' @describeIn manipulate_str Convert string to "underscore_case" format
#'
#' @keywords internal
#' @noRd
#' @examples
#' \dontrun{
#' str_to_underscore_case(c("Niće näme", "B#ig?, trée!"))
#' [1] "nice_name" "b_ig_tree"
#' }
str_to_underscore_case <- function(string) {
  checkmate::assert_character(string)

  str_to_ascii(string) %>%
    tolower() %>%
    str_trim_nonalnum_edges() %>%
    str_replace_nonalnum("_")
}
