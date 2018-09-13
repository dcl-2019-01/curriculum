write_if_different <- function(contents, path, check = TRUE) {
  if (!file.exists(dirname(path))) {
    dir.create(dirname(path), showWarnings = FALSE)
  }

  if (same_contents(path, contents))
    return(invisible(FALSE))

  writing(basename(path))
  write_file(contents, path)

  invisible(TRUE)
}

same_contents <- function(path, contents) {
  if (!file.exists(path)) return(FALSE)

  text_hash <- digest::digest(contents, serialize = FALSE)
  file_hash <- digest::digest(file = path)

  identical(text_hash, file_hash)
}

writing <- function(path) {
  cat_line("Writing ", crayon::blue(encodeString(path, quote = "'")))
}
