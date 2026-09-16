upload_sidebar <- conditionalPanel(
        condition="input.tabselected == 'upload_data'",
        accordion_panel(
            title = "Load data",
            id = "accordion_load_data",
            fileInput("dfs_upload",
              label = tooltip(
                trigger = list(
                  "Datasets",
                  bs_icon("info-circle")
                ),
                HTML("Select two or more datasets, one for each category you want to contrast. See documentation for details.")
              ),
              multiple = TRUE,
              accept = c(".csv", ".tsv")),
            uiOutput("dataset_rename_ui"),
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
            selected = ",",
            width = "120px"
          ),
          actionButton("parse", "Parse data"),
        ),
    )
 
find_lemma_sidebar <- conditionalPanel(
        condition="input.tabselected == 'lemmas_var'",
        accordion_panel(
          title = "Find lemmas with alternating forms",
          id = "accordion_lemmas_var",
          uiOutput("lemma_selector"),
          radioButtons("match_mode", NULL,
            choices = c("Lemma only" = "lemma", "Lemma + POS" = "lemma_pos"),
            selected = "lemma", inline = TRUE
          ),
          conditionalPanel(
            condition = "input.match_mode == 'lemma_pos'",
            uiOutput("pos_selector")
          ),
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
      )

lemma_tab_sidebar <- conditionalPanel(
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
        ),
        accordion_panel(
          title = "Exclude from file",
          id = "accordion_exclude_lemmas_file",
          open = FALSE,
          fileInput("exclude_lemmas_file", NULL,
            accept = c(".csv", ".tsv", ".xlsx", ".txt"),
            placeholder = "No file selected"
          ),
          selectInput("exclude_lemmas_sep", "Separator",
            choices = c("Tab" = "\t", "Comma" = ",", "Semicolon" = ";", "Pipe" = "|"),
            selected = "\t", width = "120px"
          ),
          uiOutput("exclude_lemmas_col_ui"),
          radioButtons("exclude_lemmas_mode", NULL,
            choices = c("Exclude lemmas in file" = "exclude",
                        "Keep only lemmas in file" = "keep"),
            selected = "exclude"
          ),
          shinyjs::disabled(
            actionButton("apply_lemma_file_exclusion", "Apply",
              icon = icon("file-import"), class = "mb-2")
          )
        )
      )
      
concordancer_sidebar <- conditionalPanel(
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
          actionButton("clear_lemma_filter", "Show all lemmas", icon = icon("eye"), class="mb-2"),
          uiOutput("col_selector"),
          # downloadButton(outputId = "download_concordancer", label = "Download concordancer (.xlsx)", class="mb-2")
        ),
        accordion_panel(
          title = "Columns",
          id = "concordancer_col_display",
          open = FALSE,
          uiOutput("col_selector")
        ),
        accordion_panel(
          title = "Exclude/keep from file",
          id = "accordion_exclude_forms_file",
          open = FALSE,
          fileInput("exclude_forms_file", NULL,
            accept = c(".csv", ".tsv", ".xlsx")
          ),
          selectInput("exclude_forms_sep", "Separator",
            choices = c("Tab" = "\t", "Comma" = ",", "Semicolon" = ";", "Pipe" = "|"),
            selected = "\t", width = "120px"
          ),
          tags$strong("File columns:"),
          uiOutput("exclude_forms_file_text_col_ui"),
          uiOutput("exclude_forms_file_token_col_ui"),
          tags$strong("Concordancer columns:"),
          uiOutput("exclude_forms_conc_text_col_ui"),
          uiOutput("exclude_forms_conc_token_col_ui"),
          radioButtons("exclude_forms_mode", NULL,
            choices = c("Exclude matched forms" = "exclude",
                        "Keep only matched forms" = "keep"),
            selected = "exclude"
          ),
          shinyjs::disabled(
            actionButton("apply_forms_file_filter", "Apply",
              icon = icon("file-import"), class = "mb-2")
          )
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
      )

