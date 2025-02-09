# Main script for diachronic (temporal series) plots

#---------------------------------------------------------------------
#Data_cat1_cat2_cleaned: global observations
##This is to plot the number of observations of lemmas with <e>/Ø variation
#---------------------------------------------------------------------
#Prepare Data_cat1_cat2_cleaned for plotting qty of words with variation by text
cat1_count <- Data_cat1_cleaned %>%
				count(id)  %>%
				rename(n.cat1 = n)
cat2_count <- Data_cat2_cleaned %>%
				count(id) %>%
				rename(n.cat2 = n)

cat1_cat2_count <- full_join(cat1_count,
							cat2_count,
							by = "id")
	# cat1_cat2_count$std_date <- as.numeric(cat1_cat2_count$std_date)

cat1_cat2_count <- replace(cat1_cat2_count, is.na(cat1_cat2_count), 0)

cat1_cat2_count <- cat1_cat2_count %>%
 mutate(n.tot = n.cat1 + n.cat2) %>%
 mutate(Tx_cat2 = n.cat1 / n.tot)

## Reinject metadata
cat1_cat2_count <- merge (cat1_cat2_count,
                          metadata,
                          by="id")
  cat1_cat2_count$std_date <- as.numeric(cat1_cat2_count$std_date)


# Begin with basic measures
	cat1_cat2_mean <- mean(cat1_cat2_count$Tx_cat2, na.rm=TRUE)
		cat1_cat2_mean <- round(cat1_cat2_mean, digits=2)
	cat1_cat2_median <- median(cat1_cat2_count$Tx_cat2, na.rm=TRUE)
		cat1_cat2_median <- round(cat1_cat2_median, digits=2)
	cat1_cat2_sd <- sd(cat1_cat2_count$Tx_cat2, na.rm=TRUE)
		cat1_cat2_sd <- round(cat1_cat2_sd, digits=2)
	cat1_cat2_sum <- sum(cat1_cat2_count$n.tot, na.rm=TRUE)
		cat1_cat2_sum <- round(cat1_cat2_sum, digits=2)
	min_date <- min(cat1_cat2_count$std_date) # usefull for measures annotation location
	max_date <- max(cat1_cat2_count$std_date) # idem
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
	plot1 <- scatter_plot(cat1_cat2_count, std_date, Tx_cat2) + geom_point()
	plot1

	# Scatter plot with weighted dots (by number of observations)
	plot1_weighted <- scatter_plot(cat1_cat2_count, std_date, Tx_cat2) +
		geom_point(aes(size=n.tot)) +
		scale_size(range = c(1, 5)) +
		theme(	legend.position = c(1, 1),
       			legend.justification = c("right", "top"),
       			legend.box.just = "right",
       			legend.margin = margin(6, 6, 6, 6)) +
		labs(size="Nb obs.")
	plot1_weighted

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

	plot2 <- scatter_plot(cat1_cat2_count, std_date, Tx_cat2) +
		geom_point(aes(size=n.tot, color=get(independent_var))) +
		scale_size(range = c(1, 5)) +
		theme(	legend.position = c(1, 1),
       			legend.justification = c("right", "top"),
       			legend.box.just = "right",
       			legend.margin = margin(6, 6, 6, 6)) +
		labs(size="Nb obs.",color=independent_var)
	plot2
