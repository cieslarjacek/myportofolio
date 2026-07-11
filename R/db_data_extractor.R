#' @include make_active_field.R
NULL

#' Make SQL query for "clickable"/"notclickable" geometry data
#'
#' Makes SQL query for fetching country specific "clickable"/"notclickable"
#'   geometry data using database schema.
#'
#' @param db_schema A named list with SQL table names as the list element names
#'   and column names, in a qualified column name format, as the list elements.
#' @return A character vector containing SQL query.
#' @keywords internal
#' @noRd
make_query_geom_clickable <- function(db_schema) {
  assert_with(checkmate::assert_list, db_schema, assert_named_args())

  aux_world_geo_country_id <- db_schema$world_geo[1]

  make_query_geometry(db_schema) %>%
    glue::glue(
      "\nWHERE {world_geo_country_id} IN (
        SELECT DISTINCT {country_id_col}
        FROM {indicator_dt}
        WHERE {country_id_col} > 0
      );",
      world_geo_country_id = aux_world_geo_country_id,
      country_id_col = sub(".*\\.", "", aux_world_geo_country_id),
      indicator_dt = names(db_schema)[3]
    )
}

#' @rdname make_query_geom_clickable
#' @keywords internal
#' @noRd
make_query_geom_notclickable <- function(db_schema) {
  assert_with(checkmate::assert_list, db_schema, assert_named_args())

  aux_indicator_dt <- names(db_schema)[3]

  make_query_geometry(db_schema) %>%
    glue::glue(
      "\nLEFT JOIN {indicator_dt}
      ON {country_id} = {indicator_country_id}
      WHERE {indicator_country_id} IS NULL;",
      indicator_dt = aux_indicator_dt,
      country_id = db_schema$country[1],
      indicator_country_id = db_schema[[aux_indicator_dt]][1]
    )
}

#' @rdname make_query_geom_clickable
#' @keywords internal
#' @noRd
make_query_geometry <- function(db_schema) {
  aux_world_geo_geometry <- db_schema$world_geo[2]

  glue::glue(
    "SELECT
      {country_id},
  	  {country_label},
      ST_AsText({world_geo_geometry}) AS {geometry_col}
    FROM {country_dt}
    INNER JOIN {geometry_dt}
    ON {country_id} = {world_geo_country_id}",
    country_id = db_schema$country[1],
    country_label = db_schema$country[4],
    world_geo_geometry = aux_world_geo_geometry,
    geometry_col = sub(".*\\.", "", aux_world_geo_geometry),
    country_dt = names(db_schema)[1],
    geometry_dt = names(db_schema)[2],
    world_geo_country_id = db_schema$world_geo[1]
  )
}

#' Make SQL query for indicator/weight values
#'
#' Makes SQL query for fetching country specific indicator/weight values using
#'   database schema.
#'
#' @param db_schema A named list with SQL table names as the list element names
#'   and column names, in a qualified column name format, as the list elements.
#' @param indic_id A string with a id of database table containing indicator
#'   values.
#' @return A character vector containing SQL query.
#' @keywords internal
#' @noRd
make_query_values_indicator <- function(db_schema) {
  assert_with(checkmate::assert_list, db_schema, assert_named_args())

  make_query_values(db_schema, names(db_schema)[3])
}

#' @rdname make_query_values_indicator
#' @keywords internal
#' @noRd
make_query_values_weight <- function(db_schema) {
  assert_with(checkmate::assert_list, db_schema, assert_named_args())

  aux_table_name <- names(db_schema)[4]
  if (is_empty(aux_table_name)) {
    warning(
      "In 'make_query_values_weight':",
      "\nWeight data table name doesn't exist in 'db_schema'.",
      "\nSQL query wasn't created and data weren't extracted.",
      call. = FALSE
    )
    return(NULL)
  }

  make_query_values(db_schema, aux_table_name)
}

#' @rdname make_query_values_indicator
#' @keywords internal
#' @noRd
make_query_values <- function(db_schema, indic_id) {
  sort_part <- glue::glue(
    " ORDER BY {indicator_time_period} ASC;",
    indicator_time_period = db_schema[[indic_id]][2]
  )
  glue::glue(
    "SELECT * FROM {indicator_dt} WHERE {indicator_country_id} = ",
    indicator_dt = indic_id,
    indicator_country_id = db_schema[[indic_id]][1]
  ) %>%
    glue::glue_sql(., "?", sort_part, .con = DBI::ANSI())
}

#' Make SQL query for country ids.
#'
#' Makes SQL query for fetching country unique ids using database schema.
#'
#' @param db_schema A named list with SQL table names as the list element names
#'   and column names, in a qualified column name format, as the list elements.
#' @return A character vector containing SQL query.
#' @keywords internal
#' @noRd
make_query_country_ids <- function(db_schema) {
  aux_table_name <- names(db_schema)[3]

  glue::glue(
    "SELECT DISTINCT {indicator_country_id}
    FROM {indicator_dt}
    WHERE {indicator_country_id} > 0;",
    indicator_country_id = db_schema[[aux_table_name]][1],
    indicator_dt = aux_table_name
  )
}

