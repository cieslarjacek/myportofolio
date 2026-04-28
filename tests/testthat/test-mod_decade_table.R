# TODO: ADD MORE TESTS TO INCREASE COVERAGE.
test_that("decadeTableUI() creates expected HTML", {
  expect_snapshot(decadeTableUI("x"))
})
