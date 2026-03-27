#' Extract a range values from a list of data tables
#'
#' Finds range values for a given column from a list of data tables.
#'
#' @details
#' **`config`** list needs to have maximum two elements. First element
#' is mandatory and contains a column name for which range will be calculated.
#' Second element is optional and contains filtering details - column name and
#' condition values.
#'
#' @param data_list A list containing objects that can be coerced to
#'   `data.table`.
#' @param config A list with a configuration data (see Details).
#' @param data_object An object that can be coerced to `data.table`.
#' @param col_name A character string with a column name for which data table
#'   operation will be conducted.
#' @return A vector containing a pair of numeric values - minimum and maximum.
#' @export
extract_dt_list_range <- function(data_list, config) {
  assert_with(checkmate::assert_list, data_list, assert_named_args())
  assert_with(checkmate::assert_list, config, assert_args())

  data.table::rbindlist(data_list) %>%
    {
      if (length(config) == 2) {
        select_in_dt(., config[[2]][[1]], config[[2]][[2]])
      } else {
        .
      }
    } %>%
    get_dt_range(config[[1]])
}

#' @rdname extract_dt_list_range
#' @export
get_dt_range <- function(data_object, col_name) {
  checkmate::assert_string(col_name)
  dt <- try_coerce_to_dt(data_object)
  checkmate::assert_names(names(dt), must.include = col_name)

  dt[, range(get(col_name), na.rm = TRUE)]
}

#' Coerce to `data.table`
#'
#' Tries to coerce given data to `data.table` object.
#'
#' @details
#' Please check [data.table::as.data.table()] for more details.
#'
#' @inheritParams extract_dt_list_range
#' @keywords internal
#' @noRd
try_coerce_to_dt <- function(data_object) {
  tryCatch(
    data.table::as.data.table(data_object),
    error = function(e) {
      stop(
        "Coercion 'data_object' to data table failed with the error message:\n",
        e$message,
        call. = FALSE
      )
    }
  )
}

#' Filter data table rows using `%in%` operator
#'
#' Selects data table rows that are `%in%` the expected values for
#'   the given column.
#'
#' @inheritParams extract_dt_list_range
#' @param target_values A vector containing expected values.
#' @return A data table with selected rows.
#' @export
select_in_dt <- function(data_object, col_name, target_values) {
  checkmate::assert_string(col_name)
  dt <- try_coerce_to_dt(data_object)
  checkmate::assert_names(names(dt), must.include = col_name)
  checkmate::assert_vector(target_values)

  dt[get(col_name) %in% target_values]
}

#' Extract data that are in the trend chart
#'
#' Extracts current data that are shown in the trend chart UI.
#'
#' @details
#' **`config`** list needs to have exact two elements. First element
#' is a column name which will be used as `idcol` in [data.table::rbindlist]
#' when creating the long format data. Second element is a filtering details
#' - column name and condition values.
#'
#' @inheritParams extract_dt_list_range
#' @return A data table with the filtered trends chart data in the long format.
#' @export
extract_trends_chart_dt <- function(data_list, config) {
  assert_with(checkmate::assert_list, data_list, assert_named_args())
  assert_with(checkmate::assert_list, config, assert_len2_args())

  data.table::rbindlist(data_list, use.names = TRUE, idcol = config[[1]]) %>%
    select_in_dt(., config[[2]][[1]], config[[2]][[2]])
}

#' Convert a data table to character string or JSON format
#'
#' Converts a data table to character string or JSON format.
#'
#' @inheritParams extract_dt_list_range
#' @return A `character` string or `json` object.
#' @export
convert_dt_to_string <- function(data_object) {
  dt <- try_coerce_to_dt(data_object)

  capture.output(
    write.csv(dt, row.names = FALSE, na = "", quote = TRUE)
  ) %>% paste(collapse = "\n")
}

#' @rdname convert_dt_to_string
#' @export
convert_dt_to_json <- function(data_object) {
  dt <- try_coerce_to_dt(data_object)

  jsonlite::toJSON(
    dt, dataframe = "rows", pretty = FALSE, auto_unbox = TRUE, na = "null"
  )
}

