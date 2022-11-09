library('BOE')
suppressPackageStartupMessages({library("rtweet")})
suppressPackageStartupMessages({library("poorman")})
token <- rtweet::rtweet_bot(
    api_key =    Sys.getenv("TWITTER_API_KEY"),
    api_secret = Sys.getenv("TWITTER_API_SECRET_KEY"),
    access_token =    Sys.getenv("TWITTER_ACCESS_TOKEN"),
    access_secret =   Sys.getenv("TWITTER_ACCESS_SECRET_TOKEN")
)
rtweet::auth_as(token)
today <- Sys.Date()
print(list.files(pattern = "*.RDS"))
if (file.access("boe-hoy.RDS", mode = "4") == 0) {
    message("Artifact downloaded and found.")
    boe <- readRDS("boe-hoy.RDS")
} else {
    message("Data downloaded from the website.")
    boe <- retrieve_sumario(today)
    boe <- boe[!is.na(boe$epigraph), ]
}

if (nrow(boe) == 0) {
    message("BOE is empty")
    boe <- retrieve_sumario(today)
    boe <- boe[!is.na(boe$epigraph), ]
}

if (boe$date[1] != today) {
    message("Retrieve ne data")
    boe <- retrieve_sumario(today)
    boe <- boe[!is.na(boe$epigraph), ]
}

# Run code if there are message to post
if (nrow(boe) > 0) {

    departaments <- boe %>%
        filter(!is.na(epigraph)) %>%
        count(departament, sort = TRUE) %>%
        pull(departament) %>%
        .[1]

    message("Posting about:", departaments)
    # Remove it from future tweets:
    boe2 <- filter(boe, !departament %in% departaments, !is.na(epigraph))
    saveRDS(boe2,  "boe-hoy.RDS")

    pre_message <- boe %>%
        filter(!is.na(epigraph), departaments == departament) %>%
        count(section_number, epigraph, sort = TRUE) %>%
        mutate(section_number = gsub("[IV].*\\. ", "", section_number)) %>%
        mutate(epigraph = case_when(
            section_number == "Oposiciones y concursos" ~ paste(section_number, "a", tolower(epigraph)),
            TRUE ~ epigraph)) %>%
        select(epigraph, n)

    msg <- paste(apply(pre_message, 1, function(x){paste(rev(x), collapse = " ")}), collapse = ", ")

    header <- c("Hoy en el #BOE: ", "Publicado en el #BOE: ")
    h <- sample(header, 1)

    message_length <- 280
    link_hashtag <- 30
    limit_text_message <- message_length - link_hashtag
    msg <- paste0(h, tolower(departaments), ": ", msg)

    if (nchar(msg) > limit_text_message) {
        split_text <- strsplit(msg, "\\s")[[1]]
        characters <- cumsum(nchar(split_text) + 1)
        text_tweet <- paste(split_text[characters + 4 < limit_text_message],
                            collapse = " ")
        text_tweet <- paste0(text_tweet, "...")
    } else {
        text_tweet <- msg
    }

    message(text_tweet)
    message <- paste0(text_tweet, ": ",
                      "https://llrs.github.io/BOE_historico/last_BOE.html",
                      collapse = "")
    r <- post_tweet(status = message)
}