meta_sidebar <- conditionalPanel(
        condition="input.tabselected == 'filter_texts_tab'",
        accordion_panel(
          title = "Filter by metadata",
          uiOutput("text_id_col_ui"),
          conditionalPanel(
            condition = "input.meta_inner_tab == 'Filter by metadata'",
            uiOutput("text_filtering_col_ui"),
            shinyjs::disabled(actionButton("coerce_col_numeric",
              "Coerce to numeric",
              icon = icon("list-ol"), class="mb-2"
            )),
          ),
          conditionalPanel(
            condition = "input.meta_inner_tab == 'Coerce metadata type'",
            shinyjs::disabled(actionButton("coerce_selected_to_numeric", "Coerce to numeric",
                         icon = icon("list-ol"), class = "mb-2"))
          ),
          hr(),
          shinyjs::disabled(actionButton("delete_text_filter", "Exclude selected", icon = icon("trash"), class="mb-2")),
          conditionalPanel(
            condition = "input.meta_inner_tab == 'Filter by text ID'",
            shinyjs::disabled(actionButton("delete_by_text_id", "Exclude selected IDs", icon = icon("trash"), class="mb-2")),
          ),
          shinyjs::disabled(actionButton("undo_last_text_filter", "Undo last exclusion", icon = icon("undo"), class="mb-2")),
          shinyjs::disabled(actionButton("undo_all_text_filter", "Reset exclusions", icon = icon("history"), class="mb-2"))
        ),
        accordion_panel(
          title = "Advanced type coercion",
          shinyjs::disabled(
            actionButton("center_scale_col", "Center and scale",
                         icon = icon("scale-balanced"), class = "mb-2")
          ),
          shinyjs::disabled(
            actionButton("factorise_col", "Factorise",
                         icon = icon("chart-line"), class = "mb-2")
          ),
          shinyjs::disabled(
            actionButton("unfactorise_col", "Unfactorise",
                         icon = icon("chart-column"), class = "mb-2")
          ),
          shinyjs::disabled(
            actionButton("coerce_to_discrete_col", "Coerce to discrete",
                         icon = icon("list"), class = "mb-2")
          ),
          shinyjs::disabled(
            actionButton("restore_unscaled_col", "Restore unscaled values",
                         icon = icon("scale-unbalanced"), class = "mb-2")
          )
        ),
        accordion_panel(
          title = "Custom labels",
          id = "custom_labels_meta",
          open = FALSE,
          textInput("filter_plot_title", "Plot title", value = ""),
          textInput("filter_plot_x_label", "X axis title", value = ""),
          textInput("filter_plot_y_label", "Y axis title", value = "")
        ),
        accordion_panel(
          title = "Export",
          id = "export_meta",
          uiOutput("save_filter_plot_ui")
        )
      )

descriptive_sidebar <- conditionalPanel(
        condition="input.tabselected == 'desc_tab'",
        accordion_panel(
          title = "Corpus/texts settings",
          id = "corpus_settings_desc",
          uiOutput("text_id_col_ui_desc"),
          uiOutput("dependent_cat_ui"),
          uiOutput("x_axis_col_ui"),
          uiOutput("group_col_ui"),
          actionButton("coerce_x_axis_numeric", "Coerce type to continuous", icon = icon("ruler"), class="mb-2")
        ),
        accordion_panel(
          title = "Subset texts",
          id = "subset_texts_desc",
          open = FALSE,
          uiOutput("subset_col_ui"),
          uiOutput("subset_vals_ui")
        ),
        accordion_panel(
          title = "Group tokens",
          id = "token_filter_desc",
          open = FALSE,
          uiOutput("token_filter_col_ui"),
          uiOutput("token_filter_vals_ui")
        ),
        accordion_panel(
          title = "Regression",
          id = "regression_settings_desc",
          checkboxInput("show_loess", "Show LOESS", value = TRUE),
          checkboxInput("show_lm",    "Show linear (dashed)", value = TRUE),
          selectInput("lm_formula", "LOESS formula",
            choices = c(
              "y ~ x"       = "y ~ x",
              "y ~ x + I(x^2)" = "y ~ x + I(x^2)",
              "y ~ log(x)"  = "y ~ log(x)"
            )
          )
        ),
        accordion_panel(
          title = "Custom labels",
          id = "custom_labels_desc",
          open = FALSE,
          textInput("plot_title", "Plot title", value = ""),
          textInput("x_axis_label", "X axis title", value = ""),
          textInput("y_axis_label", "Y axis title", value = ""),
          textInput("legend_title", "Legend title", value = ""),
          textInput("size_legend_title", "Point size legend title", value = "")
        ),
        accordion_panel(
          title = "Export",
          id = "export_desc",
          actionButton("save_desc_plot", "Save current plot", icon = icon("save"), class = "mb-2")
        )
      )