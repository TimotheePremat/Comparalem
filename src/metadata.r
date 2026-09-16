# Filter out texts using metadata columns

text_id_col_choices <- reactive({
    req(concordancer_rv())
    setdiff(names(concordancer_rv()), c("cat", "form_id"))
})

output$text_id_col_ui <- renderUI({
    choices  <- req(text_id_col_choices())
    saved    <- text_id_col_rv()
    selected <- if (!is.null(saved) && saved %in% choices) saved else ""
    selectInput(inputId = "text_id_col", label = "Set text-ID column",
                choices = c("— select —" = "", choices), selected = selected)
})

output$text_id_col_ui_desc <- renderUI({
    choices  <- req(text_id_col_choices())
    saved    <- text_id_col_rv()
    selected <- if (!is.null(saved) && saved %in% choices) saved else ""
    selectInput(inputId = "text_id_col", label = "Set text-ID column",
                choices = c("— select —" = "", choices), selected = selected)
})

observeEvent(input$text_id_col, {
    text_id_col_rv(input$text_id_col)
}, ignoreNULL = TRUE)

observe({
    id_set <- isTRUE(nzchar(input$text_id_col))
    btns <- c("coerce_col_numeric", "coerce_selected_to_numeric",
              "delete_text_filter", "delete_by_text_id",
              "undo_last_text_filter", "undo_all_text_filter")
    for (btn in btns) {
        if (id_set) shinyjs::enable(btn) else shinyjs::disable(btn)
    }
})

output$text_filtering_col_ui <- renderUI({
    req(concordancer_rv(), input$text_id_col)
    conc   <- concordancer_rv()
    id_col <- input$text_id_col
    req(id_col %in% names(conc))
    # Keep only columns where every text ID maps to exactly one unique value
    valid_cols <- Filter(function(col) {
    tbl <- unique(conc[, c(id_col, col), drop = FALSE])
    nrow(tbl) == length(unique(conc[[id_col]]))
    }, setdiff(names(conc), id_col))
    saved    <- isolate(text_filtering_col_rv())
    selected <- if (!is.null(saved) && saved %in% valid_cols) saved else valid_cols[1]
    selectInput(
    inputId  = "text_filtering_col",
    label    = "Column to filter on",
    choices  = valid_cols,
    selected = selected
    )
})

plotly_filter_range_rv <- reactiveVal(NULL)

observeEvent(input$text_filtering_col, {
    text_filtering_col_rv(input$text_filtering_col)
    plotly_filter_range_rv(NULL)
}, ignoreNULL = TRUE)

# Reactive: is the selected column numeric?
col_is_numeric <- reactive({
    req(concordancer_rv(), input$text_filtering_col)
    col <- trimws(input$text_filtering_col)
    req(col %in% names(concordancer_rv()))
    is.numeric(concordancer_rv()[[col]])
})

observe({
    req(concordancer_rv(), input$text_filtering_col)
    if (isTRUE(col_is_numeric())) {
    updateActionButton(session, "delete_text_filter", label = "Set interval", icon = icon("filter"))
    bslib::accordion_panel_open("filter_accordion", "View distribution", session = session)
    } else {
    updateActionButton(session, "delete_text_filter", label = "Exclude selected", icon = icon("trash"))
    }
})

# Coerce selected column to numeric in concordancer
observeEvent(input$coerce_col_numeric, {
    col  <- trimws(input$text_filtering_col)
    conc <- concordancer_rv()
    req(col %in% names(conc))
    old_type <- class(conc[[col]])[1]
    old_vals <- paste(sort(unique(conc[[col]][!is.na(conc[[col]])])), collapse = ", ")
    conc[[col]] <- suppressWarnings(as.numeric(conc[[col]]))
    new_vals <- paste(sort(unique(conc[[col]][!is.na(conc[[col]])])), collapse = ", ")
    log_info(sprintf("[coerce] '%s': %s -> numeric | old_values: [%s] | new_values: [%s]", col, old_type, old_vals, new_vals))
    concordancer_rv(conc)
})

output$text_filtering_table_container <- renderUI({
    req(!isTRUE(col_is_numeric()))
    DTOutput("text_filtering_table")
})

