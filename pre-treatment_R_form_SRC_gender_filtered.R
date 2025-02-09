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

source("AA_filter_gender.R")

POS_E_masc_sg$Duplicated <- POS_E_masc_sg$lemma %in% POS_nonE_masc_sg$lemma
POS_E_masc_pl$Duplicated <- POS_E_masc_pl$lemma %in% POS_nonE_masc_pl$lemma
POS_E_femi_sg$Duplicated <- POS_E_femi_sg$lemma %in% POS_nonE_femi_sg$lemma
POS_E_femi_pl$Duplicated <- POS_E_femi_pl$lemma %in% POS_nonE_femi_pl$lemma

POS_E_masc_sg_duplicated <- POS_E_masc_sg %>% filter(Duplicated=='TRUE')
POS_E_masc_pl_duplicated <- POS_E_masc_pl %>% filter(Duplicated=='TRUE')
POS_E_femi_sg_duplicated <- POS_E_femi_sg %>% filter(Duplicated=='TRUE')
POS_E_femi_pl_duplicated <- POS_E_femi_pl %>% filter(Duplicated=='TRUE')

POS_E_masc_sg_freq <- POS_E_masc_sg_duplicated %>% count(lemma, sort=TRUE)
POS_E_masc_pl_freq <- POS_E_masc_pl_duplicated %>% count(lemma, sort=TRUE)
POS_E_femi_sg_freq <- POS_E_femi_sg_duplicated %>% count(lemma, sort=TRUE)
POS_E_femi_pl_freq <- POS_E_femi_pl_duplicated %>% count(lemma, sort=TRUE)


POS_nonE_masc_sg$Duplicated <- POS_nonE_masc_sg$lemma %in% POS_E_masc_sg$lemma
POS_nonE_masc_pl$Duplicated <- POS_nonE_masc_pl$lemma %in% POS_E_masc_pl$lemma
POS_nonE_femi_sg$Duplicated <- POS_nonE_femi_sg$lemma %in% POS_E_femi_sg$lemma
POS_nonE_femi_pl$Duplicated <- POS_nonE_femi_pl$lemma %in% POS_E_femi_pl$lemma

POS_nonE_masc_sg_duplicated <- POS_nonE_masc_sg %>% filter(Duplicated=='TRUE')
POS_nonE_masc_pl_duplicated <- POS_nonE_masc_pl %>% filter(Duplicated=='TRUE')
POS_nonE_femi_sg_duplicated <- POS_nonE_femi_sg %>% filter(Duplicated=='TRUE')
POS_nonE_femi_pl_duplicated <- POS_nonE_femi_pl %>% filter(Duplicated=='TRUE')

POS_nonE_masc_sg_freq <- POS_nonE_masc_sg_duplicated %>% count(lemma, sort=TRUE)
POS_nonE_masc_pl_freq <- POS_nonE_masc_pl_duplicated %>% count(lemma, sort=TRUE)
POS_nonE_femi_sg_freq <- POS_nonE_femi_sg_duplicated %>% count(lemma, sort=TRUE)
POS_nonE_femi_pl_freq <- POS_nonE_femi_pl_duplicated %>% count(lemma, sort=TRUE)


POS_masc_sg_merged_freq <- merge (POS_E_masc_sg_freq, POS_nonE_masc_sg_freq, by="lemma")
POS_masc_pl_merged_freq <- merge (POS_E_masc_pl_freq, POS_nonE_masc_pl_freq, by="lemma")
POS_femi_sg_merged_freq <- merge (POS_E_femi_sg_freq, POS_nonE_femi_sg_freq, by="lemma")
POS_femi_pl_merged_freq <- merge (POS_E_femi_pl_freq, POS_nonE_femi_pl_freq, by="lemma")

#Export
##merged file for later computation
write_xlsx(POS_masc_sg_merged_freq,path=paste("Data/pre-treatment/R",my_var,"masc_sg merged freq.xlsx"))
write_xlsx(POS_masc_pl_merged_freq,path=paste("Data/pre-treatment/R",my_var,"masc_pl merged freq.xlsx"))
write_xlsx(POS_femi_sg_merged_freq,path=paste("Data/pre-treatment/R",my_var,"femi_sg merged freq.xlsx"))
write_xlsx(POS_femi_pl_merged_freq,path=paste("Data/pre-treatment/R",my_var,"femi_pl merged freq.xlsx"))

