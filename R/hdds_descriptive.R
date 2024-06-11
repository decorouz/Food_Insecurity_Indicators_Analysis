setwd("~/Documents/Dev/Python Programming/Data Science/data_science_with_python")


# Load the neccessary libraries
library(gtsummary)
library(dplyr)
# library(haven)
library(tidyverse)
library(survey)
library("haven")


#--------- Load the data ----------------------
hdds_data <- read.csv("data/hdds_round4_data.csv")

# ------ Demographic and Socioeconomic Descriptive----- 

hdds_data$hdds_class <- factor(hdds_data$hdds_class)


# --------- Turn categorical variables to factor ------
# subset categorical variables
names <- c(1:4, 7, 9:28,30)

# Convert chr columns to categorical
hdds_data <- hdds_data %>%
  mutate(across(all_of(names), as.factor))


str(hdds_data)

# Add Labels
attributes(hdds_data$hh_agricactivity)$label <- "HH Agricultural Activity"
attributes(hdds_data$crp_landsize_ha)$label <- "Cultivated land size"
attributes(hdds_data$hh_size)$label <- "Household size"
attributes(hdds_data$hh_age)$label <- "Household Age"
attributes(hdds_data$hh_gender)$label <- "Household Head gender"
attributes(hdds_data$hh_education)$label <- "Education Level"
attributes(hdds_data$tot_income)$label <- "Total Income"
attributes(hdds_data$tot_income_dollar)$label <- "Total Income($)"
attributes(hdds_data$shock_higherfoodprices)$label <- "Shock from higer food price"
attributes(hdds_data$shock_drought)$label <- "Shock from Drought"
attributes(hdds_data$shock_flood)$label <- "Shock from flood"
attributes(hdds_data$shock_plantdisease)$label <- "Shock from plant disease"
attributes(hdds_data$shock_animaldisease)$label <- "Shock from animal disease"
attributes(hdds_data$shock_violenceinsecconf)$label <- "Shock from conflict"
attributes(hdds_data$hdds_class)$label <- "HDDS category"
attributes(hdds_data$hdds_score)$label <- "HDDS score"
# attributes(hdds_data$hh_wealth_light2)$label <- "Access to Electricity"
# attributes(hdds_data$hh_wealth_water2)$label <- "Access to Safe Water"
# attributes(hdds_data$hh_wealth_toilet2)$label <- "Access to Sanitation"



# Select the column of interest
col_of_interest <- hdds_data %>% select(state,crp_landsize_ha, hh_size, hh_gender,hh_age,
                                        hh_agricactivity, hh_education,tot_income,tot_income_dollar,
                                        shock_higherfoodprices, shock_drought,
                                        shock_flood, shock_plantdisease, shock_animaldisease,
                                        shock_violenceinsecconf, hdds_score, hdds_class)


# Table 5. Parameter estimates of ordinal logistic regression


# ------------------- Weighted Descriptive ---------------------
design.hdds <- svydesign(id=~1, weights=~weight_final, data=hdds_data)

# help(svydesign)
design.hdds %>% 
  tbl_svysummary(
    # Use a character variable here. A factor leads to an error
    by = state,
    # Use include to select variables
    include = c(state, crp_landsize_ha, hh_size, tot_income, tot_income_dollar,
                hh_age,hh_gender, hh_agricactivity, hh_education,
                shock_higherfoodprices, shock_drought,
                shock_flood, shock_plantdisease, 
                shock_animaldisease,
                shock_violenceinsecconf,
                hdds_score, hdds_class),
    statistic = list(all_continuous()  ~ "{mean} ± {sd}",
                     all_categorical() ~ "{n}    ({p}%)"),
    digits = list(all_categorical() ~ c(0, 1)),
    missing = "no"
  ) %>%
  modify_header(label = "**Variable**",
                all_stat_cols() ~ "**{level}**<br>N = {n} ({style_percent(p, digits=1)}%)") %>%
  modify_caption("Weighted descriptive statistics,") %>%
  
  bold_labels()


#------ Table 1: Comparison of household dietary diversity categories HDDS (categorical explanatory variables)
design.hdds %>% 
  tbl_svysummary(
    # Use a character variable here. A factor leads to an error
    by = hdds_class,
    # Use include to select variables
    include = c(state, hh_age,hh_gender, hh_agricactivity, hh_education,
                shock_higherfoodprices, shock_drought,
                shock_flood, shock_plantdisease, 
                shock_animaldisease,
                shock_violenceinsecconf),
    statistic = list(all_continuous()  ~ "{mean} ± {sd}",
                     all_categorical() ~ "{n}    ({p}%)"),
    digits = list(all_categorical() ~ c(0, 1)),
    missing = "no"
  ) %>%
  modify_header(label = "**Variable**",
                all_stat_cols() ~ "**{level}**<br>N = {n} ({style_percent(p, digits=1)}%)") %>%
  modify_caption("Weighted descriptive statistics,") %>%
  
  bold_labels() %>% 
  add_p()


#------ Table 2: Comparison of household dietary diversity categories HDDS (continuous explanatory variables)
design.hdds %>% 
  tbl_svysummary(
    # Use a character variable here. A factor leads to an error
    by = hdds_class,
    # Use include to select variables
    include = c(crp_landsize_ha, hh_size, tot_income, tot_income_dollar),
    statistic = list(all_continuous()  ~ "{mean} ± {sd}",
                     all_categorical() ~ "{n}    ({p}%)"),
    digits = list(all_categorical() ~ c(0, 1)),
    missing = "no"
  ) %>%
  modify_header(label = "**Variable**",
                all_stat_cols() ~ "**{level}**<br>N = {n} ({style_percent(p, digits=1)}%)") %>%
  modify_caption("Weighted descriptive statistics,") %>%
  
  bold_labels() %>% 
  add_p()


# ----------- Table 3. Distribution of respondents by level of household dietary diversity

# Function to calculate the weighted standard deviation
weighted_sd <- function(x, w) {
  sum_w <- sum(w)
  mean_w <- sum(x * w) / sum_w
  sqrt(sum(w * (x - mean_w)^2) / sum_w)
}

# Group by hdds_class and calculate metrics
metrics <- hdds_data %>%
  group_by(hdds_class) %>%
  summarise(
    Frequency = n(),
    Percentage = (n() / nrow(hdds_data)) * 100,
    Mean = weighted.mean(hdds_score, weight_final),
    SD = weighted_sd(hdds_score, weight_final),
    Max = max(hdds_score),
    Min = min(hdds_score)
  )


#------ Table 4: Household dietary diversity category -----
design.hdds %>% 
  tbl_svysummary(
    # Use a character variable here. A factor leads to an error
    # by = hdds_class,
    # Use include to select variables
    include = c(hdds_cereals, hdds_rootstubers, hdds_rootstubers, hdds_vegetables,
                hdds_fruits, hdds_meat, hdds_eggs, hdds_fish, hdds_legumes, hdds_milkdairy,
                hdds_oils, hdds_sugar, hdds_condiments),
    statistic = list(all_continuous()  ~ "{mean} ± {sd}",
                     all_categorical() ~ "{n}    ({p}%)"),
    digits = list(all_categorical() ~ c(0, 1)),
    missing = "no"
  ) %>%
  modify_header(label = "**Variable**",
                all_stat_cols() ~ "**{level}**<br>N = {n} ({style_percent(p, digits=1)}%)") %>%
  modify_caption("Weighted descriptive statistics,") %>%
  bold_labels()


# ---------------------Ordinal Logistic Regresion ---
library(VGAM)
# Fit the vector generalized linear model
fit_vglm <- vglm(hdds_class ~ state+
                   hh_size +
                   hh_agricactivity +
                   hh_gender +
                   hh_education +
                   tot_income_dollar +
                   shock_higherfoodprices +
                   shock_drought + 
                   shock_flood +
                   shock_plantdisease +
                   shock_animaldisease +
                   shock_violenceinsecconf,
                 family = cumulative(parallel = TRUE),
                 weights = weight_final,
                 data = hdds_data)


# Summary of the model
summary(fit_vglm)

# -------------------CLM: Ordinal Logistic Regression ---------------------
install.packages("ordinal")
library(ordinal)
library(gt)
# Fit the vector generalized linear model
fit_clm <- clm(hdds_class ~ state+
                   hh_size +
                   hh_agricactivity +
                   hh_gender +
                   hh_education +
                   tot_income_dollar +
                   shock_higherfoodprices +
                   shock_drought + 
                   shock_flood +
                   shock_plantdisease +
                   shock_animaldisease +
                   shock_violenceinsecconf,
                 weights = weight_final,
                 data = hdds_data)



step_fit <- step(fit_clm)
# Summary of the model
summary(step_fit)
clm_table <- gt(tidy(step_fit)) %>%
  tab_header(title = "Summary of Ordinal Logistic Regression Model (clm)") %>%
  fmt_number(columns = vars(estimate, std.error, statistic, p.value), decimals = 3) %>%
  cols_label(estimate = "Estimate", std.error = "Std. Error", statistic = "Z Value", p.value = "P Value") %>%
  tab_footnote(
    footnote = "Ordinal Logistic Regression using clm",
    locations = cells_title(groups = "title")
  ) %>%
  tab_options(
    table.font.size = "small",
    table.font.names = "Arial"
  )

clm_table

tbl_regression(step_fit, exponentiate=TRUE)

# ------------- Ordinall Logistic Regression SVYOLR -------
library(broom)
library(MASS)
ologit1 <- polr(hdds_class~
                  # state+
                    hh_size +
                    # hh_agricactivity +
                    hh_gender +
                    # hh_education +
                    tot_income_dollar +
                    shock_higherfoodprices +
                    shock_drought + 
                    shock_flood +
                    shock_plantdisease +
                    shock_animaldisease +
                    shock_violenceinsecconf, 
                  weights = weight_final, 
                data=hdds_data,
                method = c("logistic"))

tidy(ologit1, p.values = TRUE)

# ------- Poisson regression
#Poisson regression can be run. This is a type of count model (meaning that the outcome variable should be a count).

hdds_poison <- svyglm(hdds_score~state+
                 hh_size +
                 hh_agricactivity +
                 hh_gender +
                 hh_education +
                 tot_income_dollar +
                 shock_higherfoodprices +
                 shock_drought + 
                 shock_flood +
                 shock_plantdisease +
                 shock_animaldisease +
                 shock_violenceinsecconf,
               design=design.hdds, family=poisson())

??svyglm
tbl_regression(hdds_poison, exponentiate=TRUE)

