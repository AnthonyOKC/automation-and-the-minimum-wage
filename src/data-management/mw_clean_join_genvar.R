### Clean Minimum Wage Data, Adjust to 2015 Dollars, and Compute Moving Average
## Import Packages
if (!require("pacman")) install.packages("pacman")
pacman::p_load(
  "tidyverse",
  pracma
)

## Import State Monthly MW data
# Source: David Neumark Public Data Files
# https://www.economics.uci.edu/~dneumark/datasets.html
mw <- read.csv("../data/state_mw_monthly.csv")

## PCE Chained Price Index
# Source: U.S. Bureau of Economic Analysis,
# Personal Consumption Expenditures: Chain-type Price Index [PCEPI],
# retrieved from FRED, Federal Reserve Bank of St. Louis
# https://fred.stlouisfed.org/series/PCEPI
pce <- read_csv("../data/PCEPI.csv")

## Adjust MW to 2015 dollars.
pce <- 
  pce %>% 
    separate(DATE, into = c("Year", "Month"), sep ="-", extra = "drop") %>% 
    mutate(Year = as.numeric(Year),
           Month = as.numeric(Month)) %>% 
    rename(pce = names(pce)[2])
pce2015 <- 
  pce %>% 
    filter(Year == 2015) %>% 
    pull(pce) %>% 
    mean()
mw <- 
  mw %>% 
  left_join(pce) %>% 
  mutate(mw_real2015 = MW * (pce2015 / pce))

## Moving Average of mw_real2015
  # 12-Month Moving Average means current month and prior 11 months.
mw <-
  mw %>%
  group_by(State.Fips) %>%
  mutate(mw_real2015_12month_movavg = movavg(mw_real2015, n = 12, type = "s"))

mw <-
  mw %>%
    group_by(Year, State.Fips) %>% 
    mutate(mw_yearly_real2015_12month_movavg = mean(mw_real2015_12month_movavg))

## Write Data to Disk
write_csv(mw, "../../out/data-management/mw.csv")