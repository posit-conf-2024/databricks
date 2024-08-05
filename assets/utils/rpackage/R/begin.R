#' @export
#' @import cli
#' @import fs
begin <- function() {
  r_environ <- path("~/.Renviron")
  if (file_exists(r_environ)) {
    env_file <- readLines(r_environ)
  } else {
    env_file <- NULL
  }
  env_file <- entry_environ(
    env_file,
    "DATABRICKS_HOST",
    "rstudio-partner-posit-default.cloud.databricks.com"
  )
  token_val <- "{{db-token}}"
  db_token <- "DATABRICKS_TOKEN"
  old_file <- env_file
  env_file <- entry_environ(env_file, db_token, token_val)
  if (length(env_file) > length(old_file)) {
    pwd <- readline(prompt = "- Enter password: ")
    token <- get_token(pwd)
    token_line <- env_file == paste0(db_token, "=", token_val)
    if (!is.null(token)) {
      env_file[token_line] <- paste0(db_token, "=", token)
    } else {
      env_file <- env_file[!token_line]
    }
  }
  cli_alert_info("Writing .Renviron file")
  writeLines(env_file, r_environ)

  source_proj <- path("/databricks")
  if (dir_exists(source_proj)) {
    local_proj <- "~/databricks"
    if (!dir_exists(local_proj)) {
      cli_alert_info("Copying project to your Home directory")
      dir_copy(source_proj, "~")
      check_rstudio <- try(RStudio.Version(), silent = TRUE)
      is_rstudio <- !inherits(check_rstudio, "try-error")
      if (is_rstudio) {
        cli_alert_info("Opening project")
        rstudioapi::openProject(local_proj)
      } else {
        cli_alert_info("Setting working directory")
        setwd(local_proj)
      }
    } else {
      cli_alert_info("Project already exists")
    }
  } else {
    cli_alert_warning(c(source_proj, " folder not found"))
  }
}

get_token <- function(x) {
  ret <- NULL
  if (x == "abc") {
    ret <- "ACTUAL TOKEN"
    cli_alert_info("Personal Access Token retrieved")
  } else {
    cli_alert_warning("Incorrect password")
  }
  ret
}

entry_environ <- function(x, entry, value) {
  found_entry <- substr(x, 1, nchar(entry)) == entry
  if (!any(found_entry)) {
    x <- c(x, paste0(entry, "=", value))
    cli_alert_info(c("Adding ", entry, " to .Renviron file"))
  } else {
    cli_alert_warning(c("Entry ", entry, " found"))
  }
  x
}

# DATABRICKS_HOST
