# Start the logger.
app_logger <- myportfolio::SessionLogger$new()
app_logger$start()

# Load used packages.
library(bslib)
library(cachem)
library(data.table)
library(DBI)
library(DT)
library(future.apply)
library(future)
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

# Load settings and secrets.
app_settings <- myportfolio::get_app_settings()
color_palette <- app_settings$color_palette

if (as.logical(Sys.getenv("LOCAL_RUN"))) {
  app_secrets <- Sys.getenv(app_settings$secret_names)
} else {
  secret_reader <- SecretReader$new()
  app_secrets <- secret_reader$get_all_secrets()
}

# Enable in memory caching that is shared across all sessions.
app_cache <- cachem::cache_mem()

# TODO: CHECK AND REMOVE IF NOT NEEDED.
# IMPORTANT: Keep this at the end to avoid errors in `future` functions.
future::plan(future::multisession)
