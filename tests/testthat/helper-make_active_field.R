TestR6Class <- R6::R6Class(
  "TestR6Class",
  private = list(.alpha = "hello", .beta = 42, .gamma = TRUE, .epsilon = "bye"),
  active = c(
    list(
      alpha = make_active_field("alpha"), gamma = make_active_field("gamma")
    ),
    make_active_field_wrapper(c("beta", "epsilon"))
  )
)
