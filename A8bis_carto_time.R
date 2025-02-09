#Script to print maps from A5_diachro_plot_context data.
#Nota: Saving is done in A9_carto_save.R script.
#Nota: this script is independant from A8_carto.R script, because the latter is
 #lighter than this one, running on simplified data (try 'View(data1_V)' in
	#A8_carto.R to see how simplified the data is.

#Import spatial data
data_spatial <- readOGR("Regions-Shapefile")

#Calcuate pseudo-centroids, for printing values on polygons later
centroids.df <- as.data.frame(coordinates(data_spatial))
names(centroids.df) <- c("C_long", "C_lat") #rename centroids columns

centroids.df_lower <- centroids.df %>%
	mutate(C_lat = C_lat-0.12)
centroids.df_higher <- centroids.df %>%
	mutate(C_lat = C_lat+0.1)

#--------------------------------------------------
#Prepare data
#--------------------------------------------------
	##For first period
	#--------------------------------------------------
	# Prepare data for #V environment
		POS__V_1 <- POS__V %>% filter(datecomposition < bound_1b)
		data1_V_1 <- POS__V_1 %>%
          group_by(R_code_suppl_total) %>%
	      summarise(taux_moyen = mean(Tx_POS_EnonE), nb_txt = n()) %>%
	      rename(R_Code = R_code_suppl_total)
		data1_V_1$taux_moyen <- data1_V_1$taux_moyen*100

	# Prepare data for #C environment
		POS__C_1 <- POS__C %>% filter(datecomposition < bound_1b)
		data1_C_1 <- POS__C_1 %>%
          group_by(R_code_suppl_total) %>%
	      summarise(taux_moyen = mean(Tx_POS_EnonE), nb_txt = n()) %>%
	      rename(R_Code = R_code_suppl_total)
		data1_C_1$taux_moyen <- data1_C_1$taux_moyen*100

	## Merge datasets
		data3_V_1 <- merge (data_spatial, data1_V_1, by="R_Code")
		data3_C_1 <- merge (data_spatial, data1_C_1, by="R_Code")

	#Replace NA values by 0 values for regions with no texts
		data3_V_1$nb_txt <- replace(data3_V_1$nb_txt, is.na(data3_V_1$nb_txt), 0)
		data3_C_1$nb_txt <- replace(data3_C_1$nb_txt, is.na(data3_C_1$nb_txt), 0)

	# #Neutralize regions with less than 5 texts by replacing taux_moyen value by NA
		# data3_V_1$taux_moyen <- replace(data3_V_1$taux_moyen, data3_V_1$nb_txt <5, NA)
		# data3_C_1$taux_moyen <- replace(data3_C_1$taux_moyen, data3_C_1$nb_txt <5, NA)

	#--------------------------------------------------
	##For second period
	#--------------------------------------------------
	# Prepare data for #V environment
		POS__V_2 <- POS__V %>% filter(datecomposition > bound_2a) %>%
		                       filter(datecomposition < bound_2b)
		data1_V_2 <- POS__V_2 %>%
          group_by(R_code_suppl_total) %>%
	      summarise(taux_moyen = mean(Tx_POS_EnonE), nb_txt = n()) %>%
	      rename(R_Code = R_code_suppl_total)
		data1_V_2$taux_moyen <- data1_V_2$taux_moyen*100

	# Prepare data for #C environment
		POS__C_2 <- POS__C %>% filter(datecomposition > bound_2a) %>%
		                       filter(datecomposition < bound_2b)
		data1_C_2 <- POS__C_2 %>%
          group_by(R_code_suppl_total) %>%
	      summarise(taux_moyen = mean(Tx_POS_EnonE), nb_txt = n()) %>%
	      rename(R_Code = R_code_suppl_total)
		data1_C_2$taux_moyen <- data1_C_2$taux_moyen*100

	## Merge datasets
		data3_V_2 <- merge (data_spatial, data1_V_2, by="R_Code")
		data3_C_2 <- merge (data_spatial, data1_C_2, by="R_Code")

	#Replace NA values by 0 values for regions with no texts
		data3_V_2$nb_txt <- replace(data3_V_2$nb_txt, is.na(data3_V_2$nb_txt), 0)
		data3_C_2$nb_txt <- replace(data3_C_2$nb_txt, is.na(data3_C_2$nb_txt), 0)

	# #Neutralize regions with less than 5 texts by replacing taux_moyen value by NA
		# data3_V_2$taux_moyen <- replace(data3_V_2$taux_moyen, data3_V_2$nb_txt <5, NA)
		# data3_C_2$taux_moyen <- replace(data3_C_2$taux_moyen, data3_C_2$nb_txt <5, NA)

	#--------------------------------------------------
	##For third period
	#--------------------------------------------------
	# Prepare data for #V environment
		POS__V_3 <- POS__V %>% filter(datecomposition > bound_3a) %>%
		                       filter(datecomposition < bound_3b)
		data1_V_3 <- POS__V_3 %>%
          group_by(R_code_suppl_total) %>%
	      summarise(taux_moyen = mean(Tx_POS_EnonE), nb_txt = n()) %>%
	      rename(R_Code = R_code_suppl_total)
		data1_V_3$taux_moyen <- data1_V_3$taux_moyen*100

	# Prepare data for #C environment
		POS__C_3 <- POS__C %>% filter(datecomposition > bound_3a) %>%
		                       filter(datecomposition < bound_3b)
		data1_C_3 <- POS__C_3 %>%
          group_by(R_code_suppl_total) %>%
	      summarise(taux_moyen = mean(Tx_POS_EnonE), nb_txt = n()) %>%
	      rename(R_Code = R_code_suppl_total)
		data1_C_3$taux_moyen <- data1_C_3$taux_moyen*100

	## Merge datasets
		data3_V_3 <- merge (data_spatial, data1_V_3, by="R_Code")
		data3_C_3 <- merge (data_spatial, data1_C_3, by="R_Code")

	#Replace NA values by 0 values for regions with no texts
		data3_V_3$nb_txt <- replace(data3_V_3$nb_txt, is.na(data3_V_3$nb_txt), 0)
		data3_C_3$nb_txt <- replace(data3_C_3$nb_txt, is.na(data3_C_3$nb_txt), 0)

	# #Neutralize regions with less than 5 texts by replacing taux_moyen value by NA
		# data3_V_2$taux_moyen <- replace(data3_V_2$taux_moyen, data3_V_2$nb_txt <5, NA)
		# data3_C_2$taux_moyen <- replace(data3_C_2$taux_moyen, data3_C_2$nb_txt <5, NA)

	#--------------------------------------------------
	##For last period
	#--------------------------------------------------
	# Prepare data for #V environment
		POS__V_4 <- POS__V %>% filter(datecomposition > bound_4a)
		data1_V_4 <- POS__V_4 %>%
          group_by(R_code_suppl_total) %>%
	      summarise(taux_moyen = mean(Tx_POS_EnonE), nb_txt = n()) %>%
	      rename(R_Code = R_code_suppl_total)
		data1_V_4$taux_moyen <- data1_V_4$taux_moyen*100

	# Prepare data for #C environment
		POS__C_4 <- POS__C %>% filter(datecomposition > bound_4a)
		data1_C_4 <- POS__C_4 %>%
          group_by(R_code_suppl_total) %>%
	      summarise(taux_moyen = mean(Tx_POS_EnonE), nb_txt = n()) %>%
	      rename(R_Code = R_code_suppl_total)
		data1_C_4$taux_moyen <- data1_C_4$taux_moyen*100

	## Merge datasets
		data3_V_4 <- merge (data_spatial, data1_V_4, by="R_Code")
		data3_C_4 <- merge (data_spatial, data1_C_4, by="R_Code")

	#Replace NA values by 0 values for regions with no texts
		data3_V_4$nb_txt <- replace(data3_V_4$nb_txt, is.na(data3_V_4$nb_txt), 0)
		data3_C_4$nb_txt <- replace(data3_C_4$nb_txt, is.na(data3_C_4$nb_txt), 0)

	# #Neutralize regions with less than 5 texts by replacing taux_moyen value by NA
		# data3_V_2$taux_moyen <- replace(data3_V_2$taux_moyen, data3_V_2$nb_txt <5, NA)
		# data3_C_2$taux_moyen <- replace(data3_C_2$taux_moyen, data3_C_2$nb_txt <5, NA)

