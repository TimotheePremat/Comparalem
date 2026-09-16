library(tidyverse)
library(mapsf)
library(sf)
library(janitor)

#-----------------------------------
# Functions
#-----------------------------------

data_for_carto_corpus <- function(data, group) {
  data %>%
    group_by(.data[[group]], `r_code_suppl_total`) %>%
    summarise(nb_txt = n(), .groups = "drop") %>%
    rename(R_Code = `r_code_suppl_total`)
}

make_map <- function(data, var, title, regions) {
  mf_export(
    data,
    filename = paste("../../Graphs/NCA_", var, "_map.png", sep=""),
    width    = 8,
    height   = 6,
    units    = "in",
    res      = 600
  )
  mf_map(
    x         = data,
    var       = "nb_txt",
    type      = "choro",
    leg_pos   = "topleft",
    leg_title = title,
    col_na    = "light gray",
    pal       = "Teal",
    add       = ,
	breaks	  = c(0,5,10,20,30,40,47)
  )
  mf_label(
  	x =  data %>% filter(.data[[regions]] != "Moselle-Meurthe-et-Moselle"),
  	var = regions,
  	col = "black",
  	cex = 0.6,
  	font = 4,
  	halo = TRUE,
  	bg = "white",
  	r = 0.1,
  	overlap = FALSE,
  	lines = FALSE,
  	adj = c(0.5,2)
  )
  # Only for Moselle label, moved to the left
	mf_label(
	  x = data %>% filter(.data[[regions]] == "Moselle-Meurthe-et-Moselle"),
	  var = regions,
	  col = "black",
	  cex = 0.6,
	  font = 4,
	  halo = TRUE,
	  bg = "white",
	  r = 0.1,
	  overlap = FALSE,
	  lines = FALSE,
	  adj = c(0.25, 3)   # only this one gets the custom offset
	)
  mf_label(
  	x = data,
  	var = "nb_txt",
  	col = "white",
  	cex = 0.8,
  	font = 4,
  	halo = TRUE,
  	bg = "black",
  	r = 0.1,
  	overlap = FALSE,
  	lines = FALSE,
  	adj = c(0.5,0)
  )
  mf_theme(
	  background = "white"
  )
  # mf_layout(
  #   title   = title,
  #   credits = paste0("Corpus: NCA", "\nMade with Comparalem,\n", "using mapsf ", packageVersion("mapsf")),
  #   arrow   = FALSE,
  #   scale   = FALSE
  # )
  dev.off()
}

#-----------------------------------
# Run program
#-----------------------------------

df <- read.csv("../../Data/1_input_data/NCA_text_metadata_concordancer.csv", sep = "\t", quote = "")

new_names <- c("id", "base", "coderegional", "coefficientregional", "coefficientregiondees",
               "corpus-1987", "datecomposition", "datemanuscrit", "datemoyennedees", "genre",
               "lieucomposition", "lieumanuscrit", "project", "qualite",
               "r-code-from-coderegional", "r-code-from-regiondees", "r-code-suppl-phylo", "r-code-suppl-total",
               "regiondees", "regiondees-from-code-regional", "regiondees-supp", "vers")

df <- df %>%
  separate_wider_delim(
    cols      = 1,
    delim     = ",",
    names     = new_names,
    too_many  = "merge"
  ) %>%
  dplyr::select(-c("ContexteGauche", "ContexteDroit", "Pivot")) %>%
  clean_names() %>%
  mutate(across(where(is.character), stringr::str_trim)) %>%
  mutate(
	  regiondees = as.character(regiondees),
	  # R_Code = as.numeric(r_code_suppl_total)
  ) %>%
  filter(id != "nil")

rou3b_code <- c(
	"r_code_from_coderegional",
	"r_code_from_regiondees",
	"r_code_suppl_phylo",
	"r_code_suppl_total"
)
rou3b_region <- c(
	"regiondees",
	"regiondees_from_code_regional",
	"regiondees_supp"
)

df[df$id == "rou3b", rou3b_code] <- "10"
df[df$id == "rou3b", rou3b_region] <- "Normandie"
df[df$id == "rou3b", "coderegional"] <- "24"
df[df$id == "rou3b", "coefficientregional"] <- "82"

hista_code <- c(
	"r_code_from_coderegional",
	"r_code_from_regiondees",
	"r_code_suppl_phylo",
	"r_code_suppl_total"
)
hista_region <- c(
	"regiondees",
	"regiondees_from_code_regional",
	"regiondees_supp"
)

df[df$id == "hista", hista_code] <- "22"
df[df$id == "hista", hista_region] <- "Haute-Marne"
df[df$id == "hista", "coderegional"] <- "61"


corpus_atlas <- df %>%
  dplyr::filter(corpus_1987 == TRUE)
by_region <- data_for_carto_corpus(df, "regiondees") %>%
 	filter(regiondees != "nil")
by_region_supp <- data_for_carto_corpus(df, "regiondees_supp") %>%
	filter(regiondees_supp != "NA")

# by_region <- df %>%
#   dplyr::count(`regiondees`, name = "n") %>%
#   dplyr::arrange(desc(n))
# by_region_merged <- merge(shapefiles, by_region, all.x = TRUE, by="R_Code")
#
# by_region_supp <- df %>%
#   dplyr::count(`regiondees-supp`, name = "n") %>%
#   dplyr::arrange(desc(n))

