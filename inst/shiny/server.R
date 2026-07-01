server <- function(input, output, session) {
  SessionLogger$new(session, myportfolio::get_storage_connection(app_secrets))

  # TODO: WRAP IT IN A MODULE?
  myportfolio::find_server_components() %>%
    myportfolio::source_components(environment())
}
