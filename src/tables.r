# Lemma table ---------------------------------------------------------
output$data_freq_merged_preview <- DT::renderDT({
      req(lemma_render_trigger() > 0)
      DT::datatable(
        isolate(lemma_table_choice()),
        filter = "top",
        selection = "multiple",
        options = list(
          dom = "tip",
          rowCallback = JS("function(row, data) {
            $(row).on('dblclick', function() {
              Shiny.setInputValue('lemma_dblclick', data[1], {priority: 'event'});
            });
          }")
        )
      )
    })

# Concordancer ---------------------------------------------------------
    output$concordancer_preview <- renderDT({
      req(concordancer_render_trigger() > 0)
      conc_data <- req(isolate(concordancer_rv()))   # use rv() for current structure

      all_cols     <- names(conc_data)
      saved_cols   <- isolate(cols_selected_rv())
      cols_to_show <- if (!is.null(saved_cols)) saved_cols[saved_cols %in% all_cols] else all_cols
      cols_to_hide <- setdiff(all_cols, cols_to_show)

      col_defs <- list()
      hide_targets <- which(all_cols %in% cols_to_hide)
      cg_targets   <- which(all_cols == "ContexteGauche")
      pv_targets   <- which(all_cols == "Pivot")

      if (length(hide_targets) > 0) col_defs <- c(col_defs, list(list(targets = hide_targets, visible = FALSE)))
      if (length(cg_targets)   > 0) col_defs <- c(col_defs, list(list(targets = cg_targets,   className = "dt-right")))
      if (length(pv_targets)   > 0) col_defs <- c(col_defs, list(list(targets = pv_targets,   className = "dt-center")))

      datatable(
        conc_data,
        filter     = "top",
        selection  = "multiple",
        options    = list(
          dom        = "Btip",
          buttons    = list(list(extend = "colvis", text = "Show / hide columns")),
          columnDefs = col_defs
        )
      )
    })

        # DT for categorical columns
    output$text_filtering_table <- DT::renderDT({
      req(!col_is_numeric())
      col         <- trimws(input$text_filtering_col)
      unique_vals <- sort(unique(concordancer_rv()[[col]]))
      DT::datatable(
        data.frame(value = unique_vals),
        selection = "multiple",
        options   = list(dom = "tip")
      )
    })

# ----------------------------------------------
# Actions upon lemma_table()
# ----------------------------------------------
# Set empty stack (for undoing)
undo_stack <- reactiveVal(list())
# Store original full dataset (for undo all)
original_df <- reactiveVal(NULL)

# Capture original dataset the first time data_freq_merged_rv is set
observe({
  df <- lemma_table_choice()
  if (!is.null(df) && is.null(original_df())) {
    original_df(df)
  }
})

# Trigger full re-render only on first init, not on row deletions
lemma_render_trigger <- reactiveVal(0)

observeEvent(lemma_table_choice(), {
  if (isolate(lemma_render_trigger()) == 0) {
    lemma_render_trigger(1)
  }
}, ignoreNULL = TRUE)

# Update data only (preserves filters/search state) when rows are deleted/restored
observeEvent(lemma_table_choice(), {
  req(lemma_render_trigger() > 0)
  replaceData(dataTableProxy("data_freq_merged_preview"), lemma_table_choice(), resetPaging = FALSE)
}, ignoreInit = TRUE)

# Double-click a lemma row → navigate to concordancer and filter on that lemma
observeEvent(input$clear_lemma_filter, {
  shinyjs::runjs("
    var api = $('#concordancer_preview table').DataTable();
    api.search('').columns().search('').draw(false);
  ")
})

observeEvent(input$lemma_dblclick, {
  lemma_val <- input$lemma_dblclick
  req(lemma_val, concordancer_choice(), lemma_var_rv())

  # Compute column index (1-based in R, 0-based in JS; +1 for DT rownames column)
  col_names <- names(concordancer_choice())
  col_idx   <- which(col_names == lemma_var_rv())  # 1-based
  req(length(col_idx) > 0)
  js_col_idx <- col_idx  # DT adds rownames as col 0, so R col 1 → JS col 1

  updateNavbarPage(session, "tabselected", selected = "filter_forms_tab")

  shinyjs::runjs(sprintf(
    "setTimeout(function() {
        var api = $('#concordancer_preview table').DataTable();
        api.search('').columns().search('').draw(false);
        api.column(%d).search('%s', false, false).draw();
      }, 200);",
    js_col_idx, lemma_val
  ))
})

