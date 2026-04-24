test_that("sidenoteUI() creates expected HTML", {
  expect_snapshot(sidenoteUI("x"))
})

test_that("output$sidenote renders the injected message as HTML", {
  shiny::testServer(
    sidenoteServer, args = list(message = "Hello <b>world</b>"), {
      expect_equal(as.character(output$sidenote$html), "Hello <b>world</b>")
  })
})

test_that("non-character message throws error before the module starts", {
  expect_error(
    testServer(sidenoteServer, args = list(message = 123), {}),
    "Assertion on 'message' failed:"
  )
})

test_that("NULL message throws error before the module starts", {
  expect_error(
    testServer(sidenoteServer, args = list(message = NULL), {}),
    "Assertion on 'message' failed:"
  )
})

test_that("NA message throws error before the module starts", {
  expect_error(
    testServer(sidenoteServer, args = list(message = NA), {}),
    "Assertion on 'message' failed:"
  )
})

test_that("output$sidenote creates expected HTML when using default message", {
  testServer(
    sidenoteServer,
    args = list(message = get_sidenote_message("world_trends")),
    {
      expect_snapshot(as.character(output$sidenote))
    }
  )
})
