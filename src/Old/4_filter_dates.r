# Define standard date and proposes to filter out outliers by date (by hand)

# Define what it the date variable (col) to be used as standard date.
# standard_date <- get_string_input(label_text = "Indicate which variable (col) is the date variable in the data:")


	#Prepare available variable names
	col_names <- paste(colnames(Data_cat1_cleaned), collapse = "\n")
	#Prepare description for tcltk window
	description <- paste("Available variable names are:     (scroll down if needed)",
  		col_names,
  		sep = "\n"
	)
	standard_date <- get_string_input(label_text = "Indicate which variable (col) is the date variable in the data.", paragraph_text = description)
# Iterate until the column name entered exists in the dataset
while (!(standard_date %in% colnames(Data_cat1_cleaned))) {
  print(paste("Column", standard_date, "is not present in the dataset. Look at your data again and enter the name of the column for standard date."))
  # Prompt the user again for the correct column name
  standard_date <- readline(prompt="Indicate which variable is the date variable in the data:")
}

# Create new column for standard date
Data_cat1_cleaned$std_date <- Data_cat1_cleaned[[standard_date]]
Data_cat2_cleaned$std_date <- Data_cat2_cleaned[[standard_date]]
Data_cat1$std_date <- Data_cat1[[standard_date]]
Data_cat2$std_date <- Data_cat2[[standard_date]]
Data_all$std_date <- as.numeric(Data_all[[standard_date]])
metadata$std_date <- metadata[[standard_date]]

# Print confirmation message for standard date definition
print(paste(standard_date, "is defined as the standard date."))

# Filter by date to exclude outliers
filter_date <- get_bol_input(
  title = "Date Filtering Option",
  label_text = "Do you want to filter texts by date?"
)

description <- paste(
  "Boundaries can be outside of actual data.\nBoundaries are inclusive (e.g., lower boundary set at 1100 includes 1100 but not 1099).\nFor NCA corpus, consider using 1100 - 1325 to avoid late, insolated texts (date of composing).",
  sep = "\n"
)

if (filter_date == "yes" || filter_date == "y") {
	result <- input_two_numbers(title = "Input Parameters",
                            label1 = "Enter lower boundary:",
                            label2 = "Enter higher boundary:",
							paragraph_text = description)
	filter_date_min <- result$var1
	filter_date_max <- result$var2
	cat("Selected range:", filter_date_min, "-", filter_date_max, "\n")
	# filter_date_min <- readline(prompt="Enter lower date to keep (can be outside corpus boundaries):")
	# filter_date_max <- readline(prompt="Enter higher date to keep (for NCA, consider 1325; can be outside corpus boundaries):")
}

	# Define the set of datasets to be filtered
	data_list <- list(Data_cat1_cleaned, Data_cat2_cleaned, Data_cat1, Data_cat2, metadata)

	# Create function for filtering
	filtering_date <- function(data) {
			data <- data %>%
			 	filter(std_date <= filter_date_max) %>%
				filter(std_date >= filter_date_min)
			return(data)
		}


	# Apply the function to each dataset in the list
	if (filter_date == "yes" | filter_date == "Yes" | filter_date == "y" | filter_date == "Y") {
		data_list <- lapply(data_list, filtering_date)
	}

	# Implement into the original datasets
	Data_cat1_cleaned <- data_list[[1]]
	Data_cat2_cleaned <- data_list[[2]]
	Data_cat1 <- data_list[[3]]
	Data_cat2 <- data_list[[4]]
	metadata <- data_list[[5]]


# Make sure standard date is in numeric format
	# Function to check and convert std_date
	convert_std_date <- function(data) { 								# "data" is the placeholder for lapply input
  		if (!is.numeric(data$std_date)) {								# if col std_date is not numeric
    		data$std_date <- as.numeric(as.character(data$std_date)) 	# then, transform it into numbers
  		}
		return(data)													# Output statement
	}

	# Apply the function to each dataset in the list
	data_list <- lapply(data_list, convert_std_date)

	# Implement into the original datasets
	Data_cat1_cleaned <- data_list[[1]]
	Data_cat2_cleaned <- data_list[[2]]
	Data_cat1 <- data_list[[3]]
	Data_cat2 <- data_list[[4]]
	metadata <- data_list[[5]]
