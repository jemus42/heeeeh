library(readr)
library(stringr)

ebm <- read_lines("EBM_Gesamt___Stand_4._Quartal_2016.txt", locale = locale(encoding = "ISO-8859-1"))
# stringi::stri_enc_detect(ebm)

# ebm <- str_trim(ebm, "both")
# ebm[str_detect(ebm, "^\\d{3,5}")]

# Example EBM start in ebm[3098]


ebm_to_table <- function(ebm_txt) {
  ebm <- read_lines(ebm_txt, locale = locale(encoding = "ISO-8859-1"))
  
  ebm <- str_replace(ebm, pattern = "^\\s{9}", "")
  ebm <- ebm[str_detect(ebm, "^\\w")]
  ebm <- ebm[!(str_detect(ebm, "^(Stand)"))]
  ebm <- ebm[!(str_detect(ebm, "\\."))]
  ebm <- str_replace(ebm, "\\s\\w+\\,\\w+\\s$", "")
  ebm <- str_trim(ebm, "right")
  
  ebm_tab <- data.frame(ebm = str_extract(ebm, "^\\d+"),
                            ebmtext = str_replace(ebm, "^\\d+", ""))
  
  return(ebm_tab)
}


