# TODO: Convert it to R6 class maybe.
# nocov start
# nolint start
#' Get list of predefined app settings
#'
#' @details
#' `get_app_settings()` returns a named list containing a multiple elements with
#' a data that are used across the whole app. Each element is created by the
#' related "set_" function.
#'
#' * "app_component" is a character vector of component sub-directories.
#' * "color_palette" is a named list of colors.
#' * "data_labels" is a character vector of selected data labels.
#' * "db_schema_registry" is a named list with SQL table names as
#' the list element names and column names as the list elements
#' (character vectors).
#' * "export_types" is a named character vector where the element names are
#' data export format types (e.g. png, csv, json) and the elements are related
#' labels (e.g. "CSV data").
#' * "secret_names" is a character vector of secret names in the vault which
#' are also environment variables during local run.
#' * "worldbank_indicator$name_id" is a named list where the elements are
#' data indicator ids and the element names are indicator "human friendly"
#' names.
#' * "worldbank_indicator$id_aggr" is a named list where the elements are
#' the data indicator aggregation parameters (see `target_names` description)
#' and the element names are data indicator ids.
#'
#' @param ... A character vector of length two or three containing elements for
#'   aggregation parameters list.
#' @param target_names A character vector containing element names for
#'   aggregation parameters list - the aggregation function name, target
#'   column name and optionally weight data source (database table name).
#'   Default is `c("function_name", "column_name", "weight_source")`.
#' @param length_range A named integer vector containing information about
#'   minimum and maximum number of aggregation parameters.
#'   Default is `setNames(c(2, 3), c("min", "max"))`.
#' @export
get_app_settings <- function() {
  list(
    app_component = set_app_components(),
    color_palette = set_color_palette(),
    data_labels = set_data_labels(),
    db_schema_registry = set_db_schema_registry(),
    export_types = set_export_types(),
    secret_names = set_secret_names(),
    worldbank_indicator = list(
      name_id = set_name_id_indicators(),
      id_aggr = set_id_aggr_indicators()
    )
  )
}

#' @rdname get_app_settings
set_app_components <- function() {
  c("main", "dashboard", "cicd", "etl")
}

#' @rdname get_app_settings
set_color_palette <- function() {
  list(
    base = "floralwhite",
    base_dk = "orange",
    primary = "navy",
    primary_lt = "dodgerblue",
    stroke = "black",
    neutral = "grey",
    transparent = "rgba(0,0,0,0)",
    category = c(
      "#1858bbff", "#0a8d91ff", "#4eae3eff", "#fdc10fff", "#e63831ff"
    ),
    empty = NULL
  )
}

#' @rdname get_app_settings
set_data_labels <- function() {
  list(
    "world_trends" = c("clickable", "notclickable")
  )
}

#' @rdname get_app_settings
set_db_schema_registry <- function() {
  list(
    world_trends = list(
      country = c("id", "name", "iso_a3", "label"),
      world_geo = c("country_id", "geometry"),
      wb_dummy_indicator_id = c("country_id", "time_period", "value"),
      wb_dummy_weight_id = c("country_id", "time_period", "value")
    )
  )
}

#' @rdname get_app_settings
set_export_types <- function() {
  setNames(
    c("PNG image", "CSV data", "JSON data"), c("png", "csv", "json")
  )
}

#' @rdname get_app_settings
set_name_id_indicators <- function() {
  list(
    `Total Population` = "wb_wdi_sp_pop_totl",
    `Population ages 0-14, total` = "wb_wdi_sp_pop_0014_to",
    `GDP (current US$)` = "wb_wdi_ny_gdp_mktp_cd",
    `GDP per capita (current US$)` = "wb_wdi_ny_gdp_pcap_cd",
    `GDP, PPP (current international $)` = "wb_wdi_ny_gdp_mktp_pp_cd",
    `Inflation, consumer prices (annual % growth)` = "wb_wdi_fp_cpi_totl_zg",
    `Life expectancy at birth, total (years)` = "wb_wdi_sp_dyn_le00_in",
    `Unemployment (%, 15 yo and over, modeled)` = "wb_gs_sl_uem_zs",
    `Income share held by highest 10%` = "wb_wdi_si_dst_10th_10",
    `Physicians (per 1,000 people)` = "wb_wdi_sh_med_phys_zs",
    `Nurses and midwives (per 1,000 people)` = "wb_wdi_sh_med_numw_p3",
    `Mortality rate, infant (per 1,000 live births)` = "wb_wdi_sp_dyn_imrt_in"
  )
}

#' @rdname get_app_settings
set_secret_names <- function() {
  c("DB_HOST", "DB_PORT", "DB_NAME", "DB_USERNAME", "DB_PW")
}

#' @rdname get_app_settings
set_id_aggr_indicators <- function() {
  list(
    wb_wdi_sp_pop_totl = set_aggr_config("max", "time_period"),
    wb_wdi_sp_pop_0014_to = set_aggr_config("max", "time_period"),
    wb_wdi_ny_gdp_mktp_cd = set_aggr_config("mean", "value"),
    wb_wdi_ny_gdp_pcap_cd = set_aggr_config("weighted.mean", "value", "wb_wdi_sp_pop_totl"),
    wb_wdi_ny_gdp_mktp_pp_cd = set_aggr_config("none", NULL),
    wb_wdi_fp_cpi_totl_zg = set_aggr_config("geometric.mean", "value"),
    wb_wdi_sp_dyn_le00_in = set_aggr_config("mean", "value"),
    wb_gs_sl_uem_zs = set_aggr_config("weighted.mean", "value", "wb_wdi_sp_pop_15up_to"),
    wb_wdi_si_dst_10th_10 = set_aggr_config("none", NULL),
    wb_wdi_sh_med_phys_zs = set_aggr_config("weighted.mean", "value", "wb_wdi_sp_pop_totl"),
    wb_wdi_sh_med_numw_p3 = set_aggr_config("weighted.mean", "value", "wb_wdi_sp_pop_totl"),
    wb_wdi_sp_dyn_imrt_in = set_aggr_config("none", NULL)
  )
}

#' @rdname get_app_settings
set_aggr_config <- function(
  ...,
  target_names = c("function_name", "column_name", "weight_source"),
  length_range = setNames(c(2, 3), c("min", "max"))
) {
  out_list <- list(...)
  names(out_list) <- target_names[1:length_range["min"]]
  if (length(out_list) == length_range["max"]) {
    names(out_list)[length_range["max"]] <- target_names[length_range["max"]]
  }

  out_list
}
# nolint end
# nocov end
