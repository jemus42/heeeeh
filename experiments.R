#### Experimentation ####

library(stringr) # String manipulation
library(rvest)   # For HTML magic
library(dplyr)


##### src: http://www.kbv.de/html/85.php
# "EBM zur Offlineverwendung" -> Download einer zip-Datei


ebm_files <- list.files("EBMBrowserHtml/ebm/html/", pattern = "^\\d{3}.*", full.names = T)

ebm_tabelle <- plyr::ldply(ebm_files, function(file) {
                  
                  raw <- read_html(file, encoding = "ISO-8859-1")
                  
                  # Code
                  raw_code <- html_node(raw, ".ebm_head:nth-child(1)")
                  raw_code <- html_text(raw_code)
                  code     <- str_extract(raw_code, "^\\w*")
                  
                  # Beschreibung (Titel)
                  #raw_label <- html_node(raw, ".ebm_head:nth-child(2)")
                  raw_label <- html_node(raw, ":nth-child(4)")
                  label     <- html_text(raw_label)
                  
                  # Preis
                  raw_price <- html_node(raw, "tr:nth-child(2) .ebm_leistungsum")
                  price     <- html_text(raw_price)
                  
                  # Punkte
                  # raw_points <- html_node(raw, "tr:nth-child(1) .ebm_leistungsum")
                  # points     <- html_text(raw_points)
                  
                  # Assemble and return
                  tbl   <- tibble(ebmcode = code, ebmlabel = label, price = price)
                  
                  return(tbl)
                }, .progress = "text")

# Get old EBMs for completion's sake

ebm_old <- read_html("EBMBrowserHtml/ebm/html/4_162394112750509016313156.html")
ebm_old <- html_table(ebm_old, fill = TRUE)
ebm_old <- ebm_old[[3]]
ebm_old <- ebm_old[-1, c(1, 2)]
ebm_old <- ebm_old[ebm_old[1] != "", ]
names(ebm_old) <- names(ebm_tabelle)[c(1, 2)] 

# Union them

ebm_tabelle_full         <- dplyr::bind_rows(ebm_tabelle, ebm_old)
ebm_tabelle_full$ebmcode <- as.character(ebm_tabelle_full$ebmcode)

# Write table to disk
readr::write_delim(ebm_tabelle_full, "ebm_tabelle.csv", delim = ";")
saveRDS(ebm_tabelle_full, file = "ebm_tabelle.RDS")


