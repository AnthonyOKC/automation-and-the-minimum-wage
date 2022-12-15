# Install Dependencies
source("install_r_packages.R")

# Clear ./out/ folders
out_path <- R.utils::getAbsolutePath("./out")
out_files <- list.files(out_path, include.dirs = TRUE, full.names = TRUE, recursive = TRUE)
out_folders <- list.files(out_path, include.dirs = TRUE, full.names = TRUE, recursive = FALSE)
out_files <- out_files[!(out_files %in% out_folders)] # Exclude folders from list of files to delete
file.remove(out_files)

# Data Management
source("./src/data-management/rti_clean_join.R", chdir = TRUE)
source("./src/data-management/mw_clean_join_genvar.R", chdir = TRUE)
source("./src/data-management/cps_clean_join_genvar.R", chdir = TRUE)

# Analysis
source("./src/analysis/compute_rti_rsh.R", chdir = TRUE)
source("./src/analysis/regression_aggregated_rsh.R", chdir = TRUE)
source("./src/analysis/regression_disaggregated_rsh.R", chdir = TRUE)

# Tables
source("./src/tables/table1_aggregated_rsh_regression.R", chdir = TRUE)
source("./src/tables/table2_disaggregated_rsh_regression.R", chdir = TRUE)

# Paper
rmarkdown::render("./src/paper/Automation-and-the-Minimum-Wage.Rmd",
                  output_dir = "./out/paper")

# Open PDF
os = .Platform$OS.type # Operating System
if (os == "windows") {
    shell.exec(paste(getwd(), "/out/paper/Automation-and-the-Minimum-Wage.pdf", sep = ""))
} else if (os == "unix") {
    system(paste("xdg-open ", getwd(), "/out/paper/Automation-and-the-Minimum-Wage.pdf", sep = ""))
} else {
    # Mac
system(paste(getwd(), "/out/paper/Automation-and-the-Minimum-Wage.pdf", sep = "")) 
}
