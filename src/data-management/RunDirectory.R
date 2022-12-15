# Clear ./out/ folders
out_path <- R.utils::getAbsolutePath("./out/data-management")
out_files <- list.files(out_path, include.dirs = TRUE, full.names = TRUE, recursive = TRUE)
out_folders <- list.files(out_path, include.dirs = TRUE, full.names = TRUE, recursive = FALSE)
out_files <- out_files[!(out_files %in% out_folders)] # Exclude folders from list of files to delete
file.remove(out_files)

# Data Management
source("rti_clean_join.R", chdir = TRUE)
source("mw_clean_join_genvar.R", chdir = TRUE)
source("cps_clean_join_genvar.R", chdir = TRUE)