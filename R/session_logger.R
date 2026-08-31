#' @include make_active_field.R
NULL

#' @title Session Logger
#'
#' @description
#' Captures all console output (stdout and messages) for a Shiny session in a
#' local file. It can be used to control when to start and stop logging,
#' and when to write logs to MinIO storage.
#'
#' @field time_stamp A character string with current date and time in
#'   "%Y%m%d_%H%M%S" format.
#' @field log_file_dir A name of the directory for storing log files.
#' @field log_file_name A log file name in "%Y%m%d_%H%M%S.log" format.
#' @field log_file_path A path to the log file.
#' @field log_file_con A connection to the log file.
#' @field current_session_token A named list of currently active session tokens
#'    for the given visit ID.
#'
#' @export
SessionLogger <- R6::R6Class(
  classname = "SessionLogger",
  private = list(
    # A character string with current date and time in "%Y%m%d_%H%M%S" format.
    .time_stamp = NULL,
    # A name of the directory for storing log files.
    .log_file_dir = "logs",
    # A log file name in "%Y%m%d_%H%M%S.log" format.
    .log_file_name = NULL,
    # A path to the log file.
    .log_file_path = NULL,
    # A connection to the log file.
    .log_file_con = NULL,
    # A named list of currently active session tokens for the given visit ID.
    .current_session_token = NULL
  ),
  public = list(
    #' @description
    #' Creates a new `SessionLogger` object.
    #'
    #' @return A new `SessionLogger` object.
    initialize = function() {
      private$.time_stamp <- format(
        Sys.time(),
        tz = "Europe/Madrid", format = "%Y%m%d_%H%M%S"
      )
      private$.log_file_name <- sprintf("%s.log", private$.time_stamp)
      private$.log_file_path <- file.path(
        private$.log_file_dir, private$.log_file_name
      )
      private$.current_session_token <- list()
    },
    #' @description
    #' Starts capturing console output for this session.
    start = function() {
      dir.create(private$.log_file_dir, showWarnings = FALSE)
      private$.log_file_con <- file(private$.log_file_path, open = "wt")
      sink(private$.log_file_con, type = "output", append = TRUE)
      sink(private$.log_file_con, type = "message", append = TRUE)
    },
    #' @description
    #' Stops capturing console output for this session.
    stop = function() {
      sink(NULL, type = "message")
      sink(NULL, type = "output")
      close(private$.log_file_con)
    },
    #' @description
    #' Reads and writes relevant log file to the target storage bucket.
    #'
    #' @param storage_con A connection details for MinIO storage. Please check
    #'   [aws.s3::s3HTTP()] for more details.
    put = function(storage_con) {
      log_content <- readLines(private$.log_file_path, warn = FALSE) %>%
        gsub("\033[Gg][0-9;]*", "", .)
      aws.s3::s3write_using(
        x = log_content,
        FUN = writeLines,
        object = private$.log_file_path,
        bucket = storage_con$bucket,
        opts = storage_con[setdiff(names(storage_con), "bucket")]
      )
    },
    #' @description
    #' Returns the value of `visit_id` cookie.
    #'
    #' @param session A Shiny session object.
    get_visit_id = function(session) {
      get_cookie_value(session$request$HTTP_COOKIE, "visit_id") %>%
        check_cookie_value()
    },
    #' @description
    #' Register the currently active session token for a given `visit_id`.
    #'
    #' @param session A Shiny session object.
    set_session_token = function(session) {
      visit_id <- self$get_visit_id(session)
      private$.current_session_token[[visit_id]] <- session$token
    },
    #' @description
    #' Returns the currently active session token registered for a given
    #'   `visit_id`.
    #'
    #' @param session A Shiny session object.
    #' @return A single session token string or `NULL` if not found.
    get_session_token = function(session) {
      visit_id <- self$get_visit_id(session)
      private$.current_session_token[[visit_id]]
    },
    #' @description
    #' Writes a uniform session event line to the log.
    #'
    #' @param event_name A character string with the relevant event name.
    #' @param session A Shiny session object.
    log_session_event = function(event_name, session) {
      message(sprintf(
        "[%s] %s | path=%s | visit_id=%s | session_token=%s",
        format(Sys.time(), tz = "Europe/Madrid", format = "%Y-%m-%d %H:%M:%S"),
        event_name,
        shiny::isolate(session$clientData$url_pathname),
        self$get_visit_id(session),
        session$token
      ))
    },
    #' @description
    #' Initializes user session:
    #' 1. Register the currently active session token for a given `visit_id`.
    #' 2. Log a session start event with timestamp, `PATH_INFO`, `visit_id`
    #' cookie value and session token.
    #'
    #' @param session A Shiny session object.
    init_session = function(session) {
      self$set_session_token(session)
      self$log_session_event("SESSION START", session)
    },
    #' @description
    #' Terminates users session:
    #' 1. Grab the currently active session token registered for a given
    #' `visit_id`.
    #' 2. If it's correct log a session end event with timestamp, `PATH_INFO`,
    #' `visit_id` cookie value and session token.
    #' 3. Write the log file to the storage.
    #'
    #' @param session A Shiny session object.
    #' @param con_details A connection details for the storage. Please check
    #'   `put` method in [myportfolio::SessionLogger] for more details.
    terminate_session = function(session, con_details) {
      current_token <- self$get_session_token(session)

      if (!is_empty(current_token) && current_token == session$token) {
        self$log_session_event("SESSION END", session)
        if (!as.logical(Sys.getenv("LOCAL_RUN"))) {
          self$put(con_details)
        }
      } else {
        self$log_session_event("UNKNOWN TOKEN", session)
      }
    }
  ),
  active = make_active_field_wrapper(
    c(
      "time_stamp", "log_file_dir", "log_file_name", "log_file_path",
      "log_file_con", "current_session_token"
    )
  )
)
