library('BOE')
library("rtweet")
token <- rtweet::create_token(
    app = "BOE & BORME",
    consumer_key =    Sys.getenv("TWITTER_API_KEY"),
    consumer_secret = Sys.getenv("TWITTER_API_SECRET_KEY"),
    access_token =    Sys.getenv("TWITTER_ACCESS_TOKEN"),
    access_secret =   Sys.getenv("TWITTER_ACCESS_SECRET_TOKEN")
)
today <- Sys.Date()
boe <- retrieve_sumario(today)
disposiciones <- boe[!is.na(boe$epigraph), ]
message_length <- 280
link_hashtag <- 30 + 4
limit_text_message <- message_length - link_hashtag

unis <- disposiciones$departament == "UNIVERSIDADES"[]
resolucion <- grepl("resolución", x = disposiciones$text, ignore.case = TRUE)
convocatoria <- grepl("convocatoria", x = disposiciones$text, ignore.case = TRUE)
weights <- rep(0.1, seq_len(nrow(disposiciones)))
weights[unis] <- weights[unis] + 0.1
weights[convocatoria] <- weights[convocatoria] + 0.1

pick <- sample(seq_len(nrow(disposiciones)), 1, prob = weights)
split_text <- strsplit(disposiciones$text[pick], "\\s")[[1]]
characters <- cumsum(nchar(split_text) + 1)
if (any(characters >= limit_text_message)) {
    text_tweet <- paste0(split_text[characters + 4 < limit_text_message],
                         "...", collapse = " ")
} else {
    text_tweet <- disposiciones$text[pick]
}

message <- paste0(text_tweet, "\n#BOE:",
                  query_htm(disposiciones$publication[pick]),
                  collapse = "")
r <- post_tweet(status = message)