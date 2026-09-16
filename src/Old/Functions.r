#File for functions used in Comparalem

#------------------------------------------------------------
#Functions for checking inputs
#------------------------------------------------------------
check_column_exists <- function(data, var) {
  while (!(var %in% colnames(data))) {
    message <- cat(paste(paste("Column '", var, "' is not present in the dataset.", sep=""),"Look at your data again and enter the name of an existing column.", sep="\n"))
    print(message)
    # Prompt the user again for the correct column name
    var <- readline(prompt="Indicate which variable to use to filter the data:")
  }
  return(var)
}

check_value_exists <- function(data, column_name, values_vector) {
	# Use sapply to check if each value in the vector is present in the column
	matches <- sapply(values_vector, function(value) {
    		any(grepl(value, data[[column_name]], fixed = TRUE))  # fixed = TRUE disable regex matching
  		})
	# Check if all values are present
	if (all(matches)) {
    	print("All values are present in the dataset.")
	} else {
    	# Identify values that are not present
    	missing_values <- values_vector[!matches]
    	message <- paste("Value '", missing_values, "' is not present in column '", column_name, "' (type ComparaHelp_filtering for details).", sep = "")
    	print(message)

		# Prompt the user again for the correct column name
		re_enter_values <- readline(prompt="Do you want to reset values to correct them? [Y/n]")
		if (re_enter_values == "yes" || re_enter_values == "y" || re_enter_values == "Yes" || re_enter_values == "Y" ) {
			source("4_filter_custom.R")
			#As transformations have to be applied to value before call to
			#function, re-call the whole script
		}
  	}
}

check_value_exists_regex <- function(data, column_name, values_vector) {
	# Use sapply to check if each value in the vector is present in the column
	matches <- sapply(values_vector, function(value) {
    		any(grepl(value, data[[column_name]], fixed = FALSE))  # fixed = FALSE allows for regex matching
  		})
	# Check if all values are present
	if (all(matches)) {
    	print("All values are present in the dataset.")
	} else {
    	# Identify values that are not present
    	missing_values <- values_vector[!matches]
    	message <- paste("Value '", missing_values, "' is not present in column '", column_name, "' (type ComparaHelp_filtering for details).", sep = "")
    	print(message)

		# Prompt the user again for the correct column name
		re_enter_values <- readline(prompt="Do you want to reset values to correct them? [Y/n]")
		if (re_enter_values == "yes" || re_enter_values == "y" || re_enter_values == "Yes" || re_enter_values == "Y" ) {
			source("4_filter_custom.R")
			#As transformations have to be applied to value before call to
			#function, re-call the whole script
		}
  	}
}

	#----
	#Note
	#----
	#For now, I do not merge check_value_exists and check_value_exists_regex.
	#They could be merged with an if vector_regex == "no" or "yes" triggering
	#fixed = "TRUE" or fixed = "TRUE", but I am unsure vector_regex will be
	#used below and it should be reset before other calls of the FUN.
	#This is to be evaluated later. Merging would be more efficient.
	#----


#------------------------------------------------------------
#Functions for filtering data
#------------------------------------------------------------
filter_by_var_value <- function(data, column_name, value) {
	data <- data %>% filter(.data[[column_name]] %in% value)
	return(data)
}

filter_by_var_value_neg <- function(data, column_name, value) {
	data <- data %>% filter(!.data[[column_name]] %in% value)
	return(data)
}

filter_by_var_value_regex <- function(data, column_name, value) {
		if (length(value) > 1) { #If vector has multiple values, turn it in OR regex statement
			value <- paste(value, collapse = "|")
		}
	data <- data %>% filter(str_detect(.data[[column_name]], value))
	return(data)
}

filter_by_var_value_regex_neg <- function(data, column_name, value) {
		if (length(value) > 1) { #If vector has multiple values, turn it in OR regex statement
			value <- paste(value, collapse = "|")
		}
	data <- data %>% filter(str_detect(.data[[column_name]], value, negate = TRUE))
	return(data)
}

