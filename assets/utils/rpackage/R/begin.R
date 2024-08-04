#' @export
#' @import cli
#' @import fs
begin <- function() {
  r_environ <- path("~/.Renviron")
  if(file_exists(r_environ)) {
    env_file <- readLines(r_environ)
  } else {
    env_file <- NULL
  }
  env_file <- entry_environ(
    env_file,
    "DATABRICKS_HOST",
    "rstudio-partner-posit-default.cloud.databricks.com"
    )
  env_file <- entry_environ(env_file, "DATABRICKS_TOKEN", "token")
  writeLines(env_file, r_environ)
}

entry_environ <- function(x, entry, value) {
  found_entry <- substr(x, 1, nchar(entry)) == entry
  if(sum(found_entry) == 0) {
    x <- c(x, paste0(entry, "=", value))
    cli_alert_info(c("Adding ", entry, " to .Renviron file" ))
  } else {
    cli_alert_warning(c("Entry ", entry, " found"))
  }
  x
}

# DATABRICKS_HOST
