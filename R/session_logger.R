#' @title Session Logger
#'
#' @description
#' Captures all console output (stdout and messages) for a Shiny session
#' and saves the log at session end - locally if running locally, or to
#' MinIO storage if running on the server.
#'
#' @export

make_active_field <- function(field_name) {
  eval(bquote(function(value) {
    if (missing(value)) {
      private[[.(paste0(".", field_name))]]
    } else {
      stop(sprintf("'%s' is read-only", .(field_name)))
    }
  }))
}

make_active_field_wrapper <- function(field_names) {
  setNames(lapply(field_names, make_active_field), field_names)
}

SessionLogger <- R6::R6Class(
  classname = "SessionLogger",
  private = list(
    .time_stamp = NULL,
    .session_id = NULL,
    .is_local = NULL,
    .storage_con = NULL,
    .log_dir = "logs",
    .log_file_name = NULL,
    .log_file_path = NULL,
    .log_file_con = NULL
    # .start = function() {
    #   dir.create(private$.log_dir, showWarnings = FALSE)
    #   private$.log_file_con <- file(private$.log_file_path, open = "wt")
    #   sink(private$.log_file_con, type = "output", split = TRUE)
    #   sink(private$.log_file_con, type = "message", split = TRUE)
    # },
    # .stop = function() {
    #   sink(type = "message")
    #   sink(type = "output")
    #   close(private$.log_file_con)
    # },
    # .save_remote = function(log_name) {
    #   log_content <- readLines(private$.log_file, warn = FALSE)
    #   do.call(
    #     aws.s3::s3write_using,
    #     c(
    #       list(
    #         x = log_content,
    #         FUN = writeLines,
    #         object = file.path("logs", log_name)
    #       ),
    #       private$.storage
    #     )
    #   )
    # },
    # .save = function() {
    #   log_name <-
    #     private$.save_local(log_name)
    #   if (!private$.is_local) {
    #     private$.save_remote(log_name)
    #   }
    #
    #   unlink(private$.log_file)
    # }
  ),
  public = list(
    #' @description
    #' Creates a new `SessionLogger` object and immediately starts capturing
    #' console output for this session.
    #'
    #' @param session A Shiny session object.
    #' @param storage_con A connection details for MinIO storage. Please check
    #'   [aws.s3::s3HTTP()] and [get_storage_connection()] for more details.
    #' @return A new `SessionLogger` object.
    initialize = function(session, storage_con) {
      private$.time_stamp <- format(
        Sys.time(),
        tz = "Europe/Madrid", format = "%Y%m%d%H%M%S"
      )
      private$.session_id <- session$token
      private$.is_local <- as.logical(Sys.getenv("LOCAL_RUN"))
      private$.storage_con <- storage_con
      private$.log_file_name <- sprintf(
        "%s_%s.log", private$.time_stamp, private$.session_id
      )
      private$.log_file_path <- file.path(
        private$.log_dir, private$.log_file_name
      )

      # private$.start()
      #
      # session$onSessionEnded(function() {
      #   private$.stop()
      #   private$.save()
      # })
    }
  ),
  active = make_active_field_wrapper(
    c(
      "time_stamp", "session_id", "is_local", "storage_con",
      "log_dir", "log_file_name", "log_file_path", "log_file_con"
    )
  )
)




server <- function(input, output, session) {}
shiny::testServer(server, {
  browser()
  logger <- SessionLogger$new(
    session, myportfolio::get_storage_connection(app_secrets)
  )
  logger$log_file_con
})
