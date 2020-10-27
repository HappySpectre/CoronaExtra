#' @title COVID-19 cases and Deaths on World map
#' @param type 1 is reserved for death cases and 2 is reserved for confirmed case
#' @param date A string consisting the specific date when the heatmep is desired to be drawn in m/d/yy format
#' @description  Calling DeathCasesMap will return a heatmap of the World, displaying each countries situation of death and confirmed cases
#' @return A heatmap of the world at the desired date
#' @example \dontrun{DeathCasesMap("Iran", "8/5/20")}
#' @export

C19WorldMap <- function(type, date){
  library(rworldmap)
  library(dplyr)
  library(readr)
  library(knitr)
  library(ggplot2)
  library(lubridate)
  warning(F)
  options(readr.num_columns = 0)

  if(as.character(type) == 1){
    url <- "https://raw.githubusercontent.com/CSSEGISandData/COVID-19/master/csse_covid_19_data/csse_covid_19_time_series/time_series_covid19_deaths_global.csv"
    death <- read_csv(url)
    cols <- setdiff(names(death), c("Province/State", "Lat", "Long"))
    death <- death[, cols]
    death <- death %>%
      group_by(`Country/Region`) %>%
      summarise_all(list(~sum(., na.rm = TRUE))) %>% as.data.frame

    countries <- death$`Country/Region`
    death <- cbind(countries, death)
    death <- death[, 1:(length(death)-1)]

    death$countries <- recode(death$countries,
                              "Burma" = "Myanmar",
                              "Czechia" =  "Czech Republic",
                              "Congo (Brazzaville)" = "Democratic Republic of the Congo",
                              "Korea, South" = "South Korea",
                              "Taiwan*" = "Taiwan",
                              "US" = "USA",
                              "United Kingdom"= "UK")

    data <- data.frame(cbind(countries, death[,date]))
    names(data) <- c("country", "Death")
    data$Death <- as.numeric(data$Death)
    sPDF <- joinCountryData2Map( data
                                 , joinCode = "NAME"
                                 , nameJoinColumn = "country")

    par(mai=c(0,0,1,0),xaxs="i",yaxs="i")
    mapParams <- mapCountryData(sPDF, nameColumnToPlot="Death", catMethod="fixedWidth",
                                addLegend = T, mapTitle = sprintf("Death Cases in %s",date))
  }
  else if(type==2){

    url <- "https://raw.githubusercontent.com/CSSEGISandData/COVID-19/master/csse_covid_19_data/csse_covid_19_time_series/time_series_covid19_confirmed_global.csv"
    cases <- read_csv(url)
    cols <- setdiff(names(cases), c("Province/State", "Lat", "Long"))
    cases <- cases[, cols]
    cases <- cases %>%
      group_by(`Country/Region`) %>%
      summarise_all(list(~sum(., na.rm = TRUE))) %>% as.data.frame

    countries <- cases$`Country/Region`
    dates <- as.Date.character(names(cases[2:dim(cases)[2]]), tryFormats = c("%m/%d/%y", "%Y/%m/%d"))
    cases <- cases[, order(dates, decreasing = T)]
    cases <- cbind(countries, cases)
    cases <- cases[, 1:(length(cases)-1)]

    cases$countries <- recode(cases$countries,
                              "Burma" = "Myanmar",
                              "Czechia" =  "Czech Republic",
                              "Congo (Brazzaville)" = "Democratic Republic of the Congo",
                              "Korea, South" = "South Korea",
                              "Taiwan*" = "Taiwan",
                              "US" = "USA",
                              "United Kingdom"= "UK")


    df <- data.frame(cbind(countries, cases[[date]]))
    head(df)
    names(df) <- c("country", "cases")
    df$cases <- as.numeric(df$cases)
    sPDF <- joinCountryData2Map( df
                                 , joinCode = "NAME"
                                 , nameJoinColumn = "country")

    par(mai=c(0,0,1,0),xaxs="i",yaxs="i")
    map <- mapCountryData(sPDF, nameColumnToPlot="cases", catMethod="fixedWidth",
                          addLegend = T, mapTitle = sprintf("Confirmed Cases in %s",date))

  }
}