#' Source a weight data from one data table to another
#'
#' Extracts "value" column as "weight" from one indicator data table to another
#' using "country_id" and "time_period" as merge controls.
#'
#' @details
#' **`data_pair`** list needs to have exactly two elements. Both elements have
#' to be a named lists with the indicator data tables per country. Data tables
#' have to contain the same columns. The second element is always used as
#' a "giver" and the first one is always "receiver".
#'
#' @param data_pair A list containing pair of indicator data (see Details).
#' @return The "receiver" list containing the same number of elements, but with
#'   added column "weight" to each.
source_weight <- function(data_pair) {
  # TODO: CREATE A NEW S3 CLASSES FOR THE PARAM?
  assert_with(checkmate::assert_list, data_pair, check_len2_args())
  checkmate::assert_names(
    names(data_pair[[1]]),
    identical.to = names(data_pair[[2]])
  )

  mapply(function(dt1, dt2) {
    data.table::setnames(dt2, "value", "weight")
    dt1[dt2, on = .(country_id, time_period), nomatch = 0]
  }, data_pair[[1]], data_pair[[2]], SIMPLIFY = FALSE)
}

#' Make and apply an aggregation function
#'
#' Prepares and applies the aggregation strategy that transforms the annual
#'   country indicator data into decades.
#'
#' @details
#' **`create_decade_aggregator`** utilizes `aggregation_params` to create the
#' aggregation strategy (function) which will convert the annual country
#' indicator data into a ten-year summary. The aggregation function needs an
#' object that can be coerced to `data.table` as an input.
#' **`run_aggregation_pipeline`** applies the aggregation strategy to the list
#' of data tables, merges them together and reshapes from long to wide format.
#' Returns a single `data.table` with the aggregated data per country and
#' decade.
#'
#' @param aggregation_params A list containing the function name that will be
#'   used for the aggregation and the column name on which the calculation will
#'   be performed.
#' @param aggregation_strategy A function which is a relevant aggregation
#'   strategy.
#' @param data_list A list on which aggregation strategy will be used. It should
#'   contain `data.table` objects.
#'
#' @return See Details.
create_decade_aggregator <- function(aggregation_params) {
  # TODO: ADD ASSERTIONS.

  aux_func <- match.fun(aggregation_params$function_name)
  aux_col <- aggregation_params$column_name

  # TODO: EXTRACT REPEATED CODE.
  aggregation_strategy <- switch(aggregation_params$function_name,
    max = {
      function(data_object) {
        data.table::as.data.table(data_object) %>%
          .[, Decade := paste0((time_period %/% 10) * 10, "s")] %>%
          .[,
            .(value = value[
              get(aux_col) == aux_func(get(aux_col), na.rm = TRUE)
            ]),
            by = .(Decade, country_id)
          ]
      }
    },
    mean = {
      function(data_object) {
        data.table::as.data.table(data_object) %>%
          .[, Decade := paste0((time_period %/% 10) * 10, "s")] %>%
          .[,
            .(value = aux_func(get(aux_col), na.rm = TRUE)),
            by = .(Decade, country_id)
          ]
      }
    },
    geometric.mean = {
      function(data_object) {
        data.table::as.data.table(data_object) %>%
          .[, Decade := paste0((time_period %/% 10) * 10, "s")] %>%
          .[, value := 1 + get(aux_col) / 100] %>%
          .[,
            .(value = aux_func(get(aux_col), na.rm = TRUE)),
            by = .(Decade, country_id)
          ] %>%
          .[, value := (get(aux_col) - 1) * 100]
      }
    },
    weighted.mean = {
      function(data_object) {
        data.table::as.data.table(data_object) %>%
          .[, Decade := paste0((time_period %/% 10) * 10, "s")] %>%
          .[,
            .(value = aux_func(get(aux_col), weight, na.rm = TRUE)),
            by = .(Decade, country_id)
          ]
      }
    }
  )

  function(data_object) {
    aggregation_strategy(
      copy(try_coerce_to_dt(data_object))
    )
  }
}

#' @rdname create_decade_aggregator
#' @export
run_aggregation_pipeline <- function(aggregation_strategy, data_list) {
  # TODO: ADD ASSERTIONS.

  lapply(data_list, aggregation_strategy) %>%
    data.table::rbindlist(use.names = TRUE, idcol = "country_name") %>%
    .[, country_name := factor(country_name, levels = unique(country_name))] %>%
    data.table::dcast(
      Decade ~ country_name,
      value.var = "value"
    )
}
