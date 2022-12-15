###### Disaggregated Regression on RSH
    ## Disaggregated by Demographic Characteristics (Age, Gender, Race)
## Import Packages
if (!require("pacman")) install.packages("pacman")
pacman::p_load(
  "tidyverse",
  fixest,
  gsubfn,
  kableExtra,
  ipumsr
)

#### Import Cleaned/Wrangled Data
ddi <- read_ipums_ddi("../data/cps.xml")
data <- fread("../../out/data-management/cps_1976_2018.csv")
data <- set_ipums_var_attributes(data, ddi)
data <- as_tibble(data)

#### Importing metadata resets some labels, so they must be renamed.
data <- 
  data %>% 
  mutate(CIND =
            CIND %>% 
            labelled(c(
            "Agriculture, Forestry, and Fisheries" = 1,
            Mining = 2,
            Construction = 3,
            Manufacturing = 4,
            "Transporation, Communications, and Other Public Utilities" = 5,
            "Wholesale Trade" = 6,
            "Retail Trade" = 7,
            "Finance, Insurance, and Real Estate" = 8,
            Services = 9,
            "Public Administration" = 10,
            "Active Duty Military" = 11,
            Unknown = 12)),
         METRO =  # Must relabel again after using set_ipums_var_attributes()
           METRO %>% 
           labelled(
             c(Nonmetro = 0,
               Metro = 1,
               "Missing/Unknown" = 9)
           )
         )

############################# REGRESSION FUNCTIONS #############################
RSH_compute <- function(data,
                        groups = c("CIND", "STATEAREA", "YEAR"),
                        cluster_mean_vars = c("STATEAREA", "YEAR"),
                        mw = "mw_yearly_real2015_12month_movavg",
                        RTI_P66_val)
  {
  "Compute RSH values by given subgroups.
  Make sure groups argument is a character vector."
  
  mw_cluster_means <- function (data, cm = cluster_mean_vars) {
    "Provides mean of the mw variable within each cluster."
    # By default, we assume we only want to cluster-mean by STATEAREA and YEAR.
      n = length(cm)
      for (i in 1:n) {
        col_name <- paste0("mw_", cm[i], "_cluster_mean")
        data <- 
          data %>% 
          group_by(!!!syms(cm[i])) %>% 
          mutate(!!col_name := mean(!!!syms(mw)))
      }
      return(data)
  }
  
  group_call <- syms(c(groups, mw))
  data %>% 
    group_by(!!!group_call) %>% # mw is in group_call so it stays after summarise(.)
    # Compute the numerator and denominator for the RSH formula
    summarise(RSH_num = sum(WTFINL[RTI > RTI_P66_val], na.rm = TRUE),
              RSH_denom = sum(WTFINL)) %>% 
    mutate(RSH = RSH_num / RSH_denom) %>% 
    mw_cluster_means() %>% 
    ungroup()
}
# High-School or Lower Education
lowEDUC_data <- function(data) {
  "Filters data as defined in (Neumark, 2018)."
  data %>%
  filter(YEAR %in% 1980:2018,
         EDUC %in% 2:74, # High-school diploma equivalent or lower.
         OCC1990 != 999, # Excludes those without an Occupation value.
         METRO != 9, # Excludes those without METRO values.
         # Exclude Agriculture, Mining, and Armed Forces, as in (Neumark, 2018).
         !(CIND %in% c(1:2, 11:12)) # Also excludes those with Missing Industry Values.
  )
}
disagg_RSH_regressions <- function(data, lowEDUC_RTI_P66, filters, modelnames) {
  # Run Regression Models
  feols_RSH <- function(industry_RSH_data, statearea_RSH_data, modelheadings) {
    "Run industry and state level regression models for particular data, and
    combine them into a single list."
    models_industry_level <-
      feols(RSH ~ log(mw_yearly_real2015_12month_movavg) | STATEAREA + YEAR,
            fsplit = ~CIND, data = industry_RSH_data %>% as_tibble())
    model_state_level <- 
      feols(RSH ~ log(mw_yearly_real2015_12month_movavg) | STATEAREA + YEAR,
            data = statearea_RSH_data %>% as_tibble())
    models <- append(list(model_state_level), as.list(models_industry_level))
    names(models) <- modelheadings # Later become the headings for each model.
    return(models)
  }
   subgroup_reg <- function(data, filter, notes = NULL) {
    "For a given filtered subgroup, we compute RSH, run industry/statearea regressions,
     and construct a modelsummary data.frame table as the output. This way, the
     subgroups can later be bound together."
    filter_call <- parse(text = filter)
    industry_RSH_data <- 
      RSH_compute(data =
                    lowEDUC_data(data) %>% 
                    as_tibble() %>% # In case data is lazy data.table
                    filter(eval(!!filter_call)),
                  RTI_P66_val = lowEDUC_RTI_P66)
    state_RSH_data <-
      RSH_compute(data =
                    lowEDUC_data(data) %>%
                    as_tibble() %>% 
                    filter(eval(!!filter_call)),
                  # Not grouped by industry.
                  groups = c("STATEAREA", "YEAR"),
                  RTI_P66_val = lowEDUC_RTI_P66)
    models <- feols_RSH(industry_RSH_data, state_RSH_data, modelheadings = modelnames)
   }
  disaggregated_models <- lapply(filters, subgroup_reg, data = data) 
  return(disaggregated_models)
}

############################### RUN REGRESSION ################################
#### Import 66th Percentile RTI Value for Low Education Workers
lowEDUC_RTI_P66 <-  readRDS("../../out/analysis/rti_p66.rds")

#### Import Industry and State-Area level data sets for RSH.
industry_lowEDUC_RSH <- read_csv("../../out/analysis/industry_lowEDUC_RSH.csv", lazy = FALSE)
statearea_lowEDUC_RSH <- read_csv("../../out/analysis/statearea_lowEDUC_RSH.csv", lazy = FALSE)

modelnames <- c("Pooled (State-Area)", "Pooled (Industry)", "Construction",
                "Manufacturing", "Transport", "Wholesale", "Retail", "Finance",
                "Services", "P. Adm.")
filters <- c("AGE >= 40",
             "AGE >= 26 & AGE <= 39",
             "AGE <=25",
             "SEX == 1",
             "SEX == 2",
             "RACE == 100",
             "RACE == 200")

disaggregated_models <- 
  disagg_RSH_regressions(data = data,
                         lowEDUC_RTI_P66 = lowEDUC_RTI_P66,
                         filters = filters,
                         modelnames = modelnames)
saveRDS(disaggregated_models, "../../out/analysis/disaggregated_models.rds")
