#' Create a hyperlink for header/example/footer division
#'
#' Constructs a hyperlink (<a></a>) to use in the main page header,
#'   example or footer section.
#'
#' @param hlink_label A string with a hyperlink label.
#' @param hlink_ref A string with the URL link to the external web page.
#'   Used only in [create_footer_hlink()] function.
#' @return A single `shiny.tag` object.
#' @export
create_header_hlink <- function(hlink_label) {
  checkmate::assert_string(hlink_label)

  kebab_string <- str_to_kebab_case(hlink_label)
  shiny::tags$a(
    id = paste0(kebab_string, "-btn"),
    class = "header-btn",
    href = paste0("#", kebab_string),
    hlink_label
  )
}

#' @rdname create_header_hlink
#' @export
create_example_hlink <- function(hlink_label) {
  checkmate::assert_string(hlink_label)

  kebab_string <- str_to_kebab_case(hlink_label)
  shiny::tags$a(
    class = "example-btn",
    href = kebab_string,
    shiny::tags$p(
      class = "example-btn-header",
      hlink_label
    ),
    shiny::tags$img(
      class = "example-btn-image",
      src = paste0("images/", kebab_string, "_example_image.png")
    )
  )
}

#' @rdname create_header_hlink
#' @export
create_footer_hlink <- function(hlink_label, hlink_ref) {
  checkmate::assert_string(hlink_label)
  checkmate::assert_string(hlink_ref, pattern = "^https://")

  kebab_string <- str_to_kebab_case(hlink_label)
  shiny::tags$a(
    id = paste0(kebab_string, "-btn"),
    class = "contact-btn contact-btn-external",
    href = hlink_ref,
    target = "_blank",
    shiny::tags$img(
      class = "contact-btn-image",
      src = paste0("images/", kebab_string, "_black.png")
    )
  )
}
