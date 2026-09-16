# Variables naming

# Data categories
## Comparalem compares two or four categories of data. They are represented
## in the script by the dummy names 'cat2_1', 'cat2_2' and 'cat_4_1',
## 'cat_4_2', 'cat_4_3', 'cat_4_4'. Here, the user is asked to provide better
## name for them (with semantic content). If not, results to default.
## The following lines ask (interactively) the user to enter custom name.
cat2_1 <- get_string_input(
		label_text = "Enter name of 1st data category (2 cat. analysis): ",
		paragraph_text = "Typically, this is the winning category (the variant that increases over time).")
cat2_2 <- get_string_input(label_text = "Enter name of 2nd data category (2 cat. analysis): ",
paragraph_text = "Typically, this is the losing category (the variant that decreases over time).")
# cat4_1 <- readline(prompt="Enter name of 1st data category (4 cat. analysis): ")
# cat4_2 <- readline(prompt="Enter name of 2nd data category (4 cat. analysis): ")
# cat4_3 <- readline(prompt="Enter name of 3rd data category (4 cat. analysis): ")
# cat4_4 <- readline(prompt="Enter name of 4th data category (4 cat. analysis): ")
### For instance, in studying -e/-Ø (=nonE) alternation in adverbs:
#### cat2_1 = "E_non_contextual"
#### cat2_2 = "nonE_non_contextual"
#### cat4_1 = "E_before_V"
#### cat4_2 = "nonE_before_C"
#### cat4_3 = "E_before_V"
#### cat4_4 = "nonE_before_C"
## This does not change anything to the script, but allows the user to know
## which type of file to import at which time.

# If no name is provided, results to default.
if (is.null(cat2_1) || cat2_1 == "")
	{
    	cat2_1 <- "cat1(2.1)"  # Set default name if var_name is NULL
  	}
if (is.null(cat2_2) || cat2_2 == "")
	{
    	cat2_2 <- "cat2(2.2)"  # Set default name if var_name is NULL
  	}
# if (is.null(cat4_1) || cat4_1 == "")
# 	{
#     	cat4_1 <- "cat1(4.1)"  # Set default name if var_name is NULL
#   	}
# if (is.null(cat4_2) || cat4_2 == "")
# 	{
#     	cat4_2 <- "cat2(4.2)"  # Set default name if var_name is NULL
#   	}
# if (is.null(cat4_3) || cat4_3 == "")
# 	{
#     	cat4_3 <- "cat3(4.3)"  # Set default name if var_name is NULL
#   	}
# if (is.null(cat4_4) || cat4_4 == "")
# 	{
#     	cat4_3 <- "cat4(4.4)"  # Set default name if var_name is NULL
#   	}

# Variables for file naming and titles and legends
## Comparalem uses dummy variable names for filename, titles, etc.
## The following lines ask (interactively) the user to enter custom name.
file_name <- get_string_input(label_text = "Enter prefix for naming files")
title_element <- get_string_input(label_text = "Enter name for titles and legends:")
### Both corresponds to the linguistic category studied, and/or to the
### dependant variable. For instance, in studied -e/-Ø alternation in adverbs,
### it could be something like:
### file_name = "Schwa_Zero_ADV"
### title_element = "Variation -e/-Ø in Adverbs"
dependent_var <- get_string_input(label_text = "Enter the name of your dependent variable (for legends):")
corpus_var <- get_string_input(label_text = "Enter the name (and ref, optionnaly) of the corpus you use:")

# If no name is provided, results to default.
if (is.null(file_name) || file_name == "")
	{
    	file_name <- "FILE"  # Set default name if var_name is NULL
  	}

## Default for title_element is file_name
if (is.null(title_element) || title_element == "")
	{
    	title_element <- file_name  # Set default name if var_name is NULL
  	}
