#' Build a world map
#'
#' Generates a clickable `leaflet` class world map to use with the trends
#'   data.
#'
#' @details
#' Utilizes collection of functions trough the pipeline. Each "add_" function
#' appends relevant layer do the map object. Each "set_" function is responsible
#' for polygon options configuration.
#'
#' **`data_list`** list needs to contain at least two elements - "clickable"
#' and "notclickable". Each of this elements is expected to be a data frame with
#' exact three columns:
#' * "id" - integer, ISO 3166-1 numeric (or numeric-3) country codes.
#' * "label" - character, country names.
#' * "geometry" - `sfc` (simple feature collection) class object of MULTIPOLYGON
#' country geometries.
#'
#' **`color_theme`** list needs to contain at least two elements - "clickable"
#' and "notclickable". Each of this elements is expected to be a list with
#' color definition for polygon "stroke", "fill" and "highlight_stroke".
#'
#' @param data_list A named list of `sf`data frames (see Details).
#' @param color_theme A named list of color themes (see Details).
#' @param map A `leaflet` class object created using [leaflet::leaflet()].
#' @param sf_data An `sf` data frame (see Details).
#' @param stroke_color A string with a stroke color for polygon highlights.
#' @return An HTML Widget object containing `leaflet` map. Please check
#'   [leaflet](https://rstudio.github.io/leaflet/reference/leaflet.html)
#'   for more details.
#' @export
build_world_map <- function(data_list, color_theme) {
  checkmate::assert_list(data_list, min.len = 2, names = "named")
  checkmate::assert_names(
    names(data_list),
    identical.to = set_data_labels()$world_trends
  )
  checkmate::assert_list(color_theme, min.len = 2, names = "named")
  checkmate::assert_names(
    names(color_theme),
    identical.to = set_data_labels()$world_trends
  )

  create_base_map() %>%
    add_bounds() %>%
    add_view() %>%
    add_clickable_polygons(data_list$clickable, color_theme$clickable) %>%
    add_notclickable_polygons(
      data_list$notclickable, color_theme$notclickable
    ) %>%
    add_reset_button()
}

#' @rdname build_world_map
create_base_map <- function() {
  leaflet::leaflet(
    options = leaflet::leafletOptions(minZoom = 1, maxZoom = 6, tap = FALSE)
  )
}

#' @rdname build_world_map
add_bounds <- function(map) {
  leaflet::setMaxBounds(map, -180, -90, 180, 90)
}

#' @rdname build_world_map
add_view <- function(map) {
  leaflet::setView(map, lng = 14.4378, lat = 50.0755, zoom = 3)
}

#' @rdname build_world_map
add_clickable_polygons <- function(map, sf_data, color_theme) {
  assert_polygon_data(sf_data)
  checkmate::assert_list(color_theme, len = 3, names = "named")
  checkmate::assert_names(
    names(color_theme),
    identical.to = c("stroke", "fill", "highlight_stroke")
  )

  leaflet::addPolygons(
    map,
    data = sf_data,
    color = color_theme$stroke,
    weight = 1,
    opacity = 1,
    fillColor = color_theme$fill,
    fillOpacity = 1,
    layerId = ~id,
    label = ~label,
    labelOptions = set_label_options(),
    highlightOptions = set_highlight_options(color_theme$highlight_stroke)
  )
}

#' @rdname build_world_map
add_notclickable_polygons <- function(map, sf_data, color_theme) {
  assert_polygon_data(sf_data)
  checkmate::assert_list(color_theme, len = 3, names = "named")
  checkmate::assert_names(
    names(color_theme),
    identical.to = c("stroke", "fill", "highlight_stroke")
  )

  leaflet::addPolygons(
    map,
    data = sf_data,
    color = color_theme$stroke,
    weight = 1,
    opacity = 1,
    fillColor = color_theme$fill,
    fillOpacity = 1,
    label = "Data N/A",
    labelOptions = set_label_options(),
    highlightOptions = color_theme$highlight_stroke
  )
}

#' @rdname build_world_map
set_label_options <- function() {
  leaflet::labelOptions(
    interactive = TRUE,
    noHide = FALSE,
    sticky = TRUE,
    direction = "top",
    textOnly = FALSE,
    textsize = "15px"
  )
}

#' @rdname build_world_map
set_highlight_options <- function(stroke_color) {
  leaflet::highlightOptions(
    stroke = TRUE,
    color = stroke_color,
    weight = 3,
    bringToFront = TRUE
  )
}

#' @rdname build_world_map
add_reset_button <- function(map) {
  leaflet::addEasyButton(
    map,
    leaflet::easyButton(
      id = "world_trends-map_reset_btn",
      icon = shiny::icon("eraser", lib = "font-awesome"),
      title = "Reset country selection",
      onClick = htmlwidgets::JS(
        "function(btn, map) {
          Shiny.setInputValue('reset_selection', true, {priority:'event'});
        }"
      )
    )
  )
}

#' Make map color theme
#'
#' Makes a color theme to use in the world map polygons.
#'
#' @param color_palette A named list of colors used in the app. Default values
#'   are provided by [set_color_palette()]
#' @param target_names A character vector with element names for the color
#'   theme.
#' @return A named list with a color theme for "clickable" and "notclickable"
#'   map polygons.
#' @export
make_map_color_theme <- function(
  color_palette = set_color_palette(),
  target_names = c("stroke", "fill", "highlight_stroke")
) {
  # TODO: ADD ASSERTIONS.

  list(
    clickable = setNames(
      unname(color_palette[c("stroke", "base", "base_dk")]), target_names
    ),
    notclickable = setNames(
      unname(color_palette[c("stroke", "neutral", "empty")]), target_names
    )
  )
}
