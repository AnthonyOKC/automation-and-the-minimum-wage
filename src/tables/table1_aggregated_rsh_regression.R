###### Create Table 1: Aggregated Regressions of RSH
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

## Import Models
models <- readRDS("../../out/analysis/aggregated_models.rds")

## Format the Summary Statistics for Model Summary
summary_stats <- names(get_gof(models[[1]]))
gm <- modelsummary::gof_map
gm <- 
    gm %>%
    filter(clean %in% c("Num.Obs.","R2", "R2 Within")) %>% 
    filter(raw %in% summary_stats)
gm$clean <- c("$N$", "$R^2$", "$R^2$ Within")

#### Table 1
# Parameters
landscape <- TRUE
scaledown <- TRUE

# Arguments
title <- "Full sample estimates, share of automatable employment by industry"
caption <- "Dependent Variable: Share of Automatable Employment"
old_dep_var <- "log(mw_yearly_real2015_12month_movavg)"
new_dep_var <- "Log Min. Wage"
modelnames <- c("Pooled (State-Area)", "Pooled (Industry)", "Construction",
                "Manufacturing", "Transport", "Wholesale", "Retail", "Finance",
                "Services", "P. Adm.")
notes <-
  paste(
  "\\\\emph{Note:}",
  "Regressions (2) --- (10) occurs at the industry level. The industry level pooled",
  "estimate, (2), should be interpreted as the effect of a minimum wage increase on the",
  "effect of the ``average\" (typical) industry's RSH (weighted by each industry's number of",
  "employees). Similarly, the state-area level pooled estimate, (1), represents the",
  "effect on the average state-area's RSH (weighted by employees in each state-area)."
  )
texpath <- "../../out/tables/table1_aggregated_rsh_regressions.tex"

# Create Table
table <- modelsummary(models, output = "latex", title = title, gof_map = gm,
                    booktabs = TRUE, full_width = TRUE,
                    coef_rename = setNames(new_dep_var, old_dep_var),
                    stars = c("*" = 0.05, "**" = 0.01, "***" = 0.001))
table %>%
    {if(landscape == TRUE) landscape(.) else .} %>% 
    {if(scaledown == TRUE) kable_styling(., latex_options="scale_down") else .} %>% 
    add_model_number_lab(modelnames) %>% 
    add_header_above(c("", setNames(length(models), caption))) %>% 
    footnote(general = notes, general_title = "",
             escape = FALSE, threeparttable = TRUE) %>% 
    writeLines(texpath)