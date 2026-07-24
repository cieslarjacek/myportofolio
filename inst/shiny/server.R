server <- function(input, output, session) {
  # Log the event on the session start.
  app_logger$log_session_start(session)
  # Log the event and save the logs on the session end.
  shiny::onSessionEnded(function() {
    if (app_logger$current_session_token == session$token) {
      app_logger$log_session_end(session)
      if (!as.logical(Sys.getenv("LOCAL_RUN"))) {
        app_logger$put(myportfolio::get_storage_connection(app_secrets))
      }
    }
  })

  # TODO: WRAP IT IN A MODULE?
  myportfolio::find_server_components() %>%
    myportfolio::source_components(environment())
}
