library(sparklyr)
library(dplyr)
sc <- spark_connect(method = "databricks_connect")
lendingclub_dat <- tbl(sc, dbplyr::in_catalog("hive_metastore", "default", "lendingclub"))

lendingclub_sample <- lendingclub_dat |>  
  slice_sample(n = 2000) |> 
  collect()

lendingclub_prep <- lendingclub_sample |> 
  select(int_rate, term, bc_util, bc_open_to_buy, all_util) |> 
  mutate(
    int_rate = as.numeric(stringr::str_remove(int_rate, "%"))
    )

library(tidymodels)

lendingclub_rec <- recipe(int_rate ~ ., data = lendingclub_prep) |> 
  step_mutate(term = trimws(substr(term, 1,4))) |> 
  step_mutate(across(everything(), as.numeric)) |> 
  step_normalize(all_numeric_predictors()) |>
  step_impute_mean(all_of(c("bc_open_to_buy", "bc_util"))) |>   
  step_filter(!if_any(everything(), is.na)) 

lendingclub_lr <- linear_reg()

lendingclub_wf <- workflow() |> 
  add_model(lendingclub_lr) |> 
  add_recipe(lendingclub_rec) 

lendingclub_fit <- lendingclub_wf |> 
  fit(data = lendingclub_prep)

lendingclub_fit

lendingclub_fit |> 
  augment(lendingclub_prep) |> 
  metrics(int_rate, .pred)

library(ggplot2)

predict(lendingclub_fit, lendingclub_sample) |> 
  ggplot() +
  geom_histogram(aes(.pred))

library(vetiver)
library(pins)

v <- vetiver_model(lendingclub_fit, "lendingclub_model")

board <- board_connect(
  auth = "manual",
  server = Sys.getenv("CONNECT_SERVER"),
  key = Sys.getenv("CONNECT_API_KEY")
)

board |> 
  vetiver_pin_write(v)

predict_vetiver <- function(x) {
  library(workflows)
  board <- pins::board_connect(
    auth = "manual", 
    server = "https://connect.posit.it/",
    key = "Ag32KJvRRjhPHYJhWAIiZtSp9OnLbcJB"
  )
  model <- vetiver::vetiver_pin_read(board, "edgar/lendingclub_model")
  preds <- predict(model, x)
  x$pred <- preds[,1][[1]]
  x[x$pred >= 20, ]
}

predict_vetiver(lendingclub_prep)

lendingclub_dat |> 
  select(int_rate, term, bc_util, bc_open_to_buy, all_util) |> 
  spark_apply(predict_vetiver) |> 
  count()
