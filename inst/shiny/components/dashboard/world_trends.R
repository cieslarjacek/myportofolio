# TODO: PREPARE R6 CLASS FOR MANNING CUSTOM MESSAGES.
# TODO: REMOVE "ui_render_flag" IF POSSIBLE.

myportfolio::sidenoteServer("world_trends")

indicator_id <- myportfolio::indicatorSelectorServer("world_trends")

# Initiate reactive values.
reactivevals_manager <- myportfolio::ReactiveValuesManager$new()
for (obj_name in names(reactivevals_manager$init_objects)) {
  assign(obj_name, reactivevals_manager$get_init(obj_name))
}

# Update and reset reactive values after indicator selection.
shiny::observeEvent(indicator_id(),
  {
    if (is_empty(indicator_id())) {
      sql_db_schema(reactivevals_manager$reset("sql_db_schema"))
      table_aggregation_params(
        reactivevals_manager$reset("table_aggregation_params")
      )
    } else {
      sql_db_schema(
        reactivevals_manager$update("sql_db_schema")(indicator_id())
      )
      table_aggregation_params(
        reactivevals_manager$update("table_aggregation_params")(indicator_id())
      )
    }

    map_available_color(reactivevals_manager$reset("map_available_color"))
    chart_active_data(reactivevals_manager$reset("chart_active_data"))
    table_weight_data(reactivevals_manager$reset("table_weight_data"))
    ui_render_flag(reactivevals_manager$reset("ui_render_flag"))
    chart_export_btn_click(reactivevals_manager$reset("chart_export_btn_click"))

    for (name in names(map_click_registry)) {
      map_click_registry[[name]] <- reactivevals_manager$reset(
        "map_click_registry"
      )
    }
    for (name in names(chart_active_data_range)) {
      chart_active_data_range[[name]] <- reactivevals_manager$reset(
        "chart_active_data_range"
      )
    }

    session$sendCustomMessage("toggleTrendChartExportBtn", FALSE)
  },
  ignoreInit = TRUE
)

# Extract world geometry data.
world_geometry_data <- shiny::reactive({
  temp_sql_db_schema <- sql_db_schema()
  shiny::req(temp_sql_db_schema)

  geometry_all <- app_cache$get("geometry_all")
  if (cachem::is.key_missing(geometry_all)) {
    message("Cache miss - downloading 'geometry_all' from the storage...")
    storage_connection <- myportfolio::get_storage_connection(app_secrets)
    storage_service <- myportfolio::StorageService$new(storage_connection)
    geometry_all <- storage_service$get_geometry_all()

    app_cache$set("geometry_all", geometry_all)
    message("'geometry_all' loaded and cached.")
  }

  db_connection <- myportfolio::create_db_connection(app_secrets)
  db_extractor <- myportfolio::DbDataExtractor$new(
    db_connection, temp_sql_db_schema
  )
  country_ids_df <- db_extractor$get_country_ids()
  db_extractor$disconnect()

  geom_split <- rev(split(
    geometry_all, geometry_all$id %in% country_ids_df$country_id
  ))
  names(geom_split) <- app_settings$data_labels$world_trends
  geom_split
})

country_label_data <- shiny::eventReactive(world_geometry_data(), {
  data.table::as.data.table(
    sf::st_drop_geometry(world_geometry_data()$clickable)
  )
})

# Render the world map.
system.time({
  worldMapServer(
    "world_trends", indicator_id, list(world_geometry_data, country_label_data)
  )
})

# Register the world map click.
shiny::observeEvent(input$`world_trends-map_shape_click`$id, {
  temp_id <- input$`world_trends-map_shape_click`$id
  shiny::req(temp_id)

  temp_label <- country_label_data()[id == temp_id, label]
  temp_click <- list(id = temp_id, label = temp_label)

  if (any(
    myportfolio::sapply_identical(map_click_registry$active, temp_click)
  )) {
    # Run "remove country click" statement.
    map_click_registry$add <- reactivevals_manager$reset("map_click_registry")
    map_click_registry$remove <- temp_click
    map_click_registry$active <- map_click_registry$active[
      !myportfolio::sapply_identical(map_click_registry$active, temp_click)
    ]

    if (myportfolio::is_empty(map_click_registry$active)) {
      ui_render_flag(reactivevals_manager$reset("ui_render_flag"))
      chart_active_data(reactivevals_manager$reset("chart_active_data"))
    }

    session$sendCustomMessage(
      "recolorLayer", list(c(temp_click$id, color_palette$base))
    )
  } else if (length(map_click_registry$active) < 5) {
    # Run "add country click" statement.
    if (myportfolio::is_empty(map_click_registry$active)) {
      chart_with_one_trace(reactivevals_manager$reset("chart_with_one_trace"))
      ui_render_flag(TRUE)
    }

    map_click_registry$add <- temp_click
    map_click_registry$remove <- reactivevals_manager$reset(
      "map_click_registry"
    )
    map_click_registry$active <- append(
      map_click_registry$active,
      list(temp_click)
    )

    session$sendCustomMessage(
      "recolorLayer", list(c(temp_click$id, map_available_color()[1]))
    )
  }
})

