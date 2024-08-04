# Download file:
# databricks fs cp dbfs:/databricks-datasets/lending-club-loan-stats/LoanStats_2018Q2.csv lendingclub.csv 

library(arrow)
library(readr)

lendingclub <- read_csv("assets/utils/lendingclub.csv")

write_parquet(lendingclub, "assets/utils/lendingclub.parquet")
