#' Make SQL table column names in qualified format
#'
#' Converts SQL table column names to a qualified column name format.
#'
#' @param db_schema A named list with SQL table names as the list element names
#'   and column names as the list elements (character vectors).
#' @return A named list with SQL table names as the list element names and
#'   column names, in a qualified column name format, as the list elements
#'   (character vectors).
#' @export
#' @examples
#' new_db_schema <- list(
#'   table_name1 = c("col1", "col2", "col3"),
#'   table_name2 = c("col1", "col4")
#' )
#' make_sql_qualified_columns(new_db_schema)
make_sql_qualified_columns <- function(db_schema) {
  checkmate::assert_list(
    db_schema,
    names = "named", any.missing = FALSE, all.missing = FALSE
  )

  for (table_name in names(db_schema)) {
    db_schema[[table_name]] <- paste(
      table_name, db_schema[[table_name]],
      sep = "."
    )
  }
  db_schema
}

# nocov start
#' Get a list of `reactiveValues` and `reactiveVal` objects in their initial
#'   state
#'
#' @details
#' Returned objects are used for storing a different types of data:
#' * "chart_active_data" (`reactiveVal`)
#' A named list of indicator data for the countries selected on the world map.
#' The data are used for the trend chart and the decades table.
#'
#' * "chart_active_data_range" (`reactiveValues`)
#' A two element object of data ranges for the trend chart.
#' "absolute" (default) contains set of ranges extracted directly from the data.
#' "current" (user modified) is based on user selection. Both sets of ranges
#' consist two pairs of numeric values. One pair for x-axis and one pair for
#' y-axis.
#'
#' * "chart_export_btn_click" (`reactiveVal`)
#' A three element named integer vector of the user clicks on the export buttons
#' for the trend chart.
#'
#' * "chart_with_one_trace" (`reactiveVal`)
#' A `plotly` base trend chart with only one data trace.
#'
#' * "map_available_color" (`reactiveVal`)
#' A character vector of colors in HEX format that is be used to mark countries
#' selected on the world map.
#'
#' * "map_click_registry" (`reactiveValues`)
#' A three element object of country lists.
#' "active" - active countries, i.e. countries that are currently selected on
#' the world map.
#' "add" - a country that needs to be added to the trend chart and
#' the decades table.
#' "remove" - a country that needs to be removed from the the trend chart and
#' the decades table.
#' In all cases country is identified by its ISO code (id) and name (label).
#'
#' * "sql_db_schema" (`reactiveVal`)
#' A named list used to extract data from MySQL database. Please check [DbDataExtractor()]
#' and [get_app_settings()] for more details.
#'
#' * "table_aggregation_params" (`reactiveVal`)
#' A two element named list with a function and a column names that will be used
#' in the decades table.Please check [decadeTableServer] for more details.
#'
#' * "table_weight_data" (`reactiveVal`)
#' A named list of weight data for the countries selected on the world map.
#' The data are used with the relevant indicators for the decades table.
#'
#' * "ui_render_flag" (`reactiveVal`)
#' A single Boolean value that indicates whether the trend chart and the decades
#' table should be rendered.
#'
#' @param app_settings A list of predefined app settings (see
#'   [get_app_settings()]).
#' @return A named list of `reactiveVal` and `reactiveValues` objects in their
#'   initial state. See Details.
#' @keywords internal
#' @noRd
get_reactive_values_init <- function(app_settings = get_app_settings()) {
  aux_export_types <- names(app_settings$export_types)

  list(
    chart_active_data = shiny::reactiveVal(),
    chart_active_data_range = shiny::reactiveValues(
      absolute = list(x = NULL, y = NULL),
      current = list(x = NULL, y = NULL)
    ),
    chart_export_btn_click = shiny::reactiveVal(
      setNames(
        rep(0, length(aux_export_types)), aux_export_types
      )
    ),
    chart_with_one_trace = shiny::reactiveVal(),
    map_available_color = shiny::reactiveVal(
      app_settings$color_palette$category
    ),
    map_click_registry = shiny::reactiveValues(
      active = list(), add = list(), remove = list()
    ),
    sql_db_schema = shiny::reactiveVal(),
    table_aggregation_params = shiny::reactiveVal(),
    table_weight_data = shiny::reactiveVal(),
    ui_render_flag = shiny::reactiveVal(FALSE)
  )
}

#' Get a list of functions responsible for updating value of `reactiveValues`
#'   and `reactiveVal` objects
#'
#' @keywords internal
#' @noRd
get_reactive_values_updt <- function() {
  list(
    sql_db_schema = update_db_schema,
    table_aggregation_params = update_aggregation_specs
  )
}

#' Get a list of initial values for `reactiveValues` and `reactiveVal` objects
#'
#' @inheritParams get_reactive_values_init
#' @keywords internal
#' @noRd
get_reactive_values_reset <- function(app_settings = get_app_settings()) {
  aux_export_types <- names(app_settings$export_types)

  list(
    chart_active_data = list(),
    chart_active_data_range = list(x = NULL, y = NULL),
    chart_export_btn_click = setNames(
      rep(0, length(aux_export_types)), aux_export_types
    ),
    chart_with_one_trace = NULL,
    map_available_color = app_settings$color_palette$category,
    map_click_registry = list(),
    sql_db_schema = NULL,
    table_aggregation_params = NULL,
    table_weight_data = list(),
    ui_render_flag = FALSE
  )
}
# nocov end

