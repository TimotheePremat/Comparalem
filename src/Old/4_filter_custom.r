#Filtering by one variable

#Prepare available variable names
col_names <- paste("- ", colnames(Data_all), collapse = "\n")
#Prepare description for tcltk window
additional_info <- paste("Available variable names are:     (scroll down if needed)",
	col_names,
	sep = "\n"
)

filter_form <- filtering_options(Data_all, additional_text = additional_info)

var_filter <- filter_form$entry1
val_filter <- filter_form$entry2
	if (grepl(",", val_filter)){
		val_filter <- comma_separated_to_vector(filtering_value)
	}	#To be checked!!!
regex <- filter_form$checkbox_regex
negative_match <- filter_form$checkbox_negative


#Checking for values
if (regex == "1") {									# If regex activated
	check_value_exists_regex(Data_all,
							var_filter,
							val_filter)
} else if (regex == "0") {								# If regex non activated
	check_value_exists(	Data_all,
						var_filter,
						val_filter)
} else {
	print("Warning: if statement dead-end, checking for values")	#for DEBUG
}

#filter based on the variable-value couple
	#List of datasets to be filtered
	list_to_filter <- list(Data_cat1_cleaned = Data_cat1_cleaned,
							Data_cat2_cleaned = Data_cat2_cleaned,
							Data_cat1 = Data_cat1,
							Data_cat2 = Data_cat2,
							Data_all = Data_all)
		#In preparation for list2env below, assign labels to datasets (identical here)
		#Filtered datasets are before the '=' sign

	#Branch algo depending on contains regex or not (branching for vector length not needed)
	#Branch depending on positive (filter in) or negative (filter out) value
	if (regex == "1") {											#If regex match required
		if (negative_match == "1") {										#And if filtering by exclusion
			#Apply FUN to all datasets in list and store as modified_datasets
			modified_datasets <- lapply(list_to_filter, filter_by_var_value_regex_neg,
										var_filter,
										val_filter)
			#Re-assign modified_datasets to original and new datasets
			list2env(modified_datasets, envir = .GlobalEnv)
		} else {															#If regex and filtering by inclusion
			modified_datasets <- lapply(list_to_filter, filter_by_var_value_regex,
										var_filter,
										val_filter)
			list2env(modified_datasets, envir = .GlobalEnv)
		}
	} else if (negative_match == "1") {									#If not regex and filtering by exclusion
			modified_datasets <- lapply(list_to_filter, filter_by_var_value_neg,
										var_filter,
										val_filter)
			list2env(modified_datasets, envir = .GlobalEnv)
	} else {																#If not regex and filtering by inclusion
			modified_datasets <- lapply(list_to_filter, filter_by_var_value,
										var_filter,
										val_filter)
			list2env(modified_datasets, envir = .GlobalEnv)
	}

# filter <- (c(var_filter, val_filter, regex, negative_match))

# The result will store the values from the form (entry1, entry2, regex, negative match)
# print(result)
#
#
# 	#ask for variable
# 	prompt_filtering_var <- "Indicate which variable to use to filter the data:"
# 	filtering_var <- readline(prompt=paste(prompt_filtering_var))
#
# 	#ask for value
# 	prompt_filtering_value <- "Indicate which value to use to filter the data:
# (type ComparaHelp_filtering for details; add 'regex,' for regex support)"
# 	filtering_value <- readline(prompt=paste(prompt_filtering_value))
# 		#If multiple values, turn it into a vector
# 		if (grepl(",", filtering_value)){
# 			filtering_value <- comma_separated_to_vector(filtering_value)
# 		}

