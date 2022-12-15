# Clear ./out/ folders
out_path <- R.utils::getAbsolutePath("../../out/tables")
out_files <- list.files(out_path, include.dirs = TRUE, full.names = TRUE, recursive = TRUE)
file.remove(out_files)

# Tables
print("Create Table 1")
source("table1_aggregated_rsh_regression.R", chdir = TRUE)

print("Create Table 2")
source("table2_disaggregated_rsh_regression.R", chdir = TRUE)