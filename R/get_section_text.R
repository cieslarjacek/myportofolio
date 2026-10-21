# nolint start
#' Get main page section text
#'
#' Selects relevant text input for the given HTML element id.
#'
#' @param html_id A character string with HTML element id.
#' @return A single character string with HTML code or `NULL` if `html_is` is
#' not present in `switch()` element.
#' @export
get_section_text <- function(html_id) {
  checkmate::assert_string(html_id)

  switch(
    html_id,
    intro = shiny::markdown(
      paste(
        "My name is Jacek, I'm a data scientist and developer specializing in",
        "R/Shiny and Python. I have more than 15 years of experience",
        "working with data, including six years building enterprise",
        "analytical tools.",
        "<br>",
        "I design and deliver the full analytical pipeline: ETL and",
        "data processing, statistical modelling and interactive Shiny apps.",
        "Version control, automated testing and CI/CD are built into my work",
        "from the start."
      )
    ),
    about = shiny::markdown(
      paste(
        "I'm an R and Python developer, and data scientist with over 15 years",
        "of experience turning data into results people can use. I hold a",
        "master's degree in Sociology from the University of Warsaw,",
        "specialising in statistics and quantitative methods.",
        "",
        "My background is in quantitative marketing research. From 2019 to",
        "2024, I was a Software Developer / Senior Data Scientist at Kantar,",
        "building Shiny apps and analytical pipelines in an international",
        "team. My work covered the full process:",
        "",
        "- **ETL:** processing, cleaning and loading marketing and",
        "  tracking-study data into SQL databases and other storage.",
        "- **Analysis:** from trends and descriptive statistics, through",
        "  inferential statistics and segmentation, to statistical modelling.",
        "- **Delivery:** interactive Shiny apps with custom inputs and exports.",
        "",
        "I build quality in through R and Python packages, automated tests,",
        "code review, Docker and CI/CD. Since 2026 I've been working as a",
        "freelancer.",
        "",
        "**Tech stack:** R, Shiny, Python, SQL, Bash, Git, Docker,",
        "Azure DevOps, GitHub",
        sep = "\n"
      )
    ),
    contact = shiny::markdown(
      paste(
        "Do you have a project in mind? Need help with a Shiny app",
        "or analytical pipeline? Or want to discuss a role? Get in touch,",
        "I'm always happy to help!",
        "",
        "I work in English and Polish.",
        sep = "\n"
      )
    )
  )
}
# nolint end
