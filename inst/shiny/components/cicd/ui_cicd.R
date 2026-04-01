# TODO: GENERALIZE REPEATED CODE IN THE UI PAGES ACROSS COMPONENTS.
cicd_page <- bslib::page_fluid(
  # Head.
  shiny::tags$head(
    shiny::tags$link(
      rel = "stylesheet",
      type = "text/css",
      href = "css/styles_dashboard.css"
    ),
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
  bslib::card(
    card_body(
      "Placeholder for 'CI/CD' UI."
    )
  )
)