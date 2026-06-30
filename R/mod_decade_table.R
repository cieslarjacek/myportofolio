#' Decades table Shiny module
#'
#' Provides UI and server logic for a `datatables` class decades table.
#'
#' @details
#' **`aggregation_input`** list needs to contain exactly three `reactiveVal`
#' elements:
#' * parameters - a list with "function_name" and "column_name".
#' * indicator data - a list of data tables with indicator data per country.
#' * weight data - a list that can be empty or contain data tables with data
#' necessary for weighting per country.
#'
#' @param id Module ID. Check [shiny::NS()] for more details.
#' @param render_flag A `reactiveVal` object containing Boolean value.
#' @param aggregation_input A list containing input necessary for the data
#'   aggregation (see Details).
#' @param func_name An aggregation function name.
#' @export
decadeTableUI <- function(id) {
  bslib::card_body(
    myportfolio::add_default_spinner(
      shiny::uiOutput(shiny::NS(id, "table_output"))
    )
  )
}

#' @rdname decadeTableUI
#' @export
decadeTableServer <- function(id, render_flag, aggregation_input) {
  assert_reactiveval(render_flag)
  assert_with(
    checkmate::assert_vector, aggregation_input, c(list(len = 3), assert_args())
  )
  invisible(lapply(aggregation_input[1:3], assert_reactiveval))

  shiny::moduleServer(id, function(input, output, session) {
    aux_ns <- session$ns

    output$table_output <- shiny::renderUI({
      run_validate_need(render_flag())

      shiny::tags$div(
        shiny::div(
          shiny::uiOutput(aux_ns("table_description")),
          class = "table_description_flex"
        ),
        shiny::div(
          DT::dataTableOutput(aux_ns("table_content")),
          class = "table_content_flex"
        ),
        class = aux_ns("table_container")
      )
    })

    aggregation_params <- aggregation_input[[1]]

    output$table_description <- shiny::renderUI({
      shiny::req(render_flag())
      shiny::HTML(
        get_table_description(aggregation_params()$function_name)
      )
    })

    output$table_content <- DT::renderDataTable({
      shiny::req(render_flag())
      indicator_data <- data.table::copy(aggregation_input[[2]]())
      weight_data <- data.table::copy(aggregation_input[[3]]())

      if (is.null(aggregation_params()$column_name)) {
        return()
      }

      if (!is_empty(weight_data)) {
        indicator_data <- source_weight(list(indicator_data, weight_data))
      }

      decade_dt <- set_decade_aggregator(aggregation_params()) %>%
        run_decade_aggregator(indicator_data)

      build_decade_table(decade_dt) %>%
        add_js_code(shiny::getCurrentOutputInfo()$name)
    })
  })
}

# nocov start
# nolint start
#' Select a table description for the relevant aggregation function
#'
#' @rdname decadeTableUI
get_table_description <- function(func_name) {
  # TODO: EXTRACT REPEATED STRINGS.
  switch(func_name,
    max = c(
      "<br><p>The table presents yearly indicator data aggregated by decade.</p>",
      "<p>The calculations are based on the indicator values from the",
      "<b>final year</b> of each decade.</p>"
    ),
    mean = c(
      "<br><p>The table presents yearly indicator data aggregated by decade.</p>",
      "<p>The calculations were performed using the ",
      "<b>arithmetic mean</b> of the indicator values.</p>"
    ),
    geometric.mean = c(
      "<br><p>The table presents yearly indicator data aggregated by decade.</p>",
      "<p>The calculations were performed using the ",
      "<b>geometric mean</b> of the indicator values transformed into growth factors.</p>"
    ),
    weighted.mean = c(
      "<br><p>The table presents yearly indicator data aggregated by decade.</p>",
      "<p>The calculations were performed using the ",
      "<b>weighted mean</b> of the indicator values, weighted by the relevant population data.</p>"
    ),
    none = c("<br><p>Aggregated data are not available for this indicator.")
  )
}
# nolint end
# nocov end
