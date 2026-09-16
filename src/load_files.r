# Script to load files in the main pipeline
# Generalized to accept any number (2+) of uploaded datasets/categories.

# Read every uploaded file into a named list of data frames
# (names default to the file name, sans extension)
raw_dfs_list <- reactive({
    files <- req(input$dfs_upload)
    dfs <- lapply(seq_len(nrow(files)), function(i) {
        df <- read.csv(files$datapath[i], sep = "\t", quote = "")
        trim_dataframe(df)
    })
    names(dfs) <- tools::file_path_sans_ext(files$name)
    dfs
})

# ReactiveVal holding the current (possibly parsed/renamed) list of dfs
dfs_rv <- reactiveVal(list())

# Initialize/replace with raw data whenever files are (re)uploaded
observeEvent(raw_dfs_list(), {
    dfs_rv(raw_dfs_list())
})

n_datasets <- reactive({
    length(dfs_rv())
})

# One rename input per uploaded dataset (defaults to the file-derived name)
output$dataset_rename_ui <- renderUI({
    dfs <- dfs_rv()
    if (!length(dfs)) return(NULL)
    tagList(
        tags$strong("Name each dataset's category:"),
        lapply(seq_along(dfs), function(i) {
            textInput(
                inputId = paste0("user_text_cat", i),
                label = tooltip(
                    trigger = list(
                        paste0("Rename dataset ", i, " (optional)"),
                        bs_icon("info-circle")
                    ),
                    HTML("You can choose to rename the category of this dataset. This is only a display property.")
                ),
                value = names(dfs)[i]
            )
        })
    )
})

# Resolved category names in upload order (falls back to the file-derived
# name if the user leaves the rename field blank)
cat_names_rv <- reactive({
    dfs <- req(dfs_rv())
    vapply(seq_along(dfs), function(i) {
        v <- input[[paste0("user_text_cat", i)]]
        if (is.null(v) || !nzchar(trimws(v))) names(dfs)[i] else trimws(v)
    }, character(1))
})

# Bind one preview table + one name label per dataset index
observe({
    dfs   <- dfs_rv()
    n     <- length(dfs)
    req(n > 0)
    names_vec <- cat_names_rv()

    lapply(seq_len(n), function(i) {
        local({
            ii <- i
            name_txt <- reactive({
                nm <- cat_names_rv()
                paste0("Dataset ", ii, " (", nm[ii], ")")
            })
            output[[paste0("df_name_load_", ii)]]         <- renderText(name_txt())
            output[[paste0("df_name_find_lemmas_", ii)]]   <- renderText(name_txt())
            output[[paste0("df_preview_", ii)]] <- renderTable({
                req(dfs_rv())
                head(dfs_rv()[[ii]], n = 20L)
            })
        })
    })
})

# UI skeleton with one card (per dataset) for the Load Data tab
output$dataset_load_cards_ui <- renderUI({
    n <- n_datasets()
    req(n > 0)
    tagList(lapply(seq_len(n), function(i) {
        card(
            card_header(textOutput(paste0("df_name_load_", i))),
            tableOutput(paste0("df_preview_", i))
        )
    }))
})

# Action button: select col to parse (choices taken from the first dataset;
# the parse/rewrite operation below is applied to every dataset)
observe({
    dfs <- dfs_rv()
    req(length(dfs) > 0)
    updateSelectInput(
        session,
        "select_col_to_parse",
        choices = colnames(dfs[[1]])
    )
})

# Update text area with content of first cell when column selected
observeEvent(input$select_col_to_parse, {
    req(dfs_rv())
    req(input$select_col_to_parse)
    updateTextAreaInput(
    session,
    "cell_edit",
    value = NULL
    )
})

# Save rewritten column header back onto every dataset
observeEvent(input$save_text_cell, {
    dfs <- req(dfs_rv())
    req(input$select_col_to_parse)

    new_dfs <- lapply(dfs, function(d) {
        colnames(d)[colnames(d) == input$select_col_to_parse] <- input$cell_edit
        d
    })
    names(new_dfs) <- names(dfs)
    dfs_rv(new_dfs)
})

# Action button: replace every dataset with its parsed version
observeEvent(input$parse, {
    req(input$select_col_to_parse, input$cell_edit, input$sep_parse)
    dfs <- req(dfs_rv())
    col_name <- input$select_col_to_parse  # column name
    name_parts <- strsplit(input$cell_edit, input$sep_parse, fixed = TRUE)[[1]]

    new_dfs <- lapply(dfs, function(current_df) {
        current_df %>%
            separate_wider_delim(
                cols = all_of(col_name),
                delim = input$sep_parse,
                names = name_parts,
                too_many = "merge"
            )
    })
    names(new_dfs) <- names(dfs)
    dfs_rv(new_dfs)  # replace every dataset with its parsed version
})