# Apply logic for country selection reset button.
shiny::observeEvent(input$reset_selection, {
  shiny::req(input$reset_selection)

  # Clear the world map selections.
  session$sendCustomMessage(
    "recolorLayer",
    lapply(
      map_click_registry$active,
      function(elem) c(elem$id, color_palette$base)
    )
  )
  for (name in names(map_click_registry)) {
    map_click_registry[[name]] <- reactivevals_manager$reset(
      "map_click_registry"
    )
  }
  session$sendCustomMessage("toggleTrendChartExportBtn", FALSE)

  # Clear the trend chart series.
  ui_render_flag(reactivevals_manager$reset("ui_render_flag"))
  chart_active_data(reactivevals_manager$reset("chart_active_data"))
})

shiny::observe({
  session$sendCustomMessage(
    "toggleWorldMapResetBtn", !myportfolio::is_empty(map_click_registry$active)
  )
})

# Send released color back to the handler.
shiny::observeEvent(input$color_return, {
  shiny::req(input$color_return)
  map_available_color(c(map_available_color(), input$color_return))
})

# Update "chart_active_data()".
shiny::observeEvent(map_click_registry$add$id, {
  shiny::req(map_click_registry$add$id)


  # TODO: USE FUTURE AND (MAYBE) PROMISES HERE.
  # THE CHART SHOULD GET THE DATA BEFORE TABLE.
  db_connection <- myportfolio::create_db_connection(app_secrets)
  db_extractor <- myportfolio::DbDataExtractor$new(
    db_connection, sql_db_schema()
  )
  temp_indicator_dt <- data.table::as.data.table(
    db_extractor$get_indicator_values(map_click_registry$add$id)
  )
  temp_weight_dt <- data.table::as.data.table(
    db_extractor$get_weight_values(map_click_registry$add$id)
  )
  db_extractor$disconnect()

  chart_active_data(
    c(
      chart_active_data(),
      setNames(list(temp_indicator_dt), map_click_registry$add$label)
    )
  )
  table_weight_data(
    c(
      table_weight_data(),
      setNames(list(temp_weight_dt), map_click_registry$add$label)
    )
  )

  chart_active_data_range$absolute$x <- myportfolio::extract_dt_list_range(
    chart_active_data(), list("time_period")
  )

  chart_active_data_range$absolute$y <- myportfolio::extract_dt_list_range(
    chart_active_data(), list("value")
  )
})

# Render the base trend chart.
shiny::observeEvent(chart_active_data(),
  {
    # Don't re-build if the trend chart is already rendered.
    if (!is.null(chart_with_one_trace())) {
      return()
    }

    shiny::req(!myportfolio::is_empty(chart_active_data()))

    temp_plot <- myportfolio::build_trend_chart(
      chart_active_data()[map_click_registry$add$label],
      myportfolio::make_chart_color_theme(map_available_color()[1]),
      myportfolio::make_chart_config(
        indicator_id(), chart_active_data_range$absolute$y
      )
    )
    chart_with_one_trace(temp_plot)

    # Drop the color taken by the trend chart series.
    shiny::isolate(map_available_color(map_available_color()[-1]))
  },
  ignoreNULL = FALSE
)

myportfolio::trendChartServer(
  "world_trends", ui_render_flag, chart_with_one_trace
)

# Add a series (trace) to the trend chart.
observeEvent(map_click_registry$add$id, {
  shiny::req(chart_with_one_trace())
  shiny::req(map_click_registry$add$id)

  xrange <- myportfolio::select_range(list(
    chart_active_data_range$current$x,
    chart_active_data_range$absolute$x
  ))
  yrange <- myportfolio::extract_dt_list_range(
    chart_active_data(),
    list("value", list("time_period", c(xrange[1]:xrange[2])))
  )
  chart_active_data_range$current$y <- yrange

  myportfolio::addTrendChartSeriesServer(
    "world_trends",
    list(
      dt_list = chart_active_data()[map_click_registry$add$label],
      color = map_available_color()[1]
    ),
    yrange
  )

  # Drop the color taken by the trend chart series.
  shiny::isolate(map_available_color(map_available_color()[-1]))
})

