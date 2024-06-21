library(sparklyr)
library(dplyr)
sc <- spark_connect(method = "databricks_connect")
lendingclub_dat <- tbl(sc, dbplyr::in_catalog("hive_metastore", "default", "lendingclub"))

lendingclub_sample <- lendingclub_dat |> 
  select(int_rate, term, bc_util, bc_open_to_buy, all_util) |> 
  slice_sample(n = 1000) |> 
  collect()

library(tidymodels)

lendingclub_rec <- recipe(
  int_rate ~ ., 
  data = lendingclub_sample
  ) |> 
  step_mutate(
    int_rate = as.numeric(stringr::str_remove(int_rate, "%")),
    term = trimws(substr(term, 1,4))
  ) |> 
  step_mutate(across(everything(), as.numeric)) |> 
  step_normalize(all_numeric_predictors()) |>
  step_impute_mean(all_of(c("bc_open_to_buy", "bc_util"))) |>   
  step_filter(!if_any(everything(), is.na)) 

lendingclub_lr <- linear_reg()

lendingclub_wf <- workflow() |> 
  add_model(lendingclub_lr) |> 
  add_recipe(lendingclub_rec) 

lendingclub_fit <- lendingclub_wf |> 
  fit(data = lendingclub_sample)

lendingclub_fit

lendingclub_predict <- function(x) predict(lendingclub_fit, x)

predict(lendingclub_fit, lendingclub_sample)

lendingclub_dat |> 
  head() |> 
  spark_apply(lendingclub_predict) 
