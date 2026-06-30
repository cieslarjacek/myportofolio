# Function to build a valid 'data_pair' list for worldMapServer().
make_test_data_pair <- function(
    geometry_value = list(sf_stub = TRUE), label_value = list(a = 1)) {
  list(
    shiny::reactive(geometry_value),
    shiny::reactive(label_value)
  )
}
