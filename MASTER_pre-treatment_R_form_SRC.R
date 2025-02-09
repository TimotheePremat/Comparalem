#Script to process comparison of orthographic forms
#Finds common lemma in two datasets (extracted from TXM or other sources), one with one orthographic variant and the other without it. Can be adapted for more than two datasets.
#Timothée Premat | 2022-11-18

source("Packages.R") #Same as MASTER_R_form_distrib_txt_SRC.R

##Define the variable you want to investigate, in order to maintain traceability
my_var <- readline(prompt="Enter the prefix to name the files: ")
cat1_name <- readline(prompt="Enter name for first category:")
cat2_name <- readline(prompt="Enter name for second category:")
lemma_var <- readline(prompt="Enter the name of the lemma var to use:")

#Chose one of the following depending on wether you need to filter by gender
#and number, and by case
source("pre-treatment_R_form_SRC.R")
source("pre-treatment_R_form_SRC_gender_filtered.R")
source("pre-treatment_R_form_SRC_case_filtered.R")
