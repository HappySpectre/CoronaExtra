#' @title COVID-19 Cases
#'
#' @description  Calling deaths and confirmed functions will return a data frame consisting of each countries total death and confirmed cases of COVID-19 by day
#' @return A data set consisting confirmed cases
#' @export

C19Cases <- function(){
  library(lubridate)
  library(dplyr)
  library(readr)
  url <- "https://raw.githubusercontent.com/CSSEGISandData/COVID-19/master/csse_covid_19_data/csse_covid_19_time_series/time_series_covid19_confirmed_global.csv"
  cases <- read_csv(url)
  cols <- setdiff(names(cases), c("Province/State", "Lat", "Long"))
  cases <- cases[, cols]
  cases <- cases %>%
    group_by(`Country/Region`) %>%
    summarise_all(list(~sum(., na.rm = TRUE))) %>% as.data.frame
  countries <- cases$`Country/Region`
  dates <- as.Date.character(names(cases[2:dim(cases)[2]]), tryFormats = c("%m/%d/%y", "%Y/%m/%d"))
  d <- dates[2:dim(cases)[2]]
  cases <- cases[, order(dates, decreasing = T)]
  cases <- cbind(countries, cases)
  return(cases[, 1:(length(cases)-1)])
}
