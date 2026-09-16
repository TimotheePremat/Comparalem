load_pan <- nav_panel("Load Data",
  value = "upload_data",
  uiOutput("dataset_load_cards_ui")
 )

find_lemmas_pan <- nav_panel("Find lemmas",
  value="lemmas_var",
  uiOutput("dataset_lemmas_cards_ui")
 )

lemma_list_pan <- nav_panel("Filter lemmas",
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
 )

concordancer_pan <- nav_panel("Filter forms",
  value="filter_forms_tab",
  card(
    card_header("Filter out forms"),
    DTOutput("concordancer_preview")
  ),
 )

 meta_pan <- nav_panel("Corpus, metadata, tagging",
  value="filter_texts_tab",
  card(
    navset_card_underline(
      id = "meta_inner_tab",
      nav_panel("Filter by metadata",
        accordion(
          id = "filter_accordion",
          accordion_panel(
            title = "Select values",
            uiOutput("text_filtering_table_container"),
          ),
          accordion_panel(
            title = "View distribution",
            plotlyOutput("text_filtering_plot"),
          )
        )
      ),
      nav_panel("Coerce metadata type", DTOutput("coerce_metadata_table")),
      nav_panel("Filter by text ID", DTOutput("text_id_filter_table")),
      nav_panel("Tag by adding files",
        layout_columns(
          card(
            card_header("Upload reference files"),
            fileInput("ref_files", "Upload CSV files", multiple = TRUE, accept = c(".csv", ".tsv")),
            selectInput("ref_sep", "Separator",
              choices = c("Comma" = ",", "Semicolon" = ";", "Tab" = "\t", "Pipe" = "|"),
              selected = ",", width = "150px"),
            uiOutput("ref_files_rename_ui")
          ),
          card(
            card_header("Matching settings"),
            uiOutput("match_col_concordancer_ui"),
            uiOutput("match_col_ref_ui"),
            textInput("output_col_name", "Output column name", value = "source"),
            radioButtons("tag_value_source", "Tag value from",
              choices = c("Filename" = "filename", "Column value" = "column"),
              selected = "filename", inline = TRUE
            ),
            conditionalPanel(
              condition = "input.tag_value_source == 'column'",
              uiOutput("tag_value_col_ui")
            ),
            shinyjs::disabled(
              actionButton("annotate_by_ref", "Annotate concordancer",
                           icon = icon("tags"), class = "mt-2")
            )
          )
        ),
        helpText(HTML("Add layers of annotation by:
        <ul>
          <li>uploading one CSV file for each type
          of the annotation layer; value of new layer comes from the filename.</li>
          <li>uploading one CSV file; values of new layer come from a col of the file.</li>
        </ul>
        Uploaded file(s) must contain the information needed to uniquely match
        each row of the concordancer (e.g., text ID and position).<br>
        Depending on the number of rows, tagging can take a few seconds.")),
      )
    )
  )
  # card(
    
  # )
 )

save_pan <- nav_panel("Save / Load",
  value="other_saving_tab",
  layout_columns(
    card(
      card_header("Backup"),
      actionButton("download_backup", "Save backup", icon = icon("save"), class="mb-2"),
      hr(),
      shinyFilesButton("df_lemma_resume",
        label = "Select backup file",
        title = "Select a backup file to resume from",
        multiple = FALSE,
        icon = icon("folder-open"),
        class = "btn-default mb-2"
      ),
      helpText("Browse for a previously saved .xlsx backup file. Warning: this will replace the current dataset."),
      actionButton("resume_from_backup", "Resume from saved data", icon = icon("upload"), class="mb-2"),
    ),
    card(
      card_header("Export individual datasets"),
      downloadButton(outputId = "download_lemma", label = "Save lemma dataset (.xlsx)", class="mb-2"),
      downloadButton(outputId = "download_concordancer", label = "Save concordancer (.xlsx)", class="mb-2")
    )
  )
 )

descriptive_pan <- nav_panel("Descriptive statistics",
  value="desc_tab",
  card(
    navset_card_underline(
      id = "desc_inner_tab",
      nav_panel("By text",
        plotOutput("desc_scatter_plot"),
        accordion(
          id = "filter_accordion",
          accordion_panel(
            title = "Contrastive statistics",
            uiOutput("x2_result_ui")
          ),
        )
      ),
      nav_panel("By token",
        plotOutput("desc_token_plot"),
        uiOutput("x2_result_ui_token")
      )
    )
  )
)