observe({
    ed <- event_data("plotly_relayout", source = "filter_plot")
    if (is.null(ed)) return()
    # plotly for R returns the range either as ed$xaxis.range (vector)
    # or as ed[["xaxis.range[0]"]] / ed[["xaxis.range[1]"]] depending on version
    rng <- NULL
    if (!is.null(ed[["xaxis.range[0]"]]) && !is.null(ed[["xaxis.range[1]"]])) {
        rng <- c(as.numeric(ed[["xaxis.range[0]"]]), as.numeric(ed[["xaxis.range[1]"]]))
    } else if (!is.null(ed[["xaxis.range"]]) && length(ed[["xaxis.range"]]) >= 2) {
        rng <- as.numeric(ed[["xaxis.range"]][1:2])
    }
    if (!is.null(rng) && !anyNA(rng)) plotly_filter_range_rv(rng)
})

last_filter_plot_rv <- reactiveVal(NULL)

output$save_filter_plot_ui <- renderUI({
    req(col_is_numeric())
    tagList(
        hr(),
        actionButton("save_filter_plot", "Save graph", icon = icon("download"), class = "mb-2")
    )
})

output$text_filtering_plot <- renderPlotly({
    req(input$text_filtering_col, input$text_id_col)
    col    <- trimws(input$text_filtering_col)
    id_col <- trimws(input$text_id_col)
    conc   <- concordancer_rv()
    req(conc, col %in% names(conc), id_col %in% names(conc))

    plot_df <- conc %>%
        dplyr::select(dplyr::all_of(c(id_col, col))) %>%
        dplyr::distinct() %>%
        dplyr::count(.data[[col]], name = "n_texts") %>%
        dplyr::arrange(.data[[col]])

    title_val <- if (nzchar(input$filter_plot_title))   input$filter_plot_title   else NULL
    x_lab     <- if (nzchar(input$filter_plot_x_label)) input$filter_plot_x_label else col
    y_lab     <- if (nzchar(input$filter_plot_y_label)) input$filter_plot_y_label else paste0("Number of ", id_col)

    p <- ggplot(plot_df, aes(x = .data[[col]], y = n_texts)) +
        geom_col(fill = "#4e79a7") +
        scale_y_continuous(expand = ggplot2::expansion(mult = c(0, 0.05))) +
        labs(x = x_lab, y = y_lab, title = title_val) +
        theme_classic(base_size = 14) +
        theme(axis.text.x = element_text(angle = 45, hjust = 1))

    pl <- ggplotly(p, source = "filter_plot")

    if (isTRUE(col_is_numeric())) {
        pl <- pl %>% plotly::layout(
            xaxis = list(rangeslider = list(visible = TRUE))
        )
    }

    last_filter_plot_rv(list(ggplot = p, col = col))
    pl
})

observeEvent(input$save_filter_plot, {
    saved <- req(last_filter_plot_rv())
    dir.create("../plots", showWarnings = FALSE)
    file_path <- file.path(
        "../plots",
        paste0("Corpus_", saved$col, "_", format(Sys.time(), "%Y-%m-%d_%H-%M-%S"), ".png")
    )
    ggsave(file_path, plot = saved$ggplot, width = 8, height = 5, dpi = 600)
    showNotification(
        paste0("Graph saved: Comparalem/plots/", basename(file_path)),
        type = "message", duration = 5
    )
})

observeEvent(input$delete_text_filter, {
    col  <- trimws(input$text_filtering_col)
    conc <- concordancer_rv()
    req(col %in% names(conc))

    if (isolate(col_is_numeric())) {
    rng <- plotly_filter_range_rv()
    if (is.null(rng)) rng <- range(conc[[col]], na.rm = TRUE)
    new_conc <- conc[!is.na(conc[[col]]) & conc[[col]] >= rng[1] & conc[[col]] <= rng[2], , drop = FALSE]
    } else {
    s <- input$text_filtering_table_rows_selected
    if (!length(s)) return()
    unique_vals <- sort(unique(conc[[col]]))
    vals        <- unique_vals[s]
    new_conc    <- conc[!(conc[[col]] %in% vals), , drop = FALSE]
    }

    stack <- concordancer_undo()
    concordancer_undo(c(stack, list(conc)))
    concordancer_rv(new_conc)
})

observeEvent(input$undo_last_text_filter, {
    stack <- concordancer_undo()
    if (length(stack) == 0) return()
    last_df <- tail(stack, 1)[[1]]
    concordancer_undo(stack[-length(stack)])
    concordancer_rv(last_df)
})

