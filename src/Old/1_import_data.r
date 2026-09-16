# Choose the files to investigate

## Define a matrix of acceptable formats for tk_choose.files
Filters_file_format <- matrix(c("TXT", ".txt", "CSV", ".csv"),
								2, 2, byrow = TRUE)

# Set default folder for file selection
default_folder <- "../Data/1_input_data/*"

## First step is to ask the user to assign a file to the var Data_cat1 and Data_cat2
Data_cat1 <- tk_choose.files(default = file.path(default_folder),
										caption = paste('Choose file for', cat2_1),
										multi = FALSE,
										filter = Filters_file_format)
Data_cat2 <- tk_choose.files(default = file.path(default_folder),
										caption = paste('Choose file for', cat2_2),
										multi = FALSE,
										filter = Filters_file_format)

## Second step is to read that file as a CSV file
Data_cat1 <- read_delim(Data_cat1, delim = ";", escape_double = FALSE, trim_ws = TRUE)
Data_cat2 <- read_delim(Data_cat2, delim = ";", escape_double = FALSE, trim_ws = TRUE)

# Import and treat metadata
# Set default folder for file selection
default_folder <- "../Data/*"

## Define a matrix of acceptable formats for tk_choose.files
Filters_file_format <- matrix(c("CSV", ".csv", "TXT", ".txt", "Excel", ".xlsx", "Excel", ".xls"),
								4, 2, byrow = TRUE)

## Chose file
metadata1 <- tk_choose.files(default = file.path(default_folder),
										caption = paste('Choose file for text metadata'),
										multi = FALSE,
										filter = Filters_file_format)

## Load texts' meta-data
if (endsWith(metadata1, ".txt") | endsWith(metadata1, ".csv")) {
  metadata <- read_delim(metadata1, delim = ";", escape_double = FALSE, trim_ws = TRUE)
} else if (endsWith(metadata1, ".xlsx") | endsWith(metadata1, ".xls")) {
  metadata <- read_excel(metadata1)
} else {
  print("File format not recognized. Accepted inputs are .txt, .csv, .xlsx and .xls")
}

## Custom caps regularization for some NCA metadata headings
# if (metadata1 == "Dates_NCA.csv") {
# 	metadata <- metadata %>% rename(datecomposition = dateComposition) %>%
# 	    rename(datemanuscrit = dateManuscrit) %>%
# 	    rename(lieucomposition = lieuComposition) %>%
# 	    rename(lieumanuscrit = lieuManuscrit) %>%
# 	    rename(datemoyennedees = dateMoyenneDees)
# }
##Seems useless, to delete if confirmed.
# Dates_NCA <- Dates_NCA %>% rename(datecomposition = dateComposition) %>%
#     rename(datemanuscrit = dateManuscrit) %>%
#     rename(lieucomposition = lieuComposition) %>%
#     rename(lieumanuscrit = lieuManuscrit) %>%
#     rename(datemoyennedees = dateMoyenneDees)

### Merge to incorporate text metadata in the list of forms
Data_cat1 <- merge (Data_cat1, metadata, by="id")
Data_cat2 <- merge (Data_cat2, metadata, by="id")

## Create merged dataset to check for variable-values inputs
Data_all <- bind_rows(Data_cat1, Data_cat2)

# Transform frequency table to observation table
## Instead of having some observations in the same row (when same page or line
   #ref) with frequency indication, duplicate these rows (by factor F) and
   #remove column F. Needed to get the right frequencies with the code below.
   ## Seems useless in most cases, though it might be usefull in other cases.
# Data_cat1 <- uncount(Data_cat1, weights=F)
# Data_cat2 <- uncount(Data_cat2, weights=F)
