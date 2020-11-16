library('BOE')
library("rtweet")
library("poorman")
token <- rtweet::create_token(
    app = "Boletines Españoles",
    consumer_key =    Sys.getenv("TWITTER_API_KEY"),
    consumer_secret = Sys.getenv("TWITTER_API_SECRET_KEY"),
    access_token =    Sys.getenv("TWITTER_ACCESS_TOKEN"),
    access_secret =   Sys.getenv("TWITTER_ACCESS_SECRET_TOKEN")
)

today <- Sys.Date()
if (file.exists("boe-hoy.RDS")) {
    boe <- readRDS("boe-hoy.RDS")
} else {
    boe <- retrieve_sumario(today)
}

if (boe$date[1] != today) {
    boe <- retrieve_sumario(today)
    boe <- boe[!is.na(boe$epigraph), ]
}

departaments <- boe %>%
    filter(!is.na(epigraph)) %>%
    count(departament, sort = TRUE) %>%
    pull(departament) %>%
    .[1]

# Remove it from future tweets:
boe <- filter(boe, !departament %in% departaments & !is.na(epigraph))
saveRDS(boe,  "boe-hoy.RDS")

pre_message <- boe %>%
    filter(!is.na(epigraph) & departament %in% departaments) %>%
    group_by(section_number, epigraph) %>%
    count(sort = TRUE) %>%
    ungroup() %>%
    mutate(section_number = gsub("[IV].*\\. ", "", section_number)) %>%
    mutate(epigraph = case_when(
        section_number == "Oposiciones y concursos" ~ paste(section_number, "a", tolower(epigraph)),
                                TRUE ~ epigraph)) %>%
    select(epigraph, n)

msg <- paste(apply(pre_message, 1, function(x){paste(rev(x), collapse = " ")}), collapse = ", ")

message_length <- 280
link_hashtag <- 30
limit_text_message <- message_length - link_hashtag

msg <- paste0("Hoy en el #BOE; ", tolower(departaments), ": ", msg)

if (nchar(msg) > limit_text_message) {
    split_text <- strsplit(msg, "\\s")[[1]]
    characters <- cumsum(nchar(split_text) + 1)
    text_tweet <- paste(split_text[characters + 4 < limit_text_message],
                        collapse = " ")
    text_tweet <- paste0(text_tweet, "...")
} else {
    text_tweet <- msg
}

message <- paste0(text_tweet, ": ",
                  "https://llrs.github.io/BOE_historico/last_BOE.html",
                  collapse = "")
r <- post_tweet(status = message)
