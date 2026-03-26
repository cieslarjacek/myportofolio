#' Make range for data on x or y axis
#'
#' Makes x or y axis data range for `plotly` line chart.
#'
#' @details
#' For x-axis new range is created using `celinig()` and `floor()` rounding.
#'
#' For y-axis extra padding is added around its initial minimum and maximum
#' values.
#' The goal is to avoid layout elements (e.g. lines, markers, tick labels),
#' that are near the edges of the plotting area, being clipped or cut off.
#'
#' @param initial_range A vector containing a pair of integers where
#'   the first element is the data range observed minimum
#'   and the second is the observed maximum.
#' @return A vector containing a pair of integers where the first element is
#'   the data range modified minimum and the second is the modified maximum.
#' @export
make_xrange <- function(initial_range) {
  assert_with(
    checkmate::assert_numeric, initial_range, assert_len2_args()
  )

  c(ceiling(initial_range[1]), floor(initial_range[2]))
}

#' @rdname make_xrange
#' @export
make_yrange <- function(initial_range) {
  assert_with(
    checkmate::assert_numeric, initial_range, assert_len2_args()
  )

  ypadding <- calculate_yrange_padding(initial_range)
  target_yrange <- initial_range + c(ypadding * (-1), ypadding)
  target_yrange
}

#' @rdname make_xrange
calculate_yrange_padding <- function(initial_range) {
  initial_range %>%
    diff() %>%
    magrittr::divide_by(16)
}

#' Select range for data
#'
#' Selects range for data from two available choices.
#'
#' @details
#' From `range_pair` the "current" one is always preferred over the "default".
#'
#' @param range_pair A list containing two range elements. First element is the
#'   current (user modified) data range and the second element is the default
#'   (absolute) data range.
#' @return A vector containing a pair of integers where the first element is
#'   the data range minimum and the second is the maximum.
#' @export
select_range <- function(range_pair) {
  checkmate::assert_list(
    range_pair,
    len = 2, all.missing = FALSE, unique = TRUE
  )

  if (!is_empty(range_pair[[1]])) {
    return(make_xrange(range_pair[[1]]))
  }
  range_pair[[2]]
}
