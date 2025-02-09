# Main script for diachronic (temporal series) plots

# Merge Data_cat1_filtered
combined_data <- bind_rows(
	Data_cat1_cleaned %>% mutate(type_full = tolower(paste(cat2_1))) %>%
		mutate(type = 1),
	Data_cat2_cleaned %>% mutate(type_full = tolower(paste(cat2_2))) %>%
		mutate(type = 0)
)

#Plot for count by category
grouped <- combined_data %>% group_by(category)
summarise(grouped, mean = mean(type), sd = sd(type))

p_by_cat <- ggplot(combined_data, aes(x = category, fill = type_full)) +
  	geom_bar(color = "white", stat = "count", position=position_dodge()) +  # Bar chart with count
  	geom_text(stat = "count", aes(label = after_stat(count)), # Add count labels
            position = position_dodge(0.9),
			vjust = 1.6,                      # Adjust label position (above the bars)
            size = 3,
			color = "white") +                           # Font size
  	theme_classic() +                              # Use classic theme
	labs(fill = "Type") +
  	scale_fill_brewer(palette="Paired")

#Set variables for subsetting
print("Subsetting is done by two categories:")
print("1) an independent variable (typically 'category')")
print("2) the dependent variable (type, or type_full following Instructions.md)")

var_cat <- readline(prompt="Enter category variable:")
var_type <- readline(prompt="Enter type variable:")
var_cat <- as.symbol(var_cat)
var_type <- as.symbol(var_type)

#Split data into subsets
splited_data <- split(combined_data, f = list(combined_data[[var_cat]], combined_data[[var_type]]))

	#Store each list (subset) as an object
	for (name in names(splited_data)) {
	  assign(name, splited_data[[name]], envir = .GlobalEnv)
	}
	# creates PRE.[type], VERcjg.[type] etc.

#Perform basic computations

process_data_test <- function(data_cat1, data_cat2, metadata) {
	data_cat1 <- as.data.frame(data_cat1)
	data_cat2 <- as.data.frame(data_cat2)

	data_cat1 <- data_cat1 %>% dplyr::count(id) %>%
								dplyr::rename(n.cat1 = n)
	data_cat2 <- data_cat2 %>% dplyr::count(id) %>%
								dplyr::rename(n.cat2 = n)

	data_for_count <- full_join(data_cat1,
							data_cat2,
							by = "id")
	data_for_count <- replace(data_for_count, is.na(data_for_count), 0)

	data_for_count <- data_for_count %>%
	 	mutate(n.tot = n.cat1 + n.cat2) %>%
	 	mutate(Tx_cat2 = n.cat2 / n.tot)

	data_for_count <- merge (data_for_count,
	                  		metadata,
							by="id")

	return(data_for_count)
}

# To apply process_data to each pair of type per category, we need to identify
# datasets as matching pairs.
	# Get list of all objects in the global environment
	object_names <- ls()

	# Filter object names to only those in splited_data
	filtered_object_names <- intersect(object_names, names(splited_data))

	# Create pairs
	paired_names <- matrix(filtered_object_names, ncol = 2, byrow = TRUE)
		#Using order for pairing is enough, no need to look for prefixes.

# Apply process_data function
processed_data <- mapply(function(x, y) process_data_test(get(x), get(y), metadata),
	paired_names[,2], paired_names[,1], SIMPLIFY = FALSE)
		# Use get() to make sure mapply can access non-vectorised inputs.

