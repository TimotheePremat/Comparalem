server <- function(input, output, session) {
  options(shiny.maxRequestSize=1000*1024^2)

    # Helper function to trim all column names and character values
    trim_dataframe <- function(df) {
      names(df) <- trimws(names(df))
      df[] <- lapply(df, function(x) if (is.character(x)) trimws(x) else x)
      df
    }

    backup_roots <- c(
      "Saved backups" = normalizePath("../data/saved", mustWork = FALSE),
      Home            = normalizePath("~")
    )
    shinyFileChoose(input, "df_lemma_resume", roots = backup_roots,
                    filetypes = c("xlsx"))

    source("load_files.r", local = TRUE)
    source("common_lemmas.r", local = TRUE)
    source("generate_df.r", local = TRUE)
    source("tables.r", local = TRUE)
    source("metadata.r", local = TRUE)
    source("desc_stat.r", local = TRUE)
    source("classify.r", local = TRUE)

    #----------------------------------
    # Filter by metadata
    #----------------------------------
    # output$text_id_col_ui <- renderUI({
    #   req(concordancer_rv())
    #   choices  <- names(concordancer_rv())
    #   saved    <- isolate(text_id_col_rv())
    #   selected <- if (!is.null(saved) && saved %in% choices) saved else choices[1]
    #   selectInput(
    #     inputId  = "text_id_col",
    #     label    = "Text ID column",
    #     choices  = choices,
    #     selected = selected
    #   )
    # })

    # observeEvent(input$text_id_col, {
    #   text_id_col_rv(input$text_id_col)
    # }, ignoreNULL = TRUE)

    # output$text_filtering_col_ui <- renderUI({
    #   req(concordancer_rv(), input$text_id_col)
    #   conc   <- concordancer_rv()
    #   id_col <- input$text_id_col
    #   req(id_col %in% names(conc))
    #   # Keep only columns where every text ID maps to exactly one unique value
    #   valid_cols <- Filter(function(col) {
    #     tbl <- unique(conc[, c(id_col, col), drop = FALSE])
    #     nrow(tbl) == length(unique(conc[[id_col]]))
    #   }, setdiff(names(conc), id_col))
    #   saved    <- isolate(text_filtering_col_rv())
    #   selected <- if (!is.null(saved) && saved %in% valid_cols) saved else valid_cols[1]
    #   selectInput(
    #     inputId  = "text_filtering_col",
    #     label    = "Column to filter on",
    #     choices  = valid_cols,
    #     selected = selected
    #   )
    # })

    # observeEvent(input$text_filtering_col, {
    #   text_filtering_col_rv(input$text_filtering_col)
    # }, ignoreNULL = TRUE)

    # # Reactive: is the selected column numeric?
    # col_is_numeric <- reactive({
    #   req(concordancer_rv(), input$text_filtering_col)
    #   col <- trimws(input$text_filtering_col)
    #   req(col %in% names(concordancer_rv()))
    #   is.numeric(concordancer_rv()[[col]])
    # })

    # observe({
    #   req(concordancer_rv(), input$text_filtering_col)
    #   if (isTRUE(col_is_numeric())) {
    #     updateActionButton(session, "delete_text_filter", label = "Set interval", icon = icon("filter"))
    #   } else {
    #     updateActionButton(session, "delete_text_filter", label = "Exclude selected", icon = icon("trash"))
    #   }
    # })

    # # Coerce selected column to numeric in concordancer
    # observeEvent(input$coerce_col_numeric, {
    #   col  <- trimws(input$text_filtering_col)
    #   conc <- concordancer_rv()
    #   req(col %in% names(conc))
    #   conc[[col]] <- suppressWarnings(as.numeric(conc[[col]]))
    #   concordancer_rv(conc)
    # })

    # # Shared bounds reactive for slider + plot alignment
    # text_filtering_bounds <- reactive({
    #   req(col_is_numeric())
    #   col  <- trimws(input$text_filtering_col)
    #   vals <- concordancer_rv()[[col]]
    #   list(mn = floor(min(vals, na.rm = TRUE)), mx = ceiling(max(vals, na.rm = TRUE)))
    # })

    # # Slider for numeric columns
    # output$text_filtering_slider_ui <- renderUI({
    #   req(col_is_numeric())
    #   col    <- trimws(input$text_filtering_col)
    #   bounds <- text_filtering_bounds()
    #   tagList(
    #     plotOutput("text_filtering_plot"),
    #     tags$div(
    #       style = "padding-left: 45px; padding-right: 8px;",
    #       sliderInput(
    #         inputId = "text_filtering_range",
    #         label   = paste("Set boundaries for ", col, ":", sep=""),
    #         min = bounds$mn, max = bounds$mx,
    #         value = c(bounds$mn, bounds$mx),
    #         step = 1, width = "100%"
    #       )
    #     )
    #   )
    # })

    # # Bar chart for numeric columns
    # output$text_filtering_plot <- renderPlot({
    #   req(col_is_numeric())
    #   col    <- trimws(input$text_filtering_col)
    #   id_col <- input$text_id_col
    #   conc   <- concordancer_rv()
    #   bounds <- text_filtering_bounds()
    #   req(col %in% names(conc), id_col %in% names(conc))
    #   plot_df <- conc[!is.na(conc[[col]]), c(id_col, col), drop = FALSE] %>%
    #     dplyr::distinct() %>%
    #     dplyr::count(.data[[col]])
    #   ggplot2::ggplot(plot_df, ggplot2::aes(x = .data[[col]], y = n)) +
    #     ggplot2::geom_col(fill = "#4e79a7") +
    #     ggplot2::scale_x_continuous(limits = c(bounds$mn - 0.5, bounds$mx + 0.5), expand = c(0, 0)) +
    #     ggplot2::scale_y_continuous(expand = ggplot2::expansion(mult = c(0, 0.05))) +
    #     ggplot2::labs(x = NULL, y = paste("Number of texts (or other structural units)")) +
    #     ggplot2::theme_minimal(base_size = 16) +
    #     ggplot2::theme(plot.margin = ggplot2::margin(5, 8, 0, 8))
    # })

    # # # DT for categorical columns
    # # output$text_filtering_table <- DT::renderDT({
    # #   req(!col_is_numeric())
    # #   col         <- trimws(input$text_filtering_col)
    # #   unique_vals <- sort(unique(concordancer_rv()[[col]]))
    # #   DT::datatable(
    # #     data.frame(value = unique_vals),
    # #     selection = "multiple",
    # #     options   = list(dom = "tip")
    # #   )
    # # })

    # observeEvent(input$delete_text_filter, {
    #   col  <- trimws(input$text_filtering_col)
    #   conc <- concordancer_rv()
    #   req(col %in% names(conc))

    #   if (isolate(col_is_numeric())) {
    #     rng  <- input$text_filtering_range
    #     req(!is.null(rng))
    #     new_conc <- conc[!is.na(conc[[col]]) & conc[[col]] >= rng[1] & conc[[col]] <= rng[2], , drop = FALSE]
    #   } else {
    #     s <- input$text_filtering_table_rows_selected
    #     if (!length(s)) return()
    #     unique_vals <- sort(unique(conc[[col]]))
    #     vals        <- unique_vals[s]
    #     new_conc    <- conc[!(conc[[col]] %in% vals), , drop = FALSE]
    #   }

    #   stack <- concordancer_undo()
    #   concordancer_undo(c(stack, list(conc)))
    #   concordancer_rv(new_conc)
    # })

    # observeEvent(input$undo_last_text_filter, {
    #   stack <- concordancer_undo()
    #   if (length(stack) == 0) return()
    #   last_df <- tail(stack, 1)[[1]]
    #   concordancer_undo(stack[-length(stack)])
    #   concordancer_rv(last_df)
    # })

    # observeEvent(input$undo_all_text_filter, {
    #   stack <- concordancer_undo()
    #   if (length(stack) == 0) return()
    #   first_df <- stack[[1]]
    #   concordancer_rv(first_df)
    #   concordancer_undo(list())
    # })


    #----------------------------------
    # Save/resume routines
    #----------------------------------

    # Save combined lemmas and forms concordancer
    observeEvent(input$download_backup, {
      forms  <- req(concordancer_rv())
      lemmas <- req(lemma_table_choice())

      # Category names are stored for reference, but on resume they are
      # re-derived directly from the "cat" column of the restored forms
      # (this is what makes resume work for any number of categories).
      cat_vals <- if ("cat" %in% names(forms)) unique(as.character(forms$cat)) else character(0)
      variables <- data.frame(
        var = c("lemma_var_name",
                if (length(cat_vals)) paste0("cat_name_", seq_along(cat_vals)) else character(0)),
        value = c(if (!is.null(input$lemma_var)) input$lemma_var else lemma_var_rv(),
                  cat_vals)
      )
      sheets <- list(
        lemmas = lemmas,
        forms  = forms,
        settings = variables
      )

      wb <- createWorkbook()

      for (nm in names(sheets)) {
        df <- as.data.frame(sheets[[nm]])
        addWorksheet(wb, nm)
        writeDataTable(
          wb,
          sheet = nm,
          x = df,
          withFilter = TRUE
        )
        setColWidths(wb, nm, cols = 1:ncol(df), widths = "auto")
        freezePane(wb, nm, firstRow = TRUE)
      }

      dir.create("../data/saved", showWarnings = FALSE)

      file_path <- file.path(
        "../data/saved",
        paste0("Saved_data_", format(Sys.time(), "%Y-%m-%d_%H-%M-%S"), ".xlsx")
      )

      saveWorkbook(wb, file_path, overwrite = TRUE)

      showNotification(
        paste("Saved at: Comparalem/Data/saved/", basename(file_path), sep=""),
        type = "message",
        duration = 5
      )
    })

    # Resume from lemma and forms saved concordancer
    # observeEvent(input$replace_lemma_df, {
    #   req(input$df_lemma_resume)
    #   uploaded_backup_lemmas(read.xlsx(input$df_lemma_resume$datapath, sheet="lemmas"))
    # })

    observeEvent(input$resume_from_backup, {
      req(is.list(input$df_lemma_resume))
      file_info <- parseFilePaths(backup_roots, input$df_lemma_resume)
      req(nrow(file_info) > 0)
      file <- as.character(file_info$datapath)

      # Read sheets from Excel and trim all whitespace
      lemmas       <- trim_dataframe(read.xlsx(file, sheet="lemmas"))
      forms        <- trim_dataframe(read.xlsx(file, sheet="forms"))
      var_settings <- trim_dataframe(read.xlsx(file, sheet="settings"))

      # Reset render triggers so both tables do a full re-render with the new data structure
      lemma_render_trigger(0)
      concordancer_render_trigger(0)

      # Cross-filter: keep only rows present in both tables
      restored_lemma_var <- var_settings$value[var_settings$var == "lemma_var_name"]
      if (restored_lemma_var %in% names(forms) && restored_lemma_var %in% names(lemmas)) {
        lemma_vals_in_forms  <- unique(forms[[restored_lemma_var]])
        lemma_vals_in_lemmas <- unique(lemmas[[restored_lemma_var]])
        forms  <- forms[ forms[[restored_lemma_var]]  %in% lemma_vals_in_lemmas, , drop = FALSE]
        lemmas <- lemmas[lemmas[[restored_lemma_var]] %in% lemma_vals_in_forms,  , drop = FALSE]
      }

      lemma_var_rv(restored_lemma_var)
      cols_selected_rv(c(restored_lemma_var, "ContexteGauche", "Pivot", "ContexteDroit", "cat"))
      concordancer_rv(NULL)   # reset so init observer re-fires with backup data
      concordancer_from_upload(forms)
      lemma_table_from_upload(lemmas)

      # Restore the lemma-column selector. Category names (however many
      # there are) are re-derived downstream from the "cat" column of the
      # restored forms, so there is nothing per-category to restore here.
      updateSelectInput(session, "lemma_var", selected = restored_lemma_var)

      showNotification(
        paste("Backup loaded from file."),
        type = "message"
      )
    })

}