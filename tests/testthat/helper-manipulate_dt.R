# Test objects.
test_decade_dt1 <- data.table::data.table(
  country_id  = c("A", "A", "A", "A", "A", "A", "A", "A", "A"),
  time_period = c(1970, 1976, 1978, 1991, 1995, 1999, 2001, 2005, 2009),
  value = c(70, 80, 90, 10, 20, 30, 40, 50, 60),
  weight = c(1.1, 0.9, 1.0, 0.8, 1.1, 0.9, 0.1, 0.2, 0.3),
  check_decade = c(
    "1970s", "1970s", "1970s", "1990s", "1990s", "1990s", "2000s", "2000s",
    "2000s"
  )
)

test_decade_dt2 <- data.table::data.table(
  country_id  = c("B", "B", "B", "B", "B", "B", "B", "B", "B"),
  time_period = c(1970, 1976, 1978, 1981, 1985, 1989, 2001, 2005, 2009),
  value = c(10, 20, 30, 70, 80, 90, 40, 50, 60),
  weight = c(0.1, 0.2, 0.3, 1.1, 0.9, 1.0, 0.8, 1.1, 0.9),
  check_decade = c(
    "1970s", "1970s", "1970s", "1980s", "1980s", "1980s", "2000s", "2000s",
    "2000s"
  )
)
