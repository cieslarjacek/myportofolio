# TODO: Add "expect_error" test for "assert_polygon_data" etc.
test_that("make_map_color_theme() makes correct color theme", {
  expected <- list(
    clickable = setNames(
      unname(set_color_palette()[c("stroke", "base", "base_dk")]),
      c("stroke", "fill", "highlight_stroke")
    ),
    notclickable = setNames(
      unname(set_color_palette()[c("stroke", "neutral", "empty")]),
      c("stroke", "fill", "highlight_stroke")
    )
  )

  expect_equal(make_map_color_theme(), expected)
})

test_that("build_world_map() creates right map", {
  expected <- create_base_map() %>%
    add_bounds() %>%
    add_view() %>%
    add_clickable_polygons(
      test_data_list$clickable, test_map_color_theme$clickable
    ) %>%
    add_notclickable_polygons(
      test_data_list$notclickable, test_map_color_theme$notclickable
    ) %>%
    add_reset_button()

  expect_equal(
    build_world_map(test_data_list, test_map_color_theme), expected
  )
})

test_that("build_world_map() throws argument type error - 'data_list'",
  {
    error_msg <- "Assertion on 'data_list' failed"

    expect_error(
      build_world_map(c(1, 2), test_map_color_theme), error_msg
    )
    expect_error(
      build_world_map(list(), test_map_color_theme), error_msg
    )
    expect_error(
      build_world_map(NULL, test_map_color_theme), error_msg
    )
  }
)

test_that("build_world_map() throws argument type error - 'names(data_list)'",
  {
    error_msg <- "Assertion on 'names\\(data_list\\)' failed"

    names(test_data_list) <- c("name1", "name2")
    expect_error(
      build_world_map(test_data_list, test_map_color_theme), error_msg
    )
  }
)

test_that("build_world_map() throws argument type error - 'color_theme'",
  {
    error_msg <- "Assertion on 'color_theme' failed"

    expect_error(
      build_world_map(test_data_list, c(1, 2)), error_msg
    )
    expect_error(
      build_world_map(test_data_list, list()), error_msg
    )
    expect_error(
      build_world_map(test_data_list, NULL), error_msg
    )
  }
)

test_that("build_world_map() throws argument type error - 'names(color_theme)'",
  {
    error_msg <- "Assertion on 'names\\(color_theme\\)' failed"

    names(test_map_color_theme) <- c("name1", "name2")
    expect_error(
      build_world_map(test_data_list, test_map_color_theme), error_msg
    )
  }
)
