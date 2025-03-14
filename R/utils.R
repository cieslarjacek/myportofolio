#' Add a spinner
#'
#' Utilizes [shinycssloaders::withSpinner()] with a default settings.
#'
#' @param ui_element A UI element that should be wrapped with a spinner
#'   when the corresponding output is being calculated. Passed to
#'   [shinycssloaders::withSpinner()] as `ui_element` parameter.
#' @param spinner_color A string that defines the spinner color. Default value
#'   is provided by [set_color_palette()].
#' @export
add_default_spinner <- function(
  ui_element,
  spinner_color = set_color_palette()$primary_lt
) {
  # TODO: ADD ASSERTIONS.

  shinycssloaders::withSpinner(
    ui_element,
    color = spinner_color,
    size = 2
  )
}

#' Add JavaScript code to HTML Widget object
#'
#' Attaches custom JavaScript code to HTML Widget object (e.g. map, chart,
#'   table).
#'
#' @param htmlwidget_object An HTML Widget object to which JavaScript code
#'   snippet will be attached. Please check [htmlwidgets] for more details.
#' @param id `htmlwidget_object` ID.
#' @param js_code A character vector containing JavaScript code. Please check
#'   [htmlwidgets::onRender()] for more details. Default value is provided by
#'   [get_js_event()].
#' @return The modified widget object.
#' @export
add_js_code <- function(
  htmlwidget_object, id, js_code = get_js_event(id)
) {
  checkmate::assert_character(js_code)
  htmlwidgets::onRender(htmlwidget_object, js_code)
}

# nocov start
# nolint start
#' Select a JavaScript code snippet for the relevant HTML Widget object
#'
#' @rdname add_js_code
get_js_event <- function(id) {
  switch(id,
    `world_trends-map` = "function(el, x) { window.renderEvents.worldTrendsMap.call(window.renderEvents, el, x); }",
    `world_trends-chart` = "function(el, x) { window.renderEvents.worldTrendsChart.call(window.renderEvents, el, x); }",
    `world_trends-table_content` = "function(el, x) { window.renderEvents.worldTrendsTable.call(window.renderEvents, el, x); }"
  )
}
# nolint end
# nocov end

#' Check if object is empty
#'
#' Invalidates provided object.
#'
#' @details#'
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

#' Just a wrapper for a classic Shiny `validate(need())` combo
#'
#' Runs [shiny::validate()] with a single [shiny::need()].
#'
#' @param expression An expression to test.
#' @param output_id A string containing output id/name in which the validation
#'   is run. Default value is obtained using [shiny::getCurrentOutputInfo()].
#' @param message A message to show to the user if the test fails. Default value
#'   is provided by [set_validation_message()].
#' @export
run_validate_need <- function(
  expression,
  output_id = shiny::getCurrentOutputInfo()$name,
  message = set_validation_message(output_id)
) {
  shiny::validate(shiny::need(
    expression, shiny::HTML(message)
  ))
}

# nocov start
# nolint start
#' Returns a validation UI message for the relevant Shiny module output
#'
#' @rdname run_validate_need
set_validation_message <- function(output_id) {
  switch(output_id,
    `world_trends-map` = c(
      "Please use the dropdown menu above to browser ",
      "and select the indicator that you are interested in.",
      "\nWorld map will be plotted after the indicator is selected."
    ),
    `world_trends-chart` = c(
      "Please click the country on the map to plot relevant indicator data for it.",
      "\nYou can select up to five countries.",
      "\nAnother click on the already selected country will remove its data from the plot."
    ),
    `world_trends-table_output` = c(
      "Please click the country on the map to create table with relevant indicator data for it.",
      "\nYou can select up to five countries.",
      "\nAnother click on the already selected country will remove its data from the table."
    ),
    NULL
  )
}
# nolint end
# nocov end

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
