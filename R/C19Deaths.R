#' @title COVID-19 Deaths
#'
#' @description  Calling deaths and confirmed functions will return a data frame consisting of each countries total death and confirmed cases of COVID-19 by day
#' @return A data set consisting death cases
#' @export

C19Death <- function(){
  library(lubridate)
  library(dplyr)
  library(readr)
  url <- "https://raw.githubusercontent.com/CSSEGISandData/COVID-19/master/csse_covid_19_data/csse_covid_19_time_series/time_series_covid19_deaths_global.csv"
  death <- read_csv(url)
  cols <- setdiff(names(death), c("Province/State", "Lat", "Long"))
  death <- death[, cols]
  death <- death %>%
    group_by(`Country/Region`) %>%
    summarise_all(list(~sum(., na.rm = TRUE))) %>% as.data.frame
  countries <- death$`Country/Region`
  dates <- as.Date.character(names(death[2:dim(death)[2]]), tryFormats = c("%m/%d/%y", "%Y/%m/%d"))
  death <- death[, order(dates, decreasing = T)]
  death <- cbind(countries, death)
  return(death[, 1:(length(death)-1)])
}

