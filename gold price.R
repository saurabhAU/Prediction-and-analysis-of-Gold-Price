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


gold <- read_csv("G:/Project M.Sc/Gold Price.csv")
gold

glimpse(gold)  #Data structure 
head(gold)     # first 6 observations     

summary(gold)  #Summarize the data  


colSums(is.na(gold))   #To Check missing Values in any columns
 
colnames(gold)     #Names of Columns

gold[duplicated(gold) == TRUE,] 

gold <- gold %>% 
  pad(interval = "day") 
gold


# impute NA value with last day observation

gold_clean <- gold %>% na.locf()
gold_clean

colSums(is.na(gold_clean))


# ts
gold_ts <- ts(data = gold_clean$Price,
             start = 2014,
             frequency = 7*4*12)
gold_ts %>% 
  autoplot()

####
plot.ts(gold_ts, main="Gold ETF Prices (Daily)")

gold.dif <- diff(gold_ts)
plot.ts(gold.dif, main="Gold ETF Prices (Daily Differences)")

gold_decompose <- gold_ts %>% 
  decompose(type = "multiplicative")
  
gold_decompose %>% 
  autoplot()


gold_decompose$seasonal %>% 
  autoplot()


gold_clean %>% 
  mutate(Month = month(Date, label = T)) %>% 
  mutate(seasons = gold_decompose$seasonal) %>% 
  group_by(Month) %>% 
  summarise(total = sum(seasons)) %>%   
  ggplot(aes(Month, total)) +
  geom_col()+
  theme_minimal()


# train data
train <- head(gold_ts, -168)
# test data
test <- tail(gold_ts, 168)

# Making model using HoltWinters()
gold_HWmodel <- HoltWinters(train, seasonal = "multiplicative")

# alpha beta gamma
gold_HWmodel$alpha

gold_HWmodel$beta

gold_HWmodel$gamma

# forecasting
gold_HWforecast <- forecast(gold_HWmodel, h = 168)

# visualize
gold_ts %>% 
  autoplot() +
  autolayer(gold_HWmodel$fitted[,1], lwd = 0.5, 
            series = "HW model") +
  autolayer(gold_HWforecast$mean, lwd = 0.5,
            series = "Forecast 1 year")
MAPE(gold_HWmodel$fitted[,1], train)*100
MAPE(gold_HWforecast$mean, test)*100

gold_arima_stl <- stlm(y = train, method = "arima")
gold_arima_stl$model

# forecasting
gold_ARIMAforecast <- forecast(gold_arima_stl, h = 168)

# visualize
gold_ts %>% 
  autoplot() +
  autolayer(gold_arima_stl$fitted, lwd = 0.5, 
            series = "ARIMA model") +
  autolayer(gold_ARIMAforecast$mean, lwd = 0.5,
            series = "Forecast 1 year")
MAPE(gold_arima_stl$fitted, train)*100
MAPE(gold_ARIMAforecast$mean, test)*100

# ARIMA Model
Box.test(gold_arima_stl$residuals, type = "Ljung-Box")

shapiro.test(gold_arima_stl$residuals)





