# Delete rows (lemmas) when button clicked
observeEvent(input$delete_lemmas, {
  lv  <- req(lemma_var_rv())
  lt  <- req(lemma_table_choice())
  s   <- input$data_freq_merged_preview_rows_selected
  if (!length(s)) return()

  # Identify lemma values to drop
  dropped_lemmas <- lt[[lv]][s]

  # Push current concordancer state onto undo stack
  conc <- concordancer_rv()
  stack <- undo_stack()
  undo_stack(c(stack, list(conc)))

  # Remove all concordancer rows for those lemmas
  new_conc <- conc[!(conc[[lv]] %in% dropped_lemmas), , drop = FALSE]
  concordancer_rv(new_conc)
})

# Undo last deletion
observeEvent(input$undo_last_lemma, {
  stack <- undo_stack()
  if (length(stack) == 0) return()

  last_conc <- tail(stack, 1)[[1]]
  undo_stack(stack[-length(stack)])
  concordancer_rv(last_conc)
})

# Undo all deletions (restore original concordancer)
observeEvent(input$undo_all_lemma, {
  stack <- undo_stack()
  if (length(stack) == 0) return()
  concordancer_rv(stack[[1]])
  undo_stack(list())
})

# Save lemma table (filtered)
output$download_lemma <- downloadHandler(
  filename = function() {
    paste0(
      "lemma_table_",
      format(Sys.time(), "%Y-%m-%d_%H-%M-%S"),
      ".xlsx"
    )
  },
  content = function(file) {
    df <- lemma_table_choice()
    req(df)

    # Optional: ensure plain data.frame (not tibble / rowwise)
    df <- as.data.frame(df)

    wb <- createWorkbook()
    addWorksheet(wb, "Lemma_table")

    writeDataTable(
      wb,
      sheet = "Lemma_table",
      x = df,
      withFilter = TRUE
    )

    saveWorkbook(wb, file, overwrite = TRUE)
  }
)

# ----------------------------------------------
# File-based lemma exclusion
# ----------------------------------------------
exclude_lemmas_file_rv <- reactiveVal(NULL)

observeEvent(input$exclude_lemmas_file, {
  f   <- input$exclude_lemmas_file
  ext <- tolower(tools::file_ext(f$name))
  df  <- tryCatch({
    if (ext == "xlsx") {
      read.xlsx(f$datapath)
    } else if (ext == "txt") {
      lines <- readLines(f$datapath, warn = FALSE)
      lines <- trimws(lines[nzchar(trimws(lines))])
      data.frame(lemma = lines, stringsAsFactors = FALSE)
    } else {
      read.table(f$datapath, header = TRUE, sep = isolate(input$exclude_lemmas_sep),
                 stringsAsFactors = FALSE, quote = "\"", fill = TRUE)
    }
  }, error = function(e) NULL)
  exclude_lemmas_file_rv(df)
})

output$exclude_lemmas_col_ui <- renderUI({
  df <- req(exclude_lemmas_file_rv())
  saved    <- isolate(input$exclude_lemmas_col)
  selected <- if (!is.null(saved) && saved %in% names(df)) saved else names(df)[1]
  selectInput("exclude_lemmas_col", "Column with lemmas:",
              choices = names(df), selected = selected)
})

observe({
  ready <- !is.null(exclude_lemmas_file_rv()) &&
           !is.null(concordancer_rv())         &&
           !is.null(lemma_var_rv())
  if (ready) shinyjs::enable("apply_lemma_file_exclusion")
  else       shinyjs::disable("apply_lemma_file_exclusion")
})

observeEvent(input$apply_lemma_file_exclusion, {
  lv      <- req(lemma_var_rv())
  df_file <- req(exclude_lemmas_file_rv())
  col     <- req(input$exclude_lemmas_col)
  conc    <- req(concordancer_rv())
  req(col %in% names(df_file), lv %in% names(conc))

  to_drop <- unique(trimws(as.character(df_file[[col]])))
  to_drop <- to_drop[!is.na(to_drop) & nzchar(to_drop)]

  keep_mode <- isTRUE(input$exclude_lemmas_mode == "keep")
  in_file   <- unique(conc[[lv]]) %in% to_drop
  n_lemmas  <- sum(in_file)

  stack <- undo_stack()
  undo_stack(c(stack, list(conc)))

  new_conc <- if (keep_mode) {
    conc[ (conc[[lv]] %in% to_drop), , drop = FALSE]
  } else {
    conc[!(conc[[lv]] %in% to_drop), , drop = FALSE]
  }
  concordancer_rv(new_conc)

  action <- if (keep_mode) "Kept" else "Excluded"
  showNotification(
    sprintf("%s %d form(s) across %d matched lemma(s).",
            action, nrow(conc) - nrow(new_conc), n_lemmas),
    type = "message", duration = 5
  )
})