#' @title Database data extractor
#'
#' @description
#' Fetches data from MySQL database.
#'
#' @export
DbDataExtractor <- R6::R6Class(
  "DbDataExtractor",
  private = list(
    # A connection to database.
    .con = NULL,
    # A list of SQL queries.
    .query = list(
      geometry_clickable = NULL,
      geometry_notclickable = NULL,
      values_indicator = NULL,
      values_weight = NULL,
      country_ids = NULL
    ),
    # A list of functions that create SQL queries.
    .make_query_func = list(
      geometry_clickable = make_query_geom_clickable,
      geometry_notclickable = make_query_geom_notclickable,
      values_indicator = make_query_values_indicator,
      values_weight = make_query_values_weight,
      country_ids = make_query_country_ids
    )
  ),
  public = list(
    #' @field db_schema A named list with SQL table names as the list element
    #'   names and column names, in a qualified column name format, as the list
    #'   elements.
    db_schema = NULL,
    #' @description
    #' Creates a new extractor object.
    #'
    #' @param con A connection to a database. Please check [DBI::dbConnect()]
    #'   for more details.
    #' @param db_schema A list with database schema.
    #' @return A new `DbDataExtractor` object.
    initialize = function(con, db_schema) {
      private$.con <- con
      self$db_schema <- db_schema
    },
    #' @description
    #' Fetches relevant data from the target database.
    #'
    #' @param type A string indicating type of the data to fetch.
    #' @param country_id An integer, ISO 3166-1 numeric (or numeric-3) country.
    #' @return A `data.frame` object.
    get_data = function(type, country_id = NULL) {
      tryCatch(
        {
          aux_query <- private$.make_query_func[[type]](self$db_schema)
          private$.query[[type]] <- aux_query

          if (!is_empty(country_id)) {
            query_result <- DBI::dbSendQuery(
              private$.con,
              aux_query,
              params = list(country_id)
            )
            out <- DBI::dbFetch(query_result)
            self$clear_result(query_result)
            return(out)
          }

          DBI::dbGetQuery(private$.con, aux_query)
        },
        error = function(e) {
          message("'get_data' failed with the error message:\n", e$message)
          NULL
        },
        warning = function(w) {
          message("'get_data' generated warning:\n", w)
          NULL
        }
      )
    },
    #' @description
    #' Fetches "clickable" geometry data.
    #'
    #' @return A `data.frame` object.
    get_geometry_clickable = function() {
      self$get_data("geometry_clickable")
    },
    #' @description
    #' Fetches "notclickable" geometry data.
    #'
    #' @return A `data.frame` object.
    get_geometry_notclickable = function() {
      self$get_data("geometry_notclickable")
    },
    #' @description
    #' Fetches data for target indicator in target country.
    #'
    #' @param country_id An integer, ISO 3166-1 numeric (or numeric-3) country
    #'   code.
    #' @return A `data.frame` object.
    get_indicator_values = function(country_id) {
      checkmate::assert_integerish(country_id)
      self$get_data("values_indicator", country_id)
    },
    #' @description
    #' Fetches data for target weight in target country.
    #'
    #' @param country_id An integer, ISO 3166-1 numeric (or numeric-3) country
    #'   code.
    #' @return A `data.frame` object.
    get_weight_values = function(country_id) {
      checkmate::assert_integerish(country_id)
      self$get_data("values_weight", country_id)
    },
    #' @description
    #' Fetches country ids in target indicator.
    #' @return A `data.frame` object.
    get_country_ids = function() {
      self$get_data("country_ids")
    },
    #' @description
    #' Just a wrapper for [DBI::dbClearResult()]. Clears a result set obtained
    #'   by the query.
    #'
    #' @param result An object inheriting from [DBI::DBIResult-class].
    clear_result = function(result) {
      DBI::dbClearResult(result)
    },
    #' @description
    #' Just a wrapper for [DBI::dbDisconnect()]. Closes connection to the data
    #'   base.
    disconnect = function() {
      DBI::dbDisconnect(private$.con)
    }
  ),
  active = list(
    #' @field query A read only list of SQL queries created inside the class.
    query = make_active_field("query")
  )
)

#' Create a connection to MySQL database
#'
#' Creates a connection to relevant MySQL database using provided secrets.
#'
#' @param secrets A named object that contains a configuration data
#'   for a MySQL database connection.
#' @return A connection to a database. Please check [DBI::dbConnect()]
#'   for more details.
#' @export
create_db_connection <- function(secrets) {
  checkmate::assert_named(secrets, type = "unique")

  DBI::dbConnect(
    RMariaDB::MariaDB(),
    dbname = secrets[["DB_NAME"]],
    host = secrets[["DB_HOST"]],
    port = as.integer(secrets[["DB_PORT"]]),
    user = secrets[["DB_USERNAME"]],
    password = secrets[["DB_PW"]]
  )
}
