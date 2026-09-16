source("ui_tabs.r", local = TRUE)
source("ui_side.r", local = TRUE)

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
        upload_sidebar,
        find_lemma_sidebar,
        lemma_tab_sidebar,
        concordancer_sidebar,
        descriptive_sidebar,
        meta_sidebar
    ),

        load_pan,
        find_lemmas_pan,
        lemma_list_pan,
        concordancer_pan,
        meta_pan,
        descriptive_pan,
        save_pan,

)