# ----------------------------------------------
# File-based form filtering
# ----------------------------------------------
exclude_forms_file_rv <- reactiveVal(NULL)

observeEvent(input$exclude_forms_file, {
  f   <- input$exclude_forms_file
  ext <- tolower(tools::file_ext(f$name))
  df  <- tryCatch({
    if (ext == "xlsx") {
      read.xlsx(f$datapath)
    } else {
      read.table(f$datapath, header = TRUE, sep = isolate(input$exclude_forms_sep),
                 stringsAsFactors = FALSE, quote = "\"", fill = TRUE)
    }
  }, error = function(e) NULL)
  exclude_forms_file_rv(df)
})

output$exclude_forms_file_text_col_ui <- renderUI({
  df   <- req(exclude_forms_file_rv())
  cols <- names(df)
  selectInput("exclude_forms_file_text_col", "Text ID column:",
              choices = cols, selected = cols[1])
})

output$exclude_forms_file_token_col_ui <- renderUI({
  df   <- req(exclude_forms_file_rv())
  cols <- names(df)
  selectInput("exclude_forms_file_token_col", "Token ID column:",
              choices = cols,
              selected = if (length(cols) > 1) cols[2] else cols[1])
})

output$exclude_forms_conc_text_col_ui <- renderUI({
  conc <- req(concordancer_rv())
  cols <- names(conc)
  saved    <- text_id_col_rv()
  selected <- if (!is.null(saved) && saved %in% cols) saved else cols[1]
  selectInput("exclude_forms_conc_text_col", "Text ID column:",
              choices = cols, selected = selected)
})

output$exclude_forms_conc_token_col_ui <- renderUI({
  conc <- req(concordancer_rv())
  cols <- names(conc)
  selectInput("exclude_forms_conc_token_col", "Token ID column:",
              choices = cols,
              selected = if (length(cols) > 1) cols[2] else cols[1])
})

observe({
  ready <- !is.null(exclude_forms_file_rv()) && !is.null(concordancer_rv())
  if (ready) shinyjs::enable("apply_forms_file_filter")
  else       shinyjs::disable("apply_forms_file_filter")
})

observeEvent(input$apply_forms_file_filter, {
  conc           <- req(concordancer_rv())
  df_file        <- req(exclude_forms_file_rv())
  file_text_col  <- req(input$exclude_forms_file_text_col)
  file_token_col <- req(input$exclude_forms_file_token_col)
  conc_text_col  <- req(input$exclude_forms_conc_text_col)
  conc_token_col <- req(input$exclude_forms_conc_token_col)
  req(file_text_col  %in% names(df_file), file_token_col  %in% names(df_file))
  req(conc_text_col  %in% names(conc),    conc_token_col  %in% names(conc))

  file_keys <- paste(as.character(df_file[[file_text_col]]),
                     as.character(df_file[[file_token_col]]), sep = "\t")
  conc_keys <- paste(as.character(conc[[conc_text_col]]),
                     as.character(conc[[conc_token_col]]), sep = "\t")
  matched <- conc_keys %in% file_keys

  keep_mode <- isTRUE(input$exclude_forms_mode == "keep")
  stack <- concordancer_undo()
  concordancer_undo(c(stack, list(conc)))

  new_conc <- if (keep_mode) conc[matched, , drop = FALSE] else conc[!matched, , drop = FALSE]
  concordancer_rv(new_conc)

  action     <- if (keep_mode) "Kept" else "Excluded"
  n_affected <- if (keep_mode) nrow(new_conc) else nrow(conc) - nrow(new_conc)
  showNotification(
    sprintf("%s %d form(s) matched in file.", action, n_affected),
    type = "message", duration = 5
  )
})

