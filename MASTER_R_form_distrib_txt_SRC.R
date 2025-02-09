#Run first
source("Packages.R") #At first run, this can take some time (installing all packages needed)
source("Symbols.R")
source("Variables.R")
source("Functions.R")
source("ComparaHelp.R")

# word_keeper <- readline(prompt="Enter one or several (space-separated) words you want to keep: ")
# word_excluder <- readline(prompt="Enter one (or a vector of) word (form) you want to exclude: ")
#See A4_Filter in R.R script for directives on how to use this

source("1_import_data.R")
source("2_post_cleaning.R") #Filter by lemmas having variation.
	#Can be by-passed (if all forms are considered the same lemma) by calling instead
	#the following dummy script:
	source("2bis_fake_cleaning.R") #For testing: re-initiate data to start state
source("3_filtering_by_token_non_contextual.R") #Can be by-passed if not needed: doesn't change variables' name.
                                                #Filter out tokens (form + ID text and occurrence)
source("4_filter_dates.R") #Cannot be by-passed: indicates standard date variable
source("4_filter_custom.R") #Can be by-passed: filter data based on custom criteria
source("5_diachro_plot.R")
source("5_diachro_plot_subsets.R")
  #outputs: plot1 AND plot1_weighted AND MAYBE plot2
source("6_regression_analysis.R")
  #Outputs: glm_sum, glm_plot_accuracy, glm_plot_estimate
source("7_carto_master.R")
source("7_save_outputs.R")


#----------------------------------
#For maps by periods
#----------------------------------
#This work with any contextual analysis above. Run it after you've run an A5_diachro_plot script.
#If you want custom periods, run the following lines:
 bound_1b <- readline(prompt="Whats the top boundary of the first period?")
 bound_2a <- readline(prompt="Whats the bottom boundary of the second period?")
 bound_2b <- readline(prompt="Whats the top boundary of the second period?")
 bound_3a <- readline(prompt="Whats the bottom boundary of the third period?")
 bound_3b <- readline(prompt="Whats the top boundary of the third period?")
 bound_4a <- readline(prompt="Whats the bottom boundary of the last period?")
#If you want half century periods, run the following lines:
 bound_1b <- 1151
 bound_2a <- 1150
 bound_2b <- 1201
 bound_3a <- 1200
 bound_3b <- 1251
 bound_4a <- 1250
source("A8bis_carto_time.R")
source("A8bis_carto_time_save.R")

 #----------------------------------
 #Notes for easy access
 #----------------------------------
 View(POS_EnonE_count)
    mean(POS_EnonE_count$Tx_POS_nonE)
    min(POS_EnonE_count$Tx_POS_nonE)
    max(POS_EnonE_count$Tx_POS_nonE)
 #View(POS__V)
 #View(POS__C)
 View(POS_nonE_V_cleaned)
 View(POS_nonE_C_cleaned)
 View(POS_E_V_cleaned)
 View(POS_E_C_cleaned)

 #To see Pearson correlation coefficient pour #C and #V series of the current dataset:
 POS__C_corr
  POS__C_w_corr
 POS__V_corr
  POS__V_w_corr
