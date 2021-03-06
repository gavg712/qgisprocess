
# I wish this were less of a hack - this is probably subject to
# bugs related to encodings and special characters in output strings
qgis_parse_results <- function(algorithm, output) {
  sec_results <- stringr::str_match(
    output,
    stringr::regex(
      "-+\\s+Results\\s+-+\\s+(.*)",
      dotall = TRUE, multiline = TRUE
    )
  )[, 2, drop = TRUE]

  output_lines <- readLines(textConnection(trimws(sec_results)))
  outputs <- stringr::str_split(output_lines, "\\s*:\\s*", n = 2)
  outputs_list <- lapply(outputs, "[", 2)
  output_names <- vapply(outputs, "[", 1, FUN.VALUE = character(1))

  algorithm_outputs <- qgis_outputs(algorithm)

  outputs_list <- Map(
    qgis_parse_result_output,
    outputs_list,
    algorithm_outputs$qgis_output_type[match(output_names, algorithm_outputs$name)]
  )

  names(outputs_list) <- output_names
  outputs_list
}

# All values of `qgis_output_type`
# c("outputVector", "outputRaster", "outputString", "outputFile",
#   "outputFolder", "outputHtml", "outputNumber", "outputMultilayer",
#   "outputLayer"
# )
qgis_parse_result_output <- function(value, qgis_output_type) {
  switch(
    qgis_output_type,

    # numbers and strings have clear mappings to R types
    outputNumber = as.numeric(value),
    outputString = value,

    # e.g., native::splitvectorlayer
    # a comma-separated list of values (hopefully without commas in
    # the filenames...)
    outputMultilayer = if (trimws(value) == "") {
      structure(character(0), class = "qgis_outputMultilayer")
    } else {
      structure(stringr::str_split(value, "\\s*,\\s*")[[1]], class = "qgis_outputMultilayer")
    },

    # by default, a classed string that can be reinterpreted by
    # various functions
    structure(value, class = paste0("qgis_", qgis_output_type))
  )
}