# ----------------------------------------------
# Actions upon concordancer
# ----------------------------------------------
concordancer_rv <- reactiveVal(NULL)
concordancer_undo <- reactiveVal(list())
text_id_col_rv <- reactiveVal(NULL)
text_filtering_col_rv <- reactiveVal(NULL)

uploaded_backup_forms <- reactiveVal(NULL)
# concordancer <- reactiveVal(NULL)
concordancer_from_upload <- reactiveVal(NULL)

# Select or generate concordancer
concordancer <- reactive({
  concordancer_choice()
})

# Reactives for concordancer and undoing

# Initialize concordancer_rv only once (on first non-empty compute); user edits (deletions) must not be overwritten
observe({
  conc <- concordancer()
  req(conc, nrow(conc) > 0)
  if (is.null(isolate(concordancer_rv()))) {
    concordancer_rv(conc)
  }
})

# Delete rows
observeEvent(input$delete_forms, {
  s <- input$concordancer_preview_rows_selected
  if (!length(s)) return()

  df           <- concordancer_rv()
  selected_ids <- df$form_id[s]

  stack <- concordancer_undo()
  concordancer_undo(c(stack, list(df)))

  concordancer_rv(df[!df$form_id %in% selected_ids, , drop = FALSE])
})

# Undo last deletion
observeEvent(input$undo_last_form, {
  stack <- concordancer_undo()
  if (length(stack) == 0) return()

  last_df <- tail(stack, 1)[[1]]
  concordancer_undo(stack[-length(stack)])
  concordancer_rv(last_df)
})

# Undo all deletions
observeEvent(input$undo_all_forms, {
  stack <- concordancer_undo()
  if (length(stack) == 0) return()

  concordancer_rv(stack[[1]])
  concordancer_undo(list())
})

cols_selected_rv <- reactiveVal(NULL)

# Update stored selection when user changes checkboxes
observe({
  req(input$cols_to_show)
  cols_selected_rv(input$cols_to_show)
})

# Col selector
output$col_selector <- renderUI({
  req(concordancer_rv())
  all_cols <- isolate(names(concordancer_rv()))
  
  # Use stored selection if available, otherwise use defaults
  current <- cols_selected_rv()
  default_cols <- if (!is.null(current)) {
    current[current %in% all_cols]  # keep only valid cols
  } else {
    c(lemma_var_rv(), "ContexteGauche", "Pivot", "ContexteDroit", "cat")
  }
  
  checkboxGroupInput(
    "cols_to_show",
    label    = "Columns to display",
    choices  = all_cols,
    selected = default_cols
  )
})

# Trigger a full re-render only on first init or column visibility changes,
# NOT on row deletions (so filters are preserved via replaceData instead)
concordancer_render_trigger <- reactiveVal(0)

observeEvent(concordancer_rv(), {
  if (isolate(concordancer_render_trigger()) == 0) {
    concordancer_render_trigger(1)
  }
}, ignoreNULL = TRUE)

observeEvent(input$cols_to_show, {
  if (isolate(concordancer_render_trigger()) > 0) {
    concordancer_render_trigger(isolate(concordancer_render_trigger()) + 1)
  }
}, ignoreInit = TRUE)

# Ensure concordancer is initialized even before user visits the tab (needed for dblclick JS filter)
outputOptions(output, "concordancer_preview", suspendWhenHidden = FALSE)

# Update data only (preserves filters/search state) when rows are deleted/restored
observeEvent(concordancer_rv(), {
  req(concordancer_render_trigger() > 0)
  replaceData(dataTableProxy("concordancer_preview"), concordancer_rv(), resetPaging = FALSE)
}, ignoreInit = TRUE)

# Save concordancer (filtered forms for Comparalem)
output$download_concordancer <- downloadHandler(
  filename = function() {
    paste0(
      "concordancer_",
      format(Sys.time(), "%Y-%m-%d_%H-%M-%S"),
      ".xlsx"
    )
  },
  content = function(file) {
    df <- concordancer_rv()
    req(df)

    # Optional: ensure plain data.frame (not tibble / rowwise)
    df <- as.data.frame(df)

    wb <- createWorkbook()
    addWorksheet(wb, "Concordancer")

    writeDataTable(
      wb,
      sheet = "Concordancer",
      x = df,
      withFilter = TRUE
    )

    saveWorkbook(wb, file, overwrite = TRUE)
  }
)