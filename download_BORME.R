library("BOE")

dates <- seq(from = as.Date("01/01/2009", "%d/%m/%Y"), to = Sys.Date(), by = 1)

BORME <- lapply(dates, function(x){
    sumario_hoy <- try(retrieve_sumario(x, journal = "BORME"), silent = TRUE)
    if (is(sumario_hoy, "try-error")) {
        return(NULL)
    }
    write.csv(sumario_hoy, file.path("../BORME", paste0(x, ".csv")))
    sumario_hoy
})
k <- vapply(BORME, is.null, logical(1L))
BORME <- BORME[!k]
BORMEf <- do.call(rbind, BORME)
write.table(BORMEf, "../BORME/till_20191221.csv",sep = "\t", quote = TRUE, row.names = FALSE)
