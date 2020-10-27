#' @title  COVID-19 cases and Death over time
#' @param Country An string consisting the name a country
#' @param Start An string consisting the first date the plot needs to draw in yyyy-mm-dd format
#' @param Stop An string consisting the last date the plot needs to draw in yyyy-mm-dd format
#' @return The evolution of deaths and confirmed cases over time
#' @example \dontrun{COVID19("Iran", "2020-08-01", "2020-10-01")}
#' @export

COVID19vsTime <- function(Country, Start, Stop){
  library(ggplot2)
  library(dplyr)
  library(readr)
  library(lubridate)

  deathurl <- "https://raw.githubusercontent.com/CSSEGISandData/COVID-19/master/csse_covid_19_data/csse_covid_19_time_series/time_series_covid19_deaths_global.csv"
  death <- read_csv(deathurl)
  cols <- setdiff(names(death), c("Province/State", "Lat", "Long"))
  death <- death[, cols]
  death <- death %>%
    group_by(`Country/Region`) %>%
    summarise_all(list(~sum(., na.rm = TRUE))) %>% as.data.frame

  countries <- death$`Country/Region`
  death <- cbind(countries, death[, 2:(length(death)-1)])

  death$countries <- recode(death$countries,
                            "Burma" = "Myanmar",
                            "Czechia" =  "Czech Republic",
                            "Congo (Brazzaville)" = "Democratic Republic of the Congo",
                            "Korea, South" = "South Korea",
                            "Taiwan*" = "Taiwan",
                            "US" = "USA",
                            "United Kingdom"= "UK")


  url <- "https://raw.githubusercontent.com/CSSEGISandData/COVID-19/master/csse_covid_19_data/csse_covid_19_time_series/time_series_covid19_confirmed_global.csv"
  cases <- read_csv(url)
  cols <- setdiff(names(cases), c("Province/State", "Lat", "Long"))
  cases <- cases[, cols]
  cases <- cases %>%
    group_by(`Country/Region`) %>%
    summarise_all(list(~sum(., na.rm = TRUE))) %>% as.data.frame

  countries <- cases$`Country/Region`
  dates <- as.Date.character(names(cases[2:dim(cases)[2]]), tryFormats = c("%m/%d/%y", "%Y/%m/%d"))
  cases <- cases[, 2:(length(cases)-1)]
  cases <- cbind(countries, cases)

  cases$countries <- recode(cases$countries,
                            "Burma" = "Myanmar",
                            "Czechia" =  "Czech Republic",
                            "Congo (Brazzaville)" = "Democratic Republic of the Congo",
                            "Korea, South" = "South Korea",
                            "Taiwan*" = "Taiwan",
                            "US" = "USA",
                            "United Kingdom"= "UK")

  data <- death[death$countries==Country,]
  days <- names(data)[2:length(names(data))]
  d <- death[death$countries==Country, 2:length(days)]
  date <- names(d)
  death_cases <- unlist(d, use.names = F)

  confirmed_cases <- unlist(cases[cases$countries==Country,],use.names = F)
  confirmed_cases <- as.numeric(confirmed_cases[2:length(days)])

  out <- as.data.frame(cbind(date, death_cases, confirmed_cases))
  out$date <- as.Date(out$date, tryFormats = c("%m/%d/%y"))
  out$death_cases <- as.numeric(out$death_cases)
  out$confirmed_cases <- as.numeric(out$confirmed_cases)

  i <- which(out$date == as.character(Start))

  j <- which(out$date == as.character(Stop))

  options(repr.plot.width = 14, repr.plot.height = 8)
  ggplot(data = out[seq(i, j, 1), ], aes(x=date))+
    geom_line(aes(y = death_cases, group=1, color='Death Cases')) +
    geom_line(aes(y = confirmed_cases, group=1, color='Confirmed Cases')) +
    scale_x_date(date_breaks = "1 month", date_labels = "%Y/%m")+
    ylab(sprintf("Cases of COVID-19 in %s", Country)) +
    xlab("Date")

}
