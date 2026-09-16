source("packages.r")

# Set level of logging (e.g., DEBUG, INFO, WARNING, ERROR)
log_threshold("INFO")
dir.create("../Data/log", showWarnings = FALSE, recursive = TRUE)
log_file <- paste0("../Data/log/", format(Sys.time(), "%Y-%m-%d_%H-%M-%S"), ".log")
log_appender(appender_tee(log_file))

source("ui.r", local = TRUE)
source("server.r")

shiny::runApp(
    list(
        ui = ui, server = server
        )
    )