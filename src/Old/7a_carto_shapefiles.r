# Master script for mapping with user-provided shapefiles.

#--------------------------------------------------
# Choose variables and shapefiles
#--------------------------------------------------
# Choose shapefiles
default_folder <- "../"
shapefiles_dir <- tk_choose.dir(default = file.path(default_folder),
							caption = paste('Open directory containing shapefiles'))
shapefiles <- st_read(shapefiles_dir)

#Indicate variables
# var_loc <- readline(prompt="Which variable (col) in the data contains geo data for plotting (for NCA, try R_code_suppl_total)?")
# var_loc_rename <- readline(prompt="Which variable in the shapefiles corresponds contains geo data for plotting (for NCA: R_Code):")
# var_loc_label <- readline(prompt="Which variable (col) contains geo labels (for NCA, try regionDees_supp):")

#Pass variables
col_names <- paste(colnames(cat1_cat2_count), collapse = "\n")
#Prepare description for tcltk window
description <- paste("For NCA corpus, try:
  (1) R_code_suppl_total
  (2) R_Code
  (3) regionDees_supp\n
Available variable names are:     (scroll down if needed)",
	col_names,
	sep = "\n"
)
var_loc <- get_string_input(title_text = "Carto: geo data selection (1)",
	label_text = "Which variable (col) in the data contains geo data for plotting?",
	paragraph_text = description)
var_loc_rename <- get_string_input(title_text = "Carto: geo data selection (2)",
	label_text = "Which variable in the shapefiles corresponds contains geo data for plotting?",
	paragraph_text = description)
var_loc_label <- get_string_input(title_text = "Carto: geo data selection (3)",
	label_text = "Which variable (col) contains geo labels (for NCA, try regionDees_supp)?",
	paragraph_text = description)
#--------------------------------------------------
#Prepare text data
#--------------------------------------------------
# Function to prepare data
group_var <- var_loc

# Apply func to data
data_for_carto <- data_for_carto_func(cat1_cat2_count, group_var)

#--------------------------------------------------
#Prepare geo data
#--------------------------------------------------
## Merge datasets
data_carto <- merge(shapefiles, data_for_carto, all.x = TRUE, by="R_Code")

# Replace NA values by 0 values for regions with no texts
data_carto$nb_txt <- replace(data_carto$nb_txt, is.na(data_carto$nb_txt), 0)
data_carto <- data_carto %>% mutate(nb_txt_disp = paste(nb_txt, "txt"))

#--------------------------------------------------
#Map it!
#--------------------------------------------------
mf_export(							#Export is done right away (not in 8_save_outputs.R)
	data_carto,
	filename = paste("../Graphs/", file_name, "_map", ".png", sep=""),
	width=9,
	height = 7,
	units = "in",
	res = 600
)
mf_map(
	x=data_carto,
	var = "mean_rate",
	type = "choro",
	leg_pos = "topleft",
	leg_title = dependent_var,
	col_na = "light gray",
	pal = "Teal",
	add = TRUE
)
mf_layout(
	title = paste(title_element),
	credits = paste0("Corpus: ", corpus_var, "\nMade with Comparalem,\n", "using mapsf ", packageVersion("mapsf")),
	arrow = FALSE,
	scale = FALSE
)
# mf_label(
# 	x = data_carto,
# 	var = "R_nom",
# 	col = "black",
# 	cex = 0.7,
# 	font = 4,
# 	halo = TRUE,
# 	bg = "white",
# 	r = 0.1,
# 	overlap = FALSE,
# 	lines = FALSE,
# 	adj = c(0.5,-2)
# )
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
