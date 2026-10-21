test_that("get_section_text() returns expected HTML code", {
  for (test_id in c("intro", "about", "contact")) {
    expect_snapshot(get_section_text(test_id))
  }
})

test_that("get_section_text() returns NULL for wrong element id", {
  for (test_id in c("unknown", "", "INTRO", "Intro")) {
    expect_invisible(result <- get_section_text(test_id))
    expect_null(result)
  }
})

test_that("get_section_text() rejects non-character input with an error", {
  non_strings <- list(1, 2L, TRUE, NULL, list("intro"))
  for (test_id in non_strings) {
    expect_error(
      get_section_text(test_id),
      "Assertion on 'html_id' failed: Must be of type 'string'"
    )
  }
})

test_that("get_section_text() rejects not single-string input with an error", {
  expect_error(
    get_section_text(c("intro", "about")),
    "Assertion on 'html_id' failed: Must have length 1"
  )
  expect_error(
    get_section_text(character(0)),
    "Assertion on 'html_id' failed: Must have length 1"
  )
})

test_that("get_section_text() rejects NA input", {
  expect_error(
    get_section_text(NA_character_),
    "Assertion on 'html_id' failed: May not be NA"
  )
  expect_error(
    get_section_text(NA),
    "Assertion on 'html_id' failed: May not be NA"
  )
})
