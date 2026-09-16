# Filters out tokens (form + text ID + token ID)

# Set default folder for file selection
default_folder <- "../Data/3_filtering_out_tokens/*"

# Access the list of irrelevant forms
irrelevant_forms_file <- tk_choose.files(default = file.path(default_folder),
										caption = paste('Choose file for filtering out tokens'),
										multi = FALSE,
										filter = Filters_file_format)
## Depending on the format, chose the right parsing method
if (endsWith(irrelevant_forms_file, ".txt") | endsWith(irrelevant_forms_file, ".csv")) {
  irrelevant_forms <- read_delim(irrelevant_forms_file, delim = ";", escape_double = FALSE, trim_ws = TRUE)
} else if (endsWith(irrelevant_forms_file, ".xlsx") | endsWith(irrelevant_forms_file, ".xls")) {
  irrelevant_forms <- read_excel(irrelevant_forms_file)
} else {
  print("File format not recognized. Accepted inputs are .txt, .csv, .xlsx and .xls")
}

Data_cat1_cleaned <- Data_cat1_cleaned %>%
  anti_join(irrelevant_forms, by=c("word", "lemma", "ref1", "id"))
Data_cat2_cleaned <- Data_cat2_cleaned %>%
  anti_join(irrelevant_forms, by=c("word", "lemma", "ref1", "id"))
