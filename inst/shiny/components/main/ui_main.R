main_page <- shiny::fluidPage(
  shiny::tags$head(
    shiny::tags$link(
      rel = "stylesheet", type = "text/css", href = "css/styles_main.css"
    ),
    shiny::tags$title(paste("Homepage - Jacek Dev", format(Sys.Date(), "%Y")))
  ),
  shiny::tags$div(
    id = "main-grid",
    class = "main-grid",
    shiny::tags$div(
      class = "header",
      lapply(
        c("Intro", "Examples", "About", "Contact"),
        myportfolio::create_header_hlink
      )
    ),
    shiny::tags$div(
      class = "content",
      shiny::tags$section(
        id = "intro",
        class = "section-default",
        shiny::tags$h1(
          class = "main-heading section-heading",
          "Hi, thanks for stepping by!"
        ),
        shiny::tags$p(
          class = "section-text",
          "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do
          eiusmodtempor incididunt ut labore et dolore magna aliqua. Ut enim ad
          minim veniam,quis nostrud exercitation ullamco laboris nisi ut aliquip
          ex ea commodo consequat. Duis aute irure dolor in reprehenderit in
          voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur
          sint occaecat cupidatat non proident, sunt in culpa qui officia
          deserunt mollit anim id est laborum."
        )
      ),
      shiny::tags$section(
        id = "examples",
        class = "section-default",
        shiny::tags$div(
          id = "examples-panel",
          lapply(
            c("Dashboard", "CI/CD", "ETL"),
            myportfolio::create_example_hlink
          )
        )
      ),
      shiny::tags$section(
        id = "about",
        class = "section-default",
        shiny::tags$h2(class = "section-heading", "About"),
        shiny::tags$p(
          class = "section-text",
          "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do
          eiusmodtempor incididunt ut labore et dolore magna aliqua. Ut enim ad
          minim veniam,quis nostrud exercitation ullamco laboris nisi ut aliquip
          ex ea commodo consequat. Duis aute irure dolor in reprehenderit in
          voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur
          sint occaecat cupidatat non proident, sunt in culpa qui officia
          deserunt mollit anim id est laborum."
        )
      ),
      shiny::tags$section(
        id = "contact",
        class = "section-default",
        shiny::tags$h2(class = "section-heading", "Contact"),
        shiny::tags$p(
          class = "section-text",
          "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do
          eiusmodtempor incididunt ut labore et dolore magna aliqua. Ut enim ad
          minim veniam,quis nostrud exercitation ullamco laboris nisi ut aliquip
          ex ea commodo consequat. Duis aute irure dolor in reprehenderit in
          voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur
          sint occaecat cupidatat non proident, sunt in culpa qui officia
          deserunt mollit anim id est laborum."
        ),
        shiny::tags$a(
          id = "email-btn",
          class = "contact-btn",
          href = "mailto:contact@jacekdev.com",
          "email me"
        )
      )
    ),
    shiny::tags$div(
      class = "footer",
      shiny::tags$div(
        id = "footer-btns",
        lapply(
          list(
            c("Linkedin", "https://linkedin.com/in/jacek-cieslar-a08063a9"),
            c("GitHub", "https://github.com/cieslarjacek")
          ),
          function(elem) {
            create_footer_hlink(elem[1], elem[2])
          }
        )
      ),
      shiny::tags$div(
        id = "copr-text", "Copyrights 2025"
      )
    )
  )
)
