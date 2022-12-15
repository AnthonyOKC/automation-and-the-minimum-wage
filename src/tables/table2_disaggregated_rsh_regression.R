###### Create Table 2: Disaggregated Regressions of RSH
## Import Packages
if (!require("pacman")) install.packages("pacman")
pacman::p_load(
  "tidyverse",
  kableExtra,
  modelsummary
)

# Functions:
add_model_number_lab <- function (kable_table, modelnames) {
  "Adds a Row Above Model Names with a Sequence of Numbers."
  n <- length(modelnames) 
  header <- c("", sprintf("(%d)", 1:n))
  kable_table %>% 
  add_header_above(header)
}
add_group_number_lab <- function (kable_table, filters, n_statistics,
                                  filter_labels = NULL) {
  "Groups Subgroups in Regression Tables."
  n <- length(filters) # Number of Groups
  group_labels <-
    if (is.null(filter_labels)) {
      sprintf("Group %d", 1:n)
    } else filter_labels
  for (i in 1:n) {
    group_row_start <- 1 + (5 * (i - 1))
    group_row_end <- group_row_start + 1 + n_statistics
    kable_table <- 
      kable_table %>% 
      pack_rows(group_labels[i], group_row_start, group_row_end, escape = FALSE)
  }
  return(kable_table)
}

## Import Models
models <- readRDS("../../out/analysis/disaggregated_models.rds")

# Format the Summary Statistics for Model Summary
summary_stats <- names(get_gof(models[[1]][[1]]))
gm <- modelsummary::gof_map
gm <- 
  gm %>%
  filter(clean %in% c("Num.Obs.","R2", "R2 Within")) %>% 
  filter(raw %in% summary_stats)
gm$clean <- c("$N$", "$R^2$", "$R^2$ Within")

#### Table 2
#### Generate Modelsummary Tables
subgroup_reg_table <- function(models, gm, old_dep_var, new_dep_var) {
    "Generates a modelsummary regression table for a single subgroup from models"
    subgroup_table <-
        modelsummary(models, output = "data.frame", gof_map = gm,
                     stars = c("*" = 0.05, "**" = 0.01, "***" = 0.001),
                     coef_rename = setNames(new_dep_var, old_dep_var)) %>% 
        mutate(term = ifelse(statistic == "modelsummary_tmp2", "", term)) %>%
        select(-c("part", "statistic"))
    return(subgroup_table)
}


#### Create Table 2
## Load Parameters
landscape <- TRUE
scaledown <-  TRUE

## Load Arguments
title <- "Disaggregated estimates, shares of automatable employment by industry"
caption <- "Dependent Variable: Share of Automatable Employment"
filter_labels <-
  # Four "\" are required for the 2nd inequality in a line.
  c("AGE $\\geq$ 40", "26 $\\leq$ AGE $\\\\leq$ 39", "AGE $\\leq 25$",
    "Male", "Female", "White", "Black")
group_labels <-
if (is.null(filter_labels)) {
  sprintf("Group %d", 1:n)
} else filter_labels
filters <- c("AGE >= 40",
             "AGE >= 26 & AGE <= 39",
             "AGE <=25",
             "SEX == 1",
             "SEX == 2",
             "RACE == 100",
             "RACE == 200")
texpath <- "../../out/tables/table2_disaggregated_rsh_regressions.tex"
old_dep_var <- "log(mw_yearly_real2015_12month_movavg)"
new_dep_var <- "Log Min. Wage"
modelnames <- c("Pooled (State-Area)", "Pooled (Industry)", "Construction",
                "Manufacturing", "Transport", "Wholesale", "Retail", "Finance",
                "Services", "P. Adm.")
subgroup_tables <- lapply(models, subgroup_reg_table, gm = gm,
                          old_dep_var = old_dep_var, new_dep_var = new_dep_var) 
table <- bind_rows(subgroup_tables)
names(table)[1] <- "" 
n_statistics <- length(subgroup_tables[[1]][,1]) - 2 # Number of Summary Statistics

# Write table2_part1 to Disk
table[1:25,] %>%
  kbl(format = "latex",
      caption = title,
      booktabs = TRUE,
      escape = FALSE) %>% 
  add_group_number_lab(filters[1:5], n_statistics, filter_labels[1:5]) %>% 
  {if(landscape == TRUE) landscape(.) else .} %>% 
  # Scale down to fit page (font size allowed to change)
  {if(scaledown == TRUE) kable_styling(., latex_options="scale_down") else .} %>%
  add_model_number_lab(modelnames) %>% # Add Model Names and Numbering
  add_header_above(c("", setNames(length(modelnames), caption))) %>% # Dep. Variable Title
  footnote(general = "* p $<$ 0.05, ** p $<$ 0.01, *** p $<$ 0.001",
           escape = FALSE, general_title = "") %>% 
  writeLines(texpath)
texpath2 <- gsub("\\.tex", "\\_2\\.tex", texpath)

# Write table2_part2 to Disk
table[26:35,] %>% 
  kbl(format = "latex",
      caption = title,
      booktabs = TRUE,
      row.names = FALSE,
      escape = FALSE) %>% 
  add_group_number_lab(filters[6:7], n_statistics, filter_labels[6:7]) %>% 
  {if(landscape == TRUE) landscape(.) else .} %>% 
  # Scale down to fit page (font size allowed to change)
  {if(scaledown == TRUE) kable_styling(., latex_options="scale_down") else .} %>%
  add_model_number_lab(modelnames) %>% # Add Model Names and Numbering
  add_header_above(c("", setNames(length(modelnames), caption))) %>% # Dep. Variable Title
  footnote(general = "* p $<$ 0.05, ** p $<$ 0.01, *** p $<$ 0.001",
           escape = FALSE, general_title = "") %>% 
  append(x = "\n\\addtocounter{table}{-1} % decreases table number by 1") %>% 
  writeLines(texpath2)