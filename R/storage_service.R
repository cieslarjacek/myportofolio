#' @title Storage service
#'
#' @description
#' Manages writing to and fetching from dedicated MinIO storage.
#'
#' @export
StorageService <- R6::R6Class(
  "StorageService",
  private = list(
    # A connection details for storage.
    .con = NULL
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
    },
    #' @description
    #' Fetches relevant data from the target storage bucket.
    #'
    #' @param type A string indicating type of the data to fetch.
    #' @return A `data.frame` object.
    get_data = function(type) {
      tryCatch(
        {
          do.call(
            aws.s3::s3readRDS,
            c(list(object = "world_geo.rds"), private$.con)
          )
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
          do.call(
            aws.s3::s3saveRDS,
            c(list(x = source_object, object = "world_geo.rds"), private$.con)
          )
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
      self$put_data("geometry_all")
    }
  )
)

#' Get a connection details for MinIO storage
#'
#' Get a connection details for relevant MinIO storage from provided secrets.
#'
#' @param secrets A named character vector that contains a configuration data
#'   for MinIO storage connection.
#' @return A named list with connection details for MinIO storage.
get_storage_connection <- function(secrets) {
  assert_with(checkmate::check_character, secrets, assert_named_args())

  list(
    bucket = Sys.getenv("DEPLOYMENT_ENV"),
    key = secrets[["MINIO_ACCESS_KEY"]],
    secret = secrets[["MINIO_SECRET_KEY"]],
    region = "",
    base_url = sub("^https?://", "", secrets[["MINIO_ENDPOINT"]]),
    use_https = FALSE
  )
}
