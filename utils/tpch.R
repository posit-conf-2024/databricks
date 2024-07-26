library(tidyverse)
library(arrow)
library(fs)

process_tcph_file <- function(x, col_names) {
  tcph_path <- path("utils/tpch_files")
  if (!dir_exists(tcph_path)) dir_create(tcph_path)
  if (!dir_exists(path(tcph_path, "tbls"))) dir_create(path(tcph_path, "tbls"))
  if (!dir_exists(path(tcph_path, "parquet"))) dir_create(path(tcph_path, "parquet"))

  files_url <- "https://github.com/aleaugustoplus/tpch-data/raw/master/"

  file_path <- path(tcph_path, "tbls", paste0(x, ".tbl.gz"))
  if (!file_exists(file_path)) {
    download.file(path(files_url, paste0(x, ".tbl.gz")), file_path)
  }

  read_delim(
    file = file_path,
    delim = "|",
    col_names = col_names
  ) |>
    select(1:length(col_names)) |>
    write_parquet(path(tcph_path, "parquet", x, ext = "parquet"))
}

process_tcph_file(
  x = "customer",
  col_names = c(
    "c_custkey", "c_name", "c_address", "c_nationkey",
    "c_phone", "c_acctbal", "c_mktsegment", "c_comment"
  )
)

process_tcph_file(
  x = "lineitem",
  col_names = c(
    "l_orderkey", "l_partkey", "l_suppkey", "l_linenumber",
    "l_quantity", "l_extendedprice", "l_discount", "l_tax",
    "l_returnflag", "l_linestatus", "l_shipdate", "l_commitdate",
    "l_receiptdate", "l_shipinstruct", "l_shipmode", "l_comment"
  )
)

process_tcph_file(
  x = "orders",
  col_names = c(
    "o_orderkey", "o_custkey", "o_orderstatus", "o_totalprice", 
    "o_orderdate", "order_priority", "o_clerk", "o_shippriority",
    "o_comment"
  )
)

process_tcph_file(
  x = "nation",
  col_names = c(
    "n_nationkey", "n_name", "n_regionkey", "n_comment"
  )
)

process_tcph_file(
  x = "region",
  col_names = c(
    "r_regionkey", "r_name", "r_comment"
  )
)

