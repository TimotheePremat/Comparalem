get_string_input <- function(
	label_text = "Enter prefix:",
	paragraph_text = NULL,
	title_text= "Input String"
	) {

  # Fixed title
  tt <- tktoplevel()
  tkwm.title(tt, title_text)
  tkwm.minsize(tt, 400, 50)  # Minimum window size in pixels

  file_name_var <- tclVar("")
  confirmed <- tclVar("FALSE")

  # Input label and entry
  entry <- tkentry(tt, textvariable = file_name_var, width = 30)
  tkpack(tklabel(tt, text = label_text), entry)

  # OK / Cancel buttons
  on_ok <- function() {
    tclvalue(confirmed) <- "TRUE"
    tkdestroy(tt)
  }

  on_cancel <- function() {
    tclvalue(confirmed) <- "FALSE"
    tkdestroy(tt)
  }

  button_frame <- tkframe(tt)
  tkpack(
    tkbutton(button_frame, text = "OK", command = on_ok),
    tkbutton(button_frame, text = "Cancel", command = on_cancel),
    side = "left", padx = 10
  )
  tkpack(button_frame, pady = 10)

  # Optional paragraph with minimum width
  if (!is.null(paragraph_text)) {
    text_widget <- tktext(tt, height = 20, width = 60, wrap = "word")  # width in characters
    tkinsert(text_widget, "end", paragraph_text)
    tkconfigure(text_widget, state = "disabled")
    tkpack(text_widget, padx = 10, pady = 5, fill = "both")
  }

  tkwait.window(tt)

  if (tclvalue(confirmed) == "TRUE") {
    return(tclvalue(file_name_var))
  } else {
    return(NULL)
  }
}


get_bol_input <- ask_filter_by_date <- function(title = "Filter by Date",
                               label_text = "Do you wish to filter out by date?") {

  tt <- tktoplevel()
  tkwm.title(tt, title)

    # Set minimum window size
  tkwm.minsize(tt, 400, 50)

  filter_var <- tclVar("no")      # Default selection is "no"
  confirmed <- tclVar("FALSE")    # Track whether OK was clicked

  # Dynamic label
  tkpack(tklabel(tt, text = label_text))

  # Radio buttons
  rb_yes <- tkradiobutton(tt, text = "Yes", variable = filter_var, value = "yes")
  rb_no  <- tkradiobutton(tt, text = "No",  variable = filter_var, value = "no")
  tkpack(rb_yes, rb_no, anchor = "w")

  # OK and Cancel buttons
  on_ok <- function() {
    tclvalue(confirmed) <- "TRUE"
    tkdestroy(tt)
  }

  on_cancel <- function() {
    tclvalue(confirmed) <- "FALSE"
    tkdestroy(tt)
  }

  button_frame <- tkframe(tt)
  tkpack(tkbutton(button_frame, text = "OK", command = on_ok),
         tkbutton(button_frame, text = "Cancel", command = on_cancel),
         side = "left", padx = 10)
  tkpack(button_frame, pady = 10)

  tkwait.window(tt)

  if (tclvalue(confirmed) == "TRUE") {
    return(tclvalue(filter_var))
  } else {
    return(NULL)
  }
}

input_two_numbers <- function(title = "Numeric Input",
                              label1 = "Enter first number:",
                              label2 = "Enter second number:",
							  paragraph_text = NULL) {

  tt <- tktoplevel()
  tkwm.title(tt, title)
  tkwm.minsize(tt, 300, 150)

  num1_var <- tclVar("")
  num2_var <- tclVar("")
  confirmed <- tclVar("FALSE")

  # First input
  tkpack(tklabel(tt, text = label1), padx = 10, anchor = "w")
  entry1 <- tkentry(tt, textvariable = num1_var, width = 20)
  tkpack(entry1, padx = 10, pady = 5)

  # Second input
  tkpack(tklabel(tt, text = label2), padx = 10, anchor = "w")
  entry2 <- tkentry(tt, textvariable = num2_var, width = 20)
  tkpack(entry2, padx = 10, pady = 5)

  on_ok <- function() {
    tclvalue(confirmed) <- "TRUE"
    tkdestroy(tt)
  }

  on_cancel <- function() {
    tclvalue(confirmed) <- "FALSE"
    tkdestroy(tt)
  }

  button_frame <- tkframe(tt)
  tkpack(tkbutton(button_frame, text = "OK", command = on_ok),
         tkbutton(button_frame, text = "Cancel", command = on_cancel),
         side = "left", padx = 10)
  tkpack(button_frame, pady = 10)

  # Optional paragraph using a read-only tktext widget
	if (!is.null(paragraph_text)) {
	  text_widget <- tktext(tt, height = 5, width = 50, wrap = "word")
	  tkpack(text_widget, padx = 10, pady = 5)
	  tkinsert(text_widget, "end", paragraph_text)
	  tkconfigure(text_widget, state = "disabled")  # Make read-only
	}


  tkwait.window(tt)

  if (tclvalue(confirmed) == "TRUE") {
    val1 <- as.numeric(tclvalue(num1_var))
    val2 <- as.numeric(tclvalue(num2_var))
    if (is.na(val1) || is.na(val2)) {
      warning("One or both inputs are not valid numbers.")
      return(NULL)
    }
    return(list(var1 = val1, var2 = val2))
  } else {
    return(NULL)
  }
}