remove_exclamation <- function(input_text) {
  return(gsub("!", "", input_text))
}

#------------------------------------------------------------
#Functions for conversion
#------------------------------------------------------------
# Convert a comma-separated string to a vector
comma_separated_to_vector <- function(comma_separated_string) {
  # Split the string at each comma and trim whitespace
  result_vector <- unlist(strsplit(comma_separated_string, ",\\s*"))
  return(result_vector)  # Return the resulting vector
}

#------------------------------------------------------------
#Functions for time-series plots (diachro_plots)
#------------------------------------------------------------
	scatter_plot_split <- function(data, x, y) {
  		ggplot(data, aes({{x}}, {{y}})) +
			geom_smooth(method = "loess",
						se = FALSE,
						na.rm = TRUE,
						colour = "black",
						span = 0.75) +
	 		geom_smooth(method = "lm",
						se = FALSE,
						na.rm = TRUE,
						colour = "black",
						span = 0.75,
						linetype = "dashed") +
			theme_classic() +
		    scale_x_continuous(name="Date")+
		    scale_y_continuous(limits = c(0,1),
		                       name=paste(dependent_var, "(par texte)")) +
			labs(title = paste(title_element))
	}

#------------------------------------------------------------
#Functions for cartography
#------------------------------------------------------------
#Prepare data for catography (rate by text -> rate by region)
data_for_carto_func <- function(data, group) {
	data %>%
	group_by(.data[[group]]) %>%
	summarise(
		mean_rate = mean(Tx_cat2),
		median_rate = median(Tx_cat2),
		min_rate = min(Tx_cat2),
		max_rate = max(Tx_cat2),
		sd_rate = sd(Tx_cat2),
		mean_rate_disp = paste0(round(mean(Tx_cat2*100), digits = 0), "%"),
		nb_txt = n(),
		nb_tokens = sum(n.tot)) %>%
	rename(R_Code = R_code_suppl_total)
}

#Map it! (for time_span subsets)
##Create breaks vector
	n_intervals <- 20	#change to change the number of intervals
	interval_width <- 1 / n_intervals
	custom_breaks <- seq(0, 1, by = interval_width)
##Map it!
map_it <- function(data_carto, list_name) {
	mf_export(							#Export is done right away (not in 8_save_outputs.R)
		data_carto,
		filename = paste("../Graphs/", file_name, "_map_", list_name,"_", Sys.Date(), ".png", sep=""),
		width = 9,
		height = 7,
		units = "in",
		res = 600
	)
	mf_map(
		x = data_carto,
		var = "mean_rate",
		type = "choro",
		leg_pos = NA, #Hide legend (values are printed in the map, legend is useless)
		leg_title = paste(dependent_var),
		col_na = "light gray",
		pal = "Teal",
		leg_no_data = "N/A",
		breaks = custom_breaks,
		add = TRUE
	)
mf_legend(	#Create 'fake' legend (true legend with too many categories is hidden)
  type = "choro",
  val = c(0, 0.25, 0.5, 0.75, 1),
  pal = "Teal",
  pos = "topleft",
  val_rnd = 2,
  title = paste(dependent_var)
)
	mf_theme(bg = "white")
	mf_layout(
		title = paste(title_element, list_name, sep=" — "),
		credits = paste0("Corpus: ", corpus_var, "\nMade with Comparalem,\n", "using mapsf ", packageVersion("mapsf")),
		arrow = FALSE,
		scale = FALSE
	)
	mf_label(
		x = data_carto,
		var = "nb_txt_disp",
		col = "black",
		cex = 0.6,
		font = 4,
		halo = TRUE,
		bg = "white",
		r = 0.1,
		overlap = FALSE,
		lines = FALSE,
		adj = c(0.5,2)
	)
	mf_label(
		x = data_carto,
		var = "mean_rate_disp",
		col = "white",
		cex = 0.8,
		font = 4,
		halo = TRUE,
		bg = "black",
		r = 0.1,
		overlap = FALSE,
		lines = FALSE,
		adj = c(0.5,0)
	)
	dev.off()						#Needed for mf_export
}
