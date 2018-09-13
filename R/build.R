clean <- function() {
  old <- dir(here::here("docs"), pattern = "^[^_]", full.names = TRUE)
  old <- setdiff(old, here::here("docs/style.css"))
  unlink(old, recursive = TRUE)
}

build_units <- function() {
  # Update rmd files
  units_rmd <- dir(here::here("units"), pattern = "\\.Rmd$", full.names = TRUE)
  units_rmd %>%
    walk(render_rmd)

  # Copy Rmarkdown directories
  notes <- dir(here::here("units/"), pattern = "(_files|\\.md|diagrams)$", full.names = TRUE)
  notes %>% walk(file.copy, to = here::here("docs"), recursive = TRUE)

  syllabus <- load_syllabus()
  cur_week <- syllabus$`cur-week`
  weeks <- syllabus$weeks

  units <- load_units()
  supplements <- load_supplements()

  weeks[1:cur_week] %>%
    theme_index(units) %>%
    write_if_different(here::here("docs/index.md"))

  weeks %>%
    theme_index(units) %>%
    write_if_different(here::here("docs/upcoming.md"))

  supplements %>%
    supplements_index() %>%
    write_if_different(here::here("docs/supplements.md"))

  out_path <- here::here(paste0("docs/", names(units), ".md"))
  units %>%
    map2_chr(names(units), md_unit, supp_index = supplements, unit_index = units) %>%
    walk2(out_path, write_if_different)

}

build_storyboard <- function() {
  key_books <- books %>%
    filter(is.na(depth) | depth < 3) %>%
    transmute(
      book_id = forcats::fct_inorder(id),
      title
    )

  readings <- load_units() %>%
    map("readings") %>%
    discard(is.null) %>%
    map(. %>% keep(has_name, "book") %>% map_chr("book")) %>%
    enframe(name = "unit", value = "book_id") %>%
    unnest(book_id) %>%
    mutate(book_id = factor(book_id, levels = levels(key_books$book_id)))

  unit_link <- function(x) {
    sprintf("[%s](https://dcl-2019-01.github.io/curriculum/%s.html)", x, x)
  }

  syllabus <- load_syllabus()
  unit_readings <- syllabus$weeks %>%
    enframe("week", "unit") %>%
    unnest(unit) %>%
    left_join(readings, by = "unit") %>%
    group_by(week, book_id) %>%
    summarise(units = paste0(unit_link(unit), collapse = ", "))

  storyboard <- key_books %>%
    expand(book_id, week = sprintf("week-%02d", 1:10)) %>%
    left_join(unit_readings, by = c("book_id", "week")) %>%
    replace_na(list(units = "")) %>%
    left_join(key_books, by = "book_id") %>%
    select(book_id, title, everything()) %>%
    spread(week, units) %>%
    knitr::kable()

  write_if_different(
    paste0(storyboard, collapse = "\n"),
    here::here("storyboard.md"),
    check = FALSE
  )
}


build_overview <- function() {
  raw_units <- load_units()
  units <- tibble(
    name = raw_units %>% names(),
    label = gsub("-", "\n", name),
    theme = raw_units %>% map_chr("theme"),
    needs = raw_units %>% map("needs")
  )

  needs <- units %>%
    select(name, needs) %>%
    filter(needs %>% map_lgl(~ !is_empty(.))) %>%
    unnest(needs)
  leads_to <- needs %>% select(name = needs, leads_to = name)

  needs_graph <- igraph::graph_from_data_frame(leads_to, vertices = units)
  set.seed(1014)

  ggraph(needs_graph, layout = "nicely") +
    geom_edge_link(
      aes(
        start_cap = label_rect(node1.label),
        end_cap = label_rect(node2.label)
      ),
      arrow = arrow(length = unit(2, "mm"))
    ) +
    geom_node_label(aes(label = label, fill = theme), size = 3) +
    scale_y_reverse() +
    theme_void() +
    scale_fill_brewer(palette = "Set2")

  writing("overview.png")
  ggsave(here::here("overview.png"), width = 12, height = 8, dpi = 96)
}