#' @title Reactive values objects initialization manager
#'
#' @description
#' Initiates reactive values predefined in `get_reactive_values_init()`.
#'
#' @export
ReactiveValuesManager <- R6::R6Class(
  "ReactiveValuesManager",
  private = list(
    # A list of `reactiveValues` and `reactiveVal` objects in their
    # initial state.
    .init_objects = NULL,
    # A list of functions responsible for updating value of `reactiveValues`
    # and `reactiveVal` objects.
    .updt_functions = NULL,
    # A list of initial values for `reactiveValues` and `reactiveVal` objects.
    .reset_values = NULL
  ),
  public = list(
    #' @description
    #' Creates a new manager object.
    #'
    #' @return A new `ReactiveValuesManager` object.
    initialize = function() {
      private$.init_objects <- get_reactive_values_init()
      private$.updt_functions <- get_reactive_values_updt()
      private$.reset_values <- get_reactive_values_reset()
    },
    #' @description
    #' Retrieves target reactive object initial value.
    #'
    #' @param key A string that is a name in the `.init_objects` list.
    #' @return A `reactiveValues` or `reactiveVal` object.
    get_init = function(key) {
      private$.init_objects[[key]]
    },
    #' @description
    #' Updates target reactive object value.
    #'
    #' @param key A string that is a name in the `.init_objects` list.
    #' @return A function responsible for updating `reactiveValues`
    #'   or `reactiveVal` object value.
    update = function(key) {
      private$.updt_functions[[key]]
    },
    #' @description
    #' Reset target reactive object value.
    #'
    #' @param key A string that is a name in the `.init_objects` list.
    #' @return An initial value for `reactiveValues` or `reactiveVal` object.
    reset = function(key) {
      private$.reset_values[[key]]
    }
  ),
  active = list(
    #' @field init_objects A read only list of `reactiveValues`
    #'   and `reactiveVal` objects in their initial state.
    init_objects = function(value) {
      if (!missing(value)) {
        stop("'init_objects' is read only.", call. = FALSE)
      }
      private$.init_objects
    }
  )
)

#' Update `sql_db_schema()`
#'
#' Substitutes old table names in `sql_db_schema()` with a new ones. The names
#'   pinpoint to the database tables related to the selected data indicator.
#'
#' @param indic_id A string with a data indicator id.
#' @param weight_id A string with a data weight id. If `NULL` no additional data
#'   are extracted in order to perform the indicator data aggregation. Default
#'   value is provided by [set_id_aggr_indicators()].
#' @param db_schema A named list of length four. It contains SQL table names as
#'   the list element names and column names, in a qualified column name
#'   format, as the list elements (character vectors).
#'   Please check [make_sql_qualified_columns()] and [set_db_schema_registry()]
#'   for details about the default value.
#' @return An updated version of `db_schema` with replaced strings in
#'   the list names and related elements. It can be one element shorter than
#'   initial list if `weight_id` was `NULL`.
#' @examples
#' \dontrun{
#' old_db_schema <- list(
#'   table_name1 = c(
#'     "table_name1.col1", "table_name1.col2", "table_name1.col3"
#'   ),
#'   table_name2 = c(
#'     "table_name2.col1", "table_name2.col4"
#'   ),
#'   table_name3 = c(
#'     "table_name3.col1", "table_name3.col2", "table_name3.col3"
#'   ),
#'   table_name4 = c(
#'     "table_name4.col7"
#'   )
#' )
#' update_db_schema("table_name99", NULL, old_db_schema)
#' }
update_db_schema <- function(
  indic_id,
  weight_id = set_id_aggr_indicators()[[indic_id]]$weight_source,
  db_schema = make_sql_qualified_columns(
    set_db_schema_registry()$world_trends
  )
) {
  checkmate::assert_string(indic_id)
  checkmate::assert_string(weight_id, null.ok = TRUE)
  assert_with(
    checkmate::assert_list,
    db_schema,
    c(list(len = 4), assert_named_args())
  )

  target_names <- names(db_schema)[3:4]
  update_pairs <- setNames(list(indic_id, weight_id), target_names)

  for (aux_name in target_names) {
    aux_value <- update_pairs[[aux_name]]

    if (!is_empty(aux_value)) {
      db_schema[[aux_value]] <- gsub(
        aux_name, aux_value, db_schema[[aux_name]]
      )
    }
    db_schema[[aux_name]] <- NULL
  }

  db_schema
}

#' Update `table_aggregation_params()`
#'
#' Selects new set of aggregation parameters for `table_aggregation_params()`
#'   base on the indicator id.
#'
#' @inheritParams update_db_schema
#' @param aggregation_params A named list with the aggregation function name,
#'   target column name and optionally weight data source (database table name).
#'   Default values are provide by [set_id_aggr_indicators()].
#' @return A named list containing aggregation parameters.
update_aggregation_specs <- function(
  indic_id,
  aggregation_params = set_id_aggr_indicators()[[indic_id]]
) {
  aggregation_params
}

#' Remove a list element by name
#'
#' Removes an element from a named list. It is mainly used as a helper
#'   for updating `reactiveVal` objects that hold a list inside.
#'
#' @param list_object A named list.
#' @param elem_name A name of the element to remove.
#' @return A named list with removed element.
#' @export
remove_list_elem <- function(list_object, elem_name) {
  assert_with(checkmate::assert_list, list_object, assert_named_args())
  checkmate::assert_string(elem_name)

  list_object[[elem_name]] <- NULL
  list_object
}
