## Define a matrix of acceptable formats for tk_choose.files
Filters_file_format <- matrix(c("CSV", ".csv", "Excel", ".xlsx", "Excel", ".xls", "TXT", ".txt"),
								4, 2, byrow = TRUE)

# Set default folder for file selection
default_folder <- "../Data/2_filtering_in_lemmas/*"

# Chose your exploratory file. This file contains only the lemma you have chose
# to keep after manual filtering.
relevant_forms <- tk_choose.files(default = file.path(default_folder),
										caption = paste('Choose file filtering for relevant lemmas only'),
										multi = FALSE,
										filter = Filters_file_format)
## Depending on the format, chose the right parsing method
if (endsWith(relevant_forms, ".txt")) {
  list <- read_delim(relevant_forms, delim = ";", escape_double = FALSE, trim_ws = TRUE)
} else if (endsWith(relevant_forms, ".csv")) {
  list <- read_delim(relevant_forms, delim = ";", escape_double = FALSE, trim_ws = TRUE)

} else if (endsWith(relevant_forms, ".xlsx") | endsWith(relevant_forms, ".xls")) {
  list <- read_excel(relevant_forms, sheet = "Feuil2")
} else {
  print("File format not recognized. Accepted inputs are .txt, .csv, .xlsx and .xls")
}

#Enter lemma col name
lemma_var <- readline(prompt="Enter the name of the lemma variable:")
	#Convert it to symbol (for use in filter)
	lemma_var <- sym(lemma_var)

#Filter the data
Data_cat1_cleaned <- Data_cat1 %>%
  filter(!!lemma_var %in% list[[lemma_var]])
Data_cat2_cleaned <- Data_cat2 %>%
  filter(!!lemma_var %in% list[[lemma_var]])
	#This is the core of Comparalem: only working on lemmas that belong to the
	#two categories.
