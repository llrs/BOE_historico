library("rtweet")
library("BOE")
today <- Sys.Date()
httr::set_config(httr::config(ssl_verifypeer = FALSE))
url_sumario <- query_xml(sumario_xml(today, "BORME"))

valid_url <- function(url_in, t = 2){
    con <- url(url_in)
    r <- readLines(con, n = 2, encoding = "UTF-8")
    close(con)
    !grepl("No se encontr&#xF3; el sumario original.", r[2])
}

token <- rtweet::rtweet_bot(
    api_key =    Sys.getenv("TWITTER_API_KEY"),
    api_secret = Sys.getenv("TWITTER_API_SECRET_KEY"),
    access_token =    Sys.getenv("TWITTER_ACCESS_TOKEN"),
    access_secret =   Sys.getenv("TWITTER_ACCESS_SECRET_TOKEN")
)
rtweet::auth_as(token)
if (valid_url(url_sumario)) {
    rmarkdown::render_site("last_BORME.Rmd")
}
