main_page <- shiny::fluidPage(
  theme = bslib::bs_theme(version = 5),
  shiny::tags$head(
    shiny::tags$link(
      rel = "stylesheet",
      type = "text/css",
      href = "css/styles_main.css"
    ),
    shiny::tags$script(src = "js/visit_temp_id.js"),
    shiny::tags$title(paste("Homepage - Jacek Dev", format(Sys.Date(), "%Y")))
  ),
  shiny::tags$div(
    id = "main-grid",
    class = "main-grid",
    shiny::tags$div(
      class = "header",
      shiny::tags$img(
        src = "images/dev_black.svg",
        class = "header-logo"
      ),
      tags$nav(
        class = "header-nav",
        lapply(
          c("Intro", "Examples", "About", "Contact"),
          myportfolio::create_header_hlink
        )
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
        myportfolio::get_section_text("intro")
      ),
      shiny::tags$section(
        id = "examples",
        class = "section-default",
        shiny::tags$div(
          id = "examples-panel",
          lapply(
            c("Dashboard", "Data Science", "CI/CD", "ETL"),
            myportfolio::create_example_hlink
          )
        )
      ),
      shiny::tags$section(
        id = "about",
        class = "section-default",
        shiny::tags$h2(class = "section-heading", "About"),
        myportfolio::get_section_text("about")
      ),
      shiny::tags$section(
        id = "contact",
        class = "section-default",
        shiny::tags$h2(class = "section-heading", "Contact"),
        myportfolio::get_section_text("contact"),
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
        id = "copr-text-main",
        myportfolio::create_copyright_note()
      )
    )
  )
)
