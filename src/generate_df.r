# Script to generate df for lemma_table and concordancer

# ----------------------------------------------
#  Main pipeline initialization (from N uploaded datasets)
# ----------------------------------------------
# 1) create a first version of lemma_table
lemma_table_temp <- reactive({
    lv        <- req(lemma_var_rv())
    cl_list   <- req(common_lemmas_list())
    cat_names <- cat_names_rv()
    req(length(cl_list) == length(cat_names), length(cl_list) >= 2)

    # Rename each dataset's "n" count column to its category name, then
    # full-join all of them together on the lemma column
    renamed <- lapply(seq_along(cl_list), function(i) {
        d <- cl_list[[i]]
        names(d)[names(d) == "n"] <- cat_names[i]
        d
    })
    df <- Reduce(function(x, y) merge(x, y, by = lv, all = TRUE), renamed)

    # Any lemma missing from a given dataset counts as 0 occurrences
    for (cn in cat_names) {
        if (!cn %in% names(df)) df[[cn]] <- 0
        df[[cn]][is.na(df[[cn]])] <- 0
    }

    df <- df %>%
        dplyr::rowwise() %>%
        dplyr::mutate(
            tot. = sum(dplyr::c_across(dplyr::all_of(cat_names)), na.rm = TRUE),
            !!!setNames(
                lapply(cat_names, function(cn) rlang::expr(round(.data[[!!cn]] / tot., 2))),
                paste0("rate ", cat_names)
            )
        ) %>%
        dplyr::ungroup()

    # Rename raw frequency columns "<cat>" -> "F <cat>"
    for (cn in cat_names) {
        df <- dplyr::rename(df, !!paste0("F ", cn) := !!cn)
    }

    df %>% dplyr::mutate(lemma_id = dplyr::row_number())
})

# 2) create a first version of concordancer
concordancer_temp <- reactive({
    lv        <- req(lemma_var_rv())
    dfs       <- req(data_cats_rv())
    cat_names <- cat_names_rv()
    req(length(dfs) == length(cat_names), length(dfs) >= 2)

    table <- req(lemma_table_temp())
    selected_values <- table[[lv]]

    pieces <- lapply(seq_along(dfs), function(i) {
        dfs[[i]] %>%
            dplyr::filter(.data[[lv]] %in% selected_values) %>%
            dplyr::mutate(
                source = names(dfs)[i],
                cat = cat_names[i]
            )
    })

    concordancer <- dplyr::bind_rows(pieces)
    concordancer %>% dplyr::mutate(form_id = dplyr::row_number())
})

# ----------------------------------------------
# Converge with backup pipeline
# ----------------------------------------------
lemma_table_from_upload <- reactiveVal(NULL)
concordancer_from_upload <- reactiveVal(NULL)

lemma_table_choice <- reactive({
    if (!is.null(lemma_table())){
        cat("Using lemma_table()\n")
        lemma_table()
    } else if (is.null(lemma_table_from_upload())){
        cat("Using concordancer_temp()\n")
        lemma_table_temp()
    } else {
        cat("Using lemma_table_from_upload()\n")
        lemma_table_from_upload()
    }
})

concordancer_choice <- reactive({
    if (is.null(concordancer_from_upload())){
        cat("Using concordancer_temp()\n")
        concordancer_temp()
    } else {
        cat("Using concordancer_from_upload()\n")
        concordancer_from_upload()
    }
})

# ----------------------------------------------
# Make dfs reactive to one another and to actions
# ----------------------------------------------
# 1) Recreate lemma_table based on concordancer
lemma_table <- reactive({
    conc <- req(concordancer_rv())
    lv        <- req(lemma_var_rv())
    cat_names <- unique(conc$cat)   # order of first appearance; avoids input timing issues

    df <- conc %>%
        dplyr::count(.data[[lv]], cat) %>%
        tidyr::pivot_wider(names_from = cat, values_from = n, values_fill = 0L)

    # Rename raw cat columns → "F catname"
    for (cn in cat_names) {
        df <- dplyr::rename(df, !!paste0("F ", cn) := !!cn)
    }

    f_cols <- paste0("F ", cat_names)

    df %>%
        dplyr::rowwise() %>%
        dplyr::mutate(
            tot. = sum(dplyr::c_across(dplyr::all_of(f_cols)), na.rm = TRUE),
            !!!setNames(
                lapply(f_cols, function(fc) rlang::expr(round(.data[[!!fc]] / tot., 2))),
                paste0("rate ", cat_names)
            )
        ) %>%
        dplyr::ungroup() %>%
        dplyr::mutate(lemma_id = dplyr::row_number())
})
