output$subset_col_ui <- renderUI({
    conc   <- req(concordancer_rv())
    id_col <- req(input$text_id_col)
    req(id_col %in% names(conc))
    cat_cols <- Filter(function(col) !is.numeric(conc[[col]]),
                       setdiff(names(conc), c(id_col, "cat", "form_id")))
    saved    <- isolate(input$subset_col)
    selected <- if (!is.null(saved) && saved %in% c("", cat_cols)) saved else ""
    selectInput("subset_col", label = "Subset by column:",
                choices = c("None" = "", cat_cols),
                selected = selected, selectize = FALSE)
})

output$subset_vals_ui <- renderUI({
    col <- input$subset_col
    req(!is.null(col), nzchar(col))
    conc <- req(concordancer_rv())
    req(col %in% names(conc))
    vals   <- sort(unique(as.character(conc[[col]])))
    vals   <- vals[!is.na(vals)]
    saved  <- isolate(input$subset_vals)
    selected <- if (!is.null(saved) && length(intersect(saved, vals)) > 0) saved else vals
    checkboxGroupInput("subset_vals", label = "Keep values:", choices = vals, selected = selected)
})


output$token_filter_col_ui <- renderUI({
    conc <- req(concordancer_rv())
    cols <- setdiff(names(conc), c("cat", "form_id"))
    saved <- isolate(input$token_filter_col)
    selected <- if (!is.null(saved) && saved %in% c("", cols)) saved else ""
    selectInput("token_filter_col",
                label = tooltip(
                    trigger = list("Group tokens by:", bs_icon("info-circle")),
                    HTML("Splits data using another column and removes some groups.
                    This can be a non-metadata column
                    (i.e., multiple value per text, such as context) or a metadata column
                    (i.e., one value per text, such as date or genre); if it is a metadata column,
                    no division per group is displayed but this allows to remove some groups.")
                ),
                choices = c("All (no filter)" = "", cols),
                selected = selected, selectize = FALSE)
})

output$token_filter_vals_ui <- renderUI({
    col    <- input$token_filter_col
    req(!is.null(col), nzchar(col))
    conc   <- req(concordancer_rv())
    req(col %in% names(conc))
    id_col <- input$text_id_col

    vals <- sort(unique(as.character(conc[[col]])))
    vals <- vals[!is.na(vals)]
    saved    <- isolate(input$token_filter_vals)
    selected <- if (!is.null(saved) && length(intersect(saved, vals)) > 0) saved else vals

    is_constant <- if (!is.null(id_col) && nzchar(id_col) && id_col %in% names(conc)) {
        all(tapply(as.character(conc[[col]]), conc[[id_col]],
                   function(x) length(unique(x[!is.na(x)])) <= 1))
    } else NA

    mode_hint <- if (isTRUE(is_constant))
        "One value per text \u2192 acts as filter"
    else if (isFALSE(is_constant))
        "Multiple values per text \u2192 each value becomes a separate series"
    else NULL

    tagList(
        if (!is.null(mode_hint))
            tags$small(class = "text-muted fst-italic mb-1 d-block", mode_hint),
        checkboxGroupInput("token_filter_vals", label = "Values",
                           choices = vals, selected = selected)
    )
})

# All category names present in the concordancer (upload order / order of
# first appearance) -- this is what makes the app work with N >= 2 categories
cat_names <- reactive({
    conc <- req(concordancer_rv())
    req("cat" %in% names(conc))
    unique(as.character(conc$cat))
})

# Which category's proportion is used as the "dependent rate" in the by-text
# and by-token rate plots below (matters when there are 3+ categories)
output$dependent_cat_ui <- renderUI({
    cats <- req(cat_names())
    saved    <- isolate(input$dependent_cat)
    selected <- if (!is.null(saved) && saved %in% cats) saved else utils::tail(cats, 1)
    selectInput(
        "dependent_cat",
        label = tooltip(
            trigger = list("Category to model (rate of)", bs_icon("info-circle")),
            HTML("The rate/scatter plots below show the proportion of this category (out of all categories) per text.<br>
            With only two categories this is the same as the second dataset's rate.")
        ),
        choices = cats, selected = selected
    )
})

cat1_cat2_count <- reactive({
    df_full <- req(concordancer_rv())
    cats    <- req(cat_names())
    dep_cat <- req(input$dependent_cat)
    req(dep_cat %in% cats)
    req(input$text_id_col)
    id_col  <- input$text_id_col
    req(!id_col %in% c("cat", "form_id"))

    # Inner helper: count each category per text for one data frame
    compute_counts <- function(df) {
        constant_cols <- Filter(function(col) {
            tbl <- unique(df[, c(id_col, col), drop = FALSE])
            nrow(tbl) == length(unique(df[[id_col]]))
        }, setdiff(names(df), c(id_col, "cat", "form_id")))

        metadata <- df %>%
            dplyr::select(dplyr::all_of(c(id_col, constant_cols))) %>%
            dplyr::distinct()

        counted <- df %>%
            group_by(.data[[id_col]], cat) %>%
            summarise(n = dplyr::n(), .groups = "drop") %>%
            tidyr::pivot_wider(names_from = cat, values_from = n, values_fill = 0L)

        for (col_name in cats) {
            if (!col_name %in% names(counted)) counted[[col_name]] <- 0L
        }

        counted %>%
            dplyr::mutate(n_tot = rowSums(dplyr::across(dplyr::all_of(cats)), na.rm = TRUE)) %>%
            dplyr::mutate(Tx_cat2 = .data[[dep_cat]] / n_tot) %>%
            dplyr::left_join(metadata, by = id_col)
    }

    # Token-level filter/split logic applied to one concordancer slice
    apply_token_filter <- function(df) {
        filter_col  <- input$token_filter_col
        filter_vals <- input$token_filter_vals

        if (is.null(filter_col) || !nzchar(filter_col) || !filter_col %in% names(df)) {
            return(compute_counts(df))
        }

        all_vals    <- sort(unique(as.character(df[[filter_col]])))
        all_vals    <- all_vals[!is.na(all_vals)]
        active_vals <- if (!is.null(filter_vals) && length(filter_vals) > 0) filter_vals else all_vals

        is_constant <- all(tapply(
            as.character(df[[filter_col]]),
            df[[id_col]],
            function(x) length(unique(x[!is.na(x)])) <= 1
        ))

        if (is_constant) {
            sub <- df[as.character(df[[filter_col]]) %in% active_vals, , drop = FALSE]
            if (nrow(sub) == 0) return(NULL)
            compute_counts(sub)
        } else {
            result_list <- lapply(active_vals, function(val) {
                sub_df <- df[as.character(df[[filter_col]]) == val, , drop = FALSE]
                if (nrow(sub_df) == 0) return(NULL)
                compute_counts(sub_df) %>% dplyr::mutate(.split = as.character(val))
            })
            result_list <- Filter(Negate(is.null), result_list)
            if (length(result_list) == 0) return(NULL)
            dplyr::bind_rows(result_list)
        }
    }

    # Outer subset split (text-level, categorical metadata column)
    subset_col  <- input$subset_col
    subset_vals <- input$subset_vals

    if (is.null(subset_col) || !nzchar(subset_col) || !subset_col %in% names(df_full)) {
        result <- apply_token_filter(df_full)
        req(!is.null(result), nrow(result) > 0)
        return(result)
    }

    all_subset  <- sort(unique(as.character(df_full[[subset_col]])))
    all_subset  <- all_subset[!is.na(all_subset)]
    active_subset <- if (!is.null(subset_vals) && length(subset_vals) > 0) subset_vals else all_subset

    result_list <- lapply(active_subset, function(val) {
        sub_df <- df_full[as.character(df_full[[subset_col]]) == val, , drop = FALSE]
        if (nrow(sub_df) == 0) return(NULL)
        res <- apply_token_filter(sub_df)
        if (is.null(res)) return(NULL)
        res %>% dplyr::mutate(.subset = as.character(val))
    })
    result_list <- Filter(Negate(is.null), result_list)
    req(length(result_list) > 0)
    dplyr::bind_rows(result_list)
})

observe({ cat1_cat2_count() })

cat1_cat2_stats <- reactive({
    df <- req(cat1_cat2_count())
    list(
        mean   = round(mean(df$Tx_cat2, na.rm = TRUE), 2),
        median = round(median(df$Tx_cat2, na.rm = TRUE), 2),
        sd     = round(sd(df$Tx_cat2, na.rm = TRUE), 2),
        sum    = round(sum(df$n_tot, na.rm = TRUE), 2)
    )
})

cat1_cat2_dates <- reactive({
    req(input$x_axis_col)
    conc <- req(concordancer_rv())
    id_col <- input$x_axis_col
    req(id_col %in% names(conc))
    dates <- conc[[id_col]]
    min_d <- min(dates, na.rm = TRUE)
    max_d <- max(dates, na.rm = TRUE)
    list(
        min  = min_d,
        max  = max_d,
        max1 = max_d + (0.17 * (max_d - min_d)),
        max2 = max_d + (0.2  * (max_d - min_d)),
        max3 = max_d + (0.4  * (max_d - min_d))
    )
})

# Basic scatter plot
scatter_plot <- function(data, x, y, stats, dates, title_element, y_label,
                         group_col = NULL,
                         show_loess = TRUE, show_lm = TRUE, lm_formula = "y ~ x",
                         x_label = "Date") {
    grouped <- !is.null(group_col) && nzchar(group_col)

    if (grouped) {
        p <- ggplot(data, aes({{x}}, {{y}}, colour = .data[[group_col]], size = n_tot)) +
            geom_point(alpha = 0.7)
    } else {
        p <- ggplot(data, aes({{x}}, {{y}}, size = n_tot)) +
            geom_point(alpha = 0.7)
    }

    p <- p +
        theme_classic() +
        scale_x_continuous(name = x_label) +
        scale_y_continuous(limits = c(0, 1), name = y_label) +
        labs(title = paste(title_element))

    if (show_loess) {
        if (grouped) {
            p <- p + geom_smooth(method = "loess", formula = as.formula(lm_formula),
                                 se = FALSE, na.rm = TRUE, span = 0.75,
                                 show.legend = c(size = FALSE))
        } else {
            p <- p + geom_smooth(method = "loess", formula = as.formula(lm_formula),
                                 se = FALSE, na.rm = TRUE, colour = "black", span = 0.75,
                                 show.legend = FALSE)
        }
    }
    if (show_lm) {
        if (grouped) {
            p <- p + geom_smooth(method = "lm", se = FALSE, na.rm = TRUE,
                                 linetype = "dashed", show.legend = c(size = FALSE))
        } else {
            p <- p + geom_smooth(method = "lm", se = FALSE, na.rm = TRUE,
                                 colour = "black", linetype = "dashed", show.legend = FALSE)
        }
    }
    p
}

output$group_col_ui <- renderUI({
    conc   <- req(concordancer_rv())
    id_col <- req(input$text_id_col)
    req(id_col %in% names(conc))

    constant_cols <- Filter(function(col) {
        tbl <- unique(conc[, c(id_col, col), drop = FALSE])
        nrow(tbl) == length(unique(conc[[id_col]]))
    }, setdiff(names(conc), c(id_col, "cat", "form_id")))

    group_choices <- setdiff(constant_cols, isolate(input$x_axis_col))
    saved    <- isolate(input$group_col)
    selected <- if (!is.null(saved) && saved %in% c("", group_choices)) saved else ""
    selectInput("group_col",
                label = tooltip(
                    trigger = list("Group texts by:", bs_icon("info-circle")),
                    "Split texts into groups given a metadata column.<br>
                    Works only with a column with only one value per text."
                ),
                choices = c("None" = "", group_choices), selected = selected,
                selectize = FALSE)
})

output$x_axis_col_ui <- renderUI({
    conc   <- req(concordancer_rv())
    id_col <- req(input$text_id_col)
    req(id_col %in% names(conc))

    constant_cols <- Filter(function(col) {
        tbl <- unique(conc[, c(id_col, col), drop = FALSE])
        nrow(tbl) == length(unique(conc[[id_col]]))
    }, setdiff(names(conc), c(id_col, "cat", "form_id")))

    saved    <- isolate(input$x_axis_col)
    selected <- if (!is.null(saved) && saved %in% constant_cols) saved else constant_cols[1]
    selectInput("x_axis_col",
                label = tooltip(
                    trigger = list("Set x-axis column", bs_icon("info-circle")),
                    "To display a time-series scatter plot, use a date column and, if needed, coerce type to continuous."
                ),
                choices = constant_cols, selected = selected)
})

output$desc_scatter_plot <- renderPlot({
    req(input$x_axis_col)
    data  <- req(cat1_cat2_count())
    req(input$x_axis_col %in% names(data))

    x_col      <- input$x_axis_col
    split_col  <- if (".split"  %in% names(data)) ".split"  else NULL
    subset_col <- if (".subset" %in% names(data)) ".subset" else NULL
    group_col  <- if (!is.null(input$group_col) && nzchar(input$group_col) &&
                      input$group_col %in% names(data)) input$group_col else NULL
    eff_group  <- if (!is.null(split_col)) split_col else group_col
    eff_label  <- if (!is.null(split_col)) input$token_filter_col else NULL
    subset_label <- input$subset_col

    dep_cat       <- req(input$dependent_cat)
    x_label       <- if (nzchar(input$x_axis_label)) input$x_axis_label else x_col
    title_val     <- if (nzchar(input$plot_title)) input$plot_title else dep_cat
    y_label       <- if (nzchar(input$y_axis_label)) input$y_axis_label else paste("Rate of", dep_cat, "(by text)")
    legend_lab    <- if (nzchar(input$legend_title)) input$legend_title else eff_label
    size_lab      <- if (nzchar(input$size_legend_title)) input$size_legend_title else NULL

    if (is.numeric(data[[x_col]])) {
        stats <- req(cat1_cat2_stats())
        dates <- req(cat1_cat2_dates())
        p <- scatter_plot(
            data          = data,
            x             = .data[[x_col]],
            y             = Tx_cat2,
            stats         = stats,
            dates         = dates,
            title_element = title_val,
            y_label       = y_label,
            group_col     = eff_group,
            show_loess    = isTRUE(input$show_loess),
            show_lm       = isTRUE(input$show_lm),
            lm_formula    = input$lm_formula,
            x_label       = x_label
        )
        if (!is.null(legend_lab)) p <- p + labs(colour = legend_lab)
        if (!is.null(size_lab))   p <- p + labs(size = size_lab)
    } else {
        if (!is.null(eff_group)) {
            plot_data <- data %>%
                dplyr::group_by(dplyr::across(dplyr::all_of(
                    unique(c(x_col, eff_group, subset_col))
                ))) %>%
                dplyr::summarise(Tx_cat2 = mean(Tx_cat2, na.rm = TRUE), .groups = "drop")
            p <- ggplot(plot_data, aes(x = .data[[x_col]], y = Tx_cat2,
                                       fill = .data[[eff_group]])) +
                geom_col(position = "dodge") +
                theme_classic() +
                scale_y_continuous(limits = c(0, 1), name = y_label) +
                labs(x = x_label, title = title_val) +
                theme(axis.text.x = element_text(angle = 45, hjust = 1))
            if (!is.null(legend_lab)) p <- p + labs(fill = legend_lab)
        } else {
            p <- ggplot(data, aes(x = .data[[x_col]], y = Tx_cat2)) +
                geom_col(fill = "#4e79a7") +
                theme_classic() +
                scale_y_continuous(limits = c(0, 1), name = y_label) +
                labs(x = x_label, title = title_val) +
                theme(axis.text.x = element_text(angle = 45, hjust = 1))
        }
    }

    if (!is.null(subset_col)) {
        p <- p + facet_wrap(~ .data[[subset_col]],
                            labeller = labeller(.default = function(x) paste(subset_label, x, sep = ": ")))
    }
    p
})

desc_token_agg <- reactive({
    req(input$x_axis_col)
    data  <- req(cat1_cat2_count())
    req(input$x_axis_col %in% names(data))

    x_col <- input$x_axis_col
    cats  <- req(cat_names())
    req(all(cats %in% names(data)))

    split_col  <- if (".split"  %in% names(data)) ".split"  else NULL
    subset_col <- if (".subset" %in% names(data)) ".subset" else NULL
    group_col  <- if (!is.null(input$group_col) && nzchar(input$group_col) &&
                      input$group_col %in% names(data)) input$group_col else NULL

    group_vars <- unique(c(x_col, group_col, split_col, subset_col))

    agg <- data %>%
        dplyr::group_by(dplyr::across(dplyr::all_of(group_vars))) %>%
        dplyr::summarise(
            dplyr::across(dplyr::all_of(cats), ~ sum(.x, na.rm = TRUE)),
            .groups = "drop"
        )

    if (!is.null(split_col) && !is.null(input$token_filter_col) && nzchar(input$token_filter_col))
        names(agg)[names(agg) == ".split"] <- input$token_filter_col
    if (!is.null(subset_col) && !is.null(input$subset_col) && nzchar(input$subset_col))
        names(agg)[names(agg) == ".subset"] <- input$subset_col

    agg
})

output$desc_token_plot <- renderPlot({
    agg       <- req(desc_token_agg())
    x_col     <- input$x_axis_col
    cats      <- req(cat_names())
    x_label    <- if (nzchar(input$x_axis_label)) input$x_axis_label else x_col
    title_val  <- if (nzchar(input$plot_title)) input$plot_title else paste(cats, collapse = " vs. ")
    y_label    <- if (nzchar(input$y_axis_label)) input$y_axis_label else "Number of tokens"
    legend_lab <- if (nzchar(input$legend_title)) input$legend_title else NULL

    filter_col <- if (!is.null(input$token_filter_col) && nzchar(input$token_filter_col) &&
                      input$token_filter_col %in% names(agg)) input$token_filter_col else NULL
    group_col  <- if (!is.null(input$group_col) && nzchar(input$group_col) &&
                      input$group_col %in% names(agg)) input$group_col else NULL
    sub_col    <- if (!is.null(input$subset_col) && nzchar(input$subset_col) &&
                      input$subset_col %in% names(agg)) input$subset_col else NULL

    plot_data <- agg %>%
        tidyr::pivot_longer(
            cols      = dplyr::all_of(cats),
            names_to  = "category",
            values_to = "n"
        )

    p <- ggplot(plot_data, aes(x = .data[[x_col]], y = n, fill = category)) +
        geom_col(position = "stack") +
        theme_classic() +
        scale_y_continuous(expand = ggplot2::expansion(mult = c(0, 0.05)),
                           name = y_label) +
        labs(x = x_label, title = title_val, fill = legend_lab) +
        theme(axis.text.x = element_text(angle = 45, hjust = 1))

    # Facet: rows = subset, cols = filter or group
    col_facet <- if (!is.null(filter_col)) filter_col else group_col
    if (!is.null(sub_col) && !is.null(col_facet)) {
        p <- p + facet_grid(rows = vars(.data[[sub_col]]), cols = vars(.data[[col_facet]]),
                            labeller = labeller(.rows = function(x) paste(sub_col, x, sep = ": ")))
    } else if (!is.null(sub_col)) {
        p <- p + facet_wrap(~ .data[[sub_col]],
                            labeller = labeller(.default = function(x) paste(sub_col, x, sep = ": ")))
    } else if (!is.null(filter_col) && !is.null(group_col)) {
        p <- p + facet_grid(rows = vars(.data[[filter_col]]), cols = vars(.data[[group_col]]),
                            labeller = labeller(.rows = function(x) paste(filter_col, x, sep = ": ")))
    } else if (!is.null(filter_col)) {
        p <- p + facet_wrap(~ .data[[filter_col]],
                            labeller = labeller(.default = function(x) paste(filter_col, x, sep = ": ")))
    } else if (!is.null(group_col)) {
        p <- p + facet_wrap(~ .data[[group_col]])
    }

    p
})

# observe({ print(desc_token_agg()) })

# "By text" panel: always Wilcoxon rank-sum (2 subset groups) or
# Kruskal-Wallis (3+ groups) on each text's rate of the dependent category.
subset_test_result <- reactive({
    sub_col <- input$subset_col
    req(!is.null(sub_col), nzchar(sub_col))
    data <- req(cat1_cat2_count())
    req(".subset" %in% names(data))

    groups <- split(data$Tx_cat2, data$.subset)
    groups <- Filter(function(x) length(x) > 0, groups)
    test <- if (length(groups) == 2) {
        wilcox.test(groups[[1]], groups[[2]])
    } else {
        kruskal.test(Tx_cat2 ~ .subset, data = data)
    }
    list(test = test, mat = NULL)
})

# "By token" panel: always chi-squared on the token-count contingency table
# (subset group x category), i.e. it already operates on token counts.
subset_test_result_token <- reactive({
    sub_col <- input$subset_col
    req(!is.null(sub_col), nzchar(sub_col))
    data <- req(cat1_cat2_count())
    req(".subset" %in% names(data))
    cats    <- req(cat_names())
    req(all(cats %in% names(data)))

    tbl <- data %>%
        dplyr::group_by(.subset) %>%
        dplyr::summarise(
            dplyr::across(dplyr::all_of(cats), ~ sum(.x, na.rm = TRUE)),
            .groups = "drop"
        )
    mat <- as.matrix(tbl[, cats])
    rownames(mat) <- tbl$.subset
    list(test = chisq.test(mat), mat = mat)
})

x2_result_card <- function(test_info, sub_col, cats, dep_cat, medians_by_group, median_overall,
                           metric_label = "Tx", basis_note = NULL) {
    info <- tryCatch(test_info, error = function(e) e)
    if (inherits(info, "error")) return(NULL)
    res <- info$test
    mat <- info$mat

    is_chisq   <- grepl("chi-squared", res$method, ignore.case = TRUE)
    is_wilcox  <- grepl("wilcoxon",    res$method, ignore.case = TRUE)
    is_kruskal <- grepl("kruskal",     res$method, ignore.case = TRUE)

    stat_name <- if (is_chisq) "\u03C7\u00B2" else if (is_wilcox) "W" else "H"
    stat_val  <- round(unname(res$statistic), 4)
    p_fmt     <- if (res$p.value < 0.001) "< 0.001" else round(res$p.value, 4)
    p_col     <- if (res$p.value < 0.05) "text-danger fw-bold" else "text-muted"

    test_rows <- list(
        tags$tr(tags$th(stat_name), tags$td(stat_val)),
        tags$tr(tags$th("p-value"), tags$td(class = p_col, p_fmt))
    )
    if (is_chisq || is_kruskal) {
        df_val    <- unname(res$parameter[["df"]])
        test_rows <- c(list(tags$tr(tags$th("df"), tags$td(df_val))), test_rows)
    }

    median_rows <- c(
        list(tags$tr(tags$th(colspan = "2", tags$em(paste0("Median ", metric_label, "(", dep_cat, ")"))))),
        lapply(names(medians_by_group), function(g)
            tags$tr(tags$th(g), tags$td(round(medians_by_group[[g]], 4)))
        ),
        list(tags$tr(tags$th("Overall"), tags$td(round(median_overall, 4))))
    )

    # For chi-squared, show the actual observed contingency table: lets you
    # check whether the subset groups really differ, or the split isn't
    # doing what's expected (e.g. an X2 of exactly 0 means the two groups
    # have the exact same category ratio in this table)
    observed_table <- if (is_chisq && !is.null(res$observed)) {
        obs <- res$observed
        tags$table(class = "table table-sm table-bordered w-auto mb-2",
            tags$thead(tags$tr(tags$th(sub_col), lapply(colnames(obs), tags$th))),
            tags$tbody(
                !!!lapply(rownames(obs), function(rn)
                    tags$tr(tags$th(rn), lapply(colnames(obs), function(cn) tags$td(obs[rn, cn])))
                )
            )
        )
    } else NULL

    # For 2x2 tables, Yates' continuity correction (the headline stat above)
    # can be overly conservative -- show the uncorrected chi-squared and
    # Fisher's exact test alongside it for comparison
    extra_rows <- NULL
    if (is_chisq && !is.null(mat) && nrow(mat) == 2 && ncol(mat) == 2) {
        uncorrected <- tryCatch(chisq.test(mat, correct = FALSE), error = function(e) NULL)
        fisher      <- tryCatch(fisher.test(mat), error = function(e) NULL)
        fmt_p <- function(p) if (p < 0.001) "< 0.001" else round(p, 4)

        extra_rows <- c(
            list(tags$tr(tags$td(colspan = "2", tags$hr()))),
            if (!is.null(uncorrected)) list(
                tags$tr(tags$th(colspan = "2", tags$em("Without continuity correction"))),
                tags$tr(tags$th("\u03C7\u00B2"), tags$td(round(unname(uncorrected$statistic), 4))),
                tags$tr(tags$th("p-value"), tags$td(fmt_p(uncorrected$p.value)))
            ),
            if (!is.null(fisher)) list(
                tags$tr(tags$th(colspan = "2", tags$em("Fisher's exact test"))),
                tags$tr(tags$th("p-value"), tags$td(fmt_p(fisher$p.value)))
            )
        )
    }

    card(
        card_header(paste0(res$method, ": ", paste(cats, collapse = " vs. "), " by ", sub_col)),
        if (!is.null(basis_note))
            tags$div(class = "alert alert-warning py-1 px-2 mb-2 small", bs_icon("exclamation-triangle"), " ", basis_note),
        observed_table,
        tags$table(class = "table table-sm table-borderless w-auto",
                   tags$tbody(!!!c(test_rows, list(tags$tr(tags$td(colspan="2", tags$hr()))), median_rows, extra_rows)))
    )
}

output$x2_result_ui <- renderUI({
    sub_col <- input$subset_col
    req(!is.null(sub_col), nzchar(sub_col))
    test    <- req(subset_test_result())
    data    <- req(cat1_cat2_count())
    cats    <- req(cat_names())
    dep_cat <- req(input$dependent_cat)
    med_overall <- median(data$Tx_cat2, na.rm = TRUE)
    med_groups  <- if (".subset" %in% names(data))
        tapply(data$Tx_cat2, data$.subset, median, na.rm = TRUE) else list()
    x2_result_card(test, sub_col, cats, dep_cat, med_groups, med_overall,
                   metric_label = "Tx",
                   basis_note = "Computed on each text's rate (proportion) of the selected category, not on token counts.")
})

output$x2_result_ui_token <- renderUI({
    sub_col <- input$subset_col
    req(!is.null(sub_col), nzchar(sub_col))
    test    <- req(subset_test_result_token())
    data    <- req(cat1_cat2_count())
    cats    <- req(cat_names())
    dep_cat <- req(input$dependent_cat)
    med_overall <- median(data[[dep_cat]], na.rm = TRUE)
    med_groups  <- if (".subset" %in% names(data))
        tapply(data[[dep_cat]], data$.subset, median, na.rm = TRUE) else list()
    x2_result_card(test, sub_col, cats, dep_cat, med_groups, med_overall,
                   metric_label = "n",
                   basis_note = "Computed on each text's raw token count of the selected category, not on its rate.")
})

observeEvent(input$save_desc_plot, {
    tab <- if (!is.null(input$desc_inner_tab)) input$desc_inner_tab else "plot"
    file <- file.path(
        "../plots",
        paste0("desc_plot_", gsub(" ", "_", tab), "_", format(Sys.time(), "%Y-%m-%d_%H-%M-%S"), ".png")
    )
    dir.create("../plots", showWarnings = FALSE)

        p <- if (!is.null(input$desc_inner_tab) && input$desc_inner_tab == "By token") {
            # rebuild token plot
            agg        <- req(desc_token_agg())
            x_col      <- input$x_axis_col
            cats       <- req(cat_names())
            x_label    <- if (nzchar(input$x_axis_label)) input$x_axis_label else x_col
            title_val  <- if (nzchar(input$plot_title)) input$plot_title else paste(cats, collapse = " vs. ")
            y_label    <- if (nzchar(input$y_axis_label)) input$y_axis_label else "Number of tokens"
            legend_lab <- if (nzchar(input$legend_title)) input$legend_title else NULL
            filter_col <- if (!is.null(input$token_filter_col) && nzchar(input$token_filter_col) &&
                              input$token_filter_col %in% names(agg)) input$token_filter_col else NULL
            group_col  <- if (!is.null(input$group_col) && nzchar(input$group_col) &&
                              input$group_col %in% names(agg)) input$group_col else NULL
            sub_col    <- if (!is.null(input$subset_col) && nzchar(input$subset_col) &&
                              input$subset_col %in% names(agg)) input$subset_col else NULL
            plot_data <- agg %>%
                tidyr::pivot_longer(dplyr::all_of(cats),
                                    names_to = "category", values_to = "n")
            p <- ggplot(plot_data, aes(x = .data[[x_col]], y = n, fill = category)) +
                geom_col(position = "stack") + theme_classic() +
                scale_y_continuous(expand = ggplot2::expansion(mult = c(0, 0.05)), name = y_label) +
                labs(x = x_label, title = title_val, fill = legend_lab) +
                theme(axis.text.x = element_text(angle = 45, hjust = 1))
            col_facet <- if (!is.null(filter_col)) filter_col else group_col
            if (!is.null(sub_col) && !is.null(col_facet)) {
                p <- p + facet_grid(rows = vars(.data[[sub_col]]), cols = vars(.data[[col_facet]]))
            } else if (!is.null(sub_col)) {
                p <- p + facet_wrap(~ .data[[sub_col]])
            } else if (!is.null(filter_col) && !is.null(group_col)) {
                p <- p + facet_grid(rows = vars(.data[[filter_col]]), cols = vars(.data[[group_col]]))
            } else if (!is.null(filter_col)) {
                p <- p + facet_wrap(~ .data[[filter_col]])
            } else if (!is.null(group_col)) {
                p <- p + facet_wrap(~ .data[[group_col]])
            }
            p
        } else {
            # rebuild scatter plot
            data  <- req(cat1_cat2_count())
            x_col <- input$x_axis_col
            req(x_col %in% names(data))
            split_col    <- if (".split"  %in% names(data)) ".split"  else NULL
            subset_col_s <- if (".subset" %in% names(data)) ".subset" else NULL
            group_col    <- if (!is.null(input$group_col) && nzchar(input$group_col) &&
                                input$group_col %in% names(data)) input$group_col else NULL
            eff_group    <- if (!is.null(split_col)) split_col else group_col
            eff_label    <- if (!is.null(split_col)) input$token_filter_col else NULL
            subset_label <- input$subset_col
            dep_cat    <- req(input$dependent_cat)
            x_label    <- if (nzchar(input$x_axis_label)) input$x_axis_label else x_col
            title_val  <- if (nzchar(input$plot_title)) input$plot_title else dep_cat
            y_label    <- if (nzchar(input$y_axis_label)) input$y_axis_label else paste("Rate of", dep_cat, "(by text)")
            legend_lab <- if (nzchar(input$legend_title)) input$legend_title else eff_label
            size_lab   <- if (nzchar(input$size_legend_title)) input$size_legend_title else NULL
            if (is.numeric(data[[x_col]])) {
                p <- scatter_plot(data, .data[[x_col]], Tx_cat2,
                                  req(cat1_cat2_stats()), req(cat1_cat2_dates()),
                                  title_val, y_label,
                                  group_col = eff_group,
                                  show_loess = isTRUE(input$show_loess),
                                  show_lm    = isTRUE(input$show_lm),
                                  lm_formula = input$lm_formula,
                                  x_label    = x_label)
                if (!is.null(legend_lab)) p <- p + labs(colour = legend_lab)
                if (!is.null(size_lab))   p <- p + labs(size = size_lab)
            } else {
                x_label_val <- if (nzchar(input$x_axis_label)) input$x_axis_label else x_col
                if (!is.null(eff_group)) {
                    plot_data <- data %>%
                        dplyr::group_by(dplyr::across(dplyr::all_of(
                            unique(c(x_col, eff_group, subset_col_s))
                        ))) %>%
                        dplyr::summarise(Tx_cat2 = mean(Tx_cat2, na.rm = TRUE), .groups = "drop")
                    p <- ggplot(plot_data, aes(x = .data[[x_col]], y = Tx_cat2, fill = .data[[eff_group]])) +
                        geom_col(position = "dodge") + theme_classic() +
                        scale_y_continuous(limits = c(0, 1), name = y_label) +
                        labs(x = x_label_val, title = title_val) +
                        theme(axis.text.x = element_text(angle = 45, hjust = 1))
                    if (!is.null(legend_lab)) p <- p + labs(fill = legend_lab)
                } else {
                    p <- ggplot(data, aes(x = .data[[x_col]], y = Tx_cat2)) +
                        geom_col(fill = "#4e79a7") + theme_classic() +
                        scale_y_continuous(limits = c(0, 1), name = y_label) +
                        labs(x = x_label_val, title = title_val) +
                        theme(axis.text.x = element_text(angle = 45, hjust = 1))
                }
            }
            if (!is.null(subset_col_s)) {
                p <- p + facet_wrap(~ .data[[subset_col_s]],
                                    labeller = labeller(.default = function(x) paste(subset_label, x, sep = ": ")))
            }
            p
        }
    ggplot2::ggsave(file, plot = p, width = 10, height = 6, dpi = 300)
    showNotification(paste("Saved at: Comparalem/plots/", basename(file), sep = ""),
                     type = "message", duration = 5)
})

observeEvent(input$coerce_x_axis_numeric, {
    col  <- trimws(input$x_axis_col)
    conc <- concordancer_rv()
    req(col %in% names(conc))
    conc[[col]] <- suppressWarnings(as.numeric(conc[[col]]))
    concordancer_rv(conc)
})