# Databricks with R - Presentation

To view the published version: https://colorado.posit.co/rsc/edgar/positconf2023/


## Publish to Posit Connect

```r
setwd(here::here("datbricks"))
app_files <- fs::dir_ls()
app_files <- app_files[!grepl("qmd", app_files)]
app_files <- app_files[!grepl("rsconnect", app_files)]
rsconnect::writeManifest(
  appPrimaryDoc = "posit-conf-databricks.html",
  appFiles = app_files
)
```