observe({
    s    <- input$coerce_metadata_table_rows_selected
    conc <- concordancer_rv()
    if (!length(s) || is.null(conc)) {
        shinyjs::disable("center_scale_col")
        shinyjs::disable("factorise_col")
        shinyjs::disable("unfactorise_col")
        shinyjs::disable("coerce_to_discrete_col")
        shinyjs::disable("restore_unscaled_col")
        return()
    }
    selected_cols <- names(conc)[s]
    all_numeric  <- all(sapply(selected_cols, function(col) is.numeric(conc[[col]])))
    all_discrete <- all(sapply(selected_cols, function(col) !is.numeric(conc[[col]])))
    all_factor   <- all(sapply(selected_cols, function(col) is.factor(conc[[col]])))
    if (all_numeric)  shinyjs::enable("center_scale_col")       else shinyjs::disable("center_scale_col")
    if (all_discrete) shinyjs::enable("factorise_col")          else shinyjs::disable("factorise_col")
    if (all_factor)   shinyjs::enable("unfactorise_col")        else shinyjs::disable("unfactorise_col")
    if (all_numeric)  shinyjs::enable("coerce_to_discrete_col") else shinyjs::disable("coerce_to_discrete_col")
    if (all_numeric)  shinyjs::enable("restore_unscaled_col")   else shinyjs::disable("restore_unscaled_col")
})

observeEvent(input$center_scale_col, {
    s <- input$coerce_metadata_table_rows_selected
    if (!length(s)) return()
    conc <- concordancer_rv()
    cols <- names(conc)[s]
    for (col in cols) {
        old_type <- class(conc[[col]])[1]
        old_vals <- paste(sort(unique(conc[[col]][!is.na(conc[[col]])])), collapse = ", ")
        conc[[col]] <- as.numeric(scale(conc[[col]]))
        new_vals <- paste(sort(unique(conc[[col]][!is.na(conc[[col]])])), collapse = ", ")
        log_info(sprintf("[center+scale] '%s': %s -> numeric | old_values: [%s] | new_values: [%s]", col, old_type, old_vals, new_vals))
    }
    concordancer_rv(conc)
    showNotification(paste0("Centered and scaled: ", paste(cols, collapse = ", ")),
                     type = "message", duration = 4)
})

observeEvent(input$factorise_col, {
    s <- input$coerce_metadata_table_rows_selected
    if (!length(s)) return()
    conc <- concordancer_rv()
    cols <- names(conc)[s]
    for (col in cols) {
        old_type <- class(conc[[col]])[1]
        old_vals <- paste(sort(unique(conc[[col]][!is.na(conc[[col]])])), collapse = ", ")
        conc[[col]] <- as.factor(conc[[col]])
        log_info(sprintf("[factorise] '%s': %s -> factor | old_values: [%s]", col, old_type, old_vals))
    }
    concordancer_rv(conc)
    showNotification(paste0("Factorised: ", paste(cols, collapse = ", ")),
                     type = "message", duration = 4)
})

observeEvent(input$unfactorise_col, {
    s <- input$coerce_metadata_table_rows_selected
    if (!length(s)) return()
    conc <- concordancer_rv()
    cols <- names(conc)[s]
    for (col in cols) {
        old_vals <- paste(sort(levels(conc[[col]])), collapse = ", ")
        conc[[col]] <- as.character(conc[[col]])
        log_info(sprintf("[unfactorise] '%s': factor -> character | old_values: [%s]", col, old_vals))
    }
    concordancer_rv(conc)
    showNotification(paste0("Unfactorised: ", paste(cols, collapse = ", ")),
                     type = "message", duration = 4)
})

observeEvent(input$coerce_to_discrete_col, {
    s <- input$coerce_metadata_table_rows_selected
    if (!length(s)) return()
    conc <- concordancer_rv()
    cols <- names(conc)[s]
    for (col in cols) {
        old_vals <- paste(sort(unique(conc[[col]][!is.na(conc[[col]])])), collapse = ", ")
        conc[[col]] <- as.character(conc[[col]])
        log_info(sprintf("[coerce to discrete] '%s': numeric -> character | old_values: [%s]", col, old_vals))
    }
    concordancer_rv(conc)
    showNotification(paste0("Coerced to discrete: ", paste(cols, collapse = ", ")),
                     type = "message", duration = 4)
})