#--------------------------------------------------
#Plots for _V
#--------------------------------------------------
	##Plot for time 1
	#--------------------------------------------------
	#NAME THE VARIABLE YOU WANT TO USE
		my_var_carto_V_1 <- data3_V_1$taux_moyen
		my_var_carto_V_name <- "Devant #V,\npourcentage de Ø"
		my_var_display_V_1 <- as.numeric(my_var_carto_V_1)
		my_var_display_V_1_nb_txt <- as.numeric(data3_V_1$nb_txt)

	#Define the plot
		plot_V_1 <- ggplot() +
			#Pass fill=item to annotation_spatial to make it available for layer_spatial below
			annotation_spatial(data3_V_1, aes(fill=taux_moyen)) +
			layer_spatial(data3_V_1, aes(fill=taux_moyen)) +
			scale_fill_gradient(low="white",
					high="black",
					na.value="white",
					name=paste(my_var_carto_V_name),
					limits=c(0,100)) +
					#Verbose theme definition
					theme(panel.background=element_rect(fill = "transparent", colour = "transparent"),
				        panel.grid.major = element_blank(),
				        panel.grid.minor = element_blank(),
				        legend.justification=c(0,0),
				        axis.title.x=element_blank(),
				        axis.text.x=element_blank(),
				        axis.ticks.x=element_blank(),
				        axis.title.y=element_blank(),
				        axis.text.y=element_blank(),
				        axis.ticks.y=element_blank(),
				        legend.position=c(0.02,0.03),
				        legend.spacing=unit(1,"lines"),
				        legend.box="vertical",
				        legend.key.size=unit(1.2,"lines"),
				        legend.text.align=0,
				        legend.title.align=0,
				        legend.text=element_text(size=12, color="black"),
				        legend.key = element_rect(fill = "transparent", color="transparent"),
				        legend.title=element_text(size=12, color="black", face = "bold"),
				        legend.background = element_rect(fill = "transparent", colour = "transparent")) +

		#Add textual annotations
			annotate("text", x = -4.5, y = 51.25, label = paste(my_var_carto_V_name),
				size=6, color = "black", hjust = 0) +
			annotate("text", x = -4.5, y = 50.75, label = paste(my_var2),
				size=4.5, color = "black", hjust = 0) +
			annotate("text", x = -4.5, y = 50.35, label = "Données : NCA, Dees (1987)\n© Timothée Premat",
				size=3.5, color = "black", hjust = 0) +
			annotate("text", x = 3 , y = 51.25, label=paste("Période 1 :\nDate compo. <",bound_1b),
		  size=4.5, color = "black", hjust = 0, vjust=0.3) +
			#Annotations for statistical values
				##Labels
				annotate("text", x = 2, y = 45.8, label = paste0("min. "),
					        size=4, color = "black", hjust = 0) +
				annotate("text", x = 2, y = 45.6, label = paste0("moy. "),
					        size=4, color = "black", hjust = 0) +
				annotate("text", x = 2, y = 45.4, label = paste0("max. "),
					        size=4, color = "black", hjust = 0) +
				annotate("text", x = 2, y = 45.2, label = paste0("σ"),
					        size=4, color = "black", hjust = 0) +
				##Values
				annotate("text", x = 2.75, y = 45.8, label = paste0(round(min(my_var_display_V_1, na.rm=TRUE),2), "%"),
					        size=4, color = "black", hjust = 0) +
				annotate("text", x = 2.75, y = 45.6, label = paste0(round(mean(my_var_display_V_1, na.rm=TRUE),2), "%"),
					        size=4, color = "black", hjust = 0) +
				annotate("text", x = 2.75, y = 45.4, label = paste0(round(max(my_var_display_V_1, na.rm=TRUE),2), "%"),
					        size=4, color = "black", hjust = 0) +
				annotate("text", x = 2.75, y = 45.2, label = paste0(round(sd(my_var_display_V_1, na.rm = TRUE),2)),
					        size=4, color = "black", hjust = 0)

		#Add values and nb of texts on each polygon.
		plot2_V_1 <- plot_V_1 +
		geom_label(aes(label = ifelse(is.na(my_var_display_V_1_nb_txt), "", paste0(my_var_display_V_1_nb_txt," txt")),
			x = centroids.df_lower$C_long,
			y = centroids.df_lower$C_lat),
		 label.size = 0,
		 size=3.5) +
		geom_label(aes(label = ifelse(is.na(my_var_carto_V_1), "", paste0(round(my_var_carto_V_1, digits =0)," %")),
			x = centroids.df_higher$C_long,
			y = centroids.df_higher$C_lat),
		 label.size=0,
		 fontface = "bold")

		# plot2_V_1

		#--------------------------------------------------
		##Plot for time 2
		#--------------------------------------------------
		#NAME THE VARIABLE YOU WANT TO USE
			my_var_carto_V_2 <- data3_V_2$taux_moyen
			my_var_carto_V_name <- "Devant #V,\npourcentage de Ø"
			my_var_display_V_2 <- as.numeric(my_var_carto_V_2)
			my_var_display_V_2_nb_txt <- as.numeric(data3_V_2$nb_txt)

		#Define the plot
			plot_V_2 <- ggplot() +
				#Pass fill=item to annotation_spatial to make it available for layer_spatial below
				annotation_spatial(data3_V_2, aes(fill=taux_moyen)) +
				layer_spatial(data3_V_2, aes(fill=taux_moyen)) +
				scale_fill_gradient(low="white",
						high="black",
						na.value="white",
						name=paste(my_var_carto_V_name),
						limits=c(0,100)) +
						#Verbose theme definition
						theme(panel.background=element_rect(fill = "transparent", colour = "transparent"),
					        panel.grid.major = element_blank(),
					        panel.grid.minor = element_blank(),
					        legend.justification=c(0,0),
					        axis.title.x=element_blank(),
					        axis.text.x=element_blank(),
					        axis.ticks.x=element_blank(),
					        axis.title.y=element_blank(),
					        axis.text.y=element_blank(),
					        axis.ticks.y=element_blank(),
					        legend.position=c(0.02,0.03),
					        legend.spacing=unit(1,"lines"),
					        legend.box="vertical",
					        legend.key.size=unit(1.2,"lines"),
					        legend.text.align=0,
					        legend.title.align=0,
					        legend.text=element_text(size=12, color="black"),
					        legend.key = element_rect(fill = "transparent", color="transparent"),
					        legend.title=element_text(size=12, color="black", face = "bold"),
					        legend.background = element_rect(fill = "transparent", colour = "transparent")) +

		#Add textual annotations
			annotate("text", x = -4.5, y = 51.25, label = paste(my_var_carto_V_name),
				size=6, color = "black", hjust = 0) +
			annotate("text", x = -4.5, y = 50.75, label = paste(my_var2),
				size=4.5, color = "black", hjust = 0) +
			annotate("text", x = -4.5, y = 50.35, label = "Données : NCA, Dees (1987)\n© Timothée Premat",
				size=3.5, color = "black", hjust = 0) +
			annotate("text", x = 3 , y = 51.25, label=paste("Période 2 :\nDate compo. >", bound_2a, logiAND,"<",bound_2b),
		  size=4.5, color = "black", hjust = 0, vjust=0.3) +
			#Annotations for statistical values
				##Labels
				annotate("text", x = 2, y = 45.8, label = paste0("min. "),
					        size=4, color = "black", hjust = 0) +
				annotate("text", x = 2, y = 45.6, label = paste0("moy. "),
					        size=4, color = "black", hjust = 0) +
				annotate("text", x = 2, y = 45.4, label = paste0("max. "),
					        size=4, color = "black", hjust = 0) +
				annotate("text", x = 2, y = 45.2, label = paste0("σ"),
					        size=4, color = "black", hjust = 0) +
				##Values
				annotate("text", x = 2.75, y = 45.8, label = paste0(round(min(my_var_display_V_2, na.rm=TRUE),2), "%"),
					        size=4, color = "black", hjust = 0) +
				annotate("text", x = 2.75, y = 45.6, label = paste0(round(mean(my_var_display_V_2, na.rm=TRUE),2), "%"),
					        size=4, color = "black", hjust = 0) +
				annotate("text", x = 2.75, y = 45.4, label = paste0(round(max(my_var_display_V_2, na.rm=TRUE),2), "%"),
					        size=4, color = "black", hjust = 0) +
				annotate("text", x = 2.75, y = 45.2, label = paste0(round(sd(my_var_display_V_2, na.rm = TRUE),2)),
					        size=4, color = "black", hjust = 0)

		#Add values and nb of texts on each polygon.
			plot2_V_2 <- plot_V_2 +
			geom_label(aes(label = ifelse(is.na(my_var_display_V_2_nb_txt), "", paste0(my_var_display_V_2_nb_txt," txt")),
				x = centroids.df_lower$C_long,
				y = centroids.df_lower$C_lat),
			 label.size = 0,
			 size=3.5) +
			geom_label(aes(label = ifelse(is.na(my_var_carto_V_2), "", paste0(round(my_var_carto_V_2, digits =0)," %")),
				x = centroids.df_higher$C_long,
				y = centroids.df_higher$C_lat),
			 label.size=0,
			 fontface = "bold")

		# plot2_V_2

		#--------------------------------------------------
		##Plot for time 3
		#--------------------------------------------------
		#NAME THE VARIABLE YOU WANT TO USE
			my_var_carto_V_3 <- data3_V_3$taux_moyen
			my_var_carto_V_name <- "Devant #V,\npourcentage de Ø"
			my_var_display_V_3 <- as.numeric(my_var_carto_V_3)
			my_var_display_V_3_nb_txt <- as.numeric(data3_V_3$nb_txt)

		#Define the plot
			plot_V_3 <- ggplot() +
				#Pass fill=item to annotation_spatial to make it available for layer_spatial below
				annotation_spatial(data3_V_3, aes(fill=taux_moyen)) +
				layer_spatial(data3_V_3, aes(fill=taux_moyen)) +
				scale_fill_gradient(low="white",
						high="black",
						na.value="white",
						name=paste(my_var_carto_V_name),
						limits=c(0,100)) +
						#Verbose theme definition
						theme(panel.background=element_rect(fill = "transparent", colour = "transparent"),
					        panel.grid.major = element_blank(),
					        panel.grid.minor = element_blank(),
					        legend.justification=c(0,0),
					        axis.title.x=element_blank(),
					        axis.text.x=element_blank(),
					        axis.ticks.x=element_blank(),
					        axis.title.y=element_blank(),
					        axis.text.y=element_blank(),
					        axis.ticks.y=element_blank(),
					        legend.position=c(0.02,0.03),
					        legend.spacing=unit(1,"lines"),
					        legend.box="vertical",
					        legend.key.size=unit(1.2,"lines"),
					        legend.text.align=0,
					        legend.title.align=0,
					        legend.text=element_text(size=12, color="black"),
					        legend.key = element_rect(fill = "transparent", color="transparent"),
					        legend.title=element_text(size=12, color="black", face = "bold"),
					        legend.background = element_rect(fill = "transparent", colour = "transparent")) +

		#Add textual annotations
			annotate("text", x = -4.5, y = 51.25, label = paste(my_var_carto_V_name),
				size=6, color = "black", hjust = 0) +
			annotate("text", x = -4.5, y = 50.75, label = paste(my_var2),
				size=4.5, color = "black", hjust = 0) +
			annotate("text", x = -4.5, y = 50.35, label = "Données : NCA, Dees (1987)\n© Timothée Premat",
				size=3.5, color = "black", hjust = 0) +
			annotate("text", x = 3 , y = 51.25, label=paste("Période 3 :\nDate compo. >", bound_3a, logiAND,"<",bound_3b),
		  size=4.5, color = "black", hjust = 0, vjust=0.3) +
			#Annotations for statistical values
				##Labels
				annotate("text", x = 2, y = 45.8, label = paste0("min. "),
					        size=4, color = "black", hjust = 0) +
				annotate("text", x = 2, y = 45.6, label = paste0("moy. "),
					        size=4, color = "black", hjust = 0) +
				annotate("text", x = 2, y = 45.4, label = paste0("max. "),
					        size=4, color = "black", hjust = 0) +
				annotate("text", x = 2, y = 45.2, label = paste0("σ"),
					        size=4, color = "black", hjust = 0) +
				##Values
				annotate("text", x = 2.75, y = 45.8, label = paste0(round(min(my_var_display_V_3, na.rm=TRUE),2), "%"),
					        size=4, color = "black", hjust = 0) +
				annotate("text", x = 2.75, y = 45.6, label = paste0(round(mean(my_var_display_V_3, na.rm=TRUE),2), "%"),
					        size=4, color = "black", hjust = 0) +
				annotate("text", x = 2.75, y = 45.4, label = paste0(round(max(my_var_display_V_3, na.rm=TRUE),2), "%"),
					        size=4, color = "black", hjust = 0) +
				annotate("text", x = 2.75, y = 45.2, label = paste0(round(sd(my_var_display_V_3, na.rm = TRUE),2)),
					        size=4, color = "black", hjust = 0)

		#Add values and nb of texts on each polygon.
			plot2_V_3 <- plot_V_3 +
			geom_label(aes(label = ifelse(is.na(my_var_display_V_3_nb_txt), "", paste0(my_var_display_V_3_nb_txt," txt")),
				x = centroids.df_lower$C_long,
				y = centroids.df_lower$C_lat),
			 label.size = 0,
			 size=3.5) +
			geom_label(aes(label = ifelse(is.na(my_var_carto_V_3), "", paste0(round(my_var_carto_V_3, digits =0)," %")),
				x = centroids.df_higher$C_long,
				y = centroids.df_higher$C_lat),
			 label.size=0,
			 fontface = "bold")

		# plot2_V_3

		#--------------------------------------------------
		##Plot for time 4
		#--------------------------------------------------
		#NAME THE VARIABLE YOU WANT TO USE
			my_var_carto_V_4 <- data3_V_4$taux_moyen
			my_var_carto_V_name <- "Devant #V,\npourcentage de Ø"
			my_var_display_V_4 <- as.numeric(my_var_carto_V_4)
			my_var_display_V_4_nb_txt <- as.numeric(data3_V_4$nb_txt)

		#Define the plot
			plot_V_4 <- ggplot() +
				#Pass fill=item to annotation_spatial to make it available for layer_spatial below
				annotation_spatial(data3_V_4, aes(fill=taux_moyen)) +
				layer_spatial(data3_V_4, aes(fill=taux_moyen)) +
				scale_fill_gradient(low="white",
						high="black",
						na.value="white",
						name=paste(my_var_carto_V_name),
						limits=c(0,100)) +
						#Verbose theme definition
						theme(panel.background=element_rect(fill = "transparent", colour = "transparent"),
					        panel.grid.major = element_blank(),
					        panel.grid.minor = element_blank(),
					        legend.justification=c(0,0),
					        axis.title.x=element_blank(),
					        axis.text.x=element_blank(),
					        axis.ticks.x=element_blank(),
					        axis.title.y=element_blank(),
					        axis.text.y=element_blank(),
					        axis.ticks.y=element_blank(),
					        legend.position=c(0.02,0.03),
					        legend.spacing=unit(1,"lines"),
					        legend.box="vertical",
					        legend.key.size=unit(1.2,"lines"),
					        legend.text.align=0,
					        legend.title.align=0,
					        legend.text=element_text(size=12, color="black"),
					        legend.key = element_rect(fill = "transparent", color="transparent"),
					        legend.title=element_text(size=12, color="black", face = "bold"),
					        legend.background = element_rect(fill = "transparent", colour = "transparent")) +

		#Add textual annotations
			annotate("text", x = -4.5, y = 51.25, label = paste(my_var_carto_V_name),
				size=6, color = "black", hjust = 0) +
			annotate("text", x = -4.5, y = 50.75, label = paste(my_var2),
				size=4.5, color = "black", hjust = 0) +
			annotate("text", x = -4.5, y = 50.35, label = "Données : NCA, Dees (1987)\n© Timothée Premat",
				size=3.5, color = "black", hjust = 0) +
			annotate("text", x = 3 , y = 51.25, label=paste("Période 4 :\nDate compo. >", bound_4a),
		  size=4.5, color = "black", hjust = 0, vjust=0.3) +
			#Annotations for statistical values
				##Labels
				annotate("text", x = 2, y = 45.8, label = paste0("min. "),
					        size=4, color = "black", hjust = 0) +
				annotate("text", x = 2, y = 45.6, label = paste0("moy. "),
					        size=4, color = "black", hjust = 0) +
				annotate("text", x = 2, y = 45.4, label = paste0("max. "),
					        size=4, color = "black", hjust = 0) +
				annotate("text", x = 2, y = 45.2, label = paste0("σ"),
					        size=4, color = "black", hjust = 0) +
				##Values
				annotate("text", x = 2.75, y = 45.8, label = paste0(round(min(my_var_display_V_4, na.rm=TRUE),2), "%"),
					        size=4, color = "black", hjust = 0) +
				annotate("text", x = 2.75, y = 45.6, label = paste0(round(mean(my_var_display_V_4, na.rm=TRUE),2), "%"),
					        size=4, color = "black", hjust = 0) +
				annotate("text", x = 2.75, y = 45.4, label = paste0(round(max(my_var_display_V_4, na.rm=TRUE),2), "%"),
					        size=4, color = "black", hjust = 0) +
				annotate("text", x = 2.75, y = 45.2, label = paste0(round(sd(my_var_display_V_4, na.rm = TRUE),2)),
					        size=4, color = "black", hjust = 0)

		#Add values and nb of texts on each polygon.
			plot2_V_4 <- plot_V_4 +
			geom_label(aes(label = ifelse(is.na(my_var_display_V_4_nb_txt), "", paste0(my_var_display_V_4_nb_txt," txt")),
				x = centroids.df_lower$C_long,
				y = centroids.df_lower$C_lat),
			 label.size = 0,
			 size=3.5) +
			geom_label(aes(label = ifelse(is.na(my_var_carto_V_4), "", paste0(round(my_var_carto_V_4, digits =0)," %")),
				x = centroids.df_higher$C_long,
				y = centroids.df_higher$C_lat),
			 label.size=0,
			 fontface = "bold")

		# plot2_V_4

	##Arrange plots two by two
		plot2_V_t1_t2 <- ggarrange(plot2_V_1,
												plot2_V_2,
												labels="auto",
												ncol = 1,
												nrow = 2,
												align = "v")
		plot2_V_t3_t4 <- ggarrange(plot2_V_3,
												plot2_V_4,
												labels="auto",
												ncol = 1,
												nrow = 2,
												align = "v")