shapefiles <- st_read("../../Regions-Shapefile/")
by_region_merged <- merge(shapefiles, by_region, all.x = TRUE, by="R_Code")
by_region_supp_merged <- merge(shapefiles, by_region_supp, all.x = TRUE, by="R_Code")

make_map(by_region_merged, "by_region", "Nombre de textes (coef. < 70)", "regiondees")
make_map(by_region_supp_merged, "by_region_supp_merged", "Nombre de textes (tous coef.)", "regiondees_supp")

#### Plot diachronic distribution
df_long <- df %>%
  mutate(across(
    c(datemoyennedees, datecomposition, datemanuscrit),
    ~ as.numeric(na_if(as.character(.x), "nil"))
  )) %>%
  pivot_longer(
    cols      = c(datemoyennedees, datecomposition, datemanuscrit),
    names_to  = "date_type",
    values_to = "year"
  ) %>%
  filter(!is.na(year)) %>%
  mutate(decade = floor(year / 10) * 10) %>%
  count(date_type, decade, corpus_1987, name = "nb_txt")

diachro_plot <- ggplot(df_long, aes(x = decade, y = nb_txt, fill = corpus_1987)) +
  geom_col() +
  facet_wrap(~ date_type, ncol = 1, axes = "all_x") +
  scale_x_continuous(
    breaks = seq(1100, 1500, by = 50),
    limits = c(1090, 1500)
  ) +
  scale_fill_manual(
	values = setNames(hcl.colors(5, "Teal", rev = TRUE)[c(3, 5)], c("FALSE", "TRUE")),
    labels = c("FALSE" = "Non", "TRUE" = "Oui"),
    name   = "Corpus\natlas",
  ) +
  labs(
    x = "Date",
    y = "Nombre de textes"
  ) +
  theme_classic() +
  theme(
    axis.text.x = element_text(angle = 45, hjust = 1),
    panel.grid.minor = element_blank()
  )

ggsave(
  filename = "../../Graphs/decades_corpus.png",
  plot = diachro_plot,
  width    = 8,
  height   = 8,      # adjust to taste
  units    = "in",
  dpi      = 600
)

df_long_region <- df %>%
  mutate(across(
    c(datemoyennedees, datecomposition, datemanuscrit),
    ~ as.numeric(na_if(as.character(.x), "nil"))
  )) %>%
  mutate(region_group = if_else(regiondees_supp == "Angleterre", "Angleterre", "Continental")) %>%
  pivot_longer(
    cols      = c(datecomposition, datemanuscrit),
    names_to  = "date_type",
    values_to = "year"
  ) %>%
  filter(!is.na(year)) %>%
  mutate(decade = floor(year / 10) * 10) %>%
  count(date_type, decade, region_group, name = "nb_txt")

diachro_plot_an <- ggplot(df_long_region, aes(x = decade, y = nb_txt, fill = region_group)) +
  geom_col() +
  facet_wrap(~ date_type, ncol = 1, axes = "all_x") +
  scale_x_continuous(
    breaks = seq(1100, 1500, by = 50),
    limits = c(1090, 1500)
  ) +
  scale_fill_manual(
    values = setNames(hcl.colors(5, "Teal")[c(1, 3)], c("Continental", "Angleterre")),
    name   = "Région"
  ) +
  labs(
    x = "Date",
    y = "Nombre de textes"
  ) +
  theme_classic() +
  theme(
    axis.text.x = element_text(angle = 45, hjust = 1),
    panel.grid.minor = element_blank()
  )

ggsave(
  filename = "../../Graphs/decades_angleterre.png",
  plot = diachro_plot_an,
  width    = 8,
  height   = 5.33,      # adjust to taste
  units    = "in",
  dpi      = 600
)

df_long_vers <- df %>%
  mutate(across(
    c(datemoyennedees, datecomposition, datemanuscrit),
    ~ as.numeric(na_if(as.character(.x), "nil"))
  )) %>%
  pivot_longer(
    cols      = c(datecomposition, datemanuscrit),
    names_to  = "date_type",
    values_to = "year"
  ) %>%
  filter(!is.na(year)) %>%
  mutate(decade = floor(year / 10) * 10) %>%
  count(date_type, decade, vers, name = "nb_txt")

ggplot(df_long_vers, aes(x = decade, y = nb_txt, fill = vers)) +
  geom_col() +
  facet_wrap(~ date_type, ncol = 1, axes = "all_x") +
  scale_x_continuous(
    breaks = seq(1100, 1500, by = 50),
    limits = c(1090, 1500)
  ) +
  scale_fill_manual(
    values = setNames(hcl.colors(5, "Teal", rev = TRUE)[c(3, 5)], c("non", "oui")),
    labels = c("non" = "Prose", "oui" = "Vers"),
    name   = "Forme"
  ) +
  labs(
    x = "Date",
    y = "Nombre de textes"
  ) +
  theme_classic() +
  theme(
    axis.text.x = element_text(angle = 45, hjust = 1),
    panel.grid.minor = element_blank()
  )
