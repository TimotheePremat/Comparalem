# This script provide implementation of regression analysis.
# It is a bit complex because it asks the user which Dependent Variable to use,
# and then needs to turn it into a formula that can be called by glm()

# Two type of approaches are proposed:
# (1) effect of predictors on text rates
# (2) effect of predictors on tokens (in bulk)

#--------------------------------------------------------
#First GLM type: effect of predictors on text rates
#--------------------------------------------------------

# Set reference level
# To be passend into TCLTK!!!
cat1_cat2_count$lieu_compo_normalise <- as.factor(cat1_cat2_count$lieu_compo_normalise)
cat1_cat2_count$lieu_compo_simplifie <- as.factor(cat1_cat2_count$lieu_compo_simplifie)
cat1_cat2_count$lieu_compo_normalise <- relevel(cat1_cat2_count$lieu_compo_normalise, ref = "norm.")
cat1_cat2_count$lieu_compo_simplifie <- relevel(cat1_cat2_count$lieu_compo_simplifie, ref = "g. francien")

cat1_cat2_count$lieu_manuscrit_normalise <- as.factor(cat1_cat2_count$lieu_manuscrit_normalise)
cat1_cat2_count$lieu_manuscrit_simplifie <- as.factor(cat1_cat2_count$lieu_manuscrit_simplifie)
cat1_cat2_count$lieu_manuscrit_normalise <- relevel(cat1_cat2_count$lieu_manuscrit_normalise, ref = "norm.")
cat1_cat2_count$lieu_manuscrit_simplifie <- relevel(cat1_cat2_count$lieu_manuscrit_simplifie, ref = "g. francien")

print("First GLM: by text rate")
#Prepare available variable names
col_names <- paste(colnames(cat1_cat2_count), collapse = "\n")
#Prepare description for tcltk window
description <- paste("***Dependent variables = predictors.***
Available variable names are:     (scroll down if needed)",
	col_names,
	sep = "\n"
)
DV <- get_string_input(title_text = "First GLM: by text rate",
	label_text = "What are your Dependent Variables (DVs)?\nEnter their name separated by + (or by * to test for interaction between two DVs).",
	paragraph_text = description)

	# Check that DVs are present into the dataset
		# Import DV with values as headers (not to be used below)
		DV_check <- FixToTable(DV, sep="+", delim=";", header=TRUE)
		DV_check <- colnames(DV_check)
		DV_check <- as.data.frame(DV_check, optional=TRUE)
		DV_check <- t(DV_check)
		colnames(DV_check) <- DV_check
		df_headers <- toString(colnames(cat1_cat2_count))

		while (!all(colnames(DV_check) %in% colnames(cat1_cat2_count))) {
			# cat("One or several Dependant Variables are not present in the dataset. Variable names available are:", df_headers,sep="\n")
			# Prompt the user again for the correct column name
			DV <- get_string_input(title_text = "Error: First GLM: by text rate",
				label_text = "Error: One or several Dependant Variables are not present in the dataset.\nWhat are your Dependent Variables (DVs)?\nEnter their name separated by + (or by * to test for interaction between two DVs).",
				paragraph_text = description)
				DV_check <- FixToTable(DV, sep=",", delim=";", header=TRUE)
				DV_check <- colnames(DV_check)
				DV_check <- as.data.frame(DV_check, optional=TRUE)
				DV_check <- t(DV_check)
				colnames(DV_check) <- DV_check
		}
			#!all is needed because several values are given in input of %in%
			#cat() instead of print() is needed to print new line before list of DVs
			#if the DVs are good to go, nothing happens.

	# Confirm the DVs
	print(paste("The Dependent Variables for by-text GLM are:", DV))

	# Turn input into the format needed for glm
	DVa <- paste("Tx_cat2", DV, sep=" ~ ")	#Add Independent Variable before DVs
	DV_formula <- as.formula(DVa)			#Turn that into a formula to input in the glm

# Run GLM and LRM
glm_data = glm(DV_formula, data=cat1_cat2_count, family=gaussian)

	# Prepare textual output of GLM
	glm_sum <- summary(glm_data)
	glm_sum_output <- capture.output(glm_sum)
		# Replace DV_formula value
		glm_sum_output <- sub("DV_formula", paste(DVa), glm_sum_output)

# Plot glm accuracy
	#Define function to plot glm accuracy (theoretical vs observed)
	#From: https://larmarange.github.io/guide-R/analyses_avancees/modeles-comptage.html#cb20-35 (customized)
	observed_vs_theoretical <- function(model) {
  		observed <- model.response(model.frame(model))
  		theoretical <- simulate(model, nsim = 1)
  		theoretical <- theoretical[[1]]
  		df <- dplyr::tibble(
    		status = c(
      			rep.int("observed", length(observed)),
      			rep.int("theoretical", length(theoretical))
    		),
    		values = c(observed, theoretical)
  		)
		ggplot2::ggplot(df) +
    	ggplot2::aes(x = values, fill = status) +
    	ggplot2::geom_density(
      		alpha = .5,
      		position = "identity"
    		) +
    	ggplot2::theme_classic() +
    	ggplot2::labs(fill = NULL)
	}

	#Plot GLM
	glm_plot_accuracy <- glm_data %>% observed_vs_theoretical()
	glm_plot_accuracy
	#plot GLM with legend (GLM formula)
	glm_plot_accuracy_leg <- glm_data %>%
						observed_vs_theoretical() +
						ggplot2::labs(caption = paste("Taux de", dependent_var, "~", DV, ", family = gaussian"))
	glm_plot_accuracy_leg

