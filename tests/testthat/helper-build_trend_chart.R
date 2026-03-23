standarize_chart <- function(chart) {
  chart$x$visdat <- NULL
  chart$x$cur_data <- "proxy"
  names(chart$x$attrs) <- c("proxy", "proxy")
  names(chart$x$layoutAttrs) <- "proxy"
  chart
}

test_dt_list <- list(
  countryX = data.frame(
    time = c(1, 2, 3, 4, 5, 6),
    value = c(100, 200, 300, 400, 500, 600)
  )
)
test_color_theme <- list(
  series = "blue",
  legend = "green"
)
test_layout_config <- list(
  title = "Chart Tile",
  yrange = range(test_dt_list[[1]]$value)
)