#--------------------------------------------------
#Plots for _C
#--------------------------------------------------
	##Plot for time 1
	#--------------------------------------------------
	#NAME THE VARIABLE YOU WANT TO USE
		my_var_carto_C_1 <- data3_C_1$taux_moyen
		my_var_carto_C_name <- "Devant #C,\npourcentage de Ø"
		my_var_display_C_1 <- as.numeric(my_var_carto_C_1)
		my_var_display_C_1_nb_txt <- as.numeric(data3_C_1$nb_txt)

	#Define the plot
		plot_C_1 <- ggplot() +
			#Pass fill=item to annotation_spatial to make it available for layer_spatial below
			annotation_spatial(data3_C_1, aes(fill=taux_moyen)) +
			layer_spatial(data3_C_1, aes(fill=taux_moyen)) +
			scale_fill_gradient(low="white",
					high="black",
					na.value="white",
					name=paste(my_var_carto_C_name),
					limits=c(0,100)) +
					#Verbose theme definition
					theme(panel.background=element_rect(fill = "transparent", colour = "transparent"),
				        panel.grid.major = element_blank(),
				        panel.grid.minor = element_blank(),
				        legend.justification=c(0,0),
				        axis.title.x=element_blank(),
				        axis.text.x=element_blank(),
				        axis.ticks.x=element_blank(),
				        axis.title.y=element_blank(),
				        axis.text.y=element_blank(),
				        axis.ticks.y=element_blank(),
				        legend.position=c(0.02,0.03),
				        legend.spacing=unit(1,"lines"),
				        legend.box="vertical",
				        legend.key.size=unit(1.2,"lines"),
				        legend.text.align=0,
				        legend.title.align=0,
				        legend.text=element_text(size=12, color="black"),
				        legend.key = element_rect(fill = "transparent", color="transparent"),
				        legend.title=element_text(size=12, color="black", face = "bold"),
				        legend.background = element_rect(fill = "transparent", colour = "transparent")) +

		#Add textual annotations
			annotate("text", x = -4.5, y = 51.25, label = paste(my_var_carto_C_name),
				size=6, color = "black", hjust = 0) +
			annotate("text", x = -4.5, y = 50.75, label = paste(my_var2),
				size=4.5, color = "black", hjust = 0) +
			annotate("text", x = -4.5, y = 50.35, label = "Données : NCA, Dees (1987)\n© Timothée Premat",
				size=3.5, color = "black", hjust = 0) +
			annotate("text", x = 3 , y = 51.25, label=paste("Période 1 :\nDate compo. <",bound_1b),
		  size=4.5, color = "black", hjust = 0, vjust=0.3) +
			#Annotations for statistical values
				##Labels
				annotate("text", x = 2, y = 45.8, label = paste0("min. "),
					        size=4, color = "black", hjust = 0) +
				annotate("text", x = 2, y = 45.6, label = paste0("moy. "),
					        size=4, color = "black", hjust = 0) +
				annotate("text", x = 2, y = 45.4, label = paste0("max. "),
					        size=4, color = "black", hjust = 0) +
				annotate("text", x = 2, y = 45.2, label = paste0("σ"),
					        size=4, color = "black", hjust = 0) +
				##Values
				annotate("text", x = 2.75, y = 45.8, label = paste0(round(min(my_var_display_C_1, na.rm=TRUE),2), "%"),
					        size=4, color = "black", hjust = 0) +
				annotate("text", x = 2.75, y = 45.6, label = paste0(round(mean(my_var_display_C_1, na.rm=TRUE),2), "%"),
					        size=4, color = "black", hjust = 0) +
				annotate("text", x = 2.75, y = 45.4, label = paste0(round(max(my_var_display_C_1, na.rm=TRUE),2), "%"),
					        size=4, color = "black", hjust = 0) +
				annotate("text", x = 2.75, y = 45.2, label = paste0(round(sd(my_var_display_C_1, na.rm = TRUE),2)),
					        size=4, color = "black", hjust = 0)

		#Add values and nb of texts on each polygon.
		plot2_C_1 <- plot_C_1 +
		geom_label(aes(label = ifelse(is.na(my_var_display_C_1_nb_txt), "", paste0(my_var_display_C_1_nb_txt," txt")),
			x = centroids.df_lower$C_long,
			y = centroids.df_lower$C_lat),
		 label.size = 0,
		 size=3.5) +
		geom_label(aes(label = ifelse(is.na(my_var_carto_C_1), "", paste0(round(my_var_carto_C_1, digits =0)," %")),
			x = centroids.df_higher$C_long,
			y = centroids.df_higher$C_lat),
		 label.size=0,
		 fontface = "bold")

		# plot2_C_1

		#--------------------------------------------------
		##Plot for time 2
		#--------------------------------------------------
		#NAME THE VARIABLE YOU WANT TO USE
			my_var_carto_C_2 <- data3_C_2$taux_moyen
			my_var_carto_C_name <- "Devant #C,\npourcentage de Ø"
			my_var_display_C_2 <- as.numeric(my_var_carto_C_2)
			my_var_display_C_2_nb_txt <- as.numeric(data3_C_2$nb_txt)

		#Define the plot
			plot_C_2 <- ggplot() +
				#Pass fill=item to annotation_spatial to make it available for layer_spatial below
				annotation_spatial(data3_C_2, aes(fill=taux_moyen)) +
				layer_spatial(data3_C_2, aes(fill=taux_moyen)) +
				scale_fill_gradient(low="white",
						high="black",
						na.value="white",
						name=paste(my_var_carto_C_name),
						limits=c(0,100)) +
						#Verbose theme definition
						theme(panel.background=element_rect(fill = "transparent", colour = "transparent"),
					        panel.grid.major = element_blank(),
					        panel.grid.minor = element_blank(),
					        legend.justification=c(0,0),
					        axis.title.x=element_blank(),
					        axis.text.x=element_blank(),
					        axis.ticks.x=element_blank(),
					        axis.title.y=element_blank(),
					        axis.text.y=element_blank(),
					        axis.ticks.y=element_blank(),
					        legend.position=c(0.02,0.03),
					        legend.spacing=unit(1,"lines"),
					        legend.box="vertical",
					        legend.key.size=unit(1.2,"lines"),
					        legend.text.align=0,
					        legend.title.align=0,
					        legend.text=element_text(size=12, color="black"),
					        legend.key = element_rect(fill = "transparent", color="transparent"),
					        legend.title=element_text(size=12, color="black", face = "bold"),
					        legend.background = element_rect(fill = "transparent", colour = "transparent")) +

		#Add textual annotations
			annotate("text", x = -4.5, y = 51.25, label = paste(my_var_carto_C_name),
				size=6, color = "black", hjust = 0) +
			annotate("text", x = -4.5, y = 50.75, label = paste(my_var2),
				size=4.5, color = "black", hjust = 0) +
			annotate("text", x = -4.5, y = 50.35, label = "Données : NCA, Dees (1987)\n© Timothée Premat",
				size=3.5, color = "black", hjust = 0) +
			annotate("text", x = 3 , y = 51.25, label=paste("Période 2 :\nDate compo. >", bound_2a, logiAND,"<",bound_2b),
		  size=4.5, color = "black", hjust = 0, vjust=0.3) +
			#Annotations for statistical values
				##Labels
				annotate("text", x = 2, y = 45.8, label = paste0("min. "),
					        size=4, color = "black", hjust = 0) +
				annotate("text", x = 2, y = 45.6, label = paste0("moy. "),
					        size=4, color = "black", hjust = 0) +
				annotate("text", x = 2, y = 45.4, label = paste0("max. "),
					        size=4, color = "black", hjust = 0) +
				annotate("text", x = 2, y = 45.2, label = paste0("σ"),
					        size=4, color = "black", hjust = 0) +
				##Values
				annotate("text", x = 2.75, y = 45.8, label = paste0(round(min(my_var_display_C_2, na.rm=TRUE),2), "%"),
					        size=4, color = "black", hjust = 0) +
				annotate("text", x = 2.75, y = 45.6, label = paste0(round(mean(my_var_display_C_2, na.rm=TRUE),2), "%"),
					        size=4, color = "black", hjust = 0) +
				annotate("text", x = 2.75, y = 45.4, label = paste0(round(max(my_var_display_C_2, na.rm=TRUE),2), "%"),
					        size=4, color = "black", hjust = 0) +
				annotate("text", x = 2.75, y = 45.2, label = paste0(round(sd(my_var_display_C_2, na.rm = TRUE),2)),
					        size=4, color = "black", hjust = 0)

		#Add values and nb of texts on each polygon.
			plot2_C_2 <- plot_C_2 +
			geom_label(aes(label = ifelse(is.na(my_var_display_C_2_nb_txt), "", paste0(my_var_display_C_2_nb_txt," txt")),
				x = centroids.df_lower$C_long,
				y = centroids.df_lower$C_lat),
			 label.size = 0,
			 size=3.5) +
			geom_label(aes(label = ifelse(is.na(my_var_carto_C_2), "", paste0(round(my_var_carto_C_2, digits =0)," %")),
				x = centroids.df_higher$C_long,
				y = centroids.df_higher$C_lat),
			 label.size=0,
			 fontface = "bold")

		# plot2_C_2

		#--------------------------------------------------
		##Plot for time 3
		#--------------------------------------------------
		#NAME THE VARIABLE YOU WANT TO USE
			my_var_carto_C_3 <- data3_C_3$taux_moyen
			my_var_carto_C_name <- "Devant #C,\npourcentage de Ø"
			my_var_display_C_3 <- as.numeric(my_var_carto_C_3)
			my_var_display_C_3_nb_txt <- as.numeric(data3_C_3$nb_txt)

		#Define the plot
			plot_C_3 <- ggplot() +
				#Pass fill=item to annotation_spatial to make it available for layer_spatial below
				annotation_spatial(data3_C_3, aes(fill=taux_moyen)) +
				layer_spatial(data3_C_3, aes(fill=taux_moyen)) +
				scale_fill_gradient(low="white",
						high="black",
						na.value="white",
						name=paste(my_var_carto_C_name),
						limits=c(0,100)) +
						#Verbose theme definition
						theme(panel.background=element_rect(fill = "transparent", colour = "transparent"),
					        panel.grid.major = element_blank(),
					        panel.grid.minor = element_blank(),
					        legend.justification=c(0,0),
					        axis.title.x=element_blank(),
					        axis.text.x=element_blank(),
					        axis.ticks.x=element_blank(),
					        axis.title.y=element_blank(),
					        axis.text.y=element_blank(),
					        axis.ticks.y=element_blank(),
					        legend.position=c(0.02,0.03),
					        legend.spacing=unit(1,"lines"),
					        legend.box="vertical",
					        legend.key.size=unit(1.2,"lines"),
					        legend.text.align=0,
					        legend.title.align=0,
					        legend.text=element_text(size=12, color="black"),
					        legend.key = element_rect(fill = "transparent", color="transparent"),
					        legend.title=element_text(size=12, color="black", face = "bold"),
					        legend.background = element_rect(fill = "transparent", colour = "transparent")) +

		#Add textual annotations
			annotate("text", x = -4.5, y = 51.25, label = paste(my_var_carto_C_name),
				size=6, color = "black", hjust = 0) +
			annotate("text", x = -4.5, y = 50.75, label = paste(my_var2),
				size=4.5, color = "black", hjust = 0) +
			annotate("text", x = -4.5, y = 50.35, label = "Données : NCA, Dees (1987)\n© Timothée Premat",
				size=3.5, color = "black", hjust = 0) +
			annotate("text", x = 3 , y = 51.25, label=paste("Période 3 :\nDate compo. >", bound_3a, logiAND,"<",bound_3b),
		  size=4.5, color = "black", hjust = 0, vjust=0.3) +
			#Annotations for statistical values
				##Labels
				annotate("text", x = 2, y = 45.8, label = paste0("min. "),
					        size=4, color = "black", hjust = 0) +
				annotate("text", x = 2, y = 45.6, label = paste0("moy. "),
					        size=4, color = "black", hjust = 0) +
				annotate("text", x = 2, y = 45.4, label = paste0("max. "),
					        size=4, color = "black", hjust = 0) +
				annotate("text", x = 2, y = 45.2, label = paste0("σ"),
					        size=4, color = "black", hjust = 0) +
				##Values
				annotate("text", x = 2.75, y = 45.8, label = paste0(round(min(my_var_display_C_3, na.rm=TRUE),2), "%"),
					        size=4, color = "black", hjust = 0) +
				annotate("text", x = 2.75, y = 45.6, label = paste0(round(mean(my_var_display_C_3, na.rm=TRUE),2), "%"),
					        size=4, color = "black", hjust = 0) +
				annotate("text", x = 2.75, y = 45.4, label = paste0(round(max(my_var_display_C_3, na.rm=TRUE),2), "%"),
					        size=4, color = "black", hjust = 0) +
				annotate("text", x = 2.75, y = 45.2, label = paste0(round(sd(my_var_display_C_3, na.rm = TRUE),2)),
					        size=4, color = "black", hjust = 0)

		#Add values and nb of texts on each polygon.
			plot2_C_3 <- plot_C_3 +
			geom_label(aes(label = ifelse(is.na(my_var_display_C_3_nb_txt), "", paste0(my_var_display_C_3_nb_txt," txt")),
				x = centroids.df_lower$C_long,
				y = centroids.df_lower$C_lat),
			 label.size = 0,
			 size=3.5) +
			geom_label(aes(label = ifelse(is.na(my_var_carto_C_3), "", paste0(round(my_var_carto_C_3, digits =0)," %")),
				x = centroids.df_higher$C_long,
				y = centroids.df_higher$C_lat),
			 label.size=0,
			 fontface = "bold")

		# plot2_C_3

		#--------------------------------------------------
		##Plot for time 4
		#--------------------------------------------------
		#NAME THE VARIABLE YOU WANT TO USE
			my_var_carto_C_4 <- data3_C_4$taux_moyen
			my_var_carto_C_name <- "Devant #C,\npourcentage de Ø"
			my_var_display_C_4 <- as.numeric(my_var_carto_C_4)
			my_var_display_C_4_nb_txt <- as.numeric(data3_C_4$nb_txt)

		#Define the plot
			plot_C_4 <- ggplot() +
				#Pass fill=item to annotation_spatial to make it available for layer_spatial below
				annotation_spatial(data3_C_4, aes(fill=taux_moyen)) +
				layer_spatial(data3_C_4, aes(fill=taux_moyen)) +
				scale_fill_gradient(low="white",
						high="black",
						na.value="white",
						name=paste(my_var_carto_C_name),
						limits=c(0,100)) +
						#Verbose theme definition
						theme(panel.background=element_rect(fill = "transparent", colour = "transparent"),
					        panel.grid.major = element_blank(),
					        panel.grid.minor = element_blank(),
					        legend.justification=c(0,0),
					        axis.title.x=element_blank(),
					        axis.text.x=element_blank(),
					        axis.ticks.x=element_blank(),
					        axis.title.y=element_blank(),
					        axis.text.y=element_blank(),
					        axis.ticks.y=element_blank(),
					        legend.position=c(0.02,0.03),
					        legend.spacing=unit(1,"lines"),
					        legend.box="vertical",
					        legend.key.size=unit(1.2,"lines"),
					        legend.text.align=0,
					        legend.title.align=0,
					        legend.text=element_text(size=12, color="black"),
					        legend.key = element_rect(fill = "transparent", color="transparent"),
					        legend.title=element_text(size=12, color="black", face = "bold"),
					        legend.background = element_rect(fill = "transparent", colour = "transparent")) +

		#Add textual annotations
			annotate("text", x = -4.5, y = 51.25, label = paste(my_var_carto_C_name),
				size=6, color = "black", hjust = 0) +
			annotate("text", x = -4.5, y = 50.75, label = paste(my_var2),
				size=4.5, color = "black", hjust = 0) +
			annotate("text", x = -4.5, y = 50.35, label = "Données : NCA, Dees (1987)\n© Timothée Premat",
				size=3.5, color = "black", hjust = 0) +
			annotate("text", x = 3 , y = 51.25, label=paste("Période 4 :\nDate compo. >", bound_4a),
		  size=4.5, color = "black", hjust = 0, vjust=0.3) +
			#Annotations for statistical values
				##Labels
				annotate("text", x = 2, y = 45.8, label = paste0("min. "),
					        size=4, color = "black", hjust = 0) +
				annotate("text", x = 2, y = 45.6, label = paste0("moy. "),
					        size=4, color = "black", hjust = 0) +
				annotate("text", x = 2, y = 45.4, label = paste0("max. "),
					        size=4, color = "black", hjust = 0) +
				annotate("text", x = 2, y = 45.2, label = paste0("σ"),
					        size=4, color = "black", hjust = 0) +
				##Values
				annotate("text", x = 2.75, y = 45.8, label = paste0(round(min(my_var_display_C_4, na.rm=TRUE),2), "%"),
					        size=4, color = "black", hjust = 0) +
				annotate("text", x = 2.75, y = 45.6, label = paste0(round(mean(my_var_display_C_4, na.rm=TRUE),2), "%"),
					        size=4, color = "black", hjust = 0) +
				annotate("text", x = 2.75, y = 45.4, label = paste0(round(max(my_var_display_C_4, na.rm=TRUE),2), "%"),
					        size=4, color = "black", hjust = 0) +
				annotate("text", x = 2.75, y = 45.2, label = paste0(round(sd(my_var_display_C_4, na.rm = TRUE),2)),
					        size=4, color = "black", hjust = 0)

		#Add values and nb of texts on each polygon.
			plot2_C_4 <- plot_C_4 +
			geom_label(aes(label = ifelse(is.na(my_var_display_C_4_nb_txt), "", paste0(my_var_display_C_4_nb_txt," txt")),
				x = centroids.df_lower$C_long,
				y = centroids.df_lower$C_lat),
			 label.size = 0,
			 size=3.5) +
			geom_label(aes(label = ifelse(is.na(my_var_carto_C_4), "", paste0(round(my_var_carto_C_4, digits =0)," %")),
				x = centroids.df_higher$C_long,
				y = centroids.df_higher$C_lat),
			 label.size=0,
			 fontface = "bold")

		# plot2_C_4

	##Arrange plots two by two
		plot2_C_t1_t2 <- ggarrange(plot2_C_1,
												plot2_C_2,
												labels="auto",
												ncol = 1,
												nrow = 2,
												align = "v")
		plot2_C_t3_t4 <- ggarrange(plot2_C_3,
												plot2_C_4,
												labels="auto",
												ncol = 1,
												nrow = 2,
												align = "v")

