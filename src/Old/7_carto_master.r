# Master script for mapping.
# Chooses between shapefile and non-shapefile provided routine.

# shape_var <- readline(prompt="Do you have shapefiles for mapping your texts? [Y/n]")
shape_var <- get_bol_input(
  title = "Type of mapping",
  label_text = "Do you have shapefiles for mapping your texts?"
)
	if (shape_var == "no"|shape_var == "No"|shape_var == "n") {
		print("Mapping without shapefiles is not supported for now. Cartography script aborted. Please ignore warnings in saving files.")
	}

if (shape_var == "yes"|shape_var == "Yes"|shape_var == "y"|shape_var == "Y") {
	source("7a_carto_shapefiles.r")
 }

# if (shape_var == "no"|shape_var == "No"|shape_var == "n") {
# 	source("7b_carto_no_shapefiles.R")
#  }
# UNCOMMENT WHEN SCRIPT READY

carto_diachro_var <- get_bol_input(
  title = "Type of mapping",
  label_text = "Do you want to divide time interval to map diachrony?"
)
# carto_diachro_var <- readline(prompt="Do you want to divide time interval to map diachrony? [Y/n]")
if (carto_diachro_var == "yes"|carto_diachro_var == "Yes"|carto_diachro_var == "y"|carto_diachro_var == "Y") {
	source("7b_carto_shapefiles_diachro.r")
 }
