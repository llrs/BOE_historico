setwd("/home/lluis/Documents/Projects/Explore_BOE/")
rmarkdown::render("last_BORME.Rmd",
                  quiet = TRUE, output_dir = "docs", clean = TRUE)
rmarkdown::render("last_BOE.Rmd",
                  quiet = TRUE, output_dir = "docs", clean = TRUE)
git2r::add(path = c(
    file.path(".", "docs", c("last_BOE.html", "last_BORME.html")),
    file.path(".", "docs", "site_libs", "*")))
git2r::commit(message = "Automatic commit to update last BOE and BORME")
git2r::push()
