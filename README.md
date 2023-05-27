# Gold Price Prediction

This project code is focused on predicting the gold price using time series analysis. It utilizes various libraries in R for data manipulation, visualization, and modeling.

## Project Setup

Before running the code, make sure you have the required libraries installed. You can install them using the `install.packages()` function in R.

```R
library(tidyverse)
library(plotly)
library(lubridate)
library(forecast)
library(MLmetrics)
library(tseries)
library(TSstudio)
library(padr)
library(imputeTS)
theme_set(theme_minimal())
```

## Data Loading

The code assumes that you have a CSV file named "Gold Price.csv" located in the specified path. The data is loaded into the `gold` data frame using the `read_csv()` function.

```R
gold <- read_csv("G:/Project M.Sc/Gold Price.csv")
```

## Exploratory Data Analysis

To understand the structure and content of the data, you can use the following commands:

```R
glimpse(gold)  # Data structure
head(gold)     # First 6 observations
summary(gold)  # Summarize the data
```

## Data Cleaning

To handle missing values in the data, the code checks for missing values in each column using `colSums(is.na(gold))`. Additionally, duplicated rows are identified and removed using `gold[duplicated(gold) == TRUE,]`.

To impute NA values with the last observed value, the code utilizes the `na.locf()` function from the `padr` library.

```R
gold_clean <- gold %>% na.locf()
```

## Time Series Analysis

The code converts the `gold_clean$Price` column into a time series object (`gold_ts`) using the `ts()` function. The start year is set to 2014, and the frequency is set to 7*4*12 (weekly data).

```R
gold_ts <- ts(data = gold_clean$Price,
              start = 2014,
              frequency = 7*4*12)
```

### Visualizing Time Series

The code provides various visualizations for the time series data using the `autoplot()` and `plot.ts()` functions.

```R
autoplot(gold_ts)  # Time series plot
plot.ts(gold_ts, main = "Gold ETF Prices (Daily)")  # Line plot
```

### Decomposition

To decompose the time series into its components (trend, seasonality, and remainder), the code uses the `decompose()` function from the `forecast` library.

```R
gold_decompose <- gold_ts %>% decompose(type = "multiplicative")
```

You can visualize the decomposed components using:

```R
autoplot(gold_decompose)  # Decomposed time series plot
autoplot(gold_decompose$seasonal)  # Seasonal component plot
```

### Seasonal Analysis

The code performs a seasonal analysis by aggregating the seasonal component by month and plotting the total seasonal effect for each month.

```R
gold_clean %>%
  mutate(Month = month(Date, label = TRUE)) %>%
  mutate(seasons = gold_decompose$seasonal) %>%
  group_by(Month) %>%
  summarise(total = sum(seasons)) %>%
  ggplot(aes(Month, total)) +
  geom_col() +
  theme_minimal()
```

## Modeling and Forecasting

The code splits the time series data into training and test sets. The first part of the data (`train`) is used for model training, and the remaining part (`test`) is used for evaluating the forecast accuracy.



```R
train <- head(gold_ts, -168)  # Train data
test <- tail(gold_ts, 168)  # Test data
```

### Holt-Winters Model

The code fits a Holt-Winters model with multiplicative seasonality to the training data using the `HoltWinters()` function.

```R
gold_HWmodel <- HoltWinters(train, seasonal = "multiplicative")
```

The alpha, beta, and gamma values of the Holt-Winters model can be accessed using:

```R
gold_HWmodel$alpha
gold_HWmodel$beta
gold_HWmodel$gamma
```

The model is then used to forecast the future values (`gold_HWforecast`) for the specified forecast horizon (`h`).

```R
gold_HWforecast <- forecast(gold_HWmodel, h = 168)
```

You can visualize the original time series, the fitted values, and the forecasted values using `autoplot()` and `autolayer()`.

```R
autoplot(gold_ts) +
  autolayer(gold_HWmodel$fitted[, 1], lwd = 0.5, series = "HW model") +
  autolayer(gold_HWforecast$mean, lwd = 0.5, series = "Forecast 1 year")
```

### ARIMA Model

The code fits an ARIMA model with seasonal decomposition of time series by LOESS (STL) to the training data using the `stlm()` function.

```R
gold_arima_stl <- stlm(y = train, method = "arima")
```

You can access the model details using `gold_arima_stl$model`.

Next, the ARIMA model is used to forecast future values (`gold_ARIMAforecast`) for the specified forecast horizon (`h`).

```R
gold_ARIMAforecast <- forecast(gold_arima_stl, h = 168)
```

The forecasted values and the original time series can be visualized using `autoplot()` and `autolayer()`.

```R
autoplot(gold_ts) +
  autolayer(gold_arima_stl$fitted, lwd = 0.5, series = "ARIMA model") +
  autolayer(gold_ARIMAforecast$mean, lwd = 0.5, series = "Forecast 1 year")
```

## Model Evaluation

The code calculates the Mean Absolute Percentage Error (MAPE) for both the Holt-Winters and ARIMA models using the `MAPE()` function from the `MLmetrics` library.

```R
MAPE(gold_HWmodel$fitted[, 1], train) * 100  # MAPE for Holt-Winters model
MAPE(gold_HWforecast$mean, test) * 100  # MAPE for Holt-Winters forecast

MAPE(gold_arima_stl$fitted, train) * 100  # MAPE for ARIMA model
MAPE(gold_ARIMAforecast$mean, test) * 100  # MAPE for ARIMA forecast
```

## Model Diagnostics

The code performs diagnostic tests on the ARIMA model, including the Ljung-Box test and the Shapiro-Wilk normality test on the residuals.

```R
Box.test(gold_arima_stl$residuals, type = "Ljung-Box")  # Ljung-Box test
shapiro.test(gold_arima_stl$residuals)  # Shapiro-Wilk test
```

