# sidenoteUI() creates expected HTML

    Code
      sidenoteUI("x")
    Output
      <div id="x-sidenote" class="shiny-html-output"></div>

# output$sidenote creates expected HTML when using default message

    Code
      as.character(output$sidenote)
    Output
      [1] "<p>Data source: <a href='https://data.worldbank.org/' target='_blank'>World Bank Open Data</a></p> <p>\nThe world map is based on spatial data from  R <a href='https://github.com/rspatial/geodata' target='_blank'>geodata</a> package.  Some country borders were adjusted to fit administrative division used by the World Bank.</p>"
      [2] "list()"                                                                                                                                                                                                                                                                                                                                  

