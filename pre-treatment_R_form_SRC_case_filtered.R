#Script to process comparison of orthographic forms
#Finds common lemma in two datasets (extracted from TXM or other sources), one with one orthographic variant and the other without it. Can be adapted for more than two datasets.
#Timothée Premat | 2022-11-18

library('readxl')
library('readr')
library('dplyr')
library('tidyverse')
library('ggplot2')
library('writexl')
library('stringr')
library('ggpubr')

#Choose the files to investigate
##Either two files for general comparison, or more than two if working with contexts
##First step is to ask the user to assign a file to the var POS_E and POS_nonE
POS_E_file <- file.choose(new = FALSE)
POS_nonE_file <- file.choose(new = FALSE)

##Second step is to read that file as a CSV file
POS_E <- read_delim(POS_E_file, delim = ";", escape_double = FALSE, trim_ws = TRUE)
POS_nonE <- read_delim(POS_nonE_file, delim = ";", escape_double = FALSE, trim_ws = TRUE)

POS_E <- POS_E %>% mutate(lemma = replace(lemma, lemma == "ele-il", "il"))

##Load texts' meta-data
Dates_NCA <- read_excel("Data/Dates_NCA.xlsx", sheet = "Small_caps")

###Merge to incorporate text metadata in the list of forms
POS_E <- merge (POS_E, Dates_NCA, by="id")
POS_nonE <- merge (POS_nonE, Dates_NCA, by="id")

#Transform frequency table to observation table
## Instead of having some observations in the same row (when same page or line
   #ref) with frequency indication, duplicate these rows (by factor F) and
   #remove column F. Needed to get the right frequencies with the code below.
POS_E <- uncount(POS_E, weights=F)
POS_nonE <- uncount(POS_nonE, weights=F)

#Filtering by gender, number and case is done by calling the following script:
source('AA_filter_case.R')

##Transform, for <e>/Ø detection, data based on gender, number and case
###For E
POS_E_masc_sg_suj$Duplicated <- POS_E_masc_sg_suj$lemma %in% POS_nonE_masc_sg_suj$lemma
POS_E_masc_sg_acc$Duplicated <- POS_E_masc_sg_acc$lemma %in% POS_nonE_masc_sg_acc$lemma
POS_E_masc_sg_dat$Duplicated <- POS_E_masc_sg_dat$lemma %in% POS_nonE_masc_sg_dat$lemma
POS_E_masc_pl_suj$Duplicated <- POS_E_masc_pl_suj$lemma %in% POS_nonE_masc_pl_suj$lemma
POS_E_masc_pl_acc$Duplicated <- POS_E_masc_pl_acc$lemma %in% POS_nonE_masc_pl_acc$lemma
POS_E_masc_pl_dat$Duplicated <- POS_E_masc_pl_dat$lemma %in% POS_nonE_masc_pl_dat$lemma
POS_E_femi_sg_suj$Duplicated <- POS_E_femi_sg_suj$lemma %in% POS_nonE_femi_sg_suj$lemma
POS_E_femi_sg_acc$Duplicated <- POS_E_femi_sg_acc$lemma %in% POS_nonE_femi_sg_acc$lemma
POS_E_femi_sg_dat$Duplicated <- POS_E_femi_sg_dat$lemma %in% POS_nonE_femi_sg_dat$lemma
POS_E_femi_pl_suj$Duplicated <- POS_E_femi_pl_suj$lemma %in% POS_nonE_femi_pl_suj$lemma
POS_E_femi_pl_acc$Duplicated <- POS_E_femi_pl_acc$lemma %in% POS_nonE_femi_pl_acc$lemma
POS_E_femi_pl_dat$Duplicated <- POS_E_femi_pl_dat$lemma %in% POS_nonE_femi_pl_dat$lemma

