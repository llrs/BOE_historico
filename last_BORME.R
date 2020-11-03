library("rtweet")
token <- rtweet::create_token(
    app = "BOE & BORME",
    consumer_key =    Sys.getenv("TWITTER_API_KEY"),
    consumer_secret = Sys.getenv("TWITTER_API_SECRET_KEY"),
    access_token =    Sys.getenv("TWITTER_ACCESS_TOKEN"),
    access_secret =   Sys.getenv("TWITTER_ACCESS_SECRET_TOKEN")
)
rmarkdown::render("last_BORME.Rmd",
                  quiet = TRUE, output_dir = "docs", clean = TRUE)