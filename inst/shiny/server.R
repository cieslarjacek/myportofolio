server <- function(input, output, session) {
  # Initialize the session.
  app_logger$init_session(session)

  # Terminate the session on the session end.
  shiny::onSessionEnded(function() {
    app_logger$terminate_session(
      session, myportfolio::get_storage_connection(app_secrets)
    )
  })

  # TODO: WRAP IT IN A MODULE?
  myportfolio::find_server_components() %>%
    myportfolio::source_components(environment())
}
