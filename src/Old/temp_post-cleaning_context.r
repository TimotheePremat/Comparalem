#Chose your exploratory file
relevant_forms <- file.choose(new = FALSE)
list <- read_excel(relevant_forms, sheet = "Feuil2")

Cat1_critB_cleaned <- Cat1_critB %>%
  filter(lemma %in% list$lemma)
Cat1_critA_cleaned <- Cat1_critA %>%
  filter(lemma %in% list$lemma)
Cat2_critA_cleaned <- Cat2_critA %>%
  filter(lemma %in% list$lemma)
Cat2_critB_cleaned <- Cat2_critB %>%
  filter(lemma %in% list$lemma)
# POS_EC_V_cleaned <- POS_EC_V %>%
#   filter(lemma %in% list$lemma)
# POS_EC_C_cleaned <- POS_EC_C %>%
#   filter(lemma %in% list$lemma)

# #TRASH/OLDIES
#
# list_NOM <- read_excel("Data/NOM_merged_custom.xlsx", sheet = "Feuil3")
# list_ADV <- read_excel("Data/ADV_merged_custom.xlsx", sheet = "Feuil2")
#
# NOM_E_cleaned <- NOM_E %>%
#   filter(lemma %in% list_NOM$lemma)
#
# NOM_nonE_cleaned <- NOM_nonE %>%
# 		filter(lemma %in% list_NOM$lemma)
#
# ADV_E_cleaned <- ADV_E %>%
# 		filter(lemma %in% list_ADV$lemma)
#
# ADV_nonE_cleaned <- ADV_nonE %>%
# 		filter(lemma %in% list_ADV$lemma)
#
# ADV_EC_V_cleaned <- ADV_EC_V %>%
# 		filter(lemma %in% list_ADV$lemma)
# ADV_EC_C_cleaned <- ADV_EC_C %>%
# 		filter(lemma %in% list_ADV$lemma)
# ADV_E_V_cleaned <- ADV_E_V %>%
# 		filter(lemma %in% list_ADV$lemma)
# ADV_E_C_cleaned <- ADV_E_C %>%
# 		filter(lemma %in% list_ADV$lemma)
# ADV_nonE_C_cleaned <- ADV_nonE_C %>%
# 		filter(lemma %in% list_ADV$lemma)
# ADV_nonE_V_cleaned <- ADV_nonE_V %>%
# 		filter(lemma %in% list_ADV$lemma)
