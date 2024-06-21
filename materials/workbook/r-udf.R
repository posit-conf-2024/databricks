library(sparklyr)
library(dplyr)
sc <- spark_connect(method = "databricks_connect")
lendingclub_dat <- tbl(sc, dbplyr::in_catalog("hive_metastore", "default", "lendingclub"))


lendingclub_sample <- lendingclub_dat |> 
  slice_sample(n = 1000) |> 
  collect()


library(tidymodels)

lendingclub_prep <- lendingclub_sample |> 
  select(int_rate, term, bc_util, bc_open_to_buy, all_util) |> 
  mutate(
    int_rate = substr(int_rate, 1, nchar(int_rate) - 1),
    term = trimws(substr(term, 1,4))
    ) |> 
  mutate(across(everything(), as.numeric)) |> 
  filter(!if_any(everything(), is.na)) 

rec_lendingclub <- recipe(int_rate ~ ., data = lendingclub_sample) |> 
  step_select(int_rate, term, bc_util, bc_open_to_buy, all_util) |> 
  step_mutate(
    #int_rate = substr(int_rate, 1, nchar(int_rate) - 1),
    term = trimws(substr(term, 1,4))
  ) |> 
  step_mutate(across(everything(), as.numeric)) |> 
  step_normalize(all_numeric_predictors()) |>
  step_impute_mean(all_of(c("bc_open_to_buy", "bc_util"))) |>   
  step_filter(!if_any(everything(), is.na)) 

linear_lendingclub <- linear_reg()

workflow_lendingclub <- workflow() |> 
  add_model(linear_lendingclub) |> 
  add_recipe(rec_lendingclub) 

fit_lendingclub <- workflow_lendingclub |> 
  fit(data = lendingclub_sample)