observeEvent(input$restore_unscaled_col, {
    s <- input$coerce_metadata_table_rows_selected
    if (!length(s)) return()
    conc <- concordancer_rv()
    cols <- names(conc)[s]

    log_dir   <- "../Data/log"
    log_files <- list.files(log_dir, pattern = "\\.log$", full.names = TRUE)
    if (!length(log_files)) {
        showNotification("No log file found in Data/log.", type = "error")
        return()
    }
    log_file  <- log_files[which.max(file.mtime(log_files))]
    log_lines <- readLines(log_file, warn = FALSE)

    for (col in cols) {
        pattern <- sprintf("\\[center\\+scale\\].*'%s'", col)
        matches <- grep(pattern, log_lines, value = TRUE)
        if (!length(matches)) {
            showNotification(sprintf("No center+scale entry found for '%s' in log.", col), type = "warning")
            next
        }
        last_match <- tail(matches, 1)

        old_str      <- sub(".*old_values: \\[(.*?)\\].*", "\\1", last_match, perl = TRUE)
        new_str      <- sub(".*new_values: \\[(.*?)\\].*", "\\1", last_match, perl = TRUE)
        old_vals_vec <- as.numeric(strsplit(old_str, ", ")[[1]])
        new_vals_vec <- as.numeric(strsplit(new_str, ", ")[[1]])

        current  <- conc[[col]]
        non_na   <- !is.na(current)
        idx      <- integer(length(current))
        if (any(non_na)) {
            idx[non_na] <- apply(
                outer(current[non_na], new_vals_vec, function(a, b) abs(a - b)),
                1, which.min
            )
        }
        restored <- ifelse(non_na, old_vals_vec[idx], NA_real_)

        log_info(sprintf("[restore unscaled] '%s': %s unique values restored from '%s' | sample new->old: %s->%s",
            col, length(unique(restored[!is.na(restored)])),
            basename(log_file),
            round(new_vals_vec[1], 4), old_vals_vec[1]))

        conc[[col]] <- as.numeric(restored)
    }

    concordancer_rv(conc)
    showNotification(paste0("Restored unscaled: ", paste(cols, collapse = ", ")),
                     type = "message", duration = 4)
})

observeEvent(input$coerce_selected_to_numeric, {
    s    <- input$coerce_metadata_table_rows_selected
    if (!length(s)) return()
    conc <- concordancer_rv()
    cols <- names(conc)[s]
    for (col in cols) {
        old_type <- class(conc[[col]])[1]
        old_vals <- paste(sort(unique(conc[[col]][!is.na(conc[[col]])])), collapse = ", ")
        conc[[col]] <- suppressWarnings(as.numeric(conc[[col]]))
        new_vals <- paste(sort(unique(conc[[col]][!is.na(conc[[col]])])), collapse = ", ")
        log_info(sprintf("[coerce to numeric] '%s': %s -> numeric | old_values: [%s] | new_values: [%s]", col, old_type, old_vals, new_vals))
    }
    concordancer_rv(conc)
    showNotification(
        paste0("Coerced to numeric: ", paste(cols, collapse = ", ")),
        type = "message", duration = 4
    )
})

output$coerce_metadata_table <- DT::renderDT({
    conc <- req(concordancer_rv())
    cols <- names(conc)

    tbl <- data.frame(
        Column  = cols,
        Type    = sapply(cols, function(col) class(conc[[col]])[1]),
        Sample  = sapply(cols, function(col) {
            vals <- unique(conc[[col]])
            vals <- vals[!is.na(vals)]
            paste(head(vals, 3), collapse = ", ")
        }),
        stringsAsFactors = FALSE
    )

    DT::datatable(
        tbl,
        selection = "multiple",
        rownames  = FALSE,
        options   = list(dom = "tip", pageLength = 25)
    )
})

observeEvent(input$undo_all_text_filter, {
    stack <- concordancer_undo()
    if (length(stack) == 0) return()
    first_df <- stack[[1]]
    concordancer_rv(first_df)
    concordancer_undo(list())
})

output$text_id_filter_table <- DT::renderDT({
    conc   <- req(concordancer_rv())
    id_col <- req(input$text_id_col)
    req(nzchar(id_col), id_col %in% names(conc))
    ids <- sort(unique(conc[[id_col]]))
    DT::datatable(
        data.frame(id = ids, stringsAsFactors = FALSE),
        colnames  = id_col,
        selection = "multiple",
        rownames  = FALSE,
        options   = list(dom = "tip", pageLength = 50)
    )
})

observeEvent(input$delete_by_text_id, {
    id_col <- trimws(input$text_id_col)
    conc   <- concordancer_rv()
    req(nzchar(id_col), id_col %in% names(conc))
    s <- input$text_id_filter_table_rows_selected
    if (!length(s)) return()
    ids      <- sort(unique(conc[[id_col]]))
    to_drop  <- ids[s]
    new_conc <- conc[!(conc[[id_col]] %in% to_drop), , drop = FALSE]
    stack <- concordancer_undo()
    concordancer_undo(c(stack, list(conc)))
    concordancer_rv(new_conc)
    showNotification(paste0("Excluded ", length(to_drop), " text(s)."),
                     type = "message", duration = 3)
})
