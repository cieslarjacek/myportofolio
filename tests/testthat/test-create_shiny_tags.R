test_that("str_to_kebab_case() converts strings properly", {
  test_strings <- c(
    "Jestem Adaś?", "mam#%ha1h bim", "!Hóla, muy@bien_am9igo", "Some Nice name"
  )

  expect_equal(
    str_to_kebab_case(test_strings),
    c(
      "jestem-adas", "mam-ha1h-bim", "hola-muy-bien-am9igo", "some-nice-name"
    )
  )
})

test_that("create_header_hlink() returns correct HTML", {
  test_label <- "some_label"
  hyphen_test_label <- str_to_kebab_case(test_label)

  expected <- shiny::tags$a(
    id = paste0(str_to_kebab_case(test_label), "-btn"),
    class = "header-btn",
    href = paste0("#", hyphen_test_label),
    test_label
  )

  expect_equal(create_header_hlink(test_label), expected)
})

test_that("create_example_hlink() returns correct HTML", {
  test_label <- "some_label"
  hyphen_test_label <- str_to_kebab_case(test_label)

  expected <- shiny::tags$a(
    class = "example-btn",
    href = hyphen_test_label,
    shiny::tags$p(
      class = "example-btn-header",
      test_label
    ),
    shiny::tags$img(
      class = "example-btn-image",
      src = paste0("images/", hyphen_test_label, "_example_image.png")
    )
  )

  expect_equal(create_example_hlink(test_label), expected)
})

test_that("create_footer_hlink() returns correct HTML", {
  test_label <- "some_label"
  test_ref <- "https://some_ref"
  hyphen_test_label <- str_to_kebab_case(test_label)

  expected <- shiny::tags$a(
    id = paste0(hyphen_test_label, "-btn"),
    class = "contact-btn contact-btn-external",
    href = test_ref,
    target = "_blank",
    shiny::tags$img(
      class = "contact-btn-image",
      src = paste0("images/", hyphen_test_label, "_black.png")
    )
  )

  expect_equal(create_footer_hlink(test_label, test_ref), expected)
})