# Adjust the trend chart y-axis.
wt_chart_relayout_event <- shiny::reactive({
  shiny::req(ui_render_flag())
  plotly::event_data("plotly_relayout", source = "wt_chart")
})
observeEvent(wt_chart_relayout_event(),
  {
    xautorange_event <- wt_chart_relayout_event()$xaxis.autorange
    xrange_event <- as.numeric(wt_chart_relayout_event()$xaxis.range)
    yrange_event <- as.numeric(wt_chart_relayout_event()$yaxis$range)

    if (!myportfolio::is_empty(xautorange_event)) {
      chart_active_data_range$current <- chart_active_data_range$absolute
      myportfolio::updtTrendChartYaxisServer(
        "world_trends", chart_active_data_range$absolute$y
      )
    } else if (!myportfolio::is_empty(xrange_event)) {
      xrange <- myportfolio::make_xrange(xrange_event)
      chart_active_data_range$current$x <- xrange

      yrange <- myportfolio::extract_dt_list_range(
        chart_active_data(),
        list("value", list("time_period", c(xrange[1]:xrange[2])))
      )
      chart_active_data_range$current$y <- yrange
      myportfolio::updtTrendChartYaxisServer("world_trends", yrange)
    }
  },
  ignoreNULL = TRUE
)

# Remove a series (trace) from the trend chart.
shiny::observeEvent(map_click_registry$remove$id, {
  shiny::req(length(map_click_registry$active) >= 1)
  shiny::req(map_click_registry$remove$id)

  series_label <- map_click_registry$remove$label
  chart_active_data(
    myportfolio::remove_list_elem(chart_active_data(), series_label)
  )

  chart_active_data_range$absolute$x <- myportfolio::extract_dt_list_range(
    chart_active_data(), list("time_period")
  )
  chart_active_data_range$absolute$y <- myportfolio::extract_dt_list_range(
    chart_active_data(), list("value")
  )

  xrange <- myportfolio::select_range(list(
    chart_active_data_range$current$x,
    chart_active_data_range$absolute$x
  ))
  yrange <- myportfolio::extract_dt_list_range(
    chart_active_data(),
    list("value", list("time_period", c(xrange[1]:xrange[2])))
  )
  chart_active_data_range$current$y <- yrange

  myportfolio::removeTrendChartSeriesServer(
    "world_trends", series_label, yrange
  )
})

# Prepare the export button with a drop-down menu selector.
myportfolio::trendChartExportBtnServer("world_trends")

# Resolve an export click.
shiny::observeEvent(
  list(
    input$`world_trends-chart_download_png`,
    input$`world_trends-chart_download_csv`,
    input$`world_trends-chart_download_json`
  ),
  {
    current_click <- c(
      png = input$`world_trends-chart_download_png`,
      csv = input$`world_trends-chart_download_csv`,
      json = input$`world_trends-chart_download_json`
    )
    shiny::req(sum(current_click) > 0)

    target_click <- myportfolio::extract_download_btn_click(list(
      current_click, chart_export_btn_click()
    ))
    chart_export_btn_click(current_click)
    target_filename <- myportfolio::make_download_file_name(
      names(which(app_settings$worldbank_indicator$name_id == indicator_id()))
    )
    target_data <- shiny::NS("world_trends", "chart")

    if (target_click != "png") {
      xrange <- myportfolio::select_range(list(
        chart_active_data_range$current$x,
        chart_active_data_range$absolute$x
      ))
      export_dt <- myportfolio::extract_trends_chart_dt(
        chart_active_data(),
        list("country_name", list("time_period", c(xrange[1]:xrange[2])))
      )

      if (target_click == "csv") {
        target_data <- myportfolio::convert_dt_to_string(export_dt)
      } else if (target_click == "json") {
        target_data <- myportfolio::convert_dt_to_json(
          data.table::dcast(
            export_dt,
            time_period ~ country_name + country_id,
            value.var = "value"
          )
        )
      }
    }

    payload <- list(
      data = target_data, format = target_click, filename = target_filename
    )
    session$sendCustomMessage("exportTrendChartData", payload)
  }
)

# Render the decades table.
myportfolio::decadeTableServer(
  "world_trends",
  ui_render_flag,
  list(table_aggregation_params, chart_active_data, table_weight_data)
)
