# Clear ./out/ folders
out_path <- R.utils::getAbsolutePath("../../out/analysis")
out_files <- list.files(out_path, include.dirs = TRUE, full.names = TRUE, recursive = TRUE)
file.remove(out_files)

# Analysis
print("Computing RTI and RSH")
source("compute_rti_rsh.R", chdir = TRUE)

print("Running Aggregated Regressions on RSH")
source("regression_aggregated_rsh.R", chdir = TRUE)

print("Running Disaggregated Regressions on RSH")
source("regression_disaggregated_rsh.R", chdir = TRUE)