# Clear ./out/ folders
out_path <- R.utils::getAbsolutePath("../../out/data-management")
out_files <- list.files(out_path, include.dirs = TRUE, full.names = TRUE, recursive = TRUE)
file.remove(out_files)

# Data Management
print("Managing Routine Task Intensity Data")
source("rti_clean_join.R", chdir = TRUE)

print("Managing Minimum Wage Data")
source("mw_clean_join_genvar.R", chdir = TRUE)

print("Managing CPS Data")
source("cps_clean_join_genvar.R", chdir = TRUE)

