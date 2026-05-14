dashboard_page <- bslib::page_fluid(
  # Head.
  shiny::tags$head(
    shiny::tags$link(
      rel = "stylesheet",
      href = paste0(
        "https://cdnjs.cloudflare.com",
        "/ajax/libs/font-awesome/6.4.0/css/all.min.css"
      )
    ),
    shiny::tags$link(
      rel = "stylesheet",
      type = "text/css",
      href = "css/styles_dashboard.css"
    ),
    shiny::tags$link(rel = "stylesheet", href = "lib/leaflet/leaflet.css"),
    shiny::tags$script(src = "lib/leaflet/leaflet.js"),
    shiny::tags$title(paste("Homepage - Jacek Dev", format(Sys.Date(), "%Y")))
  ),
  # Body header.
  shiny::tags$h1(
    class = "page-title",
    shiny::tags$a(
      class = "back-btn", href = "main#examples", "Back to Examples"
    )
  ),
  # Body content.
  # TODO: ADD "create_" FUNCTION FOR ACCORDION PANELS.
  bslib::layout_sidebar(
    sidebar = bslib::sidebar(
      bslib::accordion(
        id = "examples_list",
        multiple = FALSE,
        bslib::accordion_panel(
          "World Trends",
          id = "world_trends",
          myportfolio::sidenoteUI("world_trends")
        ),
        bslib::accordion_panel(
          "Data Summary",
          id = "data_summary",
          myportfolio::sidenoteUI("data_summary")
        ),
        bslib::accordion_panel(
          "Data Modeling",
          id = "data_modeling",
          myportfolio::sidenoteUI("data_modeling")
        ),
        bslib::accordion_panel(
          "Other",
          id = "other",
          myportfolio::sidenoteUI("other")
        )
      )
    ),
    ## "default".
    shiny::conditionalPanel(
      condition = "input.examples_list === null",
      shiny::tags$div(
        myportfolio::sidenoteUI("no_panel_selected")
      )
    ),
    ## "World Trends".
    shiny::conditionalPanel(
      condition = "input.examples_list == 'World Trends'",
      shiny::tags$div(
        myportfolio::indicatorSelectorUI("world_trends"),
        bslib::layout_columns(
          bslib::card(
            bslib::card_header("Map"),
            bslib::card_body(
              add_default_spinner(
                myportfolio::worldMapUI("world_trends")
              )
            )
          ),
          bslib::card(
            bslib::card_header(
              "Chart",
              myportfolio::trendChartExportBtnUI("world_trends"),
              class = "card-header-flex"
            ),
            bslib::card_body(
              myportfolio::add_default_spinner(
                myportfolio::trendChartUI("world_trends")
              )
            )
          )
        ),
        bslib::card(
          bslib::card_header("Table"),
          myportfolio::decadeTableUI("world_trends")
        )
      )
    ),
    ## "Data Summary".
    shiny::conditionalPanel(
      condition = "input.examples_list == 'Data Summary'",
      shiny::tags$div(
        shiny::textOutput("summary_text")
      )
    ),
    ## "Data Modeling".
    shiny::conditionalPanel(
      condition = "input.examples_list == 'Data Modeling'",
      shiny::tags$div(
        shiny::textOutput("modeling_text")
      )
    ),
    ## "Other".
    shiny::conditionalPanel(
      condition = "input.examples_list == 'Other'",
      shiny::tags$div(
        shiny::textOutput("other_text")
      )
    )
  ),
  # Body footer.
  shiny::tags$footer(
    shiny::tags$div(
      class = "copr-text", myportfolio::create_copyright_note()
    )
  ),
  shiny::tags$script(src = "js/dashboard_events.js")
)
