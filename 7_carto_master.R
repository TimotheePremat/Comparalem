# Master script for mapping.
# Chooses between shapefile and non-shapefile provided routine.

shape_var <- readline(prompt="Do you have shapefiles for mapping your texts? [Y/n]")
	if (shape_var == "no"|shape_var == "No"|shape_var == "n") {
		print("Mapping without shapefiles is not supported for now. Cartography script aborts. Please ignore warnings in saving files.")
	}

if (shape_var == "yes"|shape_var == "Yes"|shape_var == "y"|shape_var == "Y") {
	source("7a_carto_shapefiles.R")
 }

# if (shape_var == "no"|shape_var == "No"|shape_var == "n") {
# 	source("7b_carto_no_shapefiles.R")
#  }
# UNCOMMENT WHEN SCRIPT READY

carto_diachro_var <- readline(prompt="Do you want to divide time interval to map diachrony? [Y/n]")
if (carto_diachro_var == "yes"|carto_diachro_var == "Yes"|carto_diachro_var == "y"|carto_diachro_var == "Y") {
	source("7b_carto_shapefiles_diachro.R")
 }
