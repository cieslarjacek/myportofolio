# Function to build a valid 'aggregation_input' list for decadeTableServer().
make_test_aggregation_input <- function(
    func_name = "mean", column_name = "value"
    ) {
  list(
    shiny::reactiveVal(
      list(function_name = func_name, column_name = column_name)
    ),
    shiny::reactiveVal(data.table::data.table()),
    shiny::reactiveVal(NULL)
  )
}