POS_E_masc_sg_suj_duplicated <- POS_E_masc_sg_suj %>% filter(Duplicated=='TRUE')
POS_E_masc_sg_acc_duplicated <- POS_E_masc_sg_acc %>% filter(Duplicated=='TRUE')
POS_E_masc_sg_dat_duplicated <- POS_E_masc_sg_dat %>% filter(Duplicated=='TRUE')
POS_E_masc_pl_suj_duplicated <- POS_E_masc_pl_suj %>% filter(Duplicated=='TRUE')
POS_E_masc_pl_acc_duplicated <- POS_E_masc_pl_acc %>% filter(Duplicated=='TRUE')
POS_E_masc_pl_dat_duplicated <- POS_E_masc_pl_dat %>% filter(Duplicated=='TRUE')
POS_E_femi_sg_suj_duplicated <- POS_E_femi_sg_suj %>% filter(Duplicated=='TRUE')
POS_E_femi_sg_acc_duplicated <- POS_E_femi_sg_acc %>% filter(Duplicated=='TRUE')
POS_E_femi_sg_dat_duplicated <- POS_E_femi_sg_dat %>% filter(Duplicated=='TRUE')
POS_E_femi_pl_suj_duplicated <- POS_E_femi_pl_suj %>% filter(Duplicated=='TRUE')
POS_E_femi_pl_acc_duplicated <- POS_E_femi_pl_acc %>% filter(Duplicated=='TRUE')
POS_E_femi_pl_dat_duplicated <- POS_E_femi_pl_dat %>% filter(Duplicated=='TRUE')

POS_E_masc_sg_suj_freq <- POS_E_masc_sg_suj_duplicated %>% count(lemma, sort=TRUE)
POS_E_masc_sg_acc_freq <- POS_E_masc_sg_acc_duplicated %>% count(lemma, sort=TRUE)
POS_E_masc_sg_dat_freq <- POS_E_masc_sg_dat_duplicated %>% count(lemma, sort=TRUE)
POS_E_masc_pl_suj_freq <- POS_E_masc_pl_suj_duplicated %>% count(lemma, sort=TRUE)
POS_E_masc_pl_acc_freq <- POS_E_masc_pl_acc_duplicated %>% count(lemma, sort=TRUE)
POS_E_masc_pl_dat_freq <- POS_E_masc_pl_dat_duplicated %>% count(lemma, sort=TRUE)
POS_E_femi_sg_suj_freq <- POS_E_femi_sg_suj_duplicated %>% count(lemma, sort=TRUE)
POS_E_femi_sg_acc_freq <- POS_E_femi_sg_acc_duplicated %>% count(lemma, sort=TRUE)
POS_E_femi_sg_dat_freq <- POS_E_femi_sg_dat_duplicated %>% count(lemma, sort=TRUE)
POS_E_femi_pl_suj_freq <- POS_E_femi_pl_suj_duplicated %>% count(lemma, sort=TRUE)
POS_E_femi_pl_acc_freq <- POS_E_femi_pl_acc_duplicated %>% count(lemma, sort=TRUE)
POS_E_femi_pl_dat_freq <- POS_E_femi_pl_dat_duplicated %>% count(lemma, sort=TRUE)

###For nonE
POS_nonE_masc_sg_suj$Duplicated <- POS_nonE_masc_sg_suj$lemma %in% POS_E_masc_sg_suj$lemma
POS_nonE_masc_sg_acc$Duplicated <- POS_nonE_masc_sg_acc$lemma %in% POS_E_masc_sg_acc$lemma
POS_nonE_masc_sg_dat$Duplicated <- POS_nonE_masc_sg_dat$lemma %in% POS_E_masc_sg_dat$lemma
POS_nonE_masc_pl_suj$Duplicated <- POS_nonE_masc_pl_suj$lemma %in% POS_E_masc_pl_suj$lemma
POS_nonE_masc_pl_acc$Duplicated <- POS_nonE_masc_pl_acc$lemma %in% POS_E_masc_pl_acc$lemma
POS_nonE_masc_pl_dat$Duplicated <- POS_nonE_masc_pl_dat$lemma %in% POS_E_masc_pl_dat$lemma
POS_nonE_femi_sg_suj$Duplicated <- POS_nonE_femi_sg_suj$lemma %in% POS_E_femi_sg_suj$lemma
POS_nonE_femi_sg_acc$Duplicated <- POS_nonE_femi_sg_acc$lemma %in% POS_E_femi_sg_acc$lemma
POS_nonE_femi_sg_dat$Duplicated <- POS_nonE_femi_sg_dat$lemma %in% POS_E_femi_sg_dat$lemma
POS_nonE_femi_pl_suj$Duplicated <- POS_nonE_femi_pl_suj$lemma %in% POS_E_femi_pl_suj$lemma
POS_nonE_femi_pl_acc$Duplicated <- POS_nonE_femi_pl_acc$lemma %in% POS_E_femi_pl_acc$lemma
POS_nonE_femi_pl_dat$Duplicated <- POS_nonE_femi_pl_dat$lemma %in% POS_E_femi_pl_dat$lemma

POS_nonE_masc_sg_suj_duplicated <- POS_nonE_masc_sg_suj %>% filter(Duplicated=='TRUE')
POS_nonE_masc_sg_acc_duplicated <- POS_nonE_masc_sg_acc %>% filter(Duplicated=='TRUE')
POS_nonE_masc_sg_dat_duplicated <- POS_nonE_masc_sg_dat %>% filter(Duplicated=='TRUE')
POS_nonE_masc_pl_suj_duplicated <- POS_nonE_masc_pl_suj %>% filter(Duplicated=='TRUE')
POS_nonE_masc_pl_acc_duplicated <- POS_nonE_masc_pl_acc %>% filter(Duplicated=='TRUE')
POS_nonE_masc_pl_dat_duplicated <- POS_nonE_masc_pl_dat %>% filter(Duplicated=='TRUE')
POS_nonE_femi_sg_suj_duplicated <- POS_nonE_femi_sg_suj %>% filter(Duplicated=='TRUE')
POS_nonE_femi_sg_acc_duplicated <- POS_nonE_femi_sg_acc %>% filter(Duplicated=='TRUE')
POS_nonE_femi_sg_dat_duplicated <- POS_nonE_femi_sg_dat %>% filter(Duplicated=='TRUE')
POS_nonE_femi_pl_suj_duplicated <- POS_nonE_femi_pl_suj %>% filter(Duplicated=='TRUE')
POS_nonE_femi_pl_acc_duplicated <- POS_nonE_femi_pl_acc %>% filter(Duplicated=='TRUE')
POS_nonE_femi_pl_dat_duplicated <- POS_nonE_femi_pl_dat %>% filter(Duplicated=='TRUE')

POS_nonE_masc_sg_suj_freq <- POS_nonE_masc_sg_suj_duplicated %>% count(lemma, sort=TRUE)
POS_nonE_masc_sg_acc_freq <- POS_nonE_masc_sg_acc_duplicated %>% count(lemma, sort=TRUE)
POS_nonE_masc_sg_dat_freq <- POS_nonE_masc_sg_dat_duplicated %>% count(lemma, sort=TRUE)
POS_nonE_masc_pl_suj_freq <- POS_nonE_masc_pl_suj_duplicated %>% count(lemma, sort=TRUE)
POS_nonE_masc_pl_acc_freq <- POS_nonE_masc_pl_acc_duplicated %>% count(lemma, sort=TRUE)
POS_nonE_masc_pl_dat_freq <- POS_nonE_masc_pl_dat_duplicated %>% count(lemma, sort=TRUE)
POS_nonE_femi_sg_suj_freq <- POS_nonE_femi_sg_suj_duplicated %>% count(lemma, sort=TRUE)
POS_nonE_femi_sg_acc_freq <- POS_nonE_femi_sg_acc_duplicated %>% count(lemma, sort=TRUE)
POS_nonE_femi_sg_dat_freq <- POS_nonE_femi_sg_dat_duplicated %>% count(lemma, sort=TRUE)
POS_nonE_femi_pl_suj_freq <- POS_nonE_femi_pl_suj_duplicated %>% count(lemma, sort=TRUE)
POS_nonE_femi_pl_acc_freq <- POS_nonE_femi_pl_acc_duplicated %>% count(lemma, sort=TRUE)
POS_nonE_femi_pl_dat_freq <- POS_nonE_femi_pl_dat_duplicated %>% count(lemma, sort=TRUE)

##Merge E and nonE
POS_masc_sg_suj_merged_freq <- merge (POS_E_masc_sg_suj_freq, POS_nonE_masc_sg_suj_freq, by="lemma")
POS_masc_sg_acc_merged_freq <- merge (POS_E_masc_sg_acc_freq, POS_nonE_masc_sg_acc_freq, by="lemma")
POS_masc_sg_dat_merged_freq <- merge (POS_E_masc_sg_dat_freq, POS_nonE_masc_sg_dat_freq, by="lemma")
POS_masc_pl_suj_merged_freq <- merge (POS_E_masc_pl_suj_freq, POS_nonE_masc_pl_suj_freq, by="lemma")
POS_masc_pl_acc_merged_freq <- merge (POS_E_masc_pl_acc_freq, POS_nonE_masc_pl_acc_freq, by="lemma")
POS_masc_pl_dat_merged_freq <- merge (POS_E_masc_pl_dat_freq, POS_nonE_masc_pl_dat_freq, by="lemma")
POS_femi_sg_suj_merged_freq <- merge (POS_E_femi_sg_suj_freq, POS_nonE_femi_sg_suj_freq, by="lemma")
POS_femi_sg_acc_merged_freq <- merge (POS_E_femi_sg_acc_freq, POS_nonE_femi_sg_acc_freq, by="lemma")
POS_femi_sg_dat_merged_freq <- merge (POS_E_femi_sg_dat_freq, POS_nonE_femi_sg_dat_freq, by="lemma")
POS_femi_pl_suj_merged_freq <- merge (POS_E_femi_pl_suj_freq, POS_nonE_femi_pl_suj_freq, by="lemma")
POS_femi_pl_acc_merged_freq <- merge (POS_E_femi_pl_acc_freq, POS_nonE_femi_pl_acc_freq, by="lemma")
POS_femi_pl_dat_merged_freq <- merge (POS_E_femi_pl_dat_freq, POS_nonE_femi_pl_dat_freq, by="lemma")

#Export
##merged file for later computation
write_xlsx(POS_masc_sg_suj_merged_freq,path=paste("Data/pre-treatment/R",my_var,"masc_sg_suj merged freq.xlsx"))
write_xlsx(POS_masc_sg_acc_merged_freq,path=paste("Data/pre-treatment/R",my_var,"masc_sg_acc merged freq.xlsx"))
write_xlsx(POS_masc_sg_dat_merged_freq,path=paste("Data/pre-treatment/R",my_var,"masc_sg_dat merged freq.xlsx"))
write_xlsx(POS_masc_pl_suj_merged_freq,path=paste("Data/pre-treatment/R",my_var,"masc_pl_suj merged freq.xlsx"))
write_xlsx(POS_masc_pl_acc_merged_freq,path=paste("Data/pre-treatment/R",my_var,"masc_pl_acc merged freq.xlsx"))
write_xlsx(POS_masc_pl_dat_merged_freq,path=paste("Data/pre-treatment/R",my_var,"masc_pl_dat merged freq.xlsx"))
write_xlsx(POS_femi_sg_suj_merged_freq,path=paste("Data/pre-treatment/R",my_var,"femi_sg_suj merged freq.xlsx"))
write_xlsx(POS_femi_sg_acc_merged_freq,path=paste("Data/pre-treatment/R",my_var,"femi_sg_acc merged freq.xlsx"))
write_xlsx(POS_femi_sg_dat_merged_freq,path=paste("Data/pre-treatment/R",my_var,"femi_sg_dat merged freq.xlsx"))
write_xlsx(POS_femi_pl_suj_merged_freq,path=paste("Data/pre-treatment/R",my_var,"femi_pl_suj merged freq.xlsx"))
write_xlsx(POS_femi_pl_acc_merged_freq,path=paste("Data/pre-treatment/R",my_var,"femi_pl_acc merged freq.xlsx"))
write_xlsx(POS_femi_pl_dat_merged_freq,path=paste("Data/pre-treatment/R",my_var,"femi_pl_dat merged freq.xlsx"))

