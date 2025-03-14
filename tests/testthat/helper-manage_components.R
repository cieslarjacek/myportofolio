get_subpath_elements <- function() {
  list(
    compA = c("ui_a.R", "b.R", "c.R"),
    compB = c("server_x.R", "y.txt"),
    compC = c("c.R", "d.json")
  )
}

construct_full_path <- function(main_dir, sub_dirs) {
  out <- NULL
  for (elem in names(sub_dirs)) {
    temp_file_path <- file.path(main_dir, elem)
    dir.create(temp_file_path)
    out <- c(out, file.path(temp_file_path, sub_dirs[[elem]]))
  }
  out
}
