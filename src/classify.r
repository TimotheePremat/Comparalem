# Classify concordancer rows by matching against user-uploaded reference files

ref_files_rv <- reactiveVal(list())

read_ref_files <- function(files, sep) {
    dfs <- lapply(seq_len(nrow(files)), function(i) {
        trim_dataframe(read.table(files$datapath[i], header = TRUE,
                                  sep = sep, stringsAsFactors = FALSE,
                                  quote = "\"", fill = TRUE))
    })
    names(dfs) <- tools::file_path_sans_ext(files$name)
    dfs
}

# Reload when files change or separator changes
observe({
    files <- input$ref_files
    sep   <- input$ref_sep
    req(files, sep)
    ref_files_rv(read_ref_files(files, sep))
})

# Render one rename input per uploaded file
output$ref_files_rename_ui <- renderUI({
    dfs <- ref_files_rv()
    if (!length(dfs)) return(NULL)
    tagList(
        # tags$hr(),
        tags$strong("Rename files:"),
        lapply(seq_along(dfs), function(i) {
            textInput(
                inputId = paste0("ref_name_", i),
                label   = paste0("Name for '", names(dfs)[i], "'"),
                value   = names(dfs)[i]
            )
        })
    )
})

# Column selector: which columns of concordancer to match on (multi)
output$match_col_concordancer_ui <- renderUI({
    conc <- req(concordancer_rv())
    selectInput("match_col_concordancer", "Concordancer columns to match on",
                choices = names(conc), multiple = TRUE)
})

# Column selector: which columns of reference files to match against (multi)
output$match_col_ref_ui <- renderUI({
    dfs <- req(ref_files_rv())
    if (!length(dfs)) return(NULL)
    common_cols <- Reduce(intersect, lapply(dfs, names))
    if (!length(common_cols)) common_cols <- names(dfs[[1]])
    prev_selected <- isolate(input$match_col_ref)
    valid_selected <- intersect(prev_selected, common_cols)
    selectInput("match_col_ref", "Reference columns to match against",
                choices = common_cols, multiple = TRUE,
                selected = if (length(valid_selected)) valid_selected else character(0))
})

# Column selector: which column's cell value to use as the tag (when not using filename)
output$tag_value_col_ui <- renderUI({
    dfs <- req(ref_files_rv())
    if (!length(dfs)) return(NULL)
    common_cols <- Reduce(intersect, lapply(dfs, names))
    if (!length(common_cols)) common_cols <- names(dfs[[1]])
    prev_selected <- isolate(input$tag_value_col)
    valid_selected <- intersect(prev_selected, common_cols)
    selectInput("tag_value_col", "Column whose value becomes the tag",
                choices = common_cols, multiple = FALSE,
                selected = if (length(valid_selected)) valid_selected[1] else common_cols[1])
})

# Enable annotate button only when all inputs are ready and col counts match
observe({
    conc_cols <- input$match_col_concordancer
    ref_cols  <- input$match_col_ref
    ready <- length(ref_files_rv()) > 0       &&
             !is.null(concordancer_rv())       &&
             length(conc_cols) > 0             &&
             length(ref_cols)  > 0             &&
             length(conc_cols) == length(ref_cols) &&
             isTRUE(nzchar(input$output_col_name))
    if (ready) shinyjs::enable("annotate_by_ref") else shinyjs::disable("annotate_by_ref")
})

# Annotate: for each row in concordancer, write the name of the first matching
# reference df whose reference column contains the concordancer column value
observeEvent(input$annotate_by_ref, {
    conc      <- req(concordancer_rv())
    dfs       <- req(ref_files_rv())
    conc_cols <- input$match_col_concordancer
    ref_cols  <- input$match_col_ref
    out_col   <- trimws(input$output_col_name)

    req(all(conc_cols %in% names(conc)), nzchar(out_col),
        length(conc_cols) == length(ref_cols))

    # Read current rename inputs
    df_names <- sapply(seq_along(dfs), function(i) {
        val <- input[[paste0("ref_name_", i)]]
        if (is.null(val) || !nzchar(val)) names(dfs)[i] else trimws(val)
    })

    # Build composite key for concordancer rows (all selected cols pasted together)
    conc_keys <- apply(conc[, conc_cols, drop = FALSE], 1,
                       function(r) paste(as.character(r), collapse = "|"))

    use_col   <- isTRUE(input$tag_value_source == "column")
    tag_col   <- if (use_col) input$tag_value_col else NULL

    # Pre-compute ref keys and (optionally) tag values for each df
    ref_keys_list <- lapply(seq_along(dfs), function(i) {
        df <- dfs[[i]]
        if (!all(ref_cols %in% names(df))) return(NULL)
        apply(df[, ref_cols, drop = FALSE], 1,
              function(r) paste(as.character(r), collapse = "|"))
    })

    conc[[out_col]] <- sapply(seq_len(nrow(conc)), function(j) {
        values <- character(0)
        for (i in seq_along(dfs)) {
            rk <- ref_keys_list[[i]]
            if (is.null(rk)) next
            hits <- which(rk == conc_keys[j])
            if (!length(hits)) next
            if (use_col && !is.null(tag_col) && tag_col %in% names(dfs[[i]])) {
                values <- c(values, as.character(dfs[[i]][[tag_col]][hits]))
            } else {
                values <- c(values, df_names[i])
            }
        }
        if (!length(values)) NA_character_ else paste(unique(values), collapse = ", ")
    })

    n_matched <- sum(!is.na(conc[[out_col]]))

    # Add new column to the displayed selection so it shows up immediately
    current_cols <- isolate(cols_selected_rv())
    if (!is.null(current_cols) && !(out_col %in% current_cols)) {
        cols_selected_rv(c(current_cols, out_col))
    }

    # Force full DT re-render (replaceData doesn't add new columns)
    concordancer_rv(conc)
    concordancer_render_trigger(isolate(concordancer_render_trigger()) + 1)

    showNotification(
        sprintf("Column '%s' written: %d / %d rows matched.", out_col, n_matched, nrow(conc)),
        type = "message", duration = 5
    )
})
