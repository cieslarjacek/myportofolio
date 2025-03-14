# TODO: CLEAN THE LIST OF LIBRARIES.
library(bslib)
library(data.table)
library(DBI)
library(dotenv)
library(DT)
library(future)
library(future.apply)
library(ggplot2)
library(glue)
library(jsonlite)
library(leaflet)
library(magrittr)
library(myportfolio)
library(plotly)
library(promises)
library(RMariaDB)
library(sf)
library(shiny)
library(shinycssloaders)
library(shinyWidgets)

# TODO: SET THE VALUE WHILE RUNNING DOCKER IMAGE.
Sys.setenv(LOCAL_RUN = TRUE)

# TODO: LOCALLY - SOURCE WHILE RUNNING DOCKER IMAGE.
# TODO: SERVER - SOURCE AS SECRETS.
if (Sys.getenv("LOCAL_RUN")) {
  dotenv::load_dot_env("../../dev.env")
}

app_settings <- myportfolio::get_app_settings()
color_palette <- app_settings$color_palette

# IMPORTANT: Keep this at the end to avoid errors in `future` functions.
future::plan(future::multisession)
