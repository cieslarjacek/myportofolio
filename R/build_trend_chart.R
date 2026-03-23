#' Build a trends chart
#'
#' Generates a `plotly` class chart to show trend data for the selected
#'   indicator and countries.
#'
#' @details
#' Utilizes collection of functions trough the pipeline. Each "add_" function
#' appends relevant layer do the trend chart object. Each "set_" function is
#' responsible for relevant configuration options.
#'
#' **`dt_list`** list needs to contain only one element - a data table with
#' a values to plot. The name of the element is a country label (name).
#'
#' **`color_theme`** list needs to contain two elements - "series"
#' and "legend". "series" is a color for the trend chart series line
#' and marker. "legend" is a color for the trend chart legend background
#' and border.
#'
#' **`layout_config`** list needs to contain two elements - "title"
#' and "yrange". "title" is the trend chart title (and data indicator name).
#' "yrange" is a pair of integers - initial real (no extra padding) minimum
#' and maximum values of y-axis.
#'
#' @param dt_list A named list with a data table (see Details).
#' @param color_theme A named list of color themes (see Details).
#' @param layout_config A named list of layout configuration (see Details).
#' @param chart A `plotly` class object created using [plotly::plot_ly()].
#' @param series_color A string with a line and marker color for
#'   the trend chart series.
#' @param legend_color A string with a background and border color for
#'   the trend chart legend.
#' @return An HTML Widget containing `plotly` chart. Please check
#'   [plotly](https://www.rdocumentation.org/packages/plotly/topics/plot_ly)
#'   for more details.
#' @export
build_trend_chart <- function(dt_list, color_theme, layout_config) {
  # TODO: CREATE A NEW S3 CLASSES FOR THE PARAMS?
  checkmate::assert_list(dt_list, len = 1, names = "named")
  checkmate::assert_list(color_theme, len = 2, names = "named")
  checkmate::assert_names(
    names(color_theme),
    identical.to = c("series", "legend")
  )

  create_base_chart() %>%
    add_series(dt_list, color_theme$series) %>%
    add_layout(layout_config, color_theme$legend) %>%
    add_config() %>%
    add_event_register()
}

#' @rdname build_trend_chart
create_base_chart <- function() {
  plotly::plot_ly(source = "wt_chart")
}

#' @rdname build_trend_chart
get_series_args <- function(dt_list, series_color) {
  data_label <- names(dt_list)
  data_values <- dt_list[[data_label]]

  list(
    x = data_values$time_period,
    y = data_values$value,
    name = data_label,
    meta = data_label,
    type = "scatter",
    mode = "lines+markers",
    line = list(color = series_color, width = 3),
    marker = list(color = series_color),
    hovertemplate = paste(
      "<b>%{meta}</b><br>",
      "%{x}: %{y}",
      "<extra></extra>"
    )
  )
}

#' @rdname build_trend_chart
add_series <- function(chart, dt_list, series_color) {
  do.call(
    plotly::add_trace, c(list(chart), get_series_args(dt_list, series_color))
  )
}

#' @rdname build_trend_chart
add_layout <- function(chart, layout_config, legend_color) {
  checkmate::assert_list(layout_config, len = 2, names = "named")
  checkmate::assert_names(
    names(layout_config),
    identical.to = c("title", "yrange")
  )

  plotly::layout(
    chart,
    hovermode = "x",
    showlegend = TRUE,
    legend = list(
      orientation = "h",
      x = 0.5,
      xanchor = "center",
      yanchor = "top",
      bgcolor = legend_color,
      bordercolor = legend_color
    ),
    title = list(
      text = layout_config$title,
      x = 0,
      xanchor = "left",
      y = 1
    ),
    xaxis = list(
      title = "Year", dtick = 2, tickmode = "linear",
      rangeslider = list(visible = TRUE)
    ),
    yaxis = list(
      title = list(standoff = 0, font = list(size = 1)),
      range = create_yrange(layout_config$yrange)
    ),
    margin = list(l = 35, r = 10, t = 40, b = 20, pad = 0)
  )
}

