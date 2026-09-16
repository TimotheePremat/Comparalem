# Master script for mapping with user-provided shapefiles.

#--------------------------------------------------
# Choose variables and shapefiles
#--------------------------------------------------
#shape files directory and variables are inherited from 7a_carto_shapefiles.R
#Passive inheritence: script files are run in order by calling them into 7_carto_master.R
# Choose shapefiles

#--------------------------------------------------
#Split data according to date division
#--------------------------------------------------
#Compute the time extent of the data
dates <- as.data.frame(cat1_cat2_count$std_date)
dates <- dates[dates != "nil"]	#removing "nil" (NCA metadata, but not NA because of na.rm below)
dates <- as.numeric(dates)

date_min <- min(dates, na.rm=T)
date_max <- max(dates, na.rm=T)
time_span_tot <- date_max - date_min

group_var <- var_loc

description <- paste("Your data extends over a period of ", time_span_tot, " years (from ", date_min, " to ", date_max,").", "\nLow boundaries are inclusive, high boundaries are exclusive.", sep="")

split_spans <- get_string_input(title_text = "Time partitioning",
	label_text = "Enter comma separated dates for spliting the dataset.",
	paragraph_text = description)
# print(paste("Your data extends over a period of ", time_span_tot, " years (from ", date_min, " to ", date_max,").", sep=""))
# split_spans <- readline(prompt=paste("Enter comma separated dates for spliting the dataset:", sep=""))
split_spans_vector <- as.numeric(comma_separated_to_vector(split_spans))
print(paste("Selected time spans boundaries are: ", split_spans, ".", sep=""))
print(paste("Remember that all data outside min and max span boundaries will be ignored (type ComparaHelp_time_span for help).", sep=""))

#Create pairs_list for time spans
pairs_list <- lapply(
	seq_along(split_spans_vector)[-length(split_spans_vector)],
	function(i) c(split_spans_vector[i],
	split_spans_vector[i + 1])
)

split_by_time_span <- function(data, time_span) {
  # Subset the data where the standard date column is within the time_span
  subset_data <- data %>% filter(std_date >= time_span[1]) %>%
   						  filter(std_date < time_span[2])
  return(subset_data)
}

#Momentarily keep for debug: to filter only one dataset
# splited_data <- lapply(pairs_list, function(time_span) split_by_time_span(Data_all, time_span))

# #Define list of datasets to be processed
# data_list_carto <- list(Data_cat1_cleaned,
# 					Data_cat2_cleaned,
# 					Data_cat1,
# 					Data_cat2,
# 					cat1_cat2_count)
#
# #Filter all relevant datasets by time spans defined by values in time_span
# 	#Nested lapply() needed because of two levels of application: different
# 	#datasets and different values in time_span.
# splited_data <- lapply(cat1_cat2_count, function(dataset) {
#   lapply(pairs_list, function(time_span) split_by_time_span(dataset, time_span))
# })
# 	#This produces a list of lists. To access an element in a sublist, use
# 	#non recursive [[x]][[y]] where 'x' is the indice of list and 'y' the
# 	#indice of sublist. 		E.g., View(splited_data[[1]][[1]])

#Apply only to cat1_cat2_count
# splited_data <- lapply(pairs_list, function(time_span) split_by_time_span(cat1_cat2_count, time_span))

# Apply split_by_time_span to cat1_cat2_count for each time span in pairs_list
splited_data <- lapply(seq_along(pairs_list), function(i) {
  # Split the dataset by the current time span
  result <- split_by_time_span(cat1_cat2_count, pairs_list[[i]])

  # Extract the start and end values from the current pair in pairs_list
  start_val <- pairs_list[[i]][1]
  end_val <- pairs_list[[i]][2]

  # Generate a unique name for each output
  object_name <- paste0("cat1_cat2_count_", start_val, "-", end_val)

  # Assign the result to a variable with the generated name
  assign(object_name, result, envir = .GlobalEnv)
})
	#Now, we have a subset of cat1_cat2_count for each time span.
	#It is named: cat1_cat2_count_[start]-[end]

# Gather them into a list (to use with lapply later)
	# Step 1: List all objects in the global environment that match the pattern
	data_per_timespan <- ls(pattern = "^cat1_cat2_count_")
	# Step 2: Retrieve these objects and store them in a list
	list_data_per_timespan <- mget(data_per_timespan)

# # If you want to inspect the results, you can check the variables by their names
# print(splited_data)
#
# #Extract and store each sublist
# 	# Iterate over the outer list
# 	for (i in seq_along(splited_data)) {
# 	  # Get the name from data_list_carto, if it exists
# 	  dataset_name <- if (!is.null(names(data_list_carto))) names(data_list_carto)[i] else paste0("dataset_", i)
#
# 	  # Iterate over the inner list
# 	  for (j in seq_along(splited_data[[i]])) {
# 	    # Generate a unique name using the dataset name and time span index
# 	    object_name <- paste0(dataset_name, "_timespan_", j)
#
# 	    # Assign the object to the global environment with the generated name
# 	    assign(object_name, splited_data[[i]][[j]])
# 	  }
# 	}
# 	#This create one object for each sublist, named depending the input data.
# 	#E.g. Data_cat1_cleaned_timespan_1, Data_cat2_cleaned_timespan_1, etc.

#--------------------------------------------------
#Prepare text data
#--------------------------------------------------
# Apply the function to each object in list_data_per_timespan
data_for_carto_list <- lapply(seq_along(list_data_per_timespan), function(i) {
  data_for_carto_func(list_data_per_timespan[[i]], group_var)
})

# Use the content of pairs_list to create descriptive names
names(data_for_carto_list) <- sapply(seq_along(pairs_list), function(i) {
  start_val <- pairs_list[[i]][1]
  end_val <- pairs_list[[i]][2]
  paste0(start_val, "-", end_val)
})

#--------------------------------------------------
#Prepare geo data
#--------------------------------------------------
# Merge datasets
	# Apply merge to each object in data_for_carto_list
	data_carto_list <- lapply(data_for_carto_list, function(data) {
	  # Merge shapefiles with each data set in data_for_carto_list by "R_Code"
	  merged_data <- merge(shapefiles, data, all.x = TRUE, by = "R_Code")
	  return(merged_data)
	})

# Replace NA values by 0 values for regions with no texts
	data_carto_list <- lapply(data_carto_list, function(data) {

	  # Replace NA values in 'nb_txt' with 0
	  data$nb_txt <- replace(data$nb_txt, is.na(data$nb_txt), 0)

	  # Use mutate to create a new column 'nb_txt_disp'
	  data <- data %>%
	    mutate(nb_txt_disp = paste(nb_txt, "txt"))

	  return(data)
	})

#--------------------------------------------------
#Map it!
#--------------------------------------------------
lapply(names(data_carto_list), function(list_name) {
  map_it(data_carto_list[[list_name]], list_name)
})


#
# #Neutralize regions with less than 5 texts by replacing taux_moyen value by NA
# data_carto$mean_rate <- replace(data_carto$mean_rate, data_carto$nb_txt <5, NA)






# Prepare grouping with env-variable
# var_loc2 <- lapply(var_loc, as.symbol)

#
# data_carto <- cat1_cat2_count %>%
# group_by(.dots=var_loc2) %>%
# summarise(mean_rate = mean(Tx_cat2), nb_txt = n()) %>%
# rename_with(~ paste0(var_loc_rename, recycle0=TRUE), var_loc)



#----------------------
# ARCHIVES, NOT RUN
#----------------------


# data_for_carto_func <- function(data) {
# 		group_by({{var_loc}}) %>%
# 		summarise(mean_rate = mean(Tx_cat2), nb_txt = n()) %>%
# 		rename_with(~ paste0(var_loc_rename, recycle0=TRUE), var_loc)
# 	}
#
# # Apply func to data
# Data_for_maps <- lapply(cat1_cat2_count, data_for_carto_func, group_var)

