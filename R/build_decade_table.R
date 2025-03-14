#' Build a trend table
#'
#' Generates a `datatables` class table to show trend data aggregated to decades
#'   for the selected indicator and countries.
#'
#' @details
#' Utilizes collection of functions trough the pipeline. Each "add_" function
#' appends relevant layer do the table object. Each "set_" function is
#' responsible for relevant configuration options.
#'
#' @param data_object A data object - either a matrix, data frame or data table.
#' @param table A `datatables` class object created using [DT::datatable()].
#' @return An HTML Widget object containing `datatables` table. Please check
#'   [DT](https://rstudio.github.io/DT/) for more details.
#' @export
build_decade_table <- function(data_object) {
  create_base_table(data_object) %>%
    add_format_style()
}

#' @rdname build_decade_table
create_base_table <- function(data_object) {
  DT::datatable(
    data_object,
    rownames = FALSE,
    escape = FALSE,
    options = set_base_options()
  )
}

#' @rdname build_decade_table
set_base_options <- function() {
  list(
    searching = FALSE,
    lengthChange = FALSE,
    info = FALSE,
    paging = FALSE,
    columnDefs = list(
      list(className = "dt-tcontent-center", targets = "_all")
    )
  )
}

#' @rdname build_decade_table
add_format_style <- function(table) {
  DT::formatStyle(table, "Decade", fontWeight = "bold")
}
