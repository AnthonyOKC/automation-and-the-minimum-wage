############################### CLEAN DATA ####################################
#### Import Packages
if (!require("pacman")) install.packages("pacman")
pacman::p_load(
  "tidyverse",
  "haven",
  data.table,
  ipumsr,
  labelled
)
p_loaded()

#### Import RAW Data
## Source: IPUMS CPS
## https://cps.ipums.org/cps/index.shtml
ddi <- read_ipums_ddi("../data/cps.xml") # Variable Metadata
system.time(data <- fread("../data/cps.csv",
                          # Subset of Columns (2x Faster Load Time)
                          select = c('YEAR', # 4 Digit Year
                                     'MONTH', # 2 Digit Month
                                     'CPSIDP', # Individual Participant CPS ID
                                     'WTFINL', # Participant's Survey Weight
                                     'STATEFIP', # State FIPS Code
                                     'METRO', # Metropolitan City Status (Urban v. Rural)
                                     'OCC1990', # Occupation Code 1990 Basis
                                     'IND1990', # Industry Code 1990 Basis
                                     'EDUC', # Participant's Level of Education
                                     'AGE', # Participant's Age
                                     'SEX', # Participant's Sex
                                     'RACE', # Participant's Race
                                     'HISPAN' # Participant's Hispanic/Latino Status
                                     )))
data <- set_ipums_var_attributes(data, ddi)
data <- as_tibble(data)

#### Create Consolidated Industry (CIND) Crosswalk to the IND1990 Industry Codes
cwCIND_IND1990 <-
  data %>% 
  select(IND1990) %>% 
  unique() %>% 
  as_tibble() %>% 
  rowwise() %>% 
  mutate(CIND =
           case_when(
             IND1990 %in% 1:39 ~ 1,
             IND1990 %in% 40:59 ~ 2,
             IND1990 %in% 60:99 ~ 3,
             IND1990 %in% 100:399 ~ 4,
             IND1990 %in% 400:499 ~ 5,
             IND1990 %in% 500:579 ~ 6,
             IND1990 %in% 580:699 ~ 7,
             IND1990 %in% 700:720 ~ 8,
             IND1990 %in% 721:899 ~ 9,
             IND1990 %in% 900:939 ~ 10,
             IND1990 %in% 940:997 ~ 11,
             TRUE ~ 12
             )
  ) %>% 
  ungroup() %>%
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
            Unknown = 12))
         )

#### Left Join CIND to IND1990 Crosswalk to the Data
data <- data %>% left_join(cwCIND_IND1990)

#### Join RTI data and CPS data via the occ1990 codes.
rti <- read_csv("../../out/data-management/rti.csv", lazy = FALSE)
data <- data %>% left_join(rti)

## Impute RTI for "Other telecom operators" (349) based on RTI for "Telephone operators" (348)
# Data from the Dictionary of Occupational Titles shows this is reasonable.
data <-
  data %>% 
  # If OCC1990 is 349 ("Other telecom operators") change value, otherwise keep it.
  mutate(RTI = ifelse(OCC1990 == 349,
                      rti %>% filter(occ1990dd == 348) %>% pull(RTI),
                      RTI),
         norm_RTI = ifelse(OCC1990 == 349,
                           rti %>% filter(occ1990dd == 348) %>% pull(norm_RTI),
                           norm_RTI),
         lbl = ifelse(OCC1990 == 349,
                      "Other telecom operators",
                      lbl)
         )

#### Left-outer join data on MW by State, Month, and Year
mw <- read_csv("../../out/data-management/mw.csv", lazy = FALSE)
data <- data %>%
        left_join(mw[,c(2:3,5,11)],
                  by = c("STATEFIP" = "State.Fips",
                         "YEAR" = "Year",
                         "MONTH" = "Month"))


#### Create a State-Area Variable
### Variable is concatenation of the State Name and whether Area is Rural or Urban.
### E.g., Oklahoma - Urban vs Oklahoma - Rural.

## Urban-Rural Classification:
  # Urban areas are defined as regions within a metropolitan area.
  # Rural areas are defined as regions NOT within a metropolitan area.

## Summary Table of the METRO Variable
#      METRO                             n      frequency   
#  NA                                1962649448. 1.88% 
#   0 [Not identifiable]             5953130739. 5.70% 
#   1 [Not in metro area]           19482192746. 18.65%
#   2 [Central city]                26456830797. 25.33%
#   3 [Outside central city]        41519661231. 39.75%
#   4 [Central city status unknown]  8037260852. 7.69% 
#   9 [Missing/Unknown]              1050902193. 1.01% 

## Reduce METRO to a binary variables for Metro or Nonmetro
data <- 
  data %>% 
  mutate(METRO =
           case_when(
             METRO %in% 1 ~ 0,
             METRO %in% 2:4 ~ 1,
             # All other cases are converted to 9s
             TRUE ~ 9
           ) %>% 
           labelled(
             c(Nonmetro = 0,
               Metro = 1,
               "Missing/Unknown" = 9)
           )
         )

## Concatenate the labels for the STATEFIP and METRO variables.
data <- 
  data %>% 
  mutate(STATEAREA =
           paste(STATEFIP %>% as_factor() %>% as.character(),
                 METRO %>% as_factor() %>% as.character(),
                 sep = " - ")
         )

#### Write Modified Data
fwrite(data %>% as.data.table(), file = "../../out/data-management/cps_1976_2018.csv")