source("global.R")
source("ui.R")
source("server.R")

# Stop the logger and save the logs.
shiny::onStop(function() {
  app_logger$stop()
  if (!as.logical(Sys.getenv("LOCAL_RUN"))) {
    app_logger$put(myportfolio::get_storage_connection(app_secrets))
  }
})

# TODO: CREATE A WRAPPER FOR "shinyApp" WITH DEFAULT "uiPattern".
shiny::shinyApp(ui, server, uiPattern = myportfolio::get_ui_pattern())
