library("BOE")
library("xml2")
library("tictoc")
year <- 2009
number <- 1

# For year 2009 the last A is BOE-A-2009-21238
tic()
while (TRUE) {
    code <- paste0("BOE-A-", year, "-", number)
    file <- paste0("../BOE_xml/", code, ".xml")
    if (file.exists(file)) {
        number <- number + 1
    }
    x <- tryCatch(get_xml(query_xml(code)),
             error = function(x){
                 FALSE
             })
    if (is.logical(x)) {
        number <- 1
        year <- year + 1
        if (year == 2020) {
            stop("Finish")
        }
    } else {
        number <- number + 1
        xml2::write_xml(x = x, file = file)
    }
}
toc()
beepr::beep()