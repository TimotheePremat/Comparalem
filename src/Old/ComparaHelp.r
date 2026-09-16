#Help messages called with prefix ComparaHelp

#------------------------------------------------------------
#Filtering input help
#------------------------------------------------------------
ComparaHelp_filtering <- c("FILTERING BY GIVEN VALUE(S) OF VARIABLE", "To filter by variable-value pairs, enter variables and values when asked.", "If several variables or values are used, enter them as a comma separated list.", "Enter 'regex' (or '!regex') as one of the values to active regex syntax.", "-> In regex, remember to anchor your string between '^' and '$' if needed.", "By default, filtering is 'filtering in', i.e., only keep the item matching the value for the variable.", "-> To filter out (i.e., exclude line matching the value for the variable), add a '!' sign before the value.", "In case of multiple values to filter out, add '!' before each value (including '!regex').", "(No value should contain ',' or '!' in its text)", "Warning: filtering by multiple values cannot mix values with '!' and without '!'", "-> To do so, run 4_filter_custom.R twice.", "Non-matched value can be due to data selection biais.")
ComparaHelp_filtering <- noquote(ComparaHelp_filtering)

ComparaHelp_time_span <- c("DIVING DATA INTO TIME-SPANS", "Comparalem allows to divide the data into different time-spans for creating maps.", "Enter time-span boundaries when asked, as comma separated list", "Lower boundary is included (standard date >= value); upper boundary is not included (standard date < value)", "-> E.g. input '1100, 1150, 1200' defines two time-spans (1100-1149 and 1150-1199)", "Time-span boundaries provided must include the lowest one (min) and the highest one (max).", "All data point outside min and max time-span boundaries will be ignored.", "Boundaries must be inputed in growing order")
ComparaHelp_time_span <- noquote(ComparaHelp_time_span)
