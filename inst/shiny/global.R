# TODO: CLEAN THE LIST OF PACKAGES.
library(bslib)
library(data.table)
library(DBI)
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

if (!as.logical(Sys.getenv("LOCAL_RUN"))) {
  # TODO: SERVER - SOURCE AS SECRETS.
}

app_settings <- myportfolio::get_app_settings()
color_palette <- app_settings$color_palette

# IMPORTANT: Keep this at the end to avoid errors in `future` functions.
future::plan(future::multisession)
