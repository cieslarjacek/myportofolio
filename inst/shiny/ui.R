# TODO: WRAP IT IN A MODULE?
myportfolio::find_ui_components() %>%
  myportfolio::source_components()

# TODO: CREATE SOME CLEAN WRAPPER FOR THE LIST IF IT MAKES SENSE.
route_mapping <- list(
  "/" = main_page,
  "/main" = main_page,
  "/main#examples" = main_page,
  "/dashboard" = dashboard_page,
  "/etl" = etl_page
)

ui <- myportfolio::route_page(route_mapping)
