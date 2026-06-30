test_that("worldMapUI() creates expected HTML", {
  expect_snapshot(worldMapUI("x"))
})

test_that("worldMapServer() rejects a non-reactive 'indic_id'", {
  expect_error(
    worldMapServer("test",
      indic_id  = "wb_wdi_ny_gdp_mktp_cd",
      data_pair = make_test_data_pair()
    ),
    "Assertion on 'indic_id' failed"
  )
})

test_that("worldMapServer() rejects 'data_pair' with wrong length", {
  expect_error(
    worldMapServer("test",
      indic_id  = shiny::reactive("wb_wdi_ny_gdp_mktp_cd"),
      data_pair = list(shiny::reactive(list()))
    ),
    "Assertion on 'data_pair' failed"
  )
})

test_that("worldMapServer() rejects non-reactive elements in 'data_pair'", {
  expect_error(
    worldMapServer(
      "test",
      indic_id = shiny::reactive("wb_wdi_ny_gdp_mktp_cd"),
      data_pair = list(list(sf_stub = TRUE), shiny::reactive(list(a = 1)))
    ),
    "Assertion on 'X[[i]]' failed",
    fixed = TRUE
  )
})

test_that(
  "worldMapServer() returns no error for valid 'indic_id' and 'label_data'",
  {
    captured_build <- NULL
    captured_name <- NULL

    local_mocked_bindings(
      build_world_map = function(geom, theme) {
        captured_build <<- list(geom = geom, theme = theme)
        leaflet::leaflet()
      },
      make_map_color_theme = function() "theme_stub",
      add_js_code = function(map, name) {
        captured_name <<- name
        map
      }
    )

    shiny::testServer(
      worldMapServer,
      args = list(
        indic_id  = shiny::reactive("wb_wdi_ny_gdp_mktp_cd"),
        data_pair = make_test_data_pair(geometry_value = list(sf_stub = "geom"))
      ),
      {
        expect_no_error(output$map)
        expect_equal(captured_build$geom, list(sf_stub = "geom"))
        expect_equal(captured_build$theme, "theme_stub")
        expect_true(grepl("map", captured_name, fixed = TRUE))
      }
    )
  }
)

test_that("worldMapServer() output is suppressed when 'indic_id' is empty", {
  pipeline_called <- FALSE
  local_mocked_bindings(
    build_world_map = function(...) {
      pipeline_called <<- TRUE
      leaflet::leaflet()
    }
  )

  shiny::testServer(
    worldMapServer,
    args = list(
      indic_id  = shiny::reactive(""),
      data_pair = make_test_data_pair()
    ),
    {
      expect_error(output$map)
      expect_false(pipeline_called)
    }
  )
})

test_that("worldMapServer() output is suppressed when 'label_data' is NULL", {
  pipeline_called <- FALSE
  local_mocked_bindings(
    build_world_map = function(...) {
      pipeline_called <<- TRUE
      leaflet::leaflet()
    }
  )

  shiny::testServer(
    worldMapServer,
    args = list(
      indic_id  = shiny::reactive("wb_wdi_ny_gdp_mktp_cd"),
      data_pair = make_test_data_pair(label_value = NULL)
    ),
    {
      expect_error(output$map)
      expect_false(pipeline_called)
    }
  )
})
