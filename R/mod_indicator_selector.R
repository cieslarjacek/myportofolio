#' Indicator selector Shiny module
#'
#' Provides UI and server logic for an indicator selector.
#'
#' @param id Module ID. Check [shiny::NS()] for more details.
#' @param choices A named vector or list with a choices for the selector.
#'   Passed to [shiny::selectInput()] as `choices` parameter. Default
#'   values are provided by [set_name_id_indicators()].
#' @return A reactive expression with a selected value inside.
#' @export
indicatorSelectorUI <- function(id) {
  shiny::uiOutput(shiny::NS(id, "selector"))
}

#' @rdname indicatorSelectorUI
#' @export
indicatorSelectorServer <- function(id, choices = set_name_id_indicators()) {
  shiny::moduleServer(id, function(input, output, session) {
    output$selector <- shiny::renderUI({
      shiny::req(!is_empty(choices))
      checkmate::assert(
        check_with(checkmate::check_list, choices, check_named_args()),
        check_with(checkmate::check_character, choices, check_named_args()),
        .var.name = checkmate::vname(choices)
      )

      shiny::selectInput(
        inputId = shiny::NS(id, "indicator_selector"),
        label = "World Trends Data Indicators",
        choices = c("-" = "", choices),
        selectize = FALSE
      )
    })
    shiny::reactive(input$indicator_selector)
  })
}
