#import library
library(tidyverse) 
library(plotly)
library(lubridate) # date manipulation
library(forecast) # time series library
library(MLmetrics) # calculate error
library(tseries) # adf.test
library(TSstudio) 
library(padr) # complete data frame
library(imputeTS)
theme_set(theme_minimal())


gold_data <- read_csv("G:/Project M.Sc/Gold Price.csv")
gold_data

glimpse(gold_data)  #Data structure 
head(gold_data)     # first 6 observations     

summary(gold_data)  #Summarize the data  

View(gold_data)
colSums(is.na(gold_data))   #To Check missing Values in any columns
 
colnames(gold_data)     #Names of Columns
colnames(gold_data)<-c("Date" ,"Price","Open" ,"High" ,"Low" ,"Volume" ,"Chg")


# Convert date column to date format
gold_data$Date <- as.Date(gold_data$Date, format = "%Y-%m-%d")

# Create line chart of gold price over time
gold_price_chart <- plot_ly(gold_data, x = ~Date, y = ~Price, type = "scatter", mode = "lines")
gold_price_chart <- gold_price_chart %>% layout(title = "Gold Price Over Time",
                                                xaxis = list(title = "Date"),
                                                yaxis = list(title = "Price"))

# Create candlestick chart of gold price
gold_candlestick_chart <- plot_ly(gold_data, x = ~Date, type = "candlestick",
                                  open = ~Open, high = ~High, low = ~Low, close = ~Price)
gold_candlestick_chart <- gold_candlestick_chart %>% layout(title = "Gold Price Candlestick Chart",
                                                            xaxis = list(title = "Date"))

# Create histogram of gold price distribution
gold_price_histogram <- plot_ly(gold_data, x = ~Price, type = "histogram", nbinsx = 50)
gold_price_histogram <- gold_price_histogram %>% layout(title = "Gold Price Distribution",
                                                        xaxis = list(title = "Price"),
                                                        yaxis = list(title = "Count"))

# Create scatter plot of gold price vs. volume
gold_price_volume_scatter <- plot_ly(gold_data, x = ~Price, y = ~Volume, type = "scatter", mode = "markers")
gold_price_volume_scatter <- gold_price_volume_scatter %>% layout(title = "Gold Price vs. Volume",
                                                                  xaxis = list(title = "Price"),
                                                                  yaxis = list(title = "Volume"))

# Create box plot of gold price by year
gold_price_year_boxplot <- plot_ly(gold_data, x = ~format(Date, "%Y"), y = ~Price, type = "box")
gold_price_year_boxplot <- gold_price_year_boxplot %>% layout(title = "Gold Price by Year",
                                                              xaxis = list(title = "Year"),
                                                              yaxis = list(title = "Price"))

# Create stacked bar chart of gold price change percentage by year
gold_chgpercent_year_bar <- plot_ly(gold_data, x = ~format(Date, "%Y"), y = ~Chg, type = "bar",
                                    marker = list(color = ifelse(gold_data$Chg >= 0, "green", "red")))
gold_chgpercent_year_bar <- gold_chgpercent_year_bar %>% layout(title = "Gold Price Change Percentage by Year",
                                                                xaxis = list(title = "Year"),
                                                                yaxis = list(title = "Change Percentage"))

# Show plots
gold_price_chart
gold_candlestick_chart
gold_price_histogram
gold_price_volume_scatter
gold_price_year_boxplot
gold_chgpercent_year_bar









                                                    