#--------------------------------------------------
#WEIGHT: Plot for elision minus apocope (_V - _C) = elision's weight over (or under) apocope's weight.
#--------------------------------------------------
#Compute elision's weight for each period
	## For period 1
		data1_W_1 <- merge (data1_V_1, data1_C_1, by="R_Code")
		data1_W_1 <- data1_W_1 %>%
			mutate(elis_W = taux_moyen.x - taux_moyen.y) %>%
			mutate(nb_txt_max = pmax(nb_txt.x, nb_txt.y))

		data3_W_1 <- merge (data_spatial, data1_W_1, by="R_Code")

		#Replace NA values by 0 values for regions with no texts
		data3_W_1$nb_txt_max <- replace(data3_W_1$nb_txt_max, is.na(data3_W_1$nb_txt_max), 0)

		#Neutralize regions with less than 5 texts by replacing taux_moyen value by NA
		# data3_W$elis_W <- replace(data3_W$elis_W, data3_W$nb_txt_max<5, NA)

	## For period 2
		data1_W_2 <- merge (data1_V_2, data1_C_2, by="R_Code")
		data1_W_2 <- data1_W_2 %>%
			mutate(elis_W = taux_moyen.x - taux_moyen.y) %>%
			mutate(nb_txt_max = pmax(nb_txt.x, nb_txt.y))

		data3_W_2 <- merge (data_spatial, data1_W_2, by="R_Code")

		#Replace NA values by 0 values for regions with no texts
		data3_W_2$nb_txt_max <- replace(data3_W_2$nb_txt_max, is.na(data3_W_2$nb_txt_max), 0)

		#Neutralize regions with less than 5 texts by replacing taux_moyen value by NA
		# data3_W$elis_W <- replace(data3_W$elis_W, data3_W$nb_txt_max<5, NA)

	## For period 3
		data1_W_3 <- merge (data1_V_3, data1_C_3, by="R_Code")
		data1_W_3 <- data1_W_3 %>%
			mutate(elis_W = taux_moyen.x - taux_moyen.y) %>%
			mutate(nb_txt_max = pmax(nb_txt.x, nb_txt.y))

		data3_W_3 <- merge (data_spatial, data1_W_3, by="R_Code")

		#Replace NA values by 0 values for regions with no texts
		data3_W_3$nb_txt_max <- replace(data3_W_3$nb_txt_max, is.na(data3_W_3$nb_txt_max), 0)

	## For period 4
		data1_W_4 <- merge (data1_V_4, data1_C_4, by="R_Code")
		data1_W_4 <- data1_W_4 %>%
			mutate(elis_W = taux_moyen.x - taux_moyen.y) %>%
			mutate(nb_txt_max = pmax(nb_txt.x, nb_txt.y))

		data3_W_4 <- merge (data_spatial, data1_W_4, by="R_Code")

		#Replace NA values by 0 values for regions with no texts
		data3_W_4$nb_txt_max <- replace(data3_W_4$nb_txt_max, is.na(data3_W_4$nb_txt_max), 0)

		#Neutralize regions with less than 5 texts by replacing taux_moyen value by NA
		# data3_W$elis_W <- replace(data3_W$elis_W, data3_W$nb_txt_max<5, NA)

	#--------------------------------------------------
	##Plot for time 1
	#--------------------------------------------------
	#NAME THE VARIABLE YOU WANT TO USE
	my_var_carto_W_1 <- data3_W_1$elis_W
	my_var_carto_W_name <- "Taux de prévalence \nde l'élision"
	my_var_display_W_1 <- as.numeric(my_var_carto_W_1)
	my_var_display_W_1_nb_txt <- as.numeric(data3_W_1$nb_txt_max)

	#Define the plot
	plot_W_1 <- ggplot() +
		#Pass fill=item to annotation_spatial to make it available for layer_spatial below
		annotation_spatial(data3_W_1, aes(fill=elis_W)) +
		layer_spatial(data3_W_1, aes(fill=elis_W)) +
		scale_fill_gradient2(low="orangered4",
				high="darkolivegreen4",
				mid = "white",
				na.value="white",
				name=paste(my_var_carto_W_name),
				limits=c(-100,100)) +
				#Verbose theme definition
				theme(panel.background=element_rect(fill = "transparent", colour = "transparent"),
			        panel.grid.major = element_blank(),
			        panel.grid.minor = element_blank(),
			        legend.justification=c(0,0),
			        axis.title.x=element_blank(),
			        axis.text.x=element_blank(),
			        axis.ticks.x=element_blank(),
			        axis.title.y=element_blank(),
			        axis.text.y=element_blank(),
			        axis.ticks.y=element_blank(),
			        legend.position=c(0.02,0.03),
			        legend.spacing=unit(1,"lines"),
			        legend.box="vertical",
			        legend.key.size=unit(1.2,"lines"),
			        legend.text.align=0,
			        legend.title.align=0,
			        legend.text=element_text(size=12, color="black"),
			        legend.key = element_rect(fill = "transparent", color="transparent"),
			        legend.title=element_text(size=12, color="black", face = "bold"),
			        legend.background = element_rect(fill = "transparent", colour = "transparent")) +

	#Add textual annotations
		annotate("text", x = -4.5, y = 51.25, label = paste(my_var_carto_W_name),
			size=6, color = "black", hjust = 0) +
		annotate("text", x = -4.5, y = 50.75, label = paste(my_var2),
			size=4.5, color = "black", hjust = 0) +
		annotate("text", x = -4.5, y = 50.35, label = "Données : NCA, Dees (1987)\n© Timothée Premat",
			size=3.5, color = "black", hjust = 0) +
		annotate("text", x = 3 , y = 51.25, label=paste("Période 1 :\nDate compo. <",bound_1b),
			size=4.5, color = "black", hjust = 0, vjust=0.3) +
		#Annotations for statistical values
			##Labels
			annotate("text", x = 2, y = 45.8, label = paste0("min. "),
				        size=4, color = "black", hjust = 0) +
			annotate("text", x = 2, y = 45.6, label = paste0("moy. "),
				        size=4, color = "black", hjust = 0) +
			annotate("text", x = 2, y = 45.4, label = paste0("max. "),
				        size=4, color = "black", hjust = 0) +
			annotate("text", x = 2, y = 45.2, label = paste0("σ"),
				        size=4, color = "black", hjust = 0) +
			##Values
			annotate("text", x = 2.75, y = 45.8, label = paste0(round(min(my_var_display_W_1, na.rm=TRUE),2), "%"),
				        size=4, color = "black", hjust = 0) +
			annotate("text", x = 2.75, y = 45.6, label = paste0(round(mean(my_var_display_W_1, na.rm=TRUE),2), "%"),
				        size=4, color = "black", hjust = 0) +
			annotate("text", x = 2.75, y = 45.4, label = paste0(round(max(my_var_display_W_1, na.rm=TRUE),2), "%"),
				        size=4, color = "black", hjust = 0) +
			annotate("text", x = 2.75, y = 45.2, label = paste0(round(sd(my_var_display_W_1, na.rm=TRUE),2)),
				        size=4, color = "black", hjust = 0)

	plot2_W_1 <- plot_W_1 +
	geom_label(aes(label = ifelse(is.na(my_var_display_W_1_nb_txt), "", paste0(my_var_display_W_1_nb_txt," txt")),
		x = centroids.df_lower$C_long,
		y = centroids.df_lower$C_lat),
	 label.size = 0,
	 size=3.5) +
	geom_label(aes(label = ifelse(is.na(my_var_carto_W_1), "", paste0(round(my_var_carto_W_1, digits =0)," %")),
		x = centroids.df_higher$C_long,
		y = centroids.df_higher$C_lat),
	 label.size=0,
	 fontface = "bold")
	plot2_W_1

	#--------------------------------------------------
	##Plot for time 2
	#--------------------------------------------------
	#NAME THE VARIABLE YOU WANT TO USE
	my_var_carto_W_2 <- data3_W_2$elis_W
	my_var_carto_W_name <- "Taux de prévalence \nde l'élision"
	my_var_display_W_2 <- as.numeric(my_var_carto_W_2)
	my_var_display_W_2_nb_txt <- as.numeric(data3_W_2$nb_txt_max)

	#Define the plot
	plot_W_2 <- ggplot() +
		#Pass fill=item to annotation_spatial to make it available for layer_spatial below
		annotation_spatial(data3_W_2, aes(fill=elis_W)) +
		layer_spatial(data3_W_2, aes(fill=elis_W)) +
		scale_fill_gradient2(low="orangered4",
				high="darkolivegreen4",
				mid = "white",
				na.value="white",
				name=paste(my_var_carto_W_name),
				limits=c(-100,100)) +
				#Verbose theme definition
				theme(panel.background=element_rect(fill = "transparent", colour = "transparent"),
											panel.grid.major = element_blank(),
											panel.grid.minor = element_blank(),
											legend.justification=c(0,0),
											axis.title.x=element_blank(),
											axis.text.x=element_blank(),
											axis.ticks.x=element_blank(),
											axis.title.y=element_blank(),
											axis.text.y=element_blank(),
											axis.ticks.y=element_blank(),
											legend.position=c(0.02,0.03),
											legend.spacing=unit(1,"lines"),
											legend.box="vertical",
											legend.key.size=unit(1.2,"lines"),
											legend.text.align=0,
											legend.title.align=0,
											legend.text=element_text(size=12, color="black"),
											legend.key = element_rect(fill = "transparent", color="transparent"),
											legend.title=element_text(size=12, color="black", face = "bold"),
											legend.background = element_rect(fill = "transparent", colour = "transparent")) +

	#Add textual annotations
		annotate("text", x = -4.5, y = 51.25, label = paste(my_var_carto_W_name),
			size=6, color = "black", hjust = 0) +
		annotate("text", x = -4.5, y = 50.75, label = paste(my_var2),
			size=4.5, color = "black", hjust = 0) +
		annotate("text", x = -4.5, y = 50.35, label = "Données : NCA, Dees (1987)\n© Timothée Premat",
			size=3.5, color = "black", hjust = 0) +
		annotate("text", x = 3 , y = 51.25, label=paste("Période 2 :\nDate compo. >", bound_2a, logiAND,"<",bound_2b),
			size=4.5, color = "black", hjust = 0, vjust=0.3) +
		#Annotations for statistical values
			##Labels
			annotate("text", x = 2, y = 45.8, label = paste0("min. "),
												size=4, color = "black", hjust = 0) +
			annotate("text", x = 2, y = 45.6, label = paste0("moy. "),
												size=4, color = "black", hjust = 0) +
			annotate("text", x = 2, y = 45.4, label = paste0("max. "),
												size=4, color = "black", hjust = 0) +
			annotate("text", x = 2, y = 45.2, label = paste0("σ"),
												size=4, color = "black", hjust = 0) +
			##Values
			annotate("text", x = 2.75, y = 45.8, label = paste0(round(min(my_var_display_W_2, na.rm=TRUE),2), "%"),
												size=4, color = "black", hjust = 0) +
			annotate("text", x = 2.75, y = 45.6, label = paste0(round(mean(my_var_display_W_2, na.rm=TRUE),2), "%"),
												size=4, color = "black", hjust = 0) +
			annotate("text", x = 2.75, y = 45.4, label = paste0(round(max(my_var_display_W_2, na.rm=TRUE),2), "%"),
												size=4, color = "black", hjust = 0) +
			annotate("text", x = 2.75, y = 45.2, label = paste0(round(sd(my_var_display_W_2, na.rm=TRUE),2)),
												size=4, color = "black", hjust = 0)

	plot2_W_2 <- plot_W_2 +
	geom_label(aes(label = ifelse(is.na(my_var_display_W_2_nb_txt), "", paste0(my_var_display_W_2_nb_txt," txt")),
		x = centroids.df_lower$C_long,
		y = centroids.df_lower$C_lat),
		label.size = 0,
		size=3.5) +
	geom_label(aes(label = ifelse(is.na(my_var_carto_W_2), "", paste0(round(my_var_carto_W_2, digits =0)," %")),
		x = centroids.df_higher$C_long,
		y = centroids.df_higher$C_lat),
		label.size=0,
		fontface = "bold")
	plot2_W_2

	#--------------------------------------------------
	##Plot for time 3
	#--------------------------------------------------
	#NAME THE VARIABLE YOU WANT TO USE
	my_var_carto_W_3 <- data3_W_3$elis_W
	my_var_carto_W_name <- "Taux de prévalence \nde l'élision"
	my_var_display_W_3 <- as.numeric(my_var_carto_W_3)
	my_var_display_W_3_nb_txt <- as.numeric(data3_W_3$nb_txt_max)

	#Define the plot
	plot_W_3 <- ggplot() +
		#Pass fill=item to annotation_spatial to make it available for layer_spatial below
		annotation_spatial(data3_W_3, aes(fill=elis_W)) +
		layer_spatial(data3_W_3, aes(fill=elis_W)) +
		scale_fill_gradient2(low="orangered4",
				high="darkolivegreen4",
				mid = "white",
				na.value="white",
				name=paste(my_var_carto_W_name),
				limits=c(-100,100)) +
				#Verbose theme definition
				theme(panel.background=element_rect(fill = "transparent", colour = "transparent"),
											panel.grid.major = element_blank(),
											panel.grid.minor = element_blank(),
											legend.justification=c(0,0),
											axis.title.x=element_blank(),
											axis.text.x=element_blank(),
											axis.ticks.x=element_blank(),
											axis.title.y=element_blank(),
											axis.text.y=element_blank(),
											axis.ticks.y=element_blank(),
											legend.position=c(0.02,0.03),
											legend.spacing=unit(1,"lines"),
											legend.box="vertical",
											legend.key.size=unit(1.2,"lines"),
											legend.text.align=0,
											legend.title.align=0,
											legend.text=element_text(size=12, color="black"),
											legend.key = element_rect(fill = "transparent", color="transparent"),
											legend.title=element_text(size=12, color="black", face = "bold"),
											legend.background = element_rect(fill = "transparent", colour = "transparent")) +

	#Add textual annotations
		annotate("text", x = -4.5, y = 51.25, label = paste(my_var_carto_W_name),
			size=6, color = "black", hjust = 0) +
		annotate("text", x = -4.5, y = 50.75, label = paste(my_var2),
			size=4.5, color = "black", hjust = 0) +
		annotate("text", x = -4.5, y = 50.35, label = "Données : NCA, Dees (1987)\n© Timothée Premat",
			size=3.5, color = "black", hjust = 0) +
		annotate("text", x = 3 , y = 51.25, label=paste("Période 3 :\nDate compo. >", bound_3a, logiAND,"<",bound_3b),
			size=4.5, color = "black", hjust = 0, vjust=0.3) +
		#Annotations for statistical values
			##Labels
			annotate("text", x = 2, y = 45.8, label = paste0("min. "),
												size=4, color = "black", hjust = 0) +
			annotate("text", x = 2, y = 45.6, label = paste0("moy. "),
												size=4, color = "black", hjust = 0) +
			annotate("text", x = 2, y = 45.4, label = paste0("max. "),
												size=4, color = "black", hjust = 0) +
			annotate("text", x = 2, y = 45.2, label = paste0("σ"),
												size=4, color = "black", hjust = 0) +
			##Values
			annotate("text", x = 2.75, y = 45.8, label = paste0(round(min(my_var_display_W_3, na.rm=TRUE),2), "%"),
												size=4, color = "black", hjust = 0) +
			annotate("text", x = 2.75, y = 45.6, label = paste0(round(mean(my_var_display_W_3, na.rm=TRUE),2), "%"),
												size=4, color = "black", hjust = 0) +
			annotate("text", x = 2.75, y = 45.4, label = paste0(round(max(my_var_display_W_3, na.rm=TRUE),2), "%"),
												size=4, color = "black", hjust = 0) +
			annotate("text", x = 2.75, y = 45.2, label = paste0(round(sd(my_var_display_W_3, na.rm=TRUE),2)),
												size=4, color = "black", hjust = 0)

	plot2_W_3 <- plot_W_3 +
	geom_label(aes(label = ifelse(is.na(my_var_display_W_3_nb_txt), "", paste0(my_var_display_W_3_nb_txt," txt")),
		x = centroids.df_lower$C_long,
		y = centroids.df_lower$C_lat),
		label.size = 0,
		size=3.5) +
	geom_label(aes(label = ifelse(is.na(my_var_carto_W_3), "", paste0(round(my_var_carto_W_3, digits =0)," %")),
		x = centroids.df_higher$C_long,
		y = centroids.df_higher$C_lat),
		label.size=0,
		fontface = "bold")
	plot2_W_3

	#--------------------------------------------------
	##Plot for time 4
	#--------------------------------------------------
	#NAME THE VARIABLE YOU WANT TO USE
	my_var_carto_W_4 <- data3_W_4$elis_W
	my_var_carto_W_name <- "Taux de prévalence \nde l'élision"
	my_var_display_W_4 <- as.numeric(my_var_carto_W_4)
	my_var_display_W_4_nb_txt <- as.numeric(data3_W_4$nb_txt_max)

	#Define the plot
	plot_W_4 <- ggplot() +
		#Pass fill=item to annotation_spatial to make it available for layer_spatial below
		annotation_spatial(data3_W_4, aes(fill=elis_W)) +
		layer_spatial(data3_W_4, aes(fill=elis_W)) +
		scale_fill_gradient2(low="orangered4",
				high="darkolivegreen4",
				mid = "white",
				na.value="white",
				name=paste(my_var_carto_W_name),
				limits=c(-100,100)) +
				#Verbose theme definition
				theme(panel.background=element_rect(fill = "transparent", colour = "transparent"),
											panel.grid.major = element_blank(),
											panel.grid.minor = element_blank(),
											legend.justification=c(0,0),
											axis.title.x=element_blank(),
											axis.text.x=element_blank(),
											axis.ticks.x=element_blank(),
											axis.title.y=element_blank(),
											axis.text.y=element_blank(),
											axis.ticks.y=element_blank(),
											legend.position=c(0.02,0.03),
											legend.spacing=unit(1,"lines"),
											legend.box="vertical",
											legend.key.size=unit(1.2,"lines"),
											legend.text.align=0,
											legend.title.align=0,
											legend.text=element_text(size=12, color="black"),
											legend.key = element_rect(fill = "transparent", color="transparent"),
											legend.title=element_text(size=12, color="black", face = "bold"),
											legend.background = element_rect(fill = "transparent", colour = "transparent")) +

	#Add textual annotations
		annotate("text", x = -4.5, y = 51.25, label = paste(my_var_carto_W_name),
			size=6, color = "black", hjust = 0) +
		annotate("text", x = -4.5, y = 50.75, label = paste(my_var2),
			size=4.5, color = "black", hjust = 0) +
		annotate("text", x = -4.5, y = 50.35, label = "Données : NCA, Dees (1987)\n© Timothée Premat",
			size=3.5, color = "black", hjust = 0) +
		annotate("text", x = 3 , y = 51.25, label=paste("Période 4 :\nDate compo. >", bound_4a),
			size=4.5, color = "black", hjust = 0, vjust=0.3) +
		#Annotations for statistical values
			##Labels
			annotate("text", x = 2, y = 45.8, label = paste0("min. "),
												size=4, color = "black", hjust = 0) +
			annotate("text", x = 2, y = 45.6, label = paste0("moy. "),
												size=4, color = "black", hjust = 0) +
			annotate("text", x = 2, y = 45.4, label = paste0("max. "),
												size=4, color = "black", hjust = 0) +
			annotate("text", x = 2, y = 45.2, label = paste0("σ"),
												size=4, color = "black", hjust = 0) +
			##Values
			annotate("text", x = 2.75, y = 45.8, label = paste0(round(min(my_var_display_W_4, na.rm=TRUE),2), "%"),
												size=4, color = "black", hjust = 0) +
			annotate("text", x = 2.75, y = 45.6, label = paste0(round(mean(my_var_display_W_4, na.rm=TRUE),2), "%"),
												size=4, color = "black", hjust = 0) +
			annotate("text", x = 2.75, y = 45.4, label = paste0(round(max(my_var_display_W_4, na.rm=TRUE),2), "%"),
												size=4, color = "black", hjust = 0) +
			annotate("text", x = 2.75, y = 45.2, label = paste0(round(sd(my_var_display_W_4, na.rm=TRUE),2)),
												size=4, color = "black", hjust = 0)

	plot2_W_4 <- plot_W_4 +
	geom_label(aes(label = ifelse(is.na(my_var_display_W_4_nb_txt), "", paste0(my_var_display_W_4_nb_txt," txt")),
		x = centroids.df_lower$C_long,
		y = centroids.df_lower$C_lat),
		label.size = 0,
		size=3.5) +
	geom_label(aes(label = ifelse(is.na(my_var_carto_W_4), "", paste0(round(my_var_carto_W_4, digits =0)," %")),
		x = centroids.df_higher$C_long,
		y = centroids.df_higher$C_lat),
		label.size=0,
		fontface = "bold")
	plot2_W_4

	##Arrange plots two by two
		plot2_W_t1_t2 <- ggarrange(plot2_W_1,
												plot2_W_2,
												labels="auto",
												ncol = 1,
												nrow = 2,
												align = "v")
		plot2_W_t3_t4 <- ggarrange(plot2_W_3,
												plot2_W_4,
												labels="auto",
												ncol = 1,
												nrow = 2,
												align = "v")
