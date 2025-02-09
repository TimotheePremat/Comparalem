# Load necessary packages
if (!requireNamespace("tidyverse", quietly = TRUE)) {
  install.packages("tidyverse")
}
library(tidyverse)

# Define a function to read each file and add a source column
read_and_label <- function(file_path) {
  # Read the text file into a dataframe using ";" as the delimiter
  data <- read_delim(file_path, delim = ";", trim_ws = TRUE)

  # Add a source column with the file name
  data <- data %>% mutate(category = basename(file_path))

  return(data)
}

# Prompt the user to enter the input directory containing the text files
input_dir <- readline(prompt = "Enter the full path of the directory containing the text files: ")

# Check if the directory exists
if (!dir.exists(input_dir)) {
  stop("The specified directory does not exist.")
}

# Prompt the user to enter the output file name
output_file_name <- readline(prompt = "Enter the name for the output file (e.g., merged_output.txt): ")

# Prompt the user to enter the output directory for the merged file
output_dir <- readline(prompt = "Enter the full path of the output directory: ")

# Check if the output directory exists
if (!dir.exists(output_dir)) {
  stop("The specified output directory does not exist.")
}

# Get a list of text files in the specified input directory
txt_files <- list.files(path = input_dir, pattern = "\\.txt$", full.names = TRUE)

# Check if there are any text files to merge
if (length(txt_files) == 0) {
  stop("No text files found in the specified directory.")
}

# Read, label, and merge all files
merged_data <- txt_files %>%
  map_dfr(read_and_label)

# Rewrite source information to keep only the relevant part
	# Ask the user for the substrings they want to delete
	delete_text <- readline(prompt = "Enter the name of the category (for category col name cleaning): ")
	merged_data$category <- gsub(paste(delete_text, "_", sep=""), "", merged_data$category)
	merged_data$category <- gsub("_cleaned\\.txt", "", merged_data$category)

# Print the merged data
print(merged_data)

# Define the full path for the output file in the specified output folder
output_path <- file.path(output_dir, output_file_name)

# Write the merged data to the specified output folder with the custom output name
write_delim(merged_data, output_path, delim = ";")

# Notify the user about the location of the output file
cat("Merged data has been written to:", output_path, "\n")
