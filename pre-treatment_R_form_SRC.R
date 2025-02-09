#Script to process comparison of orthographic forms
#Finds common lemma in two datasets (extracted from TXM or other sources), one with one orthographic variant and the other without it. Can be adapted for more than two datasets.
#Timothée Premat | 2022-11-18

Filters_file_format <- matrix(c("TXT", ".txt", "CSV", ".csv"),
								2, 2, byrow = TRUE)

# Set default folder for file selection
default_folder <- "Data/1_input_data/*"

## First step is to ask the user to assign a file to the var Data_cat1 and Data_cat2
Data_cat1 <- tk_choose.files(default = file.path(default_folder),
										caption = paste('Choose file for', cat1_name),
										multi = FALSE,
										filter = Filters_file_format)
Data_cat2 <- tk_choose.files(default = file.path(default_folder),
										caption = paste('Choose file for', cat2_name),
										multi = FALSE,
										filter = Filters_file_format)

## Second step is to read that file as a CSV file
Data_cat1 <- read_delim(Data_cat1, delim = ";", escape_double = FALSE, trim_ws = TRUE)
Data_cat2 <- read_delim(Data_cat2, delim = ";", escape_double = FALSE, trim_ws = TRUE)

# Import and treat metadata
# Set default folder for file selection
default_folder <- "Data/*"

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

### Merge to incorporate text metadata in the list of forms
Data_cat1 <- merge (Data_cat1, metadata, by="id")
Data_cat2 <- merge (Data_cat2, metadata, by="id")

# Data_cat1bis <- uncount(Data_cat1, weights=F)
# Data_cat2 <- uncount(Data_cat2, weights=F)
#
# #Transform frequency table to observation table
# ## Instead of having some observations in the same row (when same page or line
#    #ref) with frequency indication, duplicate these rows (by factor F) and
#    #remove column F. Needed to get the right frequencies with the code below.
# Data_cat1 <- uncount(Data_cat1, weights=F)
# Data_cat2 <- uncount(Data_cat2, weights=F)

Data_cat1$Duplicated <- Data_cat1[[lemma_var]] %in% Data_cat2[[lemma_var]]
Data_cat2$Duplicated <- Data_cat2[[lemma_var]] %in% Data_cat1[[lemma_var]]
	#Use [[]] instead of $ to pass env variable

Data_cat1_duplicated <- Data_cat1 %>% filter(Duplicated=='TRUE')
Data_cat1_freq <- count(Data_cat1_duplicated, !!sym(lemma_var), sort=TRUE)
	#Use !!sym() to transform lemma_var into a symbolic input (for env var)

Data_cat2_duplicated <- Data_cat2 %>% filter(Duplicated=='TRUE')
Data_cat2_freq <- count(Data_cat2_duplicated, !!sym(lemma_var), sort=TRUE)

View(Data_cat1_duplicated)
View(Data_cat2_duplicated)

cat1_cat2_freq <- merge(Data_cat1_freq, Data_cat2_freq, by=lemma_var)
cat1_cat2_freq <- cat1_cat2_freq %>%
	rename(!!paste0("n.",cat1_name) := n.x) %>%
	rename(!!paste0("n.",cat2_name) := n.y) %>%
	add_column(validated = NA) %>%
	add_column(comments = NA)
View(cat1_cat2_freq)

#Export
##Non-cleaned data
write_xlsx(Data_cat1,path=paste("Data/2_filtering_in_lemmas/junk/",my_var,"_", cat1_name, "_treated.xlsx", sep=""))
write_xlsx(Data_cat2,path=paste("Data/2_filtering_in_lemmas/junk/",my_var,"_", cat2_name, "_treated.xlsx", sep=""))
write_xlsx(Data_cat1_duplicated,path=paste("Data/2_filtering_in_lemmas/junk/", my_var,"_", cat1_name, "_duplicated.xlsx", sep=""))
write_xlsx(Data_cat2_duplicated,path=paste("Data/2_filtering_in_lemmas/junk/", my_var,"_", cat2_name, "_duplicated.xlsx", sep=""))
write_xlsx(Data_cat1_freq,path=paste("Data/2_filtering_in_lemmas/junk/", my_var,"_", cat1_name, "_freq.xlsx", sep=""))
write_xlsx(Data_cat2_freq,path=paste("Data/2_filtering_in_lemmas/junk/", my_var,"_", cat2_name, "_freq.xlsx", sep=""))
# write_xlsx(cat1_cat2_freq,path=paste("Data/2_filtering_in_lemmas/",my_var,"_merged_freq.xlsx", sep=""))
write.table(cat1_cat2_freq,
			file=paste("Data/2_filtering_in_lemmas/",my_var,"_merged_freq.csv", sep=""),
			quote=FALSE,
			sep=";",
			row.names = FALSE)
