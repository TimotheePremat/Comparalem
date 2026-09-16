#Script to save plots as PNG and GLM raw results as tables

#Save plots
	#Diachro plots
	ggsave(plot1,
			path = "../Graphs",
	      	filename = paste(file_name,"_diachro_rate", ".png", sep=""),
			width=9,
			height = 9,
			units = "in")
	ggsave(plot1_weighted,
			path = "../Graphs",
			filename = paste(file_name,"_diachro_rate_weighted", ".png", sep=""),
			width=9,
			height = 9,
			units = "in")
	ggsave(plot2,
			path = "../Graphs",
			filename = paste(file_name, "_diachro_rate_", independent_var, ".png", sep=""),
			width=9,
			height = 9,
			units = "in")
	ggsave(glm_plot_accuracy,
			path = "../Graphs",
			filename = paste(file_name, "_GLM_by_text_predict_obs", ".png", sep=""),
			width=9,
			height = 9,
			units = "in")
	ggsave(glm_plot_estimate,
			path = "../Graphs",
			filename = paste(file_name, "_GLM_by_text_estimate", ".png", sep=""),
			width=9,
			height = 9,
			units = "in")
	ggsave(glm2_plot_accuracy,
			path = "../Graphs",
			filename = paste(file_name, "_GLM_by_token_predict_obs", ".png", sep=""),
			width=9,
			height = 9,
			units = "in")
	ggsave(glm2_plot_estimate,
			path = "../Graphs",
			filename = paste(file_name, "_GLM_by_token_estimate", ".png", sep=""),
			width=9,
			height = 9,
			units = "in")

	#Splited (subsets) diachro plots
		# Non weigthed
		# Loop through each plot in the list and save it using ggsave()
		lapply(seq_along(plot_list1), function(plot_name) {
		# Retrieve the plot object from the list
		plot <- plot_list1[[plot_name]]

		# Define the file name for saving
		file_name <- paste0(file_name, plot_name, "_diachro_rate.png")

		# Use ggsave to save the plot
		ggsave(filename = file_name,
				path = "../Graphs",
				plot = plot,
				width = 9,
				height = 9,
				units = "in")
		})

		# Weigthed
		# Loop through each plot in the list and save it using ggsave()
		lapply(seq_along(plot_list1_weigthed), function(plot_name) {
		# Retrieve the plot object from the list
		plot <- plot_list1_weigthed[[plot_name]]

		# Define the file name for saving
		file_name <- paste0(file_name, plot_name, "_diachro_rate_weigthed.png")

		# Use ggsave to save the plot
		ggsave(filename = file_name,
				path = "../Graphs",
				plot = plot,
				width = 9,
				height = 9,
				units = "in")
		})

		ggsave(p_by_cat,
		path = "../Graphs",
		filename = paste(file_name, "_raw_distrib_cat", ".png", sep=""),
		width=9,
		height = 9,
		units = "in")

		# Custom var
		# Loop through each plot in the list and save it using ggsave()
		lapply(seq_along(plot_list2), function(plot_name) {
		# Retrieve the plot object from the list
		plot <- plot_list2[[plot_name]]

		# Define the file name for saving
		file_name <- paste0(file_name, plot_name, "_diachro_rate_custom_var.png")

		# Use ggsave to save the plot
		ggsave(filename = file_name,
				path = "../Graphs",
				plot = plot,
				width = 9,
				height = 9,
				units = "in")
		})

#Save tables
	#GLM1: predict rate by text
	write.table(glm_sum_output,
				file=paste("../Tables/",file_name, "_GLM_by_text.txt", sep=""),
				quote=FALSE)
	#Save general rate by text data
	write.table(cat1_cat2_count,
				file=paste("../Tables/",file_name, "_rate_by_text.csv", sep=""),
				quote=FALSE,
				sep=";",
				row.names = FALSE)
	#GLM2: predict each occurrence
	write.table(glm2_sum_output,
				file=paste("../Tables/",file_name, "_GLM_by_token.txt", sep=""),
				quote=FALSE)
	#Save general rate by text data
	write.table(combined_data,
				file=paste("../Tables/",file_name, "_tokens.csv", sep=""),
				quote=FALSE,
				sep=";",
				row.names = FALSE)
