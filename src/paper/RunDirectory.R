# Clear ./out/ folders
out_path <- R.utils::getAbsolutePath("../../out/paper")
out_files <- list.files(out_path, include.dirs = TRUE, full.names = TRUE, recursive = TRUE)
file.remove(out_files)

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