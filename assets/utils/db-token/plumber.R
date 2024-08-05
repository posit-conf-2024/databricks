library(plumber)

#* @apiTitle Databricks PAT
#* @apiDescription Returns PAT to use during workshop
#* @param pwd The pwd to access the token
#* @get /token
function(pwd = "") {
  ret <- ""
  expected_pwd <- Sys.getenv("API_PASSWORD", unset = NA)
  current_token <- Sys.getenv("CURRENT_TOKEN", unset = NA)
  if(!is.na(expected_pwd) && !is.na(current_token)) {
    if(pwd == expected_pwd) {
      ret <- current_token
    }    
  }
  ret
}

