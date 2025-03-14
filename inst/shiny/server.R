server <- function(input, output, session) {
  # TODO: WRAP IT IN A MODULE?
  myportfolio::find_server_components() %>%
    myportfolio::source_components(environment())
}
