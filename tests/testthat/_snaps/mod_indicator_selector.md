# indicatorSelectorUI() creates expected HTML

    Code
      indicatorSelectorUI("x")
    Output
      <div id="x-selector" class="shiny-html-output"></div>

# output$selector creates expected HTML for named character choices

    Code
      as.character(output$selector)
    Output
      [1] "<div class=\"form-group shiny-input-container\">\n  <label class=\"control-label\" id=\"proxy1-indicator_selector-label\" for=\"proxy1-indicator_selector\">World Trends Data Indicators</label>\n  <div>\n    <select class=\"shiny-input-select form-control\" id=\"proxy1-indicator_selector\"><option value=\"\" selected>-</option>\n<option value=\"ind_a\">Indicator A</option>\n<option value=\"ind_b\">Indicator B</option></select>\n  </div>\n</div>"
      [2] "list()"                                                                                                                                                                                                                                                                                                                                                                                                                                                         

# output$selector creates expected HTML for named list choices

    Code
      as.character(output$selector)
    Output
      [1] "<div class=\"form-group shiny-input-container\">\n  <label class=\"control-label\" id=\"proxy1-indicator_selector-label\" for=\"proxy1-indicator_selector\">World Trends Data Indicators</label>\n  <div>\n    <select class=\"shiny-input-select form-control\" id=\"proxy1-indicator_selector\"><option value=\"\" selected>-</option>\n<option value=\"ind_a\">Indicator A</option>\n<option value=\"ind_b\">Indicator B</option></select>\n  </div>\n</div>"
      [2] "list()"                                                                                                                                                                                                                                                                                                                                                                                                                                                         

