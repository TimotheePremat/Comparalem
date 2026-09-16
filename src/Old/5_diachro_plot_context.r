# Main script for diachronic (temporal series) plots

# PAtch to match Shiny app
## Define a matrix of acceptable formats for tk_choose.files
Filters_file_format <- matrix(c("XLSX", ".xlsx", "TXT", ".txt", "CSV", ".csv"),
								3, 2, byrow = TRUE)

# Set default folder for file selection
default_folder <- "../Data/1_input_data/*"

## First step is to ask the user to assign a file to the var Data_cat1 and Data_cat2
concordancer_var <- tk_choose.files(default = file.path(default_folder),
										caption = paste('Choose file for filtered data'),
										multi = FALSE,
										filter = Filters_file_format)

concordancer <- read_excel(concordancer_var)

## Temp var
lemma <- "rnnlemma"
std_date <- "datecomposition"

concordancer <- concordancer %>%
  mutate(
    !!std_date := suppressWarnings(as.numeric(.data[[std_date]]))
  )

cat1_cat2_count <- concordancer %>%
  group_by(id) %>%
  summarise(n.cat1 = sum(source == "df1"), n.cat2 = sum(source == "df2")) %>%
  mutate(n.tot = n.cat1 + n.cat2) %>%
  mutate(Tx_cat2 = n.cat1 / n.tot)

# Identify invariante id-value association to reinject metadata
invariant_cols <- concordancer %>%
  group_by(id) %>%
  summarise(across(everything(), ~ n_distinct(.x)), .groups = "drop") %>%
  summarise(across(everything(), ~ all(.x == 1))) %>%
  dplyr::select(where(identity)) %>%
  names()

#Extract one value for each invariant column
id_metadata <- concordancer %>%
  dplyr::select(dplyr::all_of(c("id", invariant_cols))) %>%
  distinct(id, .keep_all = TRUE)

cat1_cat2_count <- cat1_cat2_count %>%
  left_join(id_metadata, by = "id")

  print(cat1_cat2_count)


#---------------------------------------------------------------------
#Data_cat1_cat2_cleaned: global observations
##This is to plot the number of observations of lemmas with <e>/Ø variation
#---------------------------------------------------------------------
#Prepare Data_cat1_cat2_cleaned for plotting qty of words with variation by text
# cat1_count <- Data_cat1_cleaned %>%
# 				count(id)  %>%
# 				rename(n.cat1 = n)
# cat2_count <- Data_cat2_cleaned %>%
# 				count(id) %>%
# 				rename(n.cat2 = n)

# cat1_cat2_count <- full_join(cat1_count,
# 							cat2_count,
# 							by = "id")
# 	# cat1_cat2_count$std_date <- as.numeric(cat1_cat2_count$std_date)

# cat1_cat2_count <- replace(cat1_cat2_count, is.na(cat1_cat2_count), 0)

# cat1_cat2_count <- cat1_cat2_count %>%
#  mutate(n.tot = n.cat1 + n.cat2) %>%
#  mutate(Tx_cat2 = n.cat1 / n.tot)

# ## Reinject metadata
# cat1_cat2_count <- merge (cat1_cat2_count,
#                           metadata,
#                           by="id")
#   cat1_cat2_count$std_date <- as.numeric(cat1_cat2_count$std_date)


# Begin with basic measures
	cat1_cat2_mean <- mean(cat1_cat2_count$Tx_cat2, na.rm=TRUE)
		cat1_cat2_mean <- round(cat1_cat2_mean, digits=2)
	cat1_cat2_median <- median(cat1_cat2_count$Tx_cat2, na.rm=TRUE)
		cat1_cat2_median <- round(cat1_cat2_median, digits=2)
	cat1_cat2_sd <- sd(cat1_cat2_count$Tx_cat2, na.rm=TRUE)
		cat1_cat2_sd <- round(cat1_cat2_sd, digits=2)
	cat1_cat2_sum <- sum(cat1_cat2_count$n.tot, na.rm=TRUE)
		cat1_cat2_sum <- round(cat1_cat2_sum, digits=2)
	min_date <- min(concordancer[[std_date]]) # usefull for measures annotation location
	max_date <- max(concordancer[[std_date]]) # idem
	max_date1 <- max_date + (0.17*(max_date-min_date))
	max_date2 <- max_date + (0.2*(max_date-min_date))
	max_date3 <- max_date + (0.4*(max_date-min_date))

# Create functions for the plots

	# Basic scatter plot (time series, rate of cat2 by text)
	scatter_plot <- function(data, x, y) {
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
					label=paste("",cat1_cat2_mean,"\n",
					cat1_cat2_median,"\n",
					cat1_cat2_sd,"\n",
					cat1_cat2_sum),
					hjust=0,
					vjust=0) +
			annotate("text",
					x=max_date1,
					y=0,
					label="moy.\n méd.\n sd \n Nb. obs.",
					hjust=1,
					vjust=0) +
			labs(title = paste(title_element))
	}

# Instanciate scatter plots
	# Basic scatter plot
	plot1 <- scatter_plot(cat1_cat2_count, cat1_cat2_count[[std_date]], Tx_cat2) + geom_point()
	plot1

	# Scatter plot with weighted dots (by number of observations)
	plot1_weighted <- scatter_plot(cat1_cat2_count, cat1_cat2_count[[std_date]], Tx_cat2) +
		geom_point(aes(size=n.tot)) +
		scale_size(range = c(1, 5)) +
		theme(	legend.position = c(1, 1),
       			legend.justification = c("right", "top"),
       			legend.box.just = "right",
       			legend.margin = margin(6, 6, 6, 6)) +
		labs(size="Nb obs.")
	plot1_weighted

	# Add another variable
		#Prepare available variable names
		col_names <- paste(colnames(cat1_cat2_count), collapse = "\n")
		#Prepare description for tcltk window
		description <- paste("Available variable names are:     (scroll down if needed)",
  			col_names,
  			sep = "\n"
		)
		independent_var <- get_string_input(label_text = "Is there an independent variable you want to add to the graph? Anwser with the name of the variable or leave empty to pass:", paragraph_text = description)

	# Check that variable name is correct
	if (!(independent_var == "")) {
		while (!(independent_var %in% colnames(concordancer))) {
		  print(paste("Column", independent_var, "is not present in the dataset. Look at your data again and enter the name of the column for the independent variable:"))
		  # Prompt the user again for the correct column name
		  independent_var <- readline(prompt="Indicate which variable to add:")
		}
	}

	plot2 <- scatter_plot(cat1_cat2_count, cat1_cat2_count[[std_date]], Tx_cat2) +
		geom_point(aes(size=n.tot, color=get(independent_var))) +
		scale_size(range = c(1, 5)) +
		theme(	legend.position = c(1, 1),
       			legend.justification = c("right", "top"),
       			legend.box.just = "right",
       			legend.margin = margin(6, 6, 6, 6)) +
		labs(size="Nb obs.",color=independent_var)
	plot2
