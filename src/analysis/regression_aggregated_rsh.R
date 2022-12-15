###### Aggregated Regression on RSH
## Import Packages
if (!require("pacman")) install.packages("pacman")
pacman::p_load(
  "tidyverse",
  fixest,
  gsubfn,
  kableExtra
)

############################# REGRESSION FUNCTIONS #############################

## Aggregated Estimates
RSH_regressions <- function(industry_RSH_data, statearea_RSH_data, modelnames) {
  # Run Regression Models
  models_industry_level <-
    feols(RSH ~ log(mw_yearly_real2015_12month_movavg) | STATEAREA + YEAR,
          fsplit = ~CIND, data = industry_RSH_data %>% as_tibble())
  model_state_level <- 
    feols(RSH ~ log(mw_yearly_real2015_12month_movavg) | STATEAREA + YEAR,
          data = statearea_RSH_data %>% as_tibble())
  models <- append(list(model_state_level), as.list(models_industry_level))
  names(models) <- modelnames
  return(models)
}  


############################### RUN REGRESSION ################################
#### Import 66th Percentile RTI Value for Low Education Workers
lowEDUC_RTI_P66 <-  readRDS("../../out/analysis/rti_p66.rds")

#### Import Industry and State-Area level data sets for RSH.
industry_lowEDUC_RSH <- read_csv("../../out/analysis/industry_lowEDUC_RSH.csv", lazy = FALSE)
statearea_lowEDUC_RSH <- read_csv("../../out/analysis/statearea_lowEDUC_RSH.csv", lazy = FALSE)

#### Run Aggregated Regression
modelnames <- c("Pooled (State-Area)", "Pooled (Industry)", "Construction",
                "Manufacturing", "Transport", "Wholesale", "Retail", "Finance",
                "Services", "P. Adm.")
aggregated_models <-
  RSH_regressions(industry_RSH_data =  industry_lowEDUC_RSH,
                  statearea_RSH_data = statearea_lowEDUC_RSH,
                  modelnames = modelnames)
saveRDS(aggregated_models, "../../out/analysis/aggregated_models.rds")
