# Choose the files to investigate
## Either two files for general comparison, or more than two if working with contexts
## First step is to ask the user to assign a file to the var POS_E and POS_nonE
Cat1_critA_file <- file.choose(new = FALSE)
Cat1_critB_file <- file.choose(new = FALSE)
Cat2_critA_file <- file.choose(new = FALSE)
Cat2_critB_file <- file.choose(new = FALSE)
# POS_EC_C_file <- file.choose(new = FALSE)
# POS_EC_V_file <- file.choose(new = FALSE)

## Second step is to read that file as a CSV file
Cat1_critA_df <- read_delim(Cat1_critA_file, delim = ";", escape_double = FALSE, trim_ws = TRUE)
Cat1_critB_df <- read_delim(Cat1_critB_file, delim = ";", escape_double = FALSE, trim_ws = TRUE)
Cat2_critA_df <- read_delim(Cat2_critA_file, delim = ";", escape_double = FALSE, trim_ws = TRUE)
Cat2_critB_df <- read_delim(Cat2_critB_file, delim = ";", escape_double = FALSE, trim_ws = TRUE)
# POS_EC_C_df <- read_delim(POS_EC_C_file, delim = ";", escape_double = FALSE, trim_ws = TRUE)
# POS_EC_V_df <- read_delim(POS_EC_V_file, delim = ";", escape_double = FALSE, trim_ws = TRUE)

## Load texts' meta-data
Dates_NCA <- read_excel("../Data/Dates_NCA.xlsx", sheet = "data_basic")

Dates_NCA <- Dates_NCA %>% rename(datecomposition = dateComposition) %>%
    rename(datemanuscrit = dateManuscrit) %>%
    rename(lieucomposition = lieuComposition) %>%
    rename(lieumanuscrit = lieuManuscrit) %>%
    rename(datemoyennedees = dateMoyenneDees)

### Merge to incorporate text metadata in the list of forms
Cat1_critB <- merge (Cat1_critB_df, Dates_NCA, by="id")
Cat1_critA <- merge (Cat1_critA_df, Dates_NCA, by="id")
Cat2_critA <- merge (Cat2_critA_df, Dates_NCA, by="id")
Cat2_critB <- merge (Cat2_critB_df, Dates_NCA, by="id")

#Transform frequency table to observation table
## Instead of having some observations in the same row (when same page or line
   #ref) with frequency indication, duplicate these rows (by factor F) and
   #remove column F. Needed to get the right frequencies with the code below.
Cat1_critB <- uncount(Cat1_critB, weights=F)
Cat1_critA <- uncount(Cat1_critA, weights=F)
Cat2_critA <- uncount(Cat2_critA, weights=F)
Cat2_critB <- uncount(Cat2_critB, weights=F)
# POS_EC_V <- uncount(POS_EC_V, weights=F)
# POS_EC_C <- uncount(POS_EC_C, weights=F)
