make_test_session <- function(
  url_pathname = "/some/path", cookie = "visit_id=abc123", token = "tok_xyz"
) {
  list(
    clientData = list(url_pathname = url_pathname),
    request    = list(HTTP_COOKIE = cookie),
    token      = token
  )
}
