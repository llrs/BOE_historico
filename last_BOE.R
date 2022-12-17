library("rtweet")
library("BOE")
today <- Sys.Date()
httr::set_config(httr::config(ssl_verifypeer = FALSE))
url_sumario <- query_xml(sumario_xml(today, "BOE"))
token <- rtweet::rtweet_bot(
    api_key =    Sys.getenv("TWITTER_API_KEY"),
    api_secret = Sys.getenv("TWITTER_API_SECRET_KEY"),
    access_token =    Sys.getenv("TWITTER_ACCESS_TOKEN"),
    access_secret =   Sys.getenv("TWITTER_ACCESS_SECRET_TOKEN")
)
rtweet::auth_as(token)
rmarkdown::render_site("last_BOE.Rmd")
