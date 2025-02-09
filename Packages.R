# Install and load packages

# ipak function: install and load multiple R packages.
# check to see if packages are installed. Install them if they are not, then load them into the R session.

ipak <- function(pkg){
new.pkg <- pkg[!(pkg %in% installed.packages()[, "Package"])]
if (length(new.pkg))
    install.packages(new.pkg, dependencies = TRUE)
sapply(pkg, require, character.only = TRUE)
}

# usage
packages <- c('readr',
	'dplyr',
	'tidyverse',
	'ggplot2',
	'writexl',
	'stringr',
	'ggpubr',
	'Hmisc',
	'spatstat',
	'weights',
	'Unicode',
	'ggtext',
	'RColorBrewer',
	'sp',
	'ggspatial',
	'ggpmisc',
	'viridis',
	'sf',
	'tcltk',
	'readxl',
	'MASS',
	'rms',
	'DescTools',
	'DHARMa',
	'performance',
	'sjPlot',
	'sjlabelled',
	'sjmisc',
	'mapsf')
ipak(packages)
