setwd("~/Documents/Dev/Python Programming/Data Science/data_science_with_python")

# Load the neccessary libraries
library(gtsummary)
library(dplyr)
# library(haven)
# library(tidyverse)
library(survey)

# ------ Demographic and Socioeconomic Descriptive----- 

fies_data$FI_cat <- factor(fies_data$FI_0_6)

# Add Labels
attributes(fies_data$hh_agricactivity)$label <- "HH Agricultural Activity"
attributes(fies_data$crp_landsize_ha)$label <- "Cultivated land size"
attributes(fies_data$hh_size)$label <- "Household size"
attributes(fies_data$hh_education)$label <- "Education Level"
attributes(fies_data$income_main_cat)$label <- "Main Employment"
attributes(fies_data$income_more_than_one)$label <- "More than one employment"
attributes(fies_data$hh_maritalstat_clean)$label <- "Marital Status"
attributes(fies_data$shock_higherfoodprices)$label <- "Shock from higer food price"
attributes(fies_data$shock_drought)$label <- "Shock from Drought"
attributes(fies_data$shock_flood)$label <- "Shock from flood"
attributes(fies_data$shock_plantdisease)$label <- "Shock from plant disease"
attributes(fies_data$shock_animaldisease)$label <- "Shock from animal disease"
attributes(fies_data$shock_violenceinsecconf)$label <- "Shock from conflict"
attributes(fies_data$hh_wealth_light2)$label <- "Access to Electricity"
attributes(fies_data$hh_wealth_water2)$label <- "Access to Safe Water"
attributes(fies_data$hh_wealth_toilet2)$label <- "Access to Sanitation"
attributes(fies_data$FI_cat)$label <- "Food insecurity"

# Select the column of interest
col_of_interest <- fies_data %>% select(crp_landsize_ha, hh_size,
                              hh_agricactivity, hh_education,hh_maritalstat_clean,
                              income_main_cat, income_more_than_one,
                              shock_higherfoodprices, shock_drought,
                              shock_flood, shock_plantdisease, shock_animaldisease,
                              shock_violenceinsecconf,
                              hh_wealth_light2, hh_wealth_water2, hh_wealth_toilet2,
                              FI_cat)
# Survey desgin
design.fies <- svydesign(id=~1, weights=~weight_final, data=fies_data)


# -------------- Create the Unweighted descriptive table -----------
tbl_summary(col_of_interest, type = list(c(crp_landsize_ha, hh_size) ~ "continuous"),
            statistic = list(all_continuous() ~ "{mean} ({sd})",
                             all_categorical() ~ "{n} ({p}%)"),
            digits = list(all_categorical() ~ c(0, 1),
                          all_continuous() ~ c(2, 2, 0) 
                          ),
            missing = "no") %>% 
  add_n() 

# ------------------- Weighted Descriptive ---------------------
design.fies <- svydesign(id=~1, weights=~weight_final, data=fies_data)

# help(svydesign)
design.fies %>% 
  tbl_svysummary(
    # Use a character variable here. A factor leads to an error
    # by = state,
    # Use include to select variables
    include = c(crp_landsize_ha, hh_size,
                hh_agricactivity, hh_education,hh_maritalstat_clean,
                income_main_cat, income_more_than_one,
                shock_higherfoodprices, shock_drought,
                shock_flood, shock_plantdisease, shock_animaldisease,
                shock_violenceinsecconf,
                hh_wealth_light2, hh_wealth_water2, hh_wealth_toilet2,
                FI_cat),
    statistic = list(all_continuous()  ~ "{mean} ± {sd}",
                     all_categorical() ~ "{n}    ({p}%)"),
    digits = list(all_categorical() ~ c(0, 1)),
    missing = "no"
  ) %>%
  modify_header(label = "**Variable**",
                all_stat_cols() ~ "**{level}**<br>N = {n} ({style_percent(p, digits=1)}%)") %>%
  modify_caption("Weighted descriptive statistics, by smoking status") %>%

  bold_labels()




# ------------------- Weighted Descriptive ---------------------
design.fies <- svydesign(id=~1, weights=~weight_final, data=fies_data)


design.fies %>% 
  tbl_svysummary(
    # Use a character variable here. A factor leads to an error
    by = state,
    # Use include to select variables
    include = c(FI_0_6, crp_landsize_ha, hh_size,
                hh_agricactivity, hh_education,hh_maritalstat_clean,
                income_main_cat, income_more_than_one,
                shock_higherfoodprices, shock_drought,
                shock_flood, shock_plantdisease, shock_animaldisease,
                shock_violenceinsecconf,
                hh_wealth_light2, hh_wealth_water2, hh_wealth_toilet2,
                FI_cat),
    statistic = list(all_continuous()  ~ "{mean} ({sd})",
                     all_categorical() ~ "{n}    ({p}%)"),
    digits = list(all_categorical() ~ c(0, 1)),
    missing = "no"
  ) %>%
  modify_header(label = "**Variable**",
                all_stat_cols() ~ "**{level}**<br>N = {n} ({style_percent(p, digits=1)}%)") %>%
  modify_caption("Weighted descriptive statistics, by smoking status") %>%
  bold_labels()