# # Prepare data for #V environment
# data1_V <- POS__V %>%
# 	group_by(R_code_suppl_total) %>%
# 	summarise(taux_moyen = mean(Tx_POS_EnonE), nb_txt = n()) %>%
# 	rename(R_Code = R_code_suppl_total)
# data1_V$taux_moyen <- data1_V$taux_moyen*100
#
# # Prepare data for #C environment
# data1_C <- POS__C %>%
# 	group_by(R_code_suppl_total) %>%
# 	summarise(taux_moyen = mean(Tx_POS_EnonE), nb_txt = n()) %>%
# 	rename(R_Code = R_code_suppl_total)
# data1_C$taux_moyen <- data1_C$taux_moyen*100
#
# #Import spatial data
# data_spatial <- readOGR("Regions-Shapefile")
#
# #Calcuate pseudo-centroids, for printing values on polygons later
# centroids.df <- as.data.frame(coordinates(data_spatial))
# names(centroids.df) <- c("C_long", "C_lat") #rename centroids columns
#
# centroids.df_lower <- centroids.df %>%
# 	mutate(C_lat = C_lat-0.12)
# centroids.df_higher <- centroids.df %>%
# 	mutate(C_lat = C_lat+0.1)
#
# ## Merge datasets
# data3_V <- merge (data_spatial, data1_V, by="R_Code")
# data3_C <- merge (data_spatial, data1_C, by="R_Code")
#
# #Replace NA values by 0 values for regions with no texts
# data3_V$nb_txt <- replace(data3_V$nb_txt, is.na(data3_V$nb_txt), 0)
# data3_C$nb_txt <- replace(data3_C$nb_txt, is.na(data3_C$nb_txt), 0)
#
# #Neutralize regions with less than 5 texts by replacing taux_moyen value by NA
# data3_V$taux_moyen <- replace(data3_V$taux_moyen, data3_V$nb_txt <5, NA)
# data3_C$taux_moyen <- replace(data3_C$taux_moyen, data3_C$nb_txt <5, NA)
#
# #--------------------------------------------------
# #Plot for _V
# #--------------------------------------------------
# #NAME THE VARIABLE YOU WANT TO USE
# my_var_carto_V <- data3_V$taux_moyen
# my_var_carto_V_name <- "Devant #V,\npourcentage de Ø"
# my_var_display_V <- as.numeric(my_var_carto_V)
# my_var_display_V_nb_txt <- as.numeric(data3_V$nb_txt)
#
# #Define the plot
# plot_V <- ggplot() +
# 	#Pass fill=item to annotation_spatial to make it available for layer_spatial below
# 	annotation_spatial(data3_V, aes(fill=taux_moyen)) +
# 	layer_spatial(data3_V, aes(fill=taux_moyen)) +
# 	scale_fill_gradient(low="gray90",
# 			high="black",
# 			na.value="white",
# 			name=paste(my_var_carto_V_name),
# 			limits=c(0,100)) +
# 			#Verbose theme definition
# 			theme(panel.background=element_rect(fill = "transparent", colour = "transparent"),
# 		        panel.grid.major = element_blank(),
# 		        panel.grid.minor = element_blank(),
# 		        legend.justification=c(0,0),
# 		        axis.title.x=element_blank(),
# 		        axis.text.x=element_blank(),
# 		        axis.ticks.x=element_blank(),
# 		        axis.title.y=element_blank(),
# 		        axis.text.y=element_blank(),
# 		        axis.ticks.y=element_blank(),
# 		        legend.position=c(0.02,0.03),
# 		        legend.spacing=unit(1,"lines"),
# 		        legend.box="vertical",
# 		        legend.key.size=unit(1.2,"lines"),
# 		        legend.text.align=0,
# 		        legend.title.align=0,
# 		        legend.text=element_text(size=12, color="black"),
# 		        legend.key = element_rect(fill = "transparent", color="transparent"),
# 		        legend.title=element_text(size=12, color="black", face = "bold"),
# 		        legend.background = element_rect(fill = "transparent", colour = "transparent")) +
#
# #Add textual annotations
# 	annotate("text", x = -4.5, y = 51, label = paste(my_var_carto_V_name),
# 		size=6, color = "black", hjust = 0) +
# 	annotate("text", x = -4.5, y = 50.5, label = paste(my_var2),
# 		size=4.5, color = "black", hjust = 0) +
# 	annotate("text", x = -4.5, y = 50.1, label = "Données : NCA, Dees (1987)\n© Timothée Premat",
# 		size=3.5, color = "black", hjust = 0) +
# 	#Annotations for statistical values
# 		##Labels
# 		annotate("text", x = 2, y = 45.8, label = paste0("min. "),
# 			        size=4, color = "black", hjust = 0) +
# 		annotate("text", x = 2, y = 45.6, label = paste0("moy. "),
# 			        size=4, color = "black", hjust = 0) +
# 		annotate("text", x = 2, y = 45.4, label = paste0("max. "),
# 			        size=4, color = "black", hjust = 0) +
# 		annotate("text", x = 2, y = 45.2, label = paste0("σ"),
# 			        size=4, color = "black", hjust = 0) +
# 		##Values
# 		annotate("text", x = 2.75, y = 45.8, label = paste0(round(min(my_var_display_V, na.rm=TRUE),2), "%"),
# 			        size=4, color = "black", hjust = 0) +
# 		annotate("text", x = 2.75, y = 45.6, label = paste0(round(mean(my_var_display_V, na.rm=TRUE),2), "%"),
# 			        size=4, color = "black", hjust = 0) +
# 		annotate("text", x = 2.75, y = 45.4, label = paste0(round(max(my_var_display_V, na.rm=TRUE),2), "%"),
# 			        size=4, color = "black", hjust = 0) +
# 		annotate("text", x = 2.75, y = 45.2, label = paste0(round(sd(my_var_display_V, na.rm = TRUE),2)),
# 			        size=4, color = "black", hjust = 0)
#
# #Add values and nb of texts on each polygon.
# plot2_V <- plot_V +
# geom_label(aes(label = ifelse(is.na(my_var_display_V_nb_txt), "", paste0(my_var_display_V_nb_txt," txt")),
# 	x = centroids.df_lower$C_long,
# 	y = centroids.df_lower$C_lat),
#  label.size = 0,
#  size=3.5) +
# geom_label(aes(label = ifelse(is.na(my_var_carto_V), "", paste0(round(my_var_carto_V, digits =0)," %")),
# 	x = centroids.df_higher$C_long,
# 	y = centroids.df_higher$C_lat),
#  label.size=0,
#  fontface = "bold")
# plot2_V
#
# #--------------------------------------------------
# #Plot for _C
# #--------------------------------------------------
# #NAME THE VARIABLE YOU WANT TO USE
# my_var_carto_C <- data3_C$taux_moyen
# my_var_carto_C_name <- "Devant #C,\npourcentage de Ø"
# my_var_display_C <- as.numeric(my_var_carto_C)
# my_var_display_C_nb_txt <- as.numeric(data3_C$nb_txt)
#
# #Define the plot
# plot_C <- ggplot() +
# 	#Pass fill=item to annotation_spatial to make it available for layer_spatial below
# 	annotation_spatial(data3_C, aes(fill=taux_moyen)) +
# 	layer_spatial(data3_C, aes(fill=taux_moyen)) +
# 	scale_fill_gradient(low="gray90",
# 			high="black",
# 			na.value="white",
# 			name=paste(my_var_carto_C_name),
# 			limits=c(0,100)) +
# 			#Verbose theme definition
# 			theme(panel.background=element_rect(fill = "transparent", colour = "transparent"),
# 		        panel.grid.major = element_blank(),
# 		        panel.grid.minor = element_blank(),
# 		        legend.justification=c(0,0),
# 		        axis.title.x=element_blank(),
# 		        axis.text.x=element_blank(),
# 		        axis.ticks.x=element_blank(),
# 		        axis.title.y=element_blank(),
# 		        axis.text.y=element_blank(),
# 		        axis.ticks.y=element_blank(),
# 		        legend.position=c(0.02,0.03),
# 		        legend.spacing=unit(1,"lines"),
# 		        legend.box="vertical",
# 		        legend.key.size=unit(1.2,"lines"),
# 		        legend.text.align=0,
# 		        legend.title.align=0,
# 		        legend.text=element_text(size=12, color="black"),
# 		        legend.key = element_rect(fill = "transparent", color="transparent"),
# 		        legend.title=element_text(size=12, color="black", face = "bold"),
# 		        legend.background = element_rect(fill = "transparent", colour = "transparent")) +
#
# #Add textual annotations
# 	annotate("text", x = -4.5, y = 51, label = paste(my_var_carto_C_name),
# 		size=6, color = "black", hjust = 0) +
# 	annotate("text", x = -4.5, y = 50.5, label = paste(my_var2),
# 		size=4.5, color = "black", hjust = 0) +
# 	annotate("text", x = -4.5, y = 50.1, label = "Données : NCA, Dees (1987)\n© Timothée Premat",
# 		size=3.5, color = "black", hjust = 0) +
# 	#Annotations for statistical values
# 		##Labels
# 		annotate("text", x = 2, y = 45.8, label = paste0("min. "),
# 			        size=4, color = "black", hjust = 0) +
# 		annotate("text", x = 2, y = 45.6, label = paste0("moy. "),
# 			        size=4, color = "black", hjust = 0) +
# 		annotate("text", x = 2, y = 45.4, label = paste0("max. "),
# 			        size=4, color = "black", hjust = 0) +
# 		annotate("text", x = 2, y = 45.2, label = paste0("σ"),
# 			        size=4, color = "black", hjust = 0) +
# 		##Values
# 		annotate("text", x = 2.75, y = 45.8, label = paste0(round(min(my_var_display_C, na.rm=TRUE),2), "%"),
# 			        size=4, color = "black", hjust = 0) +
# 		annotate("text", x = 2.75, y = 45.6, label = paste0(round(mean(my_var_display_C, na.rm=TRUE),2), "%"),
# 			        size=4, color = "black", hjust = 0) +
# 		annotate("text", x = 2.75, y = 45.4, label = paste0(round(max(my_var_display_C, na.rm=TRUE),2), "%"),
# 			        size=4, color = "black", hjust = 0) +
# 		annotate("text", x = 2.75, y = 45.2, label = paste0(round(sd(my_var_display_C, na.rm=TRUE),2)),
# 			        size=4, color = "black", hjust = 0)
#
# #Add values and nb of texts on each polygon.
# plot2_C <- plot_C +
# geom_label(aes(label = ifelse(is.na(my_var_display_C_nb_txt), "", paste0(my_var_display_C_nb_txt," txt")),
# 	x = centroids.df_lower$C_long,
# 	y = centroids.df_lower$C_lat),
#  label.size = 0,
#  size=3.5) +
# geom_label(aes(label = ifelse(is.na(my_var_carto_C), "", paste0(round(my_var_carto_C, digits =0)," %")),
# 	x = centroids.df_higher$C_long,
# 	y = centroids.df_higher$C_lat),
#  label.size=0,
#  fontface = "bold")
# plot2_C
#
# ##Arrange the two plots on the same page.
# plot2_CV <- ggarrange(plot2_C,
# 										plot2_V,
# 										labels="auto",
# 										ncol = 1,
# 										nrow = 2,
# 										align = "v")
#
# #--------------------------------------------------
# #WEIGHT: Plot for elision minus apocope (_V - _C) = elision's weight over (or under) apocope's weight.
# #--------------------------------------------------
# #Compute elision's weight
# data1_W <- merge (data1_V, data1_C, by="R_Code")
# data1_W <- data1_W %>%
# 	mutate(elis_W = taux_moyen.x - taux_moyen.y) %>%
# 	mutate(nb_txt_max = pmax(nb_txt.x, nb_txt.y))
#
# data3_W <- merge (data_spatial, data1_W, by="R_Code")
#
# #Replace NA values by 0 values for regions with no texts
# data3_W$nb_txt_max <- replace(data3_W$nb_txt_max, is.na(data3_W$nb_txt_max), 0)
#
# #Neutralize regions with less than 5 texts by replacing taux_moyen value by NA
# data3_W$elis_W <- replace(data3_W$elis_W, data3_W$nb_txt_max<5, NA)
#
# #NAME THE VARIABLE YOU WANT TO USE
# my_var_carto_W <- data3_W$elis_W
# my_var_carto_W_name <- "Taux de prévalence \nde l'élision"
# my_var_display_W <- as.numeric(my_var_carto_W)
# my_var_display_nb_txt <- as.numeric(data3_W$nb_txt_max)
#
# #Define the plot
# plot_W <- ggplot() +
# 	#Pass fill=item to annotation_spatial to make it available for layer_spatial below
# 	annotation_spatial(data3_W, aes(fill=elis_W)) +
# 	layer_spatial(data3_W, aes(fill=elis_W)) +
# 	scale_fill_gradient2(low="orangered4",
# 			high="darkolivegreen4",
# 			mid = "white",
# 			na.value="white",
# 			name=paste(my_var_carto_W_name),
# 			limits=c(-100,100)) +
# 			#Verbose theme definition
# 			theme(panel.background=element_rect(fill = "transparent", colour = "transparent"),
# 		        panel.grid.major = element_blank(),
# 		        panel.grid.minor = element_blank(),
# 		        legend.justification=c(0,0),
# 		        axis.title.x=element_blank(),
# 		        axis.text.x=element_blank(),
# 		        axis.ticks.x=element_blank(),
# 		        axis.title.y=element_blank(),
# 		        axis.text.y=element_blank(),
# 		        axis.ticks.y=element_blank(),
# 		        legend.position=c(0.02,0.03),
# 		        legend.spacing=unit(1,"lines"),
# 		        legend.box="vertical",
# 		        legend.key.size=unit(1.2,"lines"),
# 		        legend.text.align=0,
# 		        legend.title.align=0,
# 		        legend.text=element_text(size=12, color="black"),
# 		        legend.key = element_rect(fill = "transparent", color="transparent"),
# 		        legend.title=element_text(size=12, color="black", face = "bold"),
# 		        legend.background = element_rect(fill = "transparent", colour = "transparent")) +
#
# #Add textual annotations
# 	annotate("text", x = -4.5, y = 51, label = paste(my_var_carto_W_name),
# 		size=6, color = "black", hjust = 0) +
# 	annotate("text", x = -4.5, y = 50.5, label = paste(my_var2),
# 		size=4.5, color = "black", hjust = 0) +
# 	annotate("text", x = -4.5, y = 50.1, label = "Données : NCA, Dees (1987)\n© Timothée Premat",
# 		size=3.5, color = "black", hjust = 0) +
# 	#Annotations for statistical values
# 		##Labels
# 		annotate("text", x = 2, y = 45.8, label = paste0("min. "),
# 			        size=4, color = "black", hjust = 0) +
# 		annotate("text", x = 2, y = 45.6, label = paste0("moy. "),
# 			        size=4, color = "black", hjust = 0) +
# 		annotate("text", x = 2, y = 45.4, label = paste0("max. "),
# 			        size=4, color = "black", hjust = 0) +
# 		annotate("text", x = 2, y = 45.2, label = paste0("σ"),
# 			        size=4, color = "black", hjust = 0) +
# 		##Values
# 		annotate("text", x = 2.75, y = 45.8, label = paste0(round(min(my_var_display_W, na.rm=TRUE),2), "%"),
# 			        size=4, color = "black", hjust = 0) +
# 		annotate("text", x = 2.75, y = 45.6, label = paste0(round(mean(my_var_display_W, na.rm=TRUE),2), "%"),
# 			        size=4, color = "black", hjust = 0) +
# 		annotate("text", x = 2.75, y = 45.4, label = paste0(round(max(my_var_display_W, na.rm=TRUE),2), "%"),
# 			        size=4, color = "black", hjust = 0) +
# 		annotate("text", x = 2.75, y = 45.2, label = paste0(round(sd(my_var_display_W, na.rm=TRUE),2)),
# 			        size=4, color = "black", hjust = 0)
#
# plot2_W <- plot_W +
# geom_label(aes(label = ifelse(is.na(my_var_display_nb_txt), "", paste0(my_var_display_nb_txt," txt")),
# 	x = centroids.df_lower$C_long,
# 	y = centroids.df_lower$C_lat),
#  label.size = 0,
#  size=3.5) +
# geom_label(aes(label = ifelse(is.na(my_var_carto_W), "", paste0(round(my_var_carto_W, digits =0)," %")),
# 	x = centroids.df_higher$C_long,
# 	y = centroids.df_higher$C_lat),
#  label.size=0,
#  fontface = "bold")
# plot2_W
