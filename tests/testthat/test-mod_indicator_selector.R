test_that("indicatorSelectorUI() creates expected HTML", {
  expect_snapshot(indicatorSelectorUI("x"))
})

test_that("output$selector creates expected HTML for named character choices", {
  shiny::testServer(
    indicatorSelectorServer,
    args = list(choices = c("Indicator A" = "ind_a", "Indicator B" = "ind_b")),
    {
      expect_snapshot(as.character(output$selector))
    }
  )
})

test_that("output$selector creates expected HTML for named list choices", {
  shiny::testServer(
    indicatorSelectorServer,
    args = list(
      choices = list("Indicator A" = "ind_a", "Indicator B" = "ind_b")
    ),
    {
      expect_snapshot(as.character(output$selector))
    }
  )
})

test_that("output$selector is not rendered when choices is empty list", {
  shiny::testServer(
    indicatorSelectorServer,
    args = list(choices = list()),
    {
      expect_error(output$selector, class = "shiny.silent.error")
    }
  )
})

test_that(
  "output$selector is not rendered when choices is empty character vector", {
    shiny::testServer(
      indicatorSelectorServer,
      args = list(choices = character(0)),
      {
        expect_error(output$selector, class = "shiny.silent.error")
      }
    )
})

test_that("output$selector errors for unnamed character vector", {
  shiny::testServer(
    indicatorSelectorServer,
    args = list(choices = c("ind_a", "ind_b")),
    {
      expect_error(output$selector, "Assertion on 'choices' failed:")
    }
  )
})

test_that("output$selector errors for unnamed list", {
  shiny::testServer(
    indicatorSelectorServer,
    args = list(choices = list("ind_a", "ind_b")),
    {
      expect_error(output$selector, "Assertion on 'choices' failed:")
    }
  )
})

test_that("output$selector errors for non-list non-character choices", {
  shiny::testServer(
    indicatorSelectorServer,
    args = list(choices = 1:3),
    {
      expect_error(output$selector, "Assertion on 'choices' failed:")
    }
  )
})

test_that("returned reactive is NULL before any selection", {
  shiny::testServer(
    indicatorSelectorServer,
    args = list(choices = c("Indicator A" = "ind_a", "Indicator B" = "ind_b")),
    {
      actual_return <- session$getReturned()
      expect_null(actual_return())
    }
  )
})

test_that("returned reactive updates when selection changes", {
  shiny::testServer(
    indicatorSelectorServer,
    args = list(
      choices = list("Indicator A" = "ind_a", "Indicator B" = "ind_b")
    ),
    {
      actual_return <- session$getReturned()

      session$setInputs(indicator_selector = "ind_a")
      expect_equal(actual_return(), "ind_a")

      session$setInputs(indicator_selector = "")
      expect_equal(actual_return(), "")

      session$setInputs(indicator_selector = "ind_b")
      expect_equal(actual_return(), "ind_b")
    }
  )
})