# Plot it!
	# processed_data_no_sublist <- unlist(processed_data, recursive = FALSE)
		# recursive = FALSE: only remove one level of list embedding
		# Apparently not needed? Check, and delete it.

	for (name in names(processed_data)) {
	  as.data.frame(assign(name, processed_data[[name]], envir = .GlobalEnv))
	}

	# Non-weigthed plots
	plot_list1 <- lapply(seq_along(processed_data), function(i) {
		# Get the data and its corresponding name
		data <- processed_data[[i]]
		name <- names(processed_data)[i]

		# Generate the base plot using the scatter_plot function
		base_plot <- scatter_plot_split(data, std_date, Tx_cat2)

		# Add additional ggplot layers and set subtitle with the data name
		final_plot <- base_plot +
		geom_point() +
		labs(subtitle = paste(name)) +
		annotate("rect",
				xmin = max_date,
				xmax = max_date3,
				ymin = 0,
				ymax = 0.25,
				alpha = .75,
				fill="white") +
		annotate("text",
				x=max_date2,
				y=0,
				label=paste("",paste(round(mean(data$Tx_cat2, na.rm=TRUE), digits=2)),"\n",
				"",paste(round(median(data$Tx_cat2, na.rm=TRUE), digits=2)),"\n",
				"",paste(round(sd(data$Tx_cat2, na.rm=TRUE), digits=2)),"\n",
				"",paste(round(sum(data$n.tot, na.rm=TRUE), digits=2))),
				hjust=0,
				vjust=0) +
		annotate("text",
				x=max_date1,
				y=0,
				label="moy.\n méd.\n sd \n Nb. obs.",
				hjust=1,
				vjust=0)

		# Store the plot in the global environment with a dynamic name
  		assign(paste0("plot1_", name), final_plot, envir = .GlobalEnv)
			#Creates objects such as plot_CONcoo.jo

  		return(final_plot)
	})

	# Weigthed plots
	plot_list1_weigthed <- lapply(seq_along(processed_data), function(i) {
		# Get the data and its corresponding name
		data <- processed_data[[i]]
		name <- names(processed_data)[i]

		# Generate the base plot using the scatter_plot function
		base_plot <- scatter_plot_split(data, std_date, Tx_cat2)

		# Add additional ggplot layers and set subtitle with the data name
		final_plot <- base_plot +
		geom_point(aes(size = n.tot)) +
		labs(subtitle = paste(name)) +
		annotate("rect",
				xmin = max_date,
				xmax = max_date3,
				ymin = 0,
				ymax = 0.25,
				alpha = .75,
				fill="white") +
		annotate("text",
				x=max_date2,
				y=0,
				label=paste("",paste(round(mean(data$Tx_cat2, na.rm=TRUE), digits=2)),"\n",
				"",paste(round(median(data$Tx_cat2, na.rm=TRUE), digits=2)),"\n",
				"",paste(round(sd(data$Tx_cat2, na.rm=TRUE), digits=2)),"\n",
				"",paste(round(sum(data$n.tot, na.rm=TRUE), digits=2))),
				hjust=0,
				vjust=0) +
		annotate("text",
				x=max_date1,
				y=0,
				label="moy.\n méd.\n sd \n Nb. obs.",
				hjust=1,
				vjust=0)

		# Store the plot in the global environment with a dynamic name
  		assign(paste0("plot1_weigthed_", name), final_plot, envir = .GlobalEnv)
			#Creates objects such as plot_CONcoo.jo

  		return(final_plot)
	})


	# Add another variable
	independent_var <- readline(prompt="Is there one independent variable you want to add to the graph? Anwser with the name of the variable (or pass):")

	# Check that variable name is correct
	if (!(independent_var == "")) {
		while (!(independent_var %in% colnames(Data_cat1_cleaned))) {
		  print(paste("Column", independent_var, "is not present in the dataset. Look at your data again and enter the name of the column for the independent variable:"))
		  # Prompt the user again for the correct column name
		  independent_var <- readline(prompt="Indicate which variable to add:")
		}
	}

	# Weigthed plots
	plot_list2 <- lapply(seq_along(processed_data), function(i) {
		# Get the data and its corresponding name
		data <- processed_data[[i]]
		name <- names(processed_data)[i]

		# Generate the base plot using the scatter_plot function
		base_plot <- scatter_plot_split(data, std_date, Tx_cat2)

		# Add additional ggplot layers and set subtitle with the data name
		final_plot <- base_plot +
		geom_point(aes(size = n.tot, color=get(independent_var))) +
		labs(subtitle = paste(name),
			color = independent_var) +
		annotate("rect",
				xmin = max_date,
				xmax = max_date3,
				ymin = 0,
				ymax = 0.25,
				alpha = .75,
				fill="white") +
		annotate("text",
				x=max_date2,
				y=0,
				label=paste("",paste(round(mean(data$Tx_cat2, na.rm=TRUE), digits=2)),"\n",
				"",paste(round(median(data$Tx_cat2, na.rm=TRUE), digits=2)),"\n",
				"",paste(round(sd(data$Tx_cat2, na.rm=TRUE), digits=2)),"\n",
				"",paste(round(sum(data$n.tot, na.rm=TRUE), digits=2))),
				hjust=0,
				vjust=0) +
		annotate("text",
				x=max_date1,
				y=0,
				label="moy.\n méd.\n sd \n Nb. obs.",
				hjust=1,
				vjust=0)

		# Store the plot in the global environment with a dynamic name
  		assign(paste0("plot2_", name), final_plot, envir = .GlobalEnv)
			#Creates objects such as plot_CONcoo.jo

  		return(final_plot)
	})
