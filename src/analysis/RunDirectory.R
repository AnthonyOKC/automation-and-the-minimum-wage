# Clear ./out/ folders
out_path <- R.utils::getAbsolutePath("./out/analysis")
out_files <- list.files(out_path, include.dirs = TRUE, full.names = TRUE, recursive = TRUE)
out_folders <- list.files(out_path, include.dirs = TRUE, full.names = TRUE, recursive = FALSE)
out_files <- out_files[!(out_files %in% out_folders)] # Exclude folders from list of files to delete
file.remove(out_files)

# Analysis
source("compute_rti_rsh.R", chdir = TRUE)
source("regression_aggregated_rsh.R", chdir = TRUE)
source("regression_disaggregated_rsh.R", chdir = TRUE)