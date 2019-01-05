library(tidyverse)
library(rvest)
library(stringr)

vis_wisdom_url <- "https://bookdown.org/content/2138/"

toc <- read_html(vis_wisdom_url) %>% html_nodes(".chapter")

id <- toc %>%
  html_attr("data-level") %>%
  forcats::fct_inorder()

depth <- str_count(id, fixed(".")) + 1

href <- toc %>%
  html_node("a") %>%
  html_attr("href") %>%
  str_c(vis_wisdom_url, .)

title <- toc %>%
  map_chr(. %>%
            html_nodes(xpath = "./a/node()[not(self::b)]") %>%
            html_text() %>%
            str_c(collapse = "") %>%
            str_trim()
  )

chapters <- tibble(id, title, depth, href)

chapters %>%
  filter(id != "", depth <= 3) %>%
  write_csv("vis-wisdom.csv")
