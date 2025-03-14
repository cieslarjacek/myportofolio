source("global.R")
source("ui.R")
source("server.R")

# TODO: CREATE A WRAPPER FOR "shinyApp" WITH DEFAULT "uiPattern".
shiny::shinyApp(ui, server, uiPattern = myportfolio::get_ui_pattern())