#Plot GML estimates
 	glm_plot_estimate <- plot_model(glm_data, title=paste("Taux de", dependent_var))
	glm_plot_estimate

#--------------------------------------------------------
#Second GLM type: effect of predictors on tokens (in bulk)
#--------------------------------------------------------

# Merge Data_cat1_filtered
combined_data <- bind_rows(
	Data_cat1_cleaned %>% mutate(type_full = tolower(paste(cat2_1))) %>%
		mutate(type = 1),
	Data_cat2_cleaned %>% mutate(type_full = tolower(paste(cat2_2))) %>%
		mutate(type = 0)
)

# Set reference level
# To be passend into TCLTK!!!
combined_data$lieu_compo_normalise <- as.factor(combined_data$lieu_compo_normalise)
combined_data$lieu_compo_simplifie <- as.factor(combined_data$lieu_compo_simplifie)
combined_data$lieu_compo_normalise <- relevel(combined_data$lieu_compo_normalise, ref = "norm.")
combined_data$lieu_compo_simplifie <- relevel(combined_data$lieu_compo_simplifie, ref = "g. francien")

combined_data$lieu_manuscrit_normalise <- as.factor(combined_data$lieu_manuscrit_normalise)
combined_data$lieu_manuscrit_simplifie <- as.factor(combined_data$lieu_manuscrit_simplifie)
combined_data$lieu_manuscrit_normalise <- relevel(combined_data$lieu_manuscrit_normalise, ref = "norm.")
combined_data$lieu_manuscrit_simplifie <- relevel(combined_data$lieu_manuscrit_simplifie, ref = "g. francien")

# print("Second GLM: by individual occurence")
# # Select DVs
# DV2 <- readline(prompt="What are your Dependent Variables (DVs: it is their effect you want to study)?
# Enter their name separated by + (or by * to test for interaction between two DVs):")


#Prepare available variable names
col_names <- paste(colnames(combined_data), collapse = "\n")
#Prepare description for tcltk window
description <- paste("***Dependent variables = predictors.***
Available variable names are:     (scroll down if needed)",
	col_names,
	sep = "\n"
)
DV2 <- get_string_input(title_text = "Second GLM: by token",
	label_text = "What are your Dependent Variables (DVs)?\nEnter their name separated by + (or by * to test for interaction between two DVs).",
	paragraph_text = description)

	# Check that DVs are present into the dataset
		# Import DV with values as headers (not to be used below)
		DV2_check <- FixToTable(DV2, sep="+", delim=";", header=TRUE)
		DV2_check <- colnames(DV2_check)
		DV2_check <- as.data.frame(DV2_check, optional=TRUE)
		DV2_check <- t(DV2_check)
		colnames(DV2_check) <- DV2_check
		df_headers2 <- toString(colnames(combined_data))

		while (!all(colnames(DV2_check) %in% colnames(combined_data))) {
			# cat("One or several Dependant Variables are not present in the dataset. Variable names available are:", df_headers,sep="\n")
			# Prompt the user again for the correct column name
			DV2 <- get_string_input(title_text = "Error: First GLM: by text rate",
				label_text = "Error: One or several Dependant Variables are not present in the dataset.\nWhat are your Dependent Variables (DVs)?\nEnter their name separated by + (or by * to test for interaction between two DVs).",
				paragraph_text = description)
				DV2_check <- FixToTable(DV2, sep=",", delim=";", header=TRUE)
				DV2_check <- colnames(DV2_check)
				DV2_check <- as.data.frame(DV2_check, optional=TRUE)
				DV2_check <- t(DV2_check)
				colnames(DV2_check) <- DV2_check
		}
			#!all is needed because several values are given in input of %in%
			#cat() instead of print() is needed to print new line before list of DVs
			#if the DVs are good to go, nothing happens.

	# Confirm the DVs
	print(paste("The Dependent Variables for occurence-based GLM are:", DV2))

	# Turn input into the format needed for glm
	DV2a <- paste("type", DV2, sep=" ~ ")	#Add Independent Variable before DVs
	DV2_formula <- as.formula(DV2a)			#Turn that into a formula to input in the glm

# Run GLM and LRM
glm2_data = glm(DV2_formula, data=combined_data, family=binomial("logit"))

	# Prepare textual output of GLM
	glm2_sum <- summary(glm2_data)
	glm2_sum_output <- capture.output(glm2_sum)
		# Replace DV_formula value
		glm2_sum_output <- sub("DV2_formula", paste(DV2a), glm2_sum_output)

# Plot glm accuracy

	#Plot GLM
	glm2_plot_accuracy <- glm2_data %>% observed_vs_theoretical()
	glm2_plot_accuracy
	#plot GLM with legend (GLM formula)
	glm2_plot_accuracy_leg <- glm2_data %>%
						observed_vs_theoretical() +
						ggplot2::labs(caption = paste(dependent_var, "~", DV, ", family = poisson"))
	glm2_plot_accuracy_leg

#Plot GML estimates
 	glm2_plot_estimate <- plot_model(glm2_data, title=paste(dependent_var), p.val="wald", type = "resid")
	glm2_plot_estimate
