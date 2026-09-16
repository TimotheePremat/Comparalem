# Comparalem

> Timothée Premat, Université de Neuchâtel, SNSF SPF Fellow, Sept. 2026.

Comparalem is an R/Shiny app for studying variation between two or more categories of linguistic
forms (e.g., competing word forms, spellings, or constructions) across a corpus, using per-token
data plus text-level metadata. You upload one dataset per category, the app pairs them up by
lemma, and lets you filter, tag, and explore the data before producing descriptive statistics and
plots (by text or by token), each with a basic significance test.

## Requirements

- R (a recent version).
- The R packages listed in `src/packages.r`. They are installed automatically on first run if
  missing (via the `ipak()` helper at the top of that file), so no manual setup is normally needed
  beyond having R itself installed.

## Launching the app

The app's working directory must be `src/`, since it saves logs, plots, and backups to paths
relative to it (`../Data/log`, `../plots`, `../data/saved`).

- **RStudio**: open `src/main.r` and click "Source" (or run it line by line). A browser window
  with the app will open once packages finish loading.
- **Terminal**: `cd src && Rscript -e 'source("main.r")'`

## Input data format

Each category you want to compare is one file:

- Tab-separated (`.csv` or `.tsv`, tab-delimited either way).
- Same set of columns across all files (or at least the same lemma column name).
- One row per token/occurrence, with at minimum a column giving the lemma, plus whatever metadata
  columns you have for the text it came from (date, genre, author, region, text ID, etc.) and any
  columns describing the local context of the token itself (POS, surrounding context, etc.).

You need **two or more** files — one per category of the variation you're studying (e.g., one file
for each of the two competing forms).

## Workflow

The tabs are meant to be used roughly in order, left to right.

### 1. Load Data

Upload your files (sidebar → "Load data"). Each dataset gets a preview card; you can rename its
category label in the sidebar (defaults to the file name). If a column needs to be split (e.g. a
concatenated metadata header from a corpus tool), use "Parse data": pick the column, optionally
rewrite its heading, choose a separator, and click "Parse data" to split it into several columns
across all uploaded datasets at once.

### 2. Find lemmas

Pick the column that holds the lemma. If you want to match by lemma *and* part-of-speech instead
of lemma alone, switch to "Lemma + POS" and also pick the POS column. Click "Find common lemmas":
this flags every lemma (or lemma+POS pair) that occurs in *every* uploaded dataset — only those are
kept downstream, since the point of the tool is to compare categories on a shared set of lexical
items.

### 3. Filter lemmas

A frequency table of the common lemmas, one row per lemma with counts and rates per category.
Select rows and click "Exclude lemmas" to drop them from the analysis (downstream only — nothing is
deleted from the raw upload). Double-click a row to jump to that lemma's occurrences in "Filter
forms". You can also exclude/keep lemmas listed in an external file (accordion "Exclude from
file").

### 4. Filter forms

The full token-level table ("concordancer") resulting from your kept lemmas. Select rows and click
"Exclude forms" to remove specific occurrences. Column visibility and file-based exclusion (same
idea as for lemmas, matched on a text-ID + token-ID pair) are in the sidebar accordions.

### 5. Corpus, metadata, tagging

Four sub-tabs for working with text-level metadata:

- **Filter by metadata**: pick a text-ID column, then a column to filter on. For a numeric column
  you get a distribution plot (with customizable title/axis text) and can set bounds interactively
  on the plot to exclude texts outside them; the plot can be saved as a PNG. For a categorical
  column you get a table to select values to exclude.
- **Coerce metadata type**: select columns in the table and center/scale, factorise, unfactorise,
  or convert numeric ↔ discrete as needed for later steps.
- **Filter by text ID**: exclude specific texts directly by their ID.
- **Tag by adding files**: upload one or more reference CSVs and match their rows against the
  concordancer (on one or more columns) to write a new annotation column — either from the
  filename of the matching reference file, or from a column's value.

### 6. Descriptive statistics

Two views, selected by the inner tabs:

- **By text**: for each text, the proportion of a chosen "dependent" category among all categories
  is plotted against a metadata column (numeric → scatter with LOESS/linear fit; categorical → bar
  chart). The paired test below the plot is always a **Wilcoxon rank-sum test** (or Kruskal-Wallis
  with 3+ subset groups) comparing that per-text rate between two groups of a "Subset by column"
  split.
- **By token**: the same categories, but as total token counts (stacked bar) rather than per-text
  rates. The test below is always a **chi-squared test** on the token-count contingency table
  (subset group × category); for a 2×2 table it also shows the uncorrected chi-squared and Fisher's
  exact test alongside the standard Yates-corrected one, plus the raw observed counts, since Yates'
  correction can look deceptively flat (X²≈0) on lopsided tables. Each panel's card carries a small
  warning noting exactly what the test was computed on (rate vs. token count), since the two are
  genuinely different statistics.

Sidebar accordions control the analysis:

- **Corpus/texts settings**: text-ID column, dependent category, x-axis column, an optional
  grouping column.
- **Subset texts**: split into two (or more) groups for the test above, via any categorical column
  and the values to keep.
- **Group tokens**: split/filter by another column (metadata or token-level) — becomes extra series
  or facets in the plots.
- **Regression**: toggle the LOESS/linear fit and formula, for the "By text" scatter plot.
- **Custom labels**: full-text overrides for the plot title, axis titles, legend title, and the
  point-size legend title — leave blank to keep the automatic defaults.
- **Export**: save the currently displayed plot as a PNG to `../plots`.

### 7. Save / Load

- **Backup**: "Save backup" writes the current lemma table + concordancer + key settings to an
  `.xlsx` file under `../data/saved`, so you can resume later without redoing the upload/filtering
  steps. Use "Select backup file" + "Resume from saved data" to reload one.
- **Export individual datasets**: download the current lemma table or concordancer as a standalone
  `.xlsx` file.

## Output locations

All paths are relative to `src/`:

- `../Data/log/` — one timestamped log file per session.
- `../plots/` — PNGs saved from the descriptive-statistics or metadata-distribution plots.
- `../data/saved/` — `.xlsx` backups written by "Save backup".

## Repository layout note

This repository also contains earlier, non-Shiny R scripts (`src/GLMM.r`, `src/Old/`, and the
top-level `Data`, `Graphs`, `Tables`, shapefile folders, etc.) used for exploratory modelling and
mapping outside of the app described above. `Instructions.md` documents how the author's own
corpus data was originally extracted from TXM; it isn't required to use the Shiny app as long as
your input files match the format described above.

## How to cite

> Premat, Timothée (2025). Comparalem, version 2-alpha. Url: <https://github.com/TimotheePremat/Comparalem_v2_SIDF25.git>

This is delivered under the GNU-GPL 3 licence. Please let me know if you use this; I'd be curious!
