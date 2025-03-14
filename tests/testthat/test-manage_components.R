test_that("find_all_components() returns valid paths", {
  main_dir <- file.path(tempdir(), "test_components") %T>%
    dir.create(., recursive = TRUE)
  sub_dirs <- get_subpath_elements()
  full_paths <- construct_full_path(main_dir, sub_dirs) %T>%
    file.create(.)
  withr::defer(unlink(main_dir, recursive = TRUE, force = TRUE))

  actual <- find_all_components(names(sub_dirs), main_dir)
  expected <- full_paths %>% .[grepl("\\.R", .)]
  expect_identical(sort(actual), sort(expected))
})

test_that("find_all_components() throws argument type error - 'main_dir'", {
  error_msg <- "Assertion on 'main_dir' failed"

  expect_error(find_all_components("a", 1), error_msg)
  expect_error(find_all_components("a", TRUE), error_msg)
  expect_error(find_all_components("a", NULL), error_msg)
  expect_error(find_all_components("a", NA), error_msg)
  expect_error(find_all_components("a", character(0)), error_msg)
})

test_that("find_all_components() throws argument type error - 'sub_dir'", {
  error_msg <- "Assertion on 'sub_dir' failed"

  expect_error(find_all_components(1, "b"), error_msg)
  expect_error(find_all_components(TRUE, "b"), error_msg)
  expect_error(find_all_components(NULL, "b"), error_msg)
  expect_error(find_all_components(NA, "b"), error_msg)
  expect_error(find_all_components(character(0), "b"), error_msg)
  expect_error(find_all_components(c(NULL, NULL), "b"), error_msg)
  expect_error(find_all_components(c(NA, NA), "b"), error_msg)
  expect_error(find_all_components(c("c", NA), "b"), error_msg)
})

test_that("find_all_components() returns valid paths", {
  main_dir <- file.path(tempdir(), "test_components") %T>%
    dir.create(., recursive = TRUE)
  sub_dirs <- get_subpath_elements()
  full_paths <- construct_full_path(main_dir, sub_dirs) %T>%
    file.create(.)
  withr::defer(unlink(main_dir, recursive = TRUE, force = TRUE))

  actual <- find_all_components(names(sub_dirs), main_dir)
  expected <- full_paths %>% .[grepl("\\.R", .)]
  expect_identical(sort(actual), sort(expected))
})

test_that("find_ui_components() returns valid paths", {
  main_dir <- file.path(tempdir(), "test_components") %T>%
    dir.create(., recursive = TRUE)
  sub_dirs <- get_subpath_elements()
  full_paths <- construct_full_path(main_dir, sub_dirs) %T>%
    file.create(.)
  withr::defer(unlink(main_dir, recursive = TRUE))

  actual <- find_ui_components(names(sub_dirs), main_dir)
  expected <- full_paths %>%
    .[grepl("\\.R", .)] %>%
    .[grepl("ui_", .)]
  expect_identical(sort(actual), sort(expected))
})

test_that("find_server_components() returns valid paths", {
  main_dir <- file.path(tempdir(), "test_components") %T>%
    dir.create(., recursive = TRUE)
  sub_dirs <- get_subpath_elements()
  full_paths <- construct_full_path(main_dir, sub_dirs) %T>%
    file.create(.)
  withr::defer(unlink(main_dir, recursive = TRUE))

  actual <- find_server_components(names(sub_dirs), main_dir)
  expected <- full_paths %>%
    .[grepl("\\.R", .)] %>%
    .[grepl("server_", .)]
  expect_identical(sort(actual), sort(expected))
})

test_that("find_other_components() returns valid paths", {
  main_dir <- file.path(tempdir(), "test_components") %T>%
    dir.create(., recursive = TRUE)
  sub_dirs <- get_subpath_elements()
  full_paths <- construct_full_path(main_dir, sub_dirs) %T>%
    file.create(.)
  withr::defer(unlink(main_dir, recursive = TRUE))

  actual <- find_other_components(names(sub_dirs), main_dir)
  expected <- full_paths %>%
    .[grepl("\\.R", .)] %>%
    .[!grepl("ui_|server_", .)]
  expect_identical(sort(actual), sort(expected))
})

test_that("source_components() reads files properly", {
  withr::with_tempfile(c("test_file1", "test_file2"),
    {
      writeLines(c(a <- 10, "100"), test_file1)
      writeLines(c(b <- 20, "200"), test_file2)

      actual <- source_components(c(test_file1, test_file2))

      # Returned values should match the last expression in each file.
      expect_equal(as.numeric(head(unname(actual), 1)), c(100, 200))
      # Side effects should be visible in the environment.
      expect_true(exists("a"))
      expect_equal(get("a"), 10)
      expect_true(exists("b"))
      expect_equal(get("b"), 20)
    },
    fileext = ".R"
  )
})

test_that(
  "source_components() throws argument type error - 'component_paths'",
  {
    error_msg <- "Assertion on 'component_paths' failed"

    expect_error(source_components(1), error_msg)
    expect_error(source_components(TRUE), error_msg)
    expect_error(source_components(NULL), error_msg)
    expect_error(source_components(NA), error_msg)
    expect_error(source_components(character(0)), error_msg)
  }
)

test_that(
  "source_components() throws error and warning when a file does not exist",
  {
    expect_error(source_components("this_file_does_not_exist_12345.R")) %>%
      expect_warning(.)
  }
)

test_that(
  "source_components() throws argument type error - 'evalutation_env'",
  {
    error_msg <- "Assertion failed. One of the following must apply"

    expect_error(source_components("a", "b"), error_msg)
    expect_error(source_components("a", 1), error_msg)
    expect_error(source_components("a", NULL), error_msg)
    expect_error(source_components("a", NA), error_msg)
    expect_error(source_components("a", character(0)), error_msg)
  }
)
