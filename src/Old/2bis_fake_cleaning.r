# Dummy script to by-pass 2_post_cleaning.R for first run (the one that allows
# you to clean). All lemmas from the original data are kept, including
# non redundant ones (ones that do not have variation).

Data_cat1_cleaned <- Data_cat1
Data_cat2_cleaned <- Data_cat2

#Rewrite Data_all, needed for tests and harmless
Data_all <- bind_rows(Data_cat1, Data_cat2)
