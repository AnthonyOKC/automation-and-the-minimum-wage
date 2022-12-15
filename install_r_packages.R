if (!require("pacman")) install.packages("pacman")
pacman::p_load(
  "tidyverse",
  "haven",
  data.table,
  ipumsr,
  labelled,
  weights,
  rlang,
  Hmisc,
  pracma,
  fixest,
  gsubfn,
  kableExtra,
  modelsummary
)