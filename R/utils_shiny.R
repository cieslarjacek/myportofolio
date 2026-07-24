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

#' Extract cookie value by name
#'
#' Gets a specific cookie value from a raw HTTP Cookie header.
#'
#' @param cookie_header A raw Cookie header string (e.g. "a=1; b=2").
#' @param cookie_name A single character string with a cookie name to extract.
#' @return The cookie value or NA if not found.
#' @export
get_cookie_value <- function(cookie_header, cookie_name) {
  checkmate::assert_string(cookie_header, na.ok = TRUE, null.ok = TRUE)
  checkmate::assert_string(cookie_name, na.ok = TRUE, null.ok = TRUE)

  if (is_empty(cookie_header) || is_empty(cookie_header)) {
    return(NA_character_)
  }

  key_value_pairs <- cookie_header %>%
    strsplit(";\\s*") %>%
    unlist() %>%
    strsplit("=")
  matched_value <- Filter(function(x) x[1] == cookie_name, key_value_pairs)

  if (is_empty(matched_value)) {
    return(NA_character_)
  } else {
    matched_value[[1]][2]
  }
}
