#' @title Storage service
#'
#' @description
#' Manages writing to and fetching from dedicated MinIO storage.
#'
#' @export
StorageService <- R6::R6Class(
  "StorageService",
  private = list(
    # A connection details for the storage.
    .con = NULL,
    # A list of GET functions.
    .get_func = NULL,
    # A list of PUT functions.
    .put_func = NULL
  ),
  public = list(
    #' @description
    #' Creates a new service object.
    #'
    #' @param con A connection details for MinIO storage. Please check
    #'   [aws.s3::s3HTTP()] for more details.
    #' @return A new `StorageService` object.
    initialize = function(con) {
      private$.con <- con
      private$.get_func <- list(
        geometry_all = function() {
          do.call(
            aws.s3::s3readRDS,
            c(list(object = "world_geo.rds"), private$.con)
          )
        }
      )
      private$.put_func <- list(
        geometry_all = function(source_object) {
          do.call(
            aws.s3::s3saveRDS,
            c(list(x = source_object, object = "world_geo.rds"), private$.con)
          )
        }
      )
    },
    #' @description
    #' Fetches relevant data from the target storage bucket.
    #'
    #' @param type A string indicating type of the data to fetch.
    #' @return A `data.frame` object.
    get_data = function(type) {
      tryCatch(
        {
          private$.get_func[[type]]()
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
    #' Fetches geometry data (for all countries) from the storage.
    #'
    #' @return A `data.frame` object.
    get_geometry_all = function() {
      self$get_data("geometry_all")
    },
    #' @description
    #' Writes relevant data to the target storage bucket.
    #'
    #' @param type A string indicating type of the data to write.
    #' @param source_object A single object to be saved in the storage.
    put_data = function(type, source_object) {
      tryCatch(
        {
          private$.put_func[[type]](source_object)
        },
        error = function(e) {
          message("'put_data' failed with the error message:\n", e$message)
          NULL
        },
        warning = function(w) {
          message("'put_data' generated warning:\n", w)
          NULL
        }
      )
    },
    #' @description
    #' Writes geometry data (for all countries) to the storage.
    #'
    #' @param source_object A single object to be saved in the storage.
    put_geometry_all = function(source_object) {
      self$put_data("geometry_all", source_object)
    }
  )
)

#' Get a connection details for MinIO storage
#'
#' Get a connection details for relevant MinIO storage from provided secrets.
#'
#' @param secrets A named object that contains a configuration data
#'   for MinIO storage connection.
#' @return A named list with connection details for MinIO storage.
#' @export
get_storage_connection <- function(secrets) {
  checkmate::assert_named(secrets, type = "unique")

  list(
    bucket = paste(
      Sys.getenv("APP_NAME"), Sys.getenv("DEPLOYMENT_ENV"),
      sep = "-"
    ),
    key = secrets[["MINIO_ACCESS_KEY"]],
    secret = secrets[["MINIO_SECRET_KEY"]],
    region = "",
    base_url = sub("^https?://", "", secrets[["MINIO_ENDPOINT"]]),
    use_https = FALSE
  )
}
