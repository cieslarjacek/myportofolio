#' Side note Shiny module
#'
#' Provides UI and server logic for creating notes inside side panels.
#'
#' @param id Module ID. Check [shiny::NS()] for more details.
#' @param message A character vector with a message to show. Default value
#'   is provided by [get_sidenote_message()].
#' @export
sidenoteUI <- function(id) {
  shiny::uiOutput(shiny::NS(id, "sidenote"))
}

#' @rdname sidenoteUI
#' @export
sidenoteServer <- function(id, message = get_sidenote_message(id)) {
  assert_with(checkmate::assert_character, message, assert_character_args())

  shiny::moduleServer(id, function(input, output, session) {
    output$sidenote <- shiny::renderUI({
      shiny::HTML(message)
    })
  })
}

# nocov start
# nolint start
#' Select a side note message for the relevant Shiny module
#'
#' @rdname sidenoteUI
get_sidenote_message <- function(id) {
  switch(id,
    no_panel_selected = "Please click one of the panels on the left to open it and see some examples.",
    world_trends = c(
      "<p>Data source: <a href='https://data.worldbank.org/' target='_blank'>World Bank Open Data</a></p>",
      "<p>\nThe world map is based on spatial data from ",
      "R <a href='https://github.com/rspatial/geodata' target='_blank'>geodata</a> package. ",
      "Some country borders were adjusted to fit administrative division used by the World Bank.</p>"
    ),
    data_summary = "Some text about and instructions."
  )
}
# nolint end
# nocov end
