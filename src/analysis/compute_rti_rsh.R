#### Compute Routine Employment Share (RSH)
# Exclude NIU/Blank, Above High-School, and Missing/Unknown
# 66th Percentile RTI of Lower-Education Population

## Import Packages
if (!require("pacman")) install.packages("pacman")
pacman::p_load(
  "tidyverse",
  ipumsr,
  rlang,
  Hmisc
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

## Functions:
RTI_P66 <- function(data) {
  "Compute the 66th weighted percentile of RTI for the data"
  data %>% 
    summarise(RTI66 = wtd.quantile(RTI, weights = WTFINL,
                                   probs = .66, na.rm = TRUE)
              ) %>% 
    pull(RTI66)
}

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

#### Compute RTI Value for low-education workers
lowEDUC_RTI_P66 <- RTI_P66(lowEDUC_data(data))
lowEDUC_RTI_P66 %>% 
  saveRDS(file = "../../out/analysis/rti_p66.rds")

#### Compute RSH values for low-education workers at the industry-level
RSH_compute(data = lowEDUC_data(data), RTI_P66_val = lowEDUC_RTI_P66) %>% 
  write_csv("../../out/analysis/industry_lowEDUC_RSH.csv")
gc()

#### Compute RSH values for low-education workers at the industry-level
RSH_compute(data = lowEDUC_data(data),
            # Grouped by STATEAREA and YEAR, but not grouped by industry.
            groups = c("STATEAREA", "YEAR"),
            RTI_P66_val = lowEDUC_RTI_P66
            ) %>% 
  write_csv("../../out/analysis/statearea_lowEDUC_RSH.csv")
gc()