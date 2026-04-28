# TODO: ADD MORE TESTS TO INCREASE COVERAGE.
test_that("worldMapUI() creates expected HTML", {
  expect_snapshot(worldMapUI("x"))
})
