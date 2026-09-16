# Script to find lemmas common to all uploaded datasets (N >= 2)

data_cats_rv <- reactiveVal(list())
lemma_var_rv <- reactiveVal(NULL)

observe({
    dfs <- dfs_rv()
    req(length(dfs) > 0)
    data_cats_rv(dfs)
})

observeEvent(input$find_lemmas, {
    dfs <- data_cats_rv()
    req(length(dfs) >= 2, input$lemma_var)

    if (isTRUE(input$match_mode == "lemma_pos")) {
        req(input$pos_var)
        key_col <- paste0(input$lemma_var, "+", input$pos_var)
        dfs <- lapply(dfs, function(d) {
            d[[key_col]] <- paste(d[[input$lemma_var]], d[[input$pos_var]], sep = "+")
            d
        })
        lv <- key_col
    } else {
        lv <- input$lemma_var
    }

    # A lemma (or lemma+POS key) is "common" when it occurs in every dataset
    key_lists   <- lapply(dfs, function(d) unique(d[[lv]]))
    common_keys <- Reduce(intersect, key_lists)

    dfs <- lapply(dfs, function(d) {
        d$Common_lemma <- d[[lv]] %in% common_keys
        d
    })

    lemma_var_rv(lv)
    data_cats_rv(dfs)
})

output$lemma_selector <- renderUI({
    dfs <- req(data_cats_rv())
    req(length(dfs) > 0)
    selectInput(
    "lemma_var",
    "Choose a column for lemmas:",
    choices = names(dfs[[1]]),
    selected = isolate(input$lemma_var)
    )
})

output$pos_selector <- renderUI({
    dfs <- req(data_cats_rv())
    req(length(dfs) > 0)
    selectInput(
    "pos_var",
    "Choose a column for POS:",
    choices = names(dfs[[1]]),
    selected = isolate(input$pos_var)
    )
})

observe({
    req(input$lemma_var)
    lemma_var_rv(input$lemma_var)
})

# UI skeleton with one card (per dataset) for the Find lemmas tab
output$dataset_lemmas_cards_ui <- renderUI({
    n <- n_datasets()
    req(n > 0)
    tagList(lapply(seq_len(n), function(i) {
        card(
            card_header(textOutput(paste0("df_name_find_lemmas_", i))),
            DTOutput(paste0("data_cat_preview_", i))
        )
    }))
})

# Bind one DT preview per dataset index
observe({
    dfs <- data_cats_rv()
    n   <- length(dfs)
    req(n > 0)

    lapply(seq_len(n), function(i) {
        local({
            ii <- i
            output[[paste0("data_cat_preview_", ii)]] <- DT::renderDT({
                data_cats_rv()[[ii]]
            })
        })
    })
})

# List of common-lemma frequency tables, one per dataset (in upload order)
common_lemmas_list <- reactive({
    dfs <- req(data_cats_rv())
    lv  <- req(lemma_var_rv())
    lapply(dfs, function(df) {
        req(lv %in% names(df), "Common_lemma" %in% names(df))
        df[df$Common_lemma, ] |>
            dplyr::count(.data[[lv]]) |>
            dplyr::arrange(desc(n))
    })
})