#For filtering window
library(tcltk)

filtering_options <- function(dataset, additional_text = NULL) {
  result <- list(entry1 = NULL, entry2 = NULL, checkbox_regex = NULL, checkbox_negative = NULL)

  win <- tktoplevel()
  tkwm.title(win, "Filtering data")
  tkwm.minsize(win, 300, 150)

  entry1_var <- tclVar("")
  entry2_var <- tclVar("")
  checkbox_regex_var <- tclVar(0)  # Checkbox for regex option
  checkbox_negative_var <- tclVar(0)  # Checkbox for negative match

  # Labels and entries
  label1 <- tklabel(win, text = "Variable :")
  entry1 <- tkentry(win, textvariable = entry1_var, width = 20)

  label2 <- tklabel(win, text = "Value(s) :")
  entry2 <- tkentry(win, textvariable = entry2_var, width = 20)

  checkbox_regex <- tkcheckbutton(win, text = "Use regex", variable = checkbox_regex_var)
  checkbox_negative <- tkcheckbutton(win, text = "Negative match (exclude values)", variable = checkbox_negative_var)

  # Buttons
  submit_button <- tkbutton(win, text = "Submit", command = function() {
    result$entry1 <<- tclvalue(entry1_var)
    result$entry2 <<- tclvalue(entry2_var)
    result$checkbox_regex <<- as.integer(tclvalue(checkbox_regex_var))
    result$checkbox_negative <<- as.integer(tclvalue(checkbox_negative_var))
    tkdestroy(win)
  })

  cancel_button <- tkbutton(win, text = "Don't filter", command = function() {
    result <<- NULL
    tkdestroy(win)
  })

  # Layout
  tkgrid(label1, entry1, padx = 5, pady = 5)
  tkgrid(label2, entry2, padx = 5, pady = 5)

  # Place checkboxes on the same row
  tkgrid(checkbox_regex, checkbox_negative, padx = 10, pady = 5)

  # Buttons
  tkgrid(cancel_button, submit_button, padx = 10, pady = 10)

  # Extract column names from the dataset passed to the function
  column_names <- paste(colnames(dataset), collapse = ", ")  # Get column names
  paragraph_text <- paste(
    "To filter by variable-value pairs, enter variables and values.",
    "- If several variables or values are used, enter them as a comma separated list.",
    "- If using the regex mode, remember to anchor your string between '^' and '$' if needed.",
    "- By default, filtering is 'filtering in'. To filter out (i.e., exclude lines matching the value), add a '!' before the value.",
    "- In case of multiple values to filter out, add '!' before each value.",
    "- Warning: filtering by multiple values cannot mix values with AND without '!'.",
    "  To do so, run 4_filter_custom.r twice (filtering is cumulative).",
    "\n\nAvailable columns for filtering: ", column_names,  # Add column names here
    sep = "\n"
  )

  # First text widget with instructions and available columns
  text_widget <- tktext(win, height = 10, width = 100, wrap = "word")
  tkgrid(text_widget, columnspan = 2, padx = 10, pady = 5)
  tkinsert(text_widget, "end", paragraph_text)
  tkconfigure(text_widget, state = "disabled")

  # Second text widget for additional text (based on function call)
  additional_text <- ifelse(is.null(additional_text), "No additional information provided.", additional_text)
  text_widget2 <- tktext(win, height = 4, width = 100, wrap = "word")
  tkgrid(text_widget2, columnspan = 2, padx = 10, pady = 5)
  tkinsert(text_widget2, "end", additional_text)  # Fill with additional text
  tkconfigure(text_widget2, state = "disabled")

  tkwait.window(win)
  return(result)
}