#' @rdname build_trend_chart
add_config <- function(chart) {
  plotly::config(
    chart,
    modeBarButtonsToRemove = set_plotly_remove_btns()
  )
}

#' @rdname build_trend_chart
add_event_register <- function(chart) {
  plotly::event_register(chart, "plotly_relayout")
}

#' @rdname build_trend_chart
set_plotly_remove_btns <- function() {
  c(
    "toImage",
    "zoom2d",
    "pan2d",
    "select2d",
    "lasso2d",
    "zoomIn2d",
    "zoomOut2d",
    "autoScale2d"
  )
}

#' Create chart color theme
#'
#' Makes a color theme to use in the trends chart series and legend.
#'
#' @param series_color A string that defines the trend chart series line
#'   and marker colors.
#' @param legend_color A string that defines the trend chart legend
#'   background and border colors. Default value is provided by
#'   [set_color_palette()].
#' @return A named list with a color theme for the trend chart series
#'   and legend.
#' @export
create_chart_color_theme <- function(
  series_color, legend_color = set_color_palette()$transparent
) {
  list(
    series = series_color,
    legend = legend_color
  )
}

#' Create chart configuration
#'
#' Makes a configuration list to use in the trends chart layout.
#'
#' @param indic_id A string with a data indicator id.
#' @param initial_range A vector containing a pair of integers where
#'   the first element is the data range real minimum
#'   and the second is the real maximum.
#' @param indic_name A string with a data indicator "human friendly" name.
#'   Default values are extracted from [set_name_id_indicators()].
#' @return A named list with a configuration for the trend chart layout.
#' @export
create_chart_config <- function(
  indic_id,
  initial_range,
  indic_name = names(
    which(set_name_id_indicators() == indic_id)
  )
) {
  # TODO: CREATE A NEW S3 CLASS FOR "range" PARAM?
  list(
    title = indic_name,
    yrange = initial_range
  )
}

#' Extract trends chart download button click
#'
#' Finds out which download button exactly was clicked by comparing current
#'   click info to stored click data.
#'
#' @param click_set A list containing two elements. Both are named vectors with
#'   data about clicks. The first element is current click count and the second
#'   one is a snapshot of the previous click count.
#' @return A string (name) identifying clicked button.
#' @export
#' @examples
#' new_clicks <- setNames(c(3, 2, 4), c("n1", "n2", "n3"))
#' old_clicks <- setNames(c(3, 2, 3), c("n1", "n2", "n3"))
#'
#' extract_download_btn_click(list(new_clicks, old_clicks))
extract_download_btn_click <- function(click_set) {
  # TODO: CREATE A NEW S3 CLASS FOR "click_set" PARAM?
  checkmate::assert_list(click_set, len = 2)

  current_clicks <- click_set[[1]]
  previous_clicks <- click_set[[2]]
  checkmate::assert_names(
    names(current_clicks),
    identical.to = names(previous_clicks)
  )

  (current_clicks - previous_clicks) %>%
    which.max(.) %>%
    names(.)
}

#' Make trends chart download file name
#'
#' Creates a name for a download file that contains the trend chart data.
#'
#' @param name_root A string containing the root of the file name.
#'   I.e. World Bank data indicator name.
#' @param name_prefix A string containing the prefix of the file name.
#'   I.e. current system date in "YYYYMMDD" format.
#' @return A string that is the file name.
#' @export
#' @examples
#' make_download_file_name("Unemployment (%, 15 yo and over, modeled)")
make_download_file_name <- function(
  name_root, name_prefix = format(Sys.Date(), "%Y%m%d")
) {
  checkmate::assert_string(name_root, min.chars = 1)
  paste0(name_prefix, "_", str_to_underscore_case(name_root))
}
