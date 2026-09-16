source("Packages_new.R") #Same as main.r

ui <- page_navbar(
  theme = bs_theme(),
  useShinyjs(),
  title = HTML("Comparalem"),
  id = "tabselected",
  tags$head(
    tags$link(
      rel = "stylesheet",
      href = "https://cdn.jsdelivr.net/npm/bootstrap-icons@1.10.5/font/bootstrap-icons.css"
    ),
    tags$style(HTML("
      .tooltip-inner { text-align: left; }
      #text_filtering_range .irs-min,
      #text_filtering_range .irs-max,
      #text_filtering_range .irs-single,
      #text_filtering_range .irs-grid-text { font-size: 15px; }
      #text_filtering_range .control-label { font-size: 16px; font-weight: 600; }
    "))
  ),

 sidebar = accordion(
    id = "accordions_data",
    open = TRUE,
    conditionalPanel(
        condition="input.tabselected == 'upload_data'",
        accordion_panel(
            title = "Load data",
            id = "accordion_load_data",
            fileInput("df1",
              label = tooltip(
                trigger = list(
                  "Dataset 1",
                  bs_icon("info-circle")
                ),
                HTML("Select a dataset containing one of the two categories you want to constrat. See documentation for details.")
              ),
              accept = c(".csv", ".tsv")),
            fileInput("df2",
              label = tooltip(
                trigger = list(
                  "Dataset 2",
                  bs_icon("info-circle")
                ),
                HTML("Select a dataset containing one of the two categories you want to constrat. See documentation for details.")
              ),
              accept = c(".csv", ".tsv")),
            textInput(
                inputId = "user_text_cat1",
                label = tooltip(
                trigger = list(
                  "Rename df1 (optional)",
                  bs_icon("info-circle")
                ),
                HTML("You can chose to rename the category of the first dataset. This is only a display property.")
              ),
                value = "df1"
            ),
            textInput(
                inputId = "user_text_cat2",
                label = tooltip(
                trigger = list(
                  "Rename df2 (optional)",
                  bs_icon("info-circle")
                ),
                HTML("You can chose to rename the category of the second dataset. This is only a display property.")
              ),
                value = "df2"
            ),
        ),
        accordion_panel(
          title = "Parse data",
          id = "accordion_parse_data",
          selectInput(
            "select_col_to_parse",
            "Select column to parse/rewrite:",
            choices = NULL
          ),
          textAreaInput(
            inputId = "cell_edit",
            label = tooltip(
              trigger = list(
                "Rewrite headings",
                bs_icon("info-circle")
              ),
              HTML("You can change the content of the first cell to match the concatenated metadata before parsing.
              This is usefull when using TXM concordancer, which does not preserves Reference content headings.")
            ),
            value = NULL,
            width = "100%"
          ),
          actionButton("save_text_cell", "Rewrite"),
          selectInput(
            "sep_parse",
              label = "Select a separator",
            choices = c("," = ",", ";" = ";", ":" = ":", "\t" = "\t", "|" = "|", "space" = " ", "_" = "_"),
            selected = "_",
            width = "120px"
          ),
          actionButton("parse", "Parse data"),
        ),
        accordion_panel(
          title = "Drop columns",
          id = "accordion_drop_cols",
          selectInput("drop_cols",
            "Columns to drop:",
            choices = NULL,
            multiple = TRUE),
          actionButton(
            "remove_cols",
            label = tooltip(
                trigger = list(
                  "Remove columns",
                  bs_icon("info-circle")
                ),
                HTML("Removing columns makes computation faster (less data to process) but is optional")
              ),
          )
        )
    ),
    conditionalPanel(
        condition="input.tabselected == 'lemmas_var'",
        accordion_panel(
          title = "Find lemmas with alternating forms",
          id = "accordion_lemmas_var",
          uiOutput("lemma_selector"),
          actionButton("find_lemmas", "Find common lemmas"),
          hr(),
          actionButton("skip_lemmas",
          label = tooltip(
                trigger = list(
                  "Skip lemmas detection",
                  bs_icon("info-circle")
                ),
                HTML("Do this only if you know that all forms have lemmas appearing in both dataset. Will print 'true' for all rows.")
              ),
          )
        )
      ),
      conditionalPanel(
        condition="input.tabselected == 'filter_lemmas_tab'",
        accordion_panel(
          title = "Filter out (exclude) lemmas",
          id = "accordion_preview_lemmas_forms",
          actionButton("delete_lemmas",
            label = tooltip(
              trigger = list(
                "Exclude lemmas",
                bs_icon("info-circle")
              ),
              HTML("Exclusion of lemmas is downstream: lemmas are not deleted in the basic data,
              but will not be considered for the next steps (exclusion of forms and analytical processing).")
            ), icon = icon("trash")
          , class="mb-2"),
          actionButton("undo_last_lemma", "Undo last exclusion", icon = icon("undo"), class="mb-2"),
          actionButton("undo_all_lemma", "Reset exclusions", icon = icon("history"), class="mb-2"),
          # downloadButton(outputId = "download_lemma", label = "Download lemma dataset (.xlsx)", class="mb-2")
        ),
        # accordion_panel(
        #   title = "Reload previous data",
        #   id = "accordion_reload_lemmas",
          
        # )
      ),
      conditionalPanel(
        condition="input.tabselected == 'filter_forms_tab'",
        accordion_panel(
          title = "Filter out (exclude) forms",
          id = "accordion_preview_forms",
          actionButton("delete_forms",
            label = tooltip(
              trigger = list(
                "Exclude forms",
                bs_icon("info-circle")
              ),
              HTML("Exclusion of forms is downstream: forms are deleted deleted in the merged data that,
              will be used for the next steps (exclusion of forms and analytical processing).<br>
              What you see at this step is the final data.")
            ), icon = icon("trash")
          , class="mb-2"),
          actionButton("undo_last_form", "Undo last exclusion", icon = icon("undo"), class="mb-2"),
          actionButton("undo_all_forms", "Reset exclusions", icon = icon("history"), class="mb-2"),
          uiOutput("col_selector"),
          # downloadButton(outputId = "download_concordancer", label = "Download concordancer (.xlsx)", class="mb-2")
        ),
        accordion_panel(
          title = "Columns",
          id = "concordancer_col_display",
          open = FALSE,
          uiOutput("col_selector")
        )
        # accordion_panel(
        #   title = "Reload previous data",
        #   id = "accordion_reload_forms",
        #   fileInput("df_forms_resume",
        #     label = tooltip(
        #       trigger = list(
        #         "Load previous forms dataset",
        #         bs_icon("info-circle")
        #       ),
        #       HTML("To resume previous work that you have saved, load the forms file previously saved.<br>Warning: this will replace the current dataset.")
        #     ),
        #     accept = c(".csv", ".tsv", ".xlsx")
        #   ),
        #   actionButton("replace_forms_df", "Replace current data", icon = icon("undo"), class="mb-2"),
        # )
      ),
      conditionalPanel(
        condition="input.tabselected == 'filter_texts_tab'",
        accordion_panel(
          title = "Filter by metadata",
          uiOutput("text_id_col_ui"),
          uiOutput("text_filtering_col_ui"),
          actionButton("coerce_col_numeric", "Try to make it continuous", icon = icon("ruler"), class="mb-2"),
          hr(),
          actionButton("delete_text_filter", "Exclude selected", icon = icon("trash"), class="mb-2"),
          actionButton("undo_last_text_filter", "Undo last exclusion", icon = icon("undo"), class="mb-2"),
          actionButton("undo_all_text_filter", "Reset exclusions", icon = icon("history"), class="mb-2"),
        ),
      )
    ),
#  ),

 nav_panel("Load Data",
  value = "upload_data",
  card(
    card_header(
      textOutput("df1_name_load")
    ),
    uiOutput("df1_preview"),
  ),
  card(
    card_header(
      textOutput("df2_name_load")
    ),
    uiOutput("df2_preview"),
  )
 ),
 nav_panel("Find lemmas",
  value="lemmas_var",
  card(
    card_header(
      textOutput("df1_name_find_lemmas")
    ),
    DTOutput("data_cat1_preview"),
  ),
  card(
    card_header(
      textOutput("df2_name_find_lemmas")
    ),
    DTOutput("data_cat2_preview"),
  )
 ),
 nav_panel("Filter lemmas",
  value="filter_lemmas_tab",
  card(
    card_header(
      tooltip(
        trigger = list("Filter out lemmas", bs_icon("info-circle")),
        HTML("This is a frequency table of lemmas with variation.<br>
        Double click on a row to open its matches in concordancer.")
      )
    ),
    #  fluidRow(
    #     column(6, DTOutput('data_freq_merged_preview')),
    #     column(6, plotOutput('data_freq_merged_preview_plot', height = 500))
    #   ),
    DTOutput("data_freq_merged_preview")
  )
 ),
 nav_panel("Filter forms",
  value="filter_forms_tab",
  card(
    card_header("Filter out forms"),
    DTOutput("concordancer_preview")
  ),
 ),
 nav_panel("Filter by metadata",
  value="filter_texts_tab",
  card(
    card_header("Filter by metadata"),
    uiOutput("text_filtering_slider_ui"),
    DTOutput("text_filtering_table")
  )
 ),

 nav_panel("Save / Load",
  value="other_saving_tab",
    card(
      card_header("Backup"),
      actionButton("download_backup", "Save backup", icon = icon("save"), class="mb-2"),
      hr(),
      fileInput("df_lemma_resume",
        label = tooltip(
          trigger = list(
            "Load backup file",
            bs_icon("info-circle")
          ),
          HTML("To resume previous work that you have saved, load the file previously saved.<br>Warning: this will replace the current dataset.")
        ),
        accept = c(".csv", ".tsv", ".xlsx")
      ),
      actionButton("resume_from_backup", "Resume from saved data", icon = icon("folder-open"), class="mb-2"),
    ),
    card(
      card_header("Export individual datasets"),
      downloadButton(outputId = "download_lemma", label = "Save lemma dataset (.xlsx)", class="mb-2"),
      downloadButton(outputId = "download_concordancer", label = "Save concordancer (.xlsx)", class="mb-2")
    )
 )
)

server <- function(input, output, session) {
  options(shiny.maxRequestSize=100*1024^2)

    # Helper function to trim all column names and character values
    trim_dataframe <- function(df) {
      names(df) <- trimws(names(df))
      df[] <- lapply(df, function(x) if (is.character(x)) trimws(x) else x)
      df
    }

    # Load df1 and df2
    raw_df1 <- reactive({
        req(input$df1)
        df <- read.csv(input$df1$datapath, sep = "\t", quote = "")
        trim_dataframe(df)
    })
    raw_df2 <- reactive({
        req(input$df2)
        df <- read.csv(input$df2$datapath, sep = "\t", quote = "")
        trim_dataframe(df)
    })

    # Displaying name of dfs
    df1_name_reac <- reactive({
      paste("Dataset 1 (", input$user_text_cat1, ")", sep = "")
    })
    output$df1_name_load <- renderText(df1_name_reac())
    output$df1_name_find_lemmas <- renderText(df1_name_reac())
    df2_name_reac <- reactive({
      paste("Dataset 2 (", input$user_text_cat2, ")", sep = "")
    })
    output$df2_name_load <- renderText(df2_name_reac())
    output$df2_name_find_lemmas <- renderText(df2_name_reac())

    # ReactiVal to hold current dfs
    df1 <- reactiveVal()
    df2 <- reactiveVal()

    # Initialize with raw data when uploaded
    observeEvent(raw_df1(), {
      df1(raw_df1())
    })
    observeEvent(raw_df2(), {
      df2(raw_df2())
    })

    # Action button: select col
    observe({
      req(df1())
        updateSelectInput(
          session,
          "select_col_to_parse",
          choices = colnames(df1())
        )
      })

    # Update text area with content of first cell when column selected
    observeEvent(input$select_col_to_parse, {
      req(df1())
      req(input$select_col_to_parse)
      updateTextAreaInput(
        session,
        "cell_edit",
        value = NULL
      )
    })
  
    # Save rewritten content back to first cell
    observeEvent(input$save_text_cell, {
      dfA <- req(df1())
      dfB <- req(df2())
      req(input$select_col_to_parse)

      colnames(dfA)[colnames(dfA) == input$select_col_to_parse] <- input$cell_edit
      colnames(dfB)[colnames(dfB) == input$select_col_to_parse] <- input$cell_edit
      df1(dfA)
      df2(dfB)
    })

    # Action button: replace df with parsed version
    observeEvent(input$parse, {
      req(input$select_col_to_parse, input$cell_edit, input$sep_parse)
      current_df <- df1()  # get current df1
      col_name <- input$select_col_to_parse  # column name
      name_parts <- strsplit(input$cell_edit, input$sep_parse, fixed = TRUE)[[1]]
      parsed_df <- current_df %>%
        separate_wider_delim(
          cols = all_of(col_name),
          delim = input$sep_parse,
          names = name_parts,
          too_many = "merge"
        )
      df1(parsed_df)  # replace df1 with parsed version
    })
    observeEvent(input$parse, {
      req(input$select_col_to_parse, input$cell_edit, input$sep_parse)
      current_df <- df2()  # get current df1
      col_name <- input$select_col_to_parse  # column name
      name_parts <- strsplit(input$cell_edit, input$sep_parse, fixed = TRUE)[[1]]
      parsed_df <- current_df %>%
        separate_wider_delim(
          cols = all_of(col_name),
          delim = input$sep_parse,
          names = name_parts,
          too_many = "merge"
        )
      df2(parsed_df)  # replace df2 with parsed version
    })
    # observeEvent(input$parse, {
    #   current_df <- df2()  # get current df2
    #   col_name <- names(current_df)[colnames(current_df) == input$select_col_to_parse]  # first column
    #   name_parts <- strsplit(names(current_df)[1], input$sep_parse, fixed = TRUE)[[1]]
    #   parsed_df <- current_df %>%
    #     separate_wider_delim(
    #       cols = 1,
    #       delim = input$sep_parse,
    #       names = name_parts,
    #       too_many = "merge"
    #     )
    #   df2(parsed_df)  # replace df2 with parsed version
    # })

    # Render df1 and df2
    output$df1_preview <- renderTable({
      req(df1())
      head(df1(), n = 20L)
    })
    output$df2_preview <- renderTable({
      req(df2())
      head(df2(), n = 20L)
    })
    
    # Update dropdown AFTER parsed_df is ready
    observeEvent(df1(), {
      updateSelectInput(
        session,
        "drop_cols",
        choices = names(df1())
      )
    })
    
    # Remove selected columns when button is clicked
    observeEvent(input$remove_cols, {
      req(df1(), df2)
      drops <- input$drop_cols
      
      if (length(drops) > 0) {
        new_df1 <- df1()[ , !(names(df1()) %in% drops), drop = FALSE]
        df1(new_df1)

        new_df2 <- df2()[ , !(names(df2()) %in% drops), drop = FALSE]
        df2(new_df2)
    
      # Update dropdown to reflect remaining columns
      updateSelectInput(
        session,
        "drop_cols",
        choices = names(df1()),
        selected = NULL )
        }
    })

    #----------------------------------
    # FIND LEMMAS with alternating forms
    #----------------------------------
    data_cat1 <- reactiveVal()
    data_cat2 <- reactiveVal()
    lemma_var_rv <- reactiveVal(NULL)
    # data_freq_merged <- reactiveVal()

    observe({
      req(df1())
      data_cat1(df1())
    })
    observe({
      req(df2())
      data_cat2(df2())
    })
    
    observeEvent(input$find_lemmas, {
      req(data_cat1(), data_cat2(), input$lemma_var)

      df1 <- data_cat1()
      df2 <- data_cat2()

      # Create the 'Common_lemma' column
      df1$Common_lemma <- df1[[input$lemma_var]] %in% df2[[input$lemma_var]]
      df2$Common_lemma <- df2[[input$lemma_var]] %in% df1[[input$lemma_var]]

      # Update data_cat1 reactiveVal
      data_cat1(df1)
      data_cat2(df2)
    })

    output$lemma_selector <- renderUI({
      req(data_cat1())
      selectInput(
        "lemma_var",
        "Choose a column for lemmas:",
        choices = names(data_cat1()),
        selected = isolate(input$lemma_var)
      )
    })

    observe({
      req(input$lemma_var)
      lemma_var_rv(input$lemma_var)
    })

    output$data_cat1_preview <- DT::renderDT({
      data_cat1()
    })
    output$data_cat2_preview <- DT::renderDT({
      data_cat2()
    })

    # List common lemmas
    common_lemmas_1 <- reactive({
      req(data_cat1(), input$lemma_var)
      df <- data_cat1()
      counts_sorted <- df[df$Common_lemma, ] |>
          dplyr::count(.data[[input$lemma_var]]) |>
          dplyr::arrange(desc(n))
    })
    common_lemmas_2 <- reactive({
      req(data_cat2(), input$lemma_var)
      df <- data_cat2()
      counts_sorted <- df[df$Common_lemma, ] |>
          dplyr::count(.data[[input$lemma_var]]) |>
          dplyr::arrange(desc(n))
    })

    data_freq_merged_temp <- reactive({
      df1 <- req(common_lemmas_1())
      df2 <- req(common_lemmas_2())
      df <- merge(df1, df2, by = input$lemma_var, all = TRUE) %>%
        rowwise() %>%
        mutate(
          tot. = sum(c_across(2:3), na.rm = TRUE),
          rate_x = round(n.x / tot., 2),
          rate_y = round(n.y / tot., 2)
        ) %>%
        ungroup() %>%
        rename(!!paste0("F ", input$user_text_cat1) := n.x) %>%
        rename(!!paste0("F ", input$user_text_cat2) := n.y) %>%
        rename(!!paste0("rate ", input$user_text_cat1) := rate_x) %>%
        rename(!!paste0("rate ", input$user_text_cat2) := rate_y) %>%
        mutate(lemma_id = row_number())
      df
    })

        data_freq_merged <- reactive({
      df1 <- req(common_lemmas_1())
      df2 <- req(common_lemmas_2())
      df <- merge(df1, df2, by = input$lemma_var, all = TRUE) %>%
        rowwise() %>%
        mutate(
          tot. = sum(c_across(2:3), na.rm = TRUE),
          rate_x = round(n.x / tot., 2),
          rate_y = round(n.y / tot., 2)
        ) %>%
        ungroup() %>%
        rename(!!paste0("F ", input$user_text_cat1) := n.x) %>%
        rename(!!paste0("F ", input$user_text_cat2) := n.y) %>%
        rename(!!paste0("rate ", input$user_text_cat1) := rate_x) %>%
        rename(!!paste0("rate ", input$user_text_cat2) := rate_y) %>%
        mutate(lemma_id = row_number())
      df
    })

    concordancer_temp <- reactive({
      if (!is.null(concordancer_from_upload())) {
        # Backup path: seed with uploaded forms, then apply same post-processing
        concordancer_from_upload() %>% mutate(form_id = row_number())
      } else {
        req(input$user_text_cat1, input$user_text_cat2, input$lemma_var)
        df1 <- req(df1())
        df2 <- req(df2())
        table <- req(data_freq_merged_temp())

        selected_values <- table[[input$lemma_var]]

        df1_filtered <- df1 %>% filter(.data[[input$lemma_var]] %in% selected_values)
        df2_filtered <- df2 %>% filter(.data[[input$lemma_var]] %in% selected_values)

        concordancer <- bind_rows(
          df1_filtered %>% mutate(
            source = "df1",
            cat = input$user_text_cat1
          ),
          df2_filtered %>% mutate(
            source = "df2",
            cat = input$user_text_cat2
          )
        )

        concordancer %>% mutate(form_id = row_number())
      }
    })

    concordancer_choice <- reactive({
      concordancer_temp()
    })

    # Print which concordancer is being used
    observe({
      conc <- concordancer_choice()
      if (!is.null(conc)) {
        if (!is.null(concordancer_from_upload())) {
          cat("\n>>> concordancer_temp seeded from BACKUP (concordancer_from_upload)\n")
        } else {
          cat("\n>>> concordancer_temp built from PIPELINE\n")
        }
        cat("    Rows:", nrow(conc), "\n\n")
      }
    })


    # FILTER OUT LEMMAS
    lemma_table <- reactive ({
      conco <- req(concordancer_choice())
      table <- if (!is.null(concordancer_from_upload())) {
        req(data_freq_merged_rv())
      } else {
        req(data_freq_merged_temp())
      }
      df <- table %>%
        filter(.data[[input$lemma_var]] %in% conco[[input$lemma_var]])
      df <- df %>%
        count(.data[[input$lemma_var]], .drop = FALSE)
      print(df)
    })

    #--------------------------------------------------------------------

    uploaded_backup_lemmas <- reactiveVal(NULL)
    
    # Use a reactiveVal so we can modify it when user deletes lemmas
    data_freq_merged_rv <- reactiveVal(NULL)
    
    # Keep it synced with data_freq_merged() or uploaded_df()
    observe({
      if (is.null(uploaded_backup_lemmas())) {
        new_data <- data_freq_merged()
        if (!is.null(new_data) && nrow(new_data) > 0) {
          data_freq_merged_rv(new_data)
        }
      }
    })

    # Set empty stack (for undoing)
    undo_stack <- reactiveVal(list())
    # Store original full dataset (for undo all)
    original_df <- reactiveVal(NULL)
    
    # Capture original dataset the first time data_freq_merged_rv is set
    observe({
      df <- data_freq_merged_rv()
      if (!is.null(df) && is.null(original_df())) {
        original_df(df)
      }
    })

    # Trigger full re-render only on first init, not on row deletions
    lemma_render_trigger <- reactiveVal(0)

    observeEvent(data_freq_merged_rv(), {
      if (isolate(lemma_render_trigger()) == 0) {
        lemma_render_trigger(1)
      }
    }, ignoreNULL = TRUE)

    # Prepare summary table
    output$data_freq_merged_preview <- DT::renderDT({
      req(lemma_render_trigger() > 0)
      DT::datatable(
        isolate(data_freq_merged_rv()),
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

    # Update data only (preserves filters/search state) when rows are deleted/restored
    observeEvent(data_freq_merged_rv(), {
      req(lemma_render_trigger() > 0)
      replaceData(dataTableProxy("data_freq_merged_preview"), data_freq_merged_rv(), resetPaging = FALSE)
    }, ignoreInit = TRUE)

    # Double-click a lemma row → navigate to concordancer and filter on that lemma
    observeEvent(input$lemma_dblclick, {
      lemma_val <- input$lemma_dblclick
      req(lemma_val, concordancer_rv(), lemma_var_rv())

      # Compute column index (1-based in R, 0-based in JS; +1 for DT rownames column)
      col_names <- names(concordancer_rv())
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

      df <- req(data_freq_merged_rv())

      s <- input$data_freq_merged_preview_rows_selected
      if (!length(s)) return()

      # Get the unique IDs of the selected rows
      selected_ids <- df$lemma_id[s]

      rows_all <- df
      # rows_to_drop <- rows_all[s]

      # df <- data_freq_merged_rv()

      # Push current state onto undo stack
      stack <- undo_stack()
      undo_stack(c(stack, list(df)))

      # Remove rows
      df <- data_freq_merged_rv()
      df_new <- df[ !df$lemma_id %in% selected_ids, , drop=FALSE]
      data_freq_merged_rv(df_new)
    })

    # Undo last deletion
    observeEvent(input$undo_last_lemma, {
      stack <- undo_stack()
      if (length(stack) == 0) return()  # Nothing to undo

      # Pop last state
      last_df <- tail(stack, 1)[[1]]
      undo_stack(stack[-length(stack)])

      data_freq_merged_rv(last_df)
    })

    # Undo all deletions (restore original data)
    observeEvent(input$undo_all_lemma, {
      undo_stack(list())         # clear undo stack
      data_freq_merged_rv(original_df())  # restore original
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
        df <- data_freq_merged_rv()
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


    #----------------------------------
    # FILTER OUT FORMS
    #----------------------------------

    concordancer_rv <- reactiveVal(NULL)
    concordancer_undo <- reactiveVal(list())
    text_id_col_rv <- reactiveVal(NULL)
    text_filtering_col_rv <- reactiveVal(NULL)

    uploaded_backup_forms <- reactiveVal(NULL)
    # concordancer <- reactiveVal(NULL)
    concordancer_from_upload <- reactiveVal(NULL)
    
    # Select or generate concordancer
    concordancer <- reactive({
      concordancer_temp()
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

    # Recompute lemma frequency table from current concordancer rows
    recompute_lemma_counts <- function(conc) {
      lv      <- lemma_var_rv()
      lemmas  <- data_freq_merged_rv()
      req(lv, lemmas)

      f_cols    <- grep("^F[. ]",    names(lemmas), value = TRUE)
      rate_cols <- grep("^rate[. ]", names(lemmas), value = TRUE)

      # Count rows per lemma per corpus (using cat column which mirrors f_cols names)
      counts <- conc %>%
        dplyr::count(.data[[lv]], cat) %>%
        tidyr::pivot_wider(names_from = cat, values_from = n, values_fill = 0L)

      # Update counts in lemma table, preserving row order and lemma_id
      updated <- lemmas
      for (fc in f_cols) {
        cat_name <- sub("^F[. ]", "", fc)   # "F corpus1" or "F.corpus1" -> "corpus1"
        if (cat_name %in% names(counts)) {
          idx <- match(updated[[lv]], counts[[lv]])
          updated[[fc]] <- ifelse(is.na(idx), 0L, counts[[cat_name]][idx])
        } else {
          updated[[fc]] <- 0L
        }
      }
      updated$tot. <- rowSums(updated[, f_cols, drop = FALSE], na.rm = TRUE)
      for (i in seq_along(rate_cols)) {
        updated[[rate_cols[i]]] <- round(updated[[f_cols[i]]] / updated$tot., 2)
      }
      data_freq_merged_rv(updated)
    }

    # Delete rows
    observeEvent(input$delete_forms, {
      s <- input$concordancer_preview_rows_selected
      if (!length(s)) return()

      df           <- concordancer_rv()
      selected_ids <- df$form_id[s]

      # Push to undo stack
      stack <- concordancer_undo()
      concordancer_undo(c(stack, list(df)))

      new_conc <- df[!df$form_id %in% selected_ids, , drop = FALSE]
      concordancer_rv(new_conc)
      recompute_lemma_counts(new_conc)
    })

    # Undo last deletion
    observeEvent(input$undo_last_form, {
      stack <- concordancer_undo()
      if (length(stack) == 0) return()

      last_df <- tail(stack, 1)[[1]]
      concordancer_undo(stack[-length(stack)])
      concordancer_rv(last_df)
      recompute_lemma_counts(last_df)
    })

    # Undo all deletions
    observeEvent(input$undo_all_forms, {
      stack <- concordancer_undo()
      if (length(stack) == 0) return()

      first_df <- stack[[1]]
      concordancer_rv(first_df)
      concordancer_undo(list())
      recompute_lemma_counts(first_df)
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

    output$concordancer_preview <- renderDT({
      req(concordancer_render_trigger() > 0)

      all_cols     <- isolate(names(concordancer_rv()))
      cols_to_show <- isolate(if (!is.null(input$cols_to_show)) input$cols_to_show else all_cols)
      cols_to_hide <- setdiff(all_cols, cols_to_show)

      col_defs <- list()
      hide_targets <- which(all_cols %in% cols_to_hide)
      cg_targets   <- which(all_cols == "ContexteGauche")
      pv_targets   <- which(all_cols == "Pivot")

      if (length(hide_targets) > 0) col_defs <- c(col_defs, list(list(targets = hide_targets, visible = FALSE)))
      if (length(cg_targets)   > 0) col_defs <- c(col_defs, list(list(targets = cg_targets,   className = "dt-right")))
      if (length(pv_targets)   > 0) col_defs <- c(col_defs, list(list(targets = pv_targets,   className = "dt-center")))

      datatable(
        isolate(concordancer_rv()),
        filter     = "top",
        selection  = "multiple",
        options    = list(
          dom        = "Btip",
          buttons    = list(list(extend = "colvis", text = "Show / hide columns")),
          columnDefs = col_defs
        )
      )
    })

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

    # Save file for backup and reloading
    # output$download_backup <- downloadHandler(
    #   filename = function() {
    #     paste0(
    #       "Saved_data_",
    #       format(Sys.time(), "%Y-%m-%d_%H-%M-%S"),
    #       ".xlsx"
    #     )
    #   },
    #   content = function(file) {
    #     forms <- req(concordancer_rv())
    #     lemmas <- req(data_freq_merged_rv())

    #     wb <- createWorkbook()
    #     addWorksheet(wb, "lemmas")
    #     writeDataTable(wb, sheet = "lemmas", x = lemmas, withFilter = TRUE)

    #     addWorksheet(wb, "forms")
    #     writeDataTable(wb, sheet = "forms", x = forms, withFilter = TRUE)

    #     saveWorkbook(wb, file, overwrite = TRUE)
    #   }
    # )

    # observeEvent(input$replace_forms_df, {
    #   req(input$df_forms_resume)
    #   uploaded_concordancer(read.xlsx(input$df_forms_resume$datapath))
    # })

    #----------------------------------
    # Filter by metadata
    #----------------------------------
    output$text_id_col_ui <- renderUI({
      req(concordancer_rv())
      choices  <- names(concordancer_rv())
      saved    <- isolate(text_id_col_rv())
      selected <- if (!is.null(saved) && saved %in% choices) saved else choices[1]
      selectInput(
        inputId  = "text_id_col",
        label    = "Text ID column",
        choices  = choices,
        selected = selected
      )
    })

    observeEvent(input$text_id_col, {
      text_id_col_rv(input$text_id_col)
    }, ignoreNULL = TRUE)

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

    observeEvent(input$text_filtering_col, {
      text_filtering_col_rv(input$text_filtering_col)
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
      } else {
        updateActionButton(session, "delete_text_filter", label = "Exclude selected", icon = icon("trash"))
      }
    })

    # Coerce selected column to numeric in concordancer
    observeEvent(input$coerce_col_numeric, {
      col  <- trimws(input$text_filtering_col)
      conc <- concordancer_rv()
      req(col %in% names(conc))
      conc[[col]] <- suppressWarnings(as.numeric(conc[[col]]))
      concordancer_rv(conc)
    })

    # Shared bounds reactive for slider + plot alignment
    text_filtering_bounds <- reactive({
      req(col_is_numeric())
      col  <- trimws(input$text_filtering_col)
      vals <- concordancer_rv()[[col]]
      list(mn = floor(min(vals, na.rm = TRUE)), mx = ceiling(max(vals, na.rm = TRUE)))
    })

    # Slider for numeric columns
    output$text_filtering_slider_ui <- renderUI({
      req(col_is_numeric())
      col    <- trimws(input$text_filtering_col)
      bounds <- text_filtering_bounds()
      tagList(
        plotOutput("text_filtering_plot"),
        tags$div(
          style = "padding-left: 45px; padding-right: 8px;",
          sliderInput(
            inputId = "text_filtering_range",
            label   = paste("Set boundaries for ", col, ":", sep=""),
            min = bounds$mn, max = bounds$mx,
            value = c(bounds$mn, bounds$mx),
            step = 1, width = "100%"
          )
        )
      )
    })

    # Bar chart for numeric columns
    output$text_filtering_plot <- renderPlot({
      req(col_is_numeric())
      col    <- trimws(input$text_filtering_col)
      id_col <- input$text_id_col
      conc   <- concordancer_rv()
      bounds <- text_filtering_bounds()
      req(col %in% names(conc), id_col %in% names(conc))
      plot_df <- conc[!is.na(conc[[col]]), c(id_col, col), drop = FALSE] %>%
        dplyr::distinct() %>%
        dplyr::count(.data[[col]])
      ggplot2::ggplot(plot_df, ggplot2::aes(x = .data[[col]], y = n)) +
        ggplot2::geom_col(fill = "#4e79a7") +
        ggplot2::scale_x_continuous(limits = c(bounds$mn - 0.5, bounds$mx + 0.5), expand = c(0, 0)) +
        ggplot2::scale_y_continuous(expand = ggplot2::expansion(mult = c(0, 0.05))) +
        ggplot2::labs(x = NULL, y = paste("Number of texts (or other structural units)")) +
        ggplot2::theme_minimal(base_size = 16) +
        ggplot2::theme(plot.margin = ggplot2::margin(5, 8, 0, 8))
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

    observeEvent(input$delete_text_filter, {
      col  <- trimws(input$text_filtering_col)
      conc <- concordancer_rv()
      req(col %in% names(conc))

      if (isolate(col_is_numeric())) {
        rng  <- input$text_filtering_range
        req(!is.null(rng))
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
      recompute_lemma_counts(new_conc)
    })

    observeEvent(input$undo_last_text_filter, {
      stack <- concordancer_undo()
      if (length(stack) == 0) return()
      last_df <- tail(stack, 1)[[1]]
      concordancer_undo(stack[-length(stack)])
      concordancer_rv(last_df)
      recompute_lemma_counts(last_df)
    })

    observeEvent(input$undo_all_text_filter, {
      stack <- concordancer_undo()
      if (length(stack) == 0) return()
      first_df <- stack[[1]]
      concordancer_rv(first_df)
      concordancer_undo(list())
      recompute_lemma_counts(first_df)
    })


    #----------------------------------
    # Save/resume routines
    #----------------------------------

    # Save combined lemmas and forms concordancer
    observeEvent(input$download_backup, {
      forms  <- req(concordancer_rv())
      lemmas <- req(data_freq_merged_rv())
      variables <- data.frame(
        var = c("lemma_var_name",      "cat1_name",     "cat2_name"),
        value = c(if (!is.null(input$lemma_var)) input$lemma_var else lemma_var_rv(),
                  input$user_text_cat1, input$user_text_cat2)
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
      req(input$df_lemma_resume$datapath)
      file <- input$df_lemma_resume$datapath

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
      concordancer_from_upload(forms)
      data_freq_merged_rv(lemmas)

      # Restore input settings values
      updateSelectInput(session, "lemma_var",       selected = restored_lemma_var)
      updateTextInput(session,   "user_text_cat1",  value    = var_settings$value[var_settings$var == "cat1_name"])
      updateTextInput(session,   "user_text_cat2",  value    = var_settings$value[var_settings$var == "cat2_name"])

      showNotification(
        paste("Backup loaded from file."),
        type = "message"
      )
    })

}

shiny::runApp(list(ui = ui, server = server))