library(tidyverse)
library(fs)

tcph_path <- path("utils/tpch_files")
if(!dir_exists(tcph_path)) dir_create(tcph_path)
if(!dir_exists(path(tcph_path, "tbls"))) dir_create(path(tcph_path, "tbls"))
if(!dir_exists(path(tcph_path, "csv"))) dir_create(path(tcph_path, "csv"))

files_url <- "https://github.com/aleaugustoplus/tpch-data/raw/master/"

file_customer <- path(tcph_path, "tbls", "customer.tbl.gz")  
if(!file_exists(file_customer)) {
  download.file(path(files_url, "customer.tbl.gz"), file_customer)
}

read_delim(
  file = file_customer,
  delim = "|", 
  col_names = c("c_custkey", "c_name", "c_address","c_nationkey", 
                "c_phone", "c_acctbal", "c_mktsegment","c_comment") 
  ) |> 
  select(1:8) |> 
  write_csv(path(tcph_path, "csv", "customer.csv")  )
