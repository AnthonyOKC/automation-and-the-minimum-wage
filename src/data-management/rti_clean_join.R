#### Clean RTI Data & Join to OCC1990 crosswalk
## Import Packages
if (!require("pacman")) install.packages("pacman")
pacman::p_load(
  "tidyverse",
  "haven",
  data.table,
  ipumsr,
  weights
)

## Source: RTI data from David Dorn's publicly available data files
## https://www.ddorn.net/data.htm
  # Occupation codes are slightly modified which is why they are named "occ1990dd" for David Dorn
RTI_data <- read_dta("../data/occ1990dd_RTI.dta")
ddi <- read_ipums_ddi("../data/cps.xml") # Variable Metadata

# Using crosswalk to convert census occupation codes from the '1990dd' to the '1990' standard in RTI data.
cw1990_1990dd <- read_dta("../data/occ1990_occ1990dd.dta")
cw1990_1990dd <-
  cw1990_1990dd %>%
  merge(RTI_data %>% select(occ1990dd, RTIa)) %>% 
  rename(RTI = RTIa, OCC1990 = occ) %>% 
  merge(ipums_val_labels(ddi, OCC1990),
        by.x = 'OCC1990', by.y = 'val') %>% 
  mutate(norm_RTI = stdz(RTI)) # Standardizes the RTI measure.

## Write Data to Disk
write_csv(cw1990_1990dd, "../../out/data-management/rti.csv")