##Junk files: contains informations not necessarily needed, but good for
##archiving and going back later to the data
### Non duplicated data
write_xlsx(POS_E_masc_sg_suj,path=paste("Data/pre-treatment/junk/R",my_var,"E masc_sg_suj.xlsx"))
write_xlsx(POS_E_masc_sg_acc,path=paste("Data/pre-treatment/junk/R",my_var,"E masc_sg_acc.xlsx"))
write_xlsx(POS_E_masc_sg_dat,path=paste("Data/pre-treatment/junk/R",my_var,"E masc_sg_dat.xlsx"))
write_xlsx(POS_E_masc_pl_suj,path=paste("Data/pre-treatment/junk/R",my_var,"E masc_pl_suj.xlsx"))
write_xlsx(POS_E_masc_pl_acc,path=paste("Data/pre-treatment/junk/R",my_var,"E masc_pl_acc.xlsx"))
write_xlsx(POS_E_masc_pl_dat,path=paste("Data/pre-treatment/junk/R",my_var,"E masc_pl_dat.xlsx"))
write_xlsx(POS_E_femi_sg_suj,path=paste("Data/pre-treatment/junk/R",my_var,"E femi_sg_suj.xlsx"))
write_xlsx(POS_E_femi_sg_acc,path=paste("Data/pre-treatment/junk/R",my_var,"E femi_sg_acc.xlsx"))
write_xlsx(POS_E_femi_sg_dat,path=paste("Data/pre-treatment/junk/R",my_var,"E femi_sg_dat.xlsx"))
write_xlsx(POS_E_femi_pl_suj,path=paste("Data/pre-treatment/junk/R",my_var,"E femi_pl_suj.xlsx"))
write_xlsx(POS_E_femi_pl_acc,path=paste("Data/pre-treatment/junk/R",my_var,"E femi_pl_acc.xlsx"))
write_xlsx(POS_E_femi_pl_dat,path=paste("Data/pre-treatment/junk/R",my_var,"E femi_pl_dat.xlsx"))

write_xlsx(POS_nonE_masc_sg_suj,path=paste("Data/pre-treatment/junk/R",my_var,"nonE masc_sg_suj.xlsx"))
write_xlsx(POS_nonE_masc_sg_acc,path=paste("Data/pre-treatment/junk/R",my_var,"nonE masc_sg_acc.xlsx"))
write_xlsx(POS_nonE_masc_sg_dat,path=paste("Data/pre-treatment/junk/R",my_var,"nonE masc_sg_dat.xlsx"))
write_xlsx(POS_nonE_masc_pl_suj,path=paste("Data/pre-treatment/junk/R",my_var,"nonE masc_pl_suj.xlsx"))
write_xlsx(POS_nonE_masc_pl_acc,path=paste("Data/pre-treatment/junk/R",my_var,"nonE masc_pl_acc.xlsx"))
write_xlsx(POS_nonE_masc_pl_dat,path=paste("Data/pre-treatment/junk/R",my_var,"nonE masc_pl_dat.xlsx"))
write_xlsx(POS_nonE_femi_sg_suj,path=paste("Data/pre-treatment/junk/R",my_var,"nonE femi_sg_suj.xlsx"))
write_xlsx(POS_nonE_femi_sg_acc,path=paste("Data/pre-treatment/junk/R",my_var,"nonE femi_sg_acc.xlsx"))
write_xlsx(POS_nonE_femi_sg_dat,path=paste("Data/pre-treatment/junk/R",my_var,"nonE femi_sg_dat.xlsx"))
write_xlsx(POS_nonE_femi_pl_suj,path=paste("Data/pre-treatment/junk/R",my_var,"nonE femi_pl_suj.xlsx"))
write_xlsx(POS_nonE_femi_pl_acc,path=paste("Data/pre-treatment/junk/R",my_var,"nonE femi_pl_acc.xlsx"))
write_xlsx(POS_nonE_femi_pl_dat,path=paste("Data/pre-treatment/junk/R",my_var,"nonE femi_pl_dat.xlsx"))

### Duplicated data
write_xlsx(POS_E_masc_sg_suj_duplicated,path=paste("Data/pre-treatment/junk/R",my_var,"E masc_sg_suj_duplicated.xlsx"))
write_xlsx(POS_E_masc_sg_acc_duplicated,path=paste("Data/pre-treatment/junk/R",my_var,"E masc_sg_acc_duplicated.xlsx"))
write_xlsx(POS_E_masc_sg_dat_duplicated,path=paste("Data/pre-treatment/junk/R",my_var,"E masc_sg_dat_duplicated.xlsx"))
write_xlsx(POS_E_masc_pl_suj_duplicated,path=paste("Data/pre-treatment/junk/R",my_var,"E masc_pl_suj_duplicated.xlsx"))
write_xlsx(POS_E_masc_pl_acc_duplicated,path=paste("Data/pre-treatment/junk/R",my_var,"E masc_pl_acc_duplicated.xlsx"))
write_xlsx(POS_E_masc_pl_dat_duplicated,path=paste("Data/pre-treatment/junk/R",my_var,"E masc_pl_dat_duplicated.xlsx"))
write_xlsx(POS_E_femi_sg_suj_duplicated,path=paste("Data/pre-treatment/junk/R",my_var,"E femi_sg_suj_duplicated.xlsx"))
write_xlsx(POS_E_femi_sg_acc_duplicated,path=paste("Data/pre-treatment/junk/R",my_var,"E femi_sg_acc_duplicated.xlsx"))
write_xlsx(POS_E_femi_sg_dat_duplicated,path=paste("Data/pre-treatment/junk/R",my_var,"E femi_sg_dat_duplicated.xlsx"))
write_xlsx(POS_E_femi_pl_suj_duplicated,path=paste("Data/pre-treatment/junk/R",my_var,"E femi_pl_suj_duplicated.xlsx"))
write_xlsx(POS_E_femi_pl_acc_duplicated,path=paste("Data/pre-treatment/junk/R",my_var,"E femi_pl_acc_duplicated.xlsx"))
write_xlsx(POS_E_femi_pl_dat_duplicated,path=paste("Data/pre-treatment/junk/R",my_var,"E femi_pl_dat_duplicated.xlsx"))

write_xlsx(POS_nonE_masc_sg_suj_duplicated,path=paste("Data/pre-treatment/junk/R",my_var,"nonE masc_sg_suj_duplicated.xlsx"))
write_xlsx(POS_nonE_masc_sg_acc_duplicated,path=paste("Data/pre-treatment/junk/R",my_var,"nonE masc_sg_acc_duplicated.xlsx"))
write_xlsx(POS_nonE_masc_sg_dat_duplicated,path=paste("Data/pre-treatment/junk/R",my_var,"nonE masc_sg_dat_duplicated.xlsx"))
write_xlsx(POS_nonE_masc_pl_suj_duplicated,path=paste("Data/pre-treatment/junk/R",my_var,"nonE masc_pl_suj_duplicated.xlsx"))
write_xlsx(POS_nonE_masc_pl_acc_duplicated,path=paste("Data/pre-treatment/junk/R",my_var,"nonE masc_pl_acc_duplicated.xlsx"))
write_xlsx(POS_nonE_masc_pl_dat_duplicated,path=paste("Data/pre-treatment/junk/R",my_var,"nonE masc_pl_dat_duplicated.xlsx"))
write_xlsx(POS_nonE_femi_sg_suj_duplicated,path=paste("Data/pre-treatment/junk/R",my_var,"nonE femi_sg_suj_duplicated.xlsx"))
write_xlsx(POS_nonE_femi_sg_acc_duplicated,path=paste("Data/pre-treatment/junk/R",my_var,"nonE femi_sg_acc_duplicated.xlsx"))
write_xlsx(POS_nonE_femi_sg_dat_duplicated,path=paste("Data/pre-treatment/junk/R",my_var,"nonE femi_sg_dat_duplicated.xlsx"))
write_xlsx(POS_nonE_femi_pl_suj_duplicated,path=paste("Data/pre-treatment/junk/R",my_var,"nonE femi_pl_suj_duplicated.xlsx"))
write_xlsx(POS_nonE_femi_pl_acc_duplicated,path=paste("Data/pre-treatment/junk/R",my_var,"nonE femi_pl_acc_duplicated.xlsx"))
write_xlsx(POS_nonE_femi_pl_dat_duplicated,path=paste("Data/pre-treatment/junk/R",my_var,"nonE femi_pl_dat_duplicated.xlsx"))

### Frequency data
write_xlsx(POS_E_masc_sg_suj_freq,path=paste("Data/pre-treatment/junk/R",my_var,"E masc_sg_suj_freq.xlsx"))
write_xlsx(POS_E_masc_sg_acc_freq,path=paste("Data/pre-treatment/junk/R",my_var,"E masc_sg_acc_freq.xlsx"))
write_xlsx(POS_E_masc_sg_dat_freq,path=paste("Data/pre-treatment/junk/R",my_var,"E masc_sg_dat_freq.xlsx"))
write_xlsx(POS_E_masc_pl_suj_freq,path=paste("Data/pre-treatment/junk/R",my_var,"E masc_pl_suj_freq.xlsx"))
write_xlsx(POS_E_masc_pl_acc_freq,path=paste("Data/pre-treatment/junk/R",my_var,"E masc_pl_acc_freq.xlsx"))
write_xlsx(POS_E_masc_pl_dat_freq,path=paste("Data/pre-treatment/junk/R",my_var,"E masc_pl_dat_freq.xlsx"))
write_xlsx(POS_E_femi_sg_suj_freq,path=paste("Data/pre-treatment/junk/R",my_var,"E femi_sg_suj_freq.xlsx"))
write_xlsx(POS_E_femi_sg_acc_freq,path=paste("Data/pre-treatment/junk/R",my_var,"E femi_sg_acc_freq.xlsx"))
write_xlsx(POS_E_femi_sg_dat_freq,path=paste("Data/pre-treatment/junk/R",my_var,"E femi_sg_dat_freq.xlsx"))
write_xlsx(POS_E_femi_pl_suj_freq,path=paste("Data/pre-treatment/junk/R",my_var,"E femi_pl_suj_freq.xlsx"))
write_xlsx(POS_E_femi_pl_acc_freq,path=paste("Data/pre-treatment/junk/R",my_var,"E femi_pl_acc_freq.xlsx"))
write_xlsx(POS_E_femi_pl_dat_freq,path=paste("Data/pre-treatment/junk/R",my_var,"E femi_pl_dat_freq.xlsx"))

write_xlsx(POS_nonE_masc_sg_suj_freq,path=paste("Data/pre-treatment/junk/R",my_var,"nonE masc_sg_suj_freq.xlsx"))
write_xlsx(POS_nonE_masc_sg_acc_freq,path=paste("Data/pre-treatment/junk/R",my_var,"nonE masc_sg_acc_freq.xlsx"))
write_xlsx(POS_nonE_masc_sg_dat_freq,path=paste("Data/pre-treatment/junk/R",my_var,"nonE masc_sg_dat_freq.xlsx"))
write_xlsx(POS_nonE_masc_pl_suj_freq,path=paste("Data/pre-treatment/junk/R",my_var,"nonE masc_pl_suj_freq.xlsx"))
write_xlsx(POS_nonE_masc_pl_acc_freq,path=paste("Data/pre-treatment/junk/R",my_var,"nonE masc_pl_acc_freq.xlsx"))
write_xlsx(POS_nonE_masc_pl_dat_freq,path=paste("Data/pre-treatment/junk/R",my_var,"nonE masc_pl_dat_freq.xlsx"))
write_xlsx(POS_nonE_femi_sg_suj_freq,path=paste("Data/pre-treatment/junk/R",my_var,"nonE femi_sg_suj_freq.xlsx"))
write_xlsx(POS_nonE_femi_sg_acc_freq,path=paste("Data/pre-treatment/junk/R",my_var,"nonE femi_sg_acc_freq.xlsx"))
write_xlsx(POS_nonE_femi_sg_dat_freq,path=paste("Data/pre-treatment/junk/R",my_var,"nonE femi_sg_dat_freq.xlsx"))
write_xlsx(POS_nonE_femi_pl_suj_freq,path=paste("Data/pre-treatment/junk/R",my_var,"nonE femi_pl_suj_freq.xlsx"))
write_xlsx(POS_nonE_femi_pl_acc_freq,path=paste("Data/pre-treatment/junk/R",my_var,"nonE femi_pl_acc_freq.xlsx"))
write_xlsx(POS_nonE_femi_pl_dat_freq,path=paste("Data/pre-treatment/junk/R",my_var,"nonE femi_pl_dat_freq.xlsx"))
