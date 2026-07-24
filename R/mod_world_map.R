#' World map Shiny module
#'
#' Provides UI and server logic for a `leaflet` class world map.
#'
#' @param id Module ID. Check [shiny::NS()] for more details.
#' @param indic_id A `reactive` object containing string with a data indicator
#'   id.
#' @param data_pair A list containing pair of country data - geometry (a list
#'   of `sf` data frames) and labels.
#' @export
worldMapUI <- function(id) {
  leaflet::leafletOutput(shiny::NS(id, "map"))
}

#' @rdname worldMapUI
#' @export
worldMapServer <- function(id, indic_id, data_pair) {
  assert_reactive(indic_id)
  assert_with(
    checkmate::assert_vector, data_pair, assert_len2_args()
  )

  invisible(lapply(data_pair[1:2], assert_reactive))
  geometry_data <- data_pair[[1]]
  label_data <- data_pair[[2]]

  shiny::moduleServer(id, function(input, output, session) {
    output$map <- leaflet::renderLeaflet({
      run_validate_need(!is_empty(indic_id()))
      shiny::req(label_data())

      build_world_map(
        geometry_data(),
        make_map_color_theme()
      ) %>%
        add_js_code(shiny::getCurrentOutputInfo()$name)
    })
  })
}
