#### Experimentation ####

library(stringr) # String manipulation
library(rvest)   # For HTML magic
library(dplyr)   # %>% and other magic
library(tidyr)   # For extended cleanup I'm to lazy to implement in base R


# src: http://www.kbv.de/html/85.php
# "EBM zur Offlineverwendung" -> Download einer zip-Datei

#### Regular EBM files (one html file per EBM, usually) ####
ebm_files <- list.files("EBMBrowserHtml/ebm/html/", pattern = "^\\d{3}.*", full.names = T)

parse_ebm_file <- function(file) {
  raw <- read_html(file, encoding = "ISO-8859-1")

  # Code
  raw_code <- html_node(raw, ".ebm_head:nth-child(1)")
  raw_code <- html_text(raw_code)
  #code     <- str_extract(raw_code, "^\\w*")
  code     <- str_extract(raw_code, "^.*\\r") %>% str_replace("\\r", "")

  if (str_detect(code, " - ")) {
    code <- str_split(code, " - ", 2, simplify = T)[1, ]
  }

  # Beschreibung (Titel)
  #raw_label <- html_node(raw, ".ebm_head:nth-child(2)")
  raw_label <- html_node(raw, ".ebm_sectiontext:nth-child(4)")
  label     <- html_text(raw_label)
  label     <- str_replace_all(label, "\\r\\n", "")
  labek     <- str_trim(label, "both")

  # Preis
  raw_price <- html_node(raw, "tr:nth-child(2) .ebm_leistungsum")
  price     <- html_text(raw_price)

  # Punkte
  # raw_points <- html_node(raw, "tr:nth-child(1) .ebm_leistungsum")
  # points     <- html_text(raw_points)

  # Assemble and return
  tbl   <- tibble(ebmcode = code, ebmlabel = label, price = price)

  return(tbl)
}


ebm_html <- plyr::ldply(ebm_files, parse_ebm_file, .progress = "text")

#### Get old EBMs for completion's sake ####

ebm_old <- read_html("EBMBrowserHtml/ebm/html/4_162394112750509016313156.html", encoding = "ISO-8859-1")
ebm_old <- html_table(ebm_old, fill = TRUE)
ebm_old <- ebm_old[[3]]
ebm_old <- ebm_old[-1, c(1, 2)]
ebm_old <- ebm_old[ebm_old[1] != "", ]
names(ebm_old) <- names(ebm_html)[c(1, 2)]

#### "Nicht gesondert berechnungsfähige ..." ####

ebm_special <- read_html("EBMBrowserHtml/ebm/html/1_162398017933962904420416.html", encoding = "ISO-8859-1")
ebm_special <- html_table(ebm_special, fill = TRUE)
ebm_special <- ebm_special[[3]]
ebm_special <- ebm_special[ebm_special$X1 != "", c("X1", "X2")]
ebm_special <- ebm_special[-1, ]
names(ebm_special) <- c("ebmcode", "ebmlabel")

# Strip text from ebmcode, convert to , or handle separately

ebm_special$ebmcode <- str_replace_all(ebm_special$ebmcode, pattern = "Aus ", replacement = "")
ebm_special$ebmcode <- str_replace_all(ebm_special$ebmcode, pattern = "/", replacement = ",")
ebm_special         <- tidyr::separate_rows(ebm_special, ebmcode, sep = ", ")

#### Union individual tables and write ####

# ebm_tabelle_full         <- dplyr::bind_rows(ebm_html, ebm_old, ebm_special)

# Bind explicitly only previously unmatched ebmcodes
ebm_tabelle_full <- bind_rows(ebm_html,
                              filter(ebm_old, !(ebm_old$ebmcode %in% ebm_html$ebmcode)))
ebm_tabelle_full <- bind_rows(ebm_tabelle_full,
                              filter(ebm_special, !(ebm_special$ebmcode %in% ebm_tabelle_full$ebmcode)))

# Guess NA price from value below to easily identify duplicate rows
ebm_html         <- tidyr::fill(ebm_tabelle_full, price, .direction = "up")
# Remove duplicate rows
ebm_html         <- dplyr::distinct(ebm_html)
ebm_html$ebmcode <- as.character(ebm_html$ebmcode)

# Write table to disk
readr::write_delim(ebm_tabelle_full, "ebm_tabelle.csv", delim = ";")
saveRDS(ebm_tabelle_full, file = "ebm_tabelle.RDS")


