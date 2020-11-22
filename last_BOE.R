library("rtweet")
library("BOE")
today <- Sys.Date()
url_sumario <- query_xml(sumario_xml(today, "BOE"))

valid_url <- function(url_in, t = 2){
    con <- url(url_in)
    r <- readLines(con, n = 2, encoding = "UTF-8")
    close(con)
    !grepl("No se encontr&#xF3; el sumario original.", r[2])
}
token <- rtweet::create_token(
    app = "Boletines Españoles",
    consumer_key =    Sys.getenv("TWITTER_API_KEY"),
    consumer_secret = Sys.getenv("TWITTER_API_SECRET_KEY"),
    access_token =    Sys.getenv("TWITTER_ACCESS_TOKEN"),
    access_secret =   Sys.getenv("TWITTER_ACCESS_SECRET_TOKEN")
)
if (valid_url(url_sumario)) {
    rmarkdown::render_site("last_BOE.Rmd")
}