##Junk files: contains informations not necessarily needed
write_xlsx(POS_E_masc_sg,path=paste("Data/pre-treatment/junk/R",my_var,"E masc_sg.xlsx"))
write_xlsx(POS_E_masc_pl,path=paste("Data/pre-treatment/junk/R",my_var,"E masc_pl.xlsx"))
write_xlsx(POS_E_femi_sg,path=paste("Data/pre-treatment/junk/R",my_var,"E femi_sg.xlsx"))
write_xlsx(POS_E_femi_pl,path=paste("Data/pre-treatment/junk/R",my_var,"E femi_pl.xlsx"))

write_xlsx(POS_nonE_masc_sg,path=paste("Data/pre-treatment/junk/R",my_var,"nonE masc_sg.xlsx"))
write_xlsx(POS_nonE_masc_pl,path=paste("Data/pre-treatment/junk/R",my_var,"nonE masc_pl.xlsx"))
write_xlsx(POS_nonE_femi_sg,path=paste("Data/pre-treatment/junk/R",my_var,"nonE femi_sg.xlsx"))
write_xlsx(POS_nonE_femi_pl,path=paste("Data/pre-treatment/junk/R",my_var,"nonE femi_pl.xlsx"))


write_xlsx(POS_E_masc_sg_duplicated,path=paste("Data/pre-treatment/junk/R",my_var,"E masc_sg_duplicated.xlsx"))
write_xlsx(POS_E_masc_pl_duplicated,path=paste("Data/pre-treatment/junk/R",my_var,"E masc_pl_duplicated.xlsx"))
write_xlsx(POS_E_femi_sg_duplicated,path=paste("Data/pre-treatment/junk/R",my_var,"E femi_sg_duplicated.xlsx"))
write_xlsx(POS_E_femi_pl_duplicated,path=paste("Data/pre-treatment/junk/R",my_var,"E femi_pl_duplicated.xlsx"))

write_xlsx(POS_nonE_masc_sg_duplicated,path=paste("Data/pre-treatment/junk/R",my_var,"nonE masc_sg_duplicated.xlsx"))
write_xlsx(POS_nonE_masc_pl_duplicated,path=paste("Data/pre-treatment/junk/R",my_var,"nonE masc_pl_duplicated.xlsx"))
write_xlsx(POS_nonE_femi_sg_duplicated,path=paste("Data/pre-treatment/junk/R",my_var,"nonE femi_sg_duplicated.xlsx"))
write_xlsx(POS_nonE_femi_pl_duplicated,path=paste("Data/pre-treatment/junk/R",my_var,"nonE femi_pl_duplicated.xlsx"))


write_xlsx(POS_E_masc_sg_freq,path=paste("Data/pre-treatment/junk/R",my_var,"E masc_sg_freq.xlsx"))
write_xlsx(POS_E_masc_pl_freq,path=paste("Data/pre-treatment/junk/R",my_var,"E masc_pl_freq.xlsx"))
write_xlsx(POS_E_femi_sg_freq,path=paste("Data/pre-treatment/junk/R",my_var,"E femi_sg_freq.xlsx"))
write_xlsx(POS_E_femi_pl_freq,path=paste("Data/pre-treatment/junk/R",my_var,"E femi_pl_freq.xlsx"))

write_xlsx(POS_nonE_masc_sg_freq,path=paste("Data/pre-treatment/junk/R",my_var,"nonE masc_sg_freq.xlsx"))
write_xlsx(POS_nonE_masc_pl_freq,path=paste("Data/pre-treatment/junk/R",my_var,"nonE masc_pl_freq.xlsx"))
write_xlsx(POS_nonE_femi_sg_freq,path=paste("Data/pre-treatment/junk/R",my_var,"nonE femi_sg_freq.xlsx"))
write_xlsx(POS_nonE_femi_pl_freq,path=paste("Data/pre-treatment/junk/R",my_var,"nonE femi_pl_freq.xlsx"))
