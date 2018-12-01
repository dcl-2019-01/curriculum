themes <- c("Explore", "Wrangle", "Visualize", "Model", "Program", "Communicate", "Workflow")

unit_row <- function(unit, title, updated, theme, week = "", n = 4) {
  ncol <- length(themes) + n
  start_col <- match(theme, tolower(themes))
  end_col <- start_col + n

  # if (identical(updated, "2018-01")) {
  #   title <- paste0(title, "*")
  # }

  week <- if (week == "") "<td></td>" else glue(  "<td id='week-{week}'>{week}</td>")
  left <- if (start_col > 1)   glue('  <td colspan="{start_col - 1}"></td>')
  right <- if (end_col < ncol) glue('  <td colspan="{ncol - end_col}"></td>')

  data <- glue('  <td colspan="{n + 1}"><a class="{theme}" href="{unit}.html">{title}</a></td>')

  paste0(c(
    glue('<tr>'),
    week,
    left,
    data,
    right,
    "</tr>"
  ), collapse = "\n")
}

week_tbody <- function(week_num, weeks, unit_index = load_units()) {
  week <- weeks[[week_num]]
  units <- lookup_units(week, unit_index)

  units_df <- tibble(
    unit = names(units),
    title = units %>% map_chr("title"),
    updated = units %>% map_chr("updated", .default = NA),
    theme = units %>% map_chr("theme"),
    week = c(week_num, rep("", length(units) - 1))
  )

  rows <- pmap_chr(units_df, unit_row)
  paste0(c("<tbody>", rows, "</tbody>"), collapse = "\n")

}

theme_index <- function(weeks, unit_index = load_units(), reverse = FALSE) {

  week <- seq_along(weeks)
  if (reverse) {
    week <- rev(week)
  }

  row_groups <- map(
    week,
    week_tbody,
    unit_index = unit_index,
    weeks = weeks
  )

  theme_headers <- paste(glue('    <th>{themes}</th>'), collapse = "\n")
  header <- glue('
    ---
    title: Theme index
    ---

    <table class="syllabus">
    <colgroup>
      <col class="week" />
      <col class="theme" />
      <col class="theme" />
      <col class="theme" />
      <col class="theme" />
      <col class="theme" />
      <col class="theme" />
      <col class="theme" />
      <col class="theme" />
      <col class="theme" />
    </colgroup>

    <thead>
    <tr>
      <th></th>
    {theme_headers}
      <th></th>
      <th></th>
    </tr>
    </thead>
    '
  )

  paste(c(header, row_groups, "</table>"), collapse = "\n")
}