###### ANTICIPATE REGEX SUPPRESSION NOT TO BLOCK ON NAME CHECKING LOOPING BELOW

	#check correct variable and value
		#Check for column
		# filtering_var <- check_column_exists(Data_all, filtering_var)

		#Create label on values needed to branch below
		# if (any(grepl("!regex", filtering_value))) {
		# 			print("contains negative regex")		#Print for DEBUG
		# 	if (length(filtering_value) > 2) {
		# 			print("contains multiple values")		#Print for DEBUG
		# 		vector_ident <- "regex_neg_several_val"
		# 	} else {
		# 			print("contains only one value")
		# 		vector_ident <- "regex_neg_one_val"
		# 	}
		# } else if (any(grepl("regex", filtering_value))) {
		# 			print("contains positive regex")		#Print for DEBUG
		# 	if (length(filtering_value) > 2) {
		# 			print("contains multiple values")		#Print for DEBUG
		# 		vector_ident <- "regex_several_valu"
		# 	} else {
		# 			print("contains only one value")		#Print for DEBUG
		# 		vector_ident <- "regex_one_val"
		# 	}
		# } else if (any(grepl("!", filtering_value))) {
		# 			print("is not regex and is neg")		#Print for DEBUG
		# 	if (length(filtering_value) > 1) {
		# 			print("contains multiple values")		#Print for DEBUG
		# 		vector_ident <- "nonregex_neg_several_val"
		# 	} else {
		# 			print("contains only one value")		#Print for DEBUG
		# 		vector_ident <- "nonregex_neg_one_val"
		# 	}
		# } else {
		# 			print("is not regex and is positive")	#Print for DEBUG
		# 	if (length(filtering_value) > 1) {
		# 			print("contains multiple values")		#Print for DEBUG
		# 		vector_ident <- "nonregex_several_val"
		# 	} else {
		# 			print("contains only one value")		#Print for DEBUG
		# 		vector_ident <- "nonregex_one_val"
		# 	}
		# }


		#Check for consistency of negation and Define negative_match (needed for branching below: exclusion or inclusion)
		#Filtering by both including and excluding ('!'-prefixed) values is not supported yet.
		#Default to all values excluding if one is !-prefixed.
	# 	if (any(grepl("!", filtering_value))) {			#If any of the values contains '!'
	# 		if (any(!grepl("!", filtering_value))) {	#Check that all values contain '!'
	# 			warning("All filtering values have been considered as excluding ('!') (type ComparaHelp_filtering for details)")
	# 			negative_match <- "neg"
	# 			filtering_value <- remove_exclamation(filtering_value)
	# 		} else {
	# 			print("'all contains '!'")
	# 			negative_match <- "neg"
	# 			filtering_value <- remove_exclamation(filtering_value)
	# 		}
	# 	} else {
	# 		print("'do not contains '!'")
	# 		negative_match <- "pos"
	# 	}
	#
	# 	#Define regex and vector_multiple_values
	# 	#(needed for branching below: regex and/or vector)
	# 	if (any(grepl("regex", filtering_value))) {								#Is regex? YES
	# 				print("contains regex")					#Print for DEBUG
	# 		if (length(filtering_value) > 2) {										#Is vector of values? YES
	# 				print("contains multiple values")		#Print for DEBUG
	# 			regex <- "yes"
	# 			vector_multiple_values <- "yes"
	# 			filtering_value <- filtering_value[filtering_value != "regex"]
	# 				#Delete value "regex" from the list of filtering values
	# 			} else {															#Is vector of values? NO
	# 				print("contains only one value")		#Print for DEBUG
	# 			regex <- "yes"
	# 			vector_multiple_values <- "no"
	# 			filtering_value <- filtering_value[filtering_value != "regex"]
	# 				#Delete value "regex" from the list of filtering values
	# 		}
	# 	} else if (length(filtering_value) > 1) {								#Is not regex. Is vector? YES
	# 				print("contains multiple values")		#Print for DEBUG
	# 			regex <- "no"
	# 			vector_multiple_values <- "yes"
	# 	} else {																	#Is vector of values? NO
	# 			print("contains only one value")		#Print for DEBUG
	# 		regex <- "no"
	# 		vector_multiple_values <- "no"
	# 	}
	#
	#
	# 	#Check for value
	# 		#Branch algo depending on contains regex or not, and depending on vector lenght > 1
	# 		#Branch depending on positive (filter in) or negative (filter out) value
	# 	if (regex == "yes") {									# If regex activated
	# 		check_value_exists_regex(Data_all,
	# 								filtering_var,
	# 								filtering_value)
	# 	} else if (regex == "no") {								# If regex non activated
	# 		check_value_exists(	Data_all,
	# 							filtering_var,
	# 							filtering_value)
	# 	} else {
	# 		print("Warning: if statement dead-end, checking for values")	#for DEBUG
	# 	}
	#
	# #filter based on the variable-value couple
	# 	#List of datasets to be filtered
	# 	list_to_filter <- list(Data_cat1_cleaned = Data_cat1_cleaned,
	# 							Data_cat2_cleaned = Data_cat2_cleaned,
	# 							Data_cat1_filtered = Data_cat1,
	# 							Data_cat2_filtered = Data_cat2,
	# 							Data_all_filtered = Data_all)
	# 		#In preparation for list2env below, assign labels to datasets (identical here)
	# 		#Filtered datasets are before the '=' sign
	#
	# 	#Branch algo depending on contains regex or not (branching for vector length not needed)
	# 	#Branch depending on positive (filter in) or negative (filter out) value
	# 	if (regex == "yes") {											#If regex match required
	# 		if (negative_match == "neg") {										#And if filtering by exclusion
	# 			#Apply FUN to all datasets in list and store as modified_datasets
	# 			modified_datasets <- lapply(list_to_filter, filter_by_var_value_regex_neg,
	# 										filtering_var,
	# 										filtering_value)
	# 			#Re-assign modified_datasets to original and new datasets
	# 			list2env(modified_datasets, envir = .GlobalEnv)
	# 		} else {															#If regex and filtering by inclusion
	# 			modified_datasets <- lapply(list_to_filter, filter_by_var_value_regex,
	# 										filtering_var,
	# 										filtering_value)
	# 			list2env(modified_datasets, envir = .GlobalEnv)
	# 		}
	# 	} else if (negative_match == "neg") {									#If not regex and filtering by exclusion
	# 			modified_datasets <- lapply(list_to_filter, filter_by_var_value_neg,
	# 										filtering_var,
	# 										filtering_value)
	# 			list2env(modified_datasets, envir = .GlobalEnv)
	# 	} else {																#If not regex and filtering by inclusion
	# 			modified_datasets <- lapply(list_to_filter, filter_by_var_value,
	# 										filtering_var,
	# 										filtering_value)
	# 			list2env(modified_datasets, envir = .GlobalEnv)
	# 	}
