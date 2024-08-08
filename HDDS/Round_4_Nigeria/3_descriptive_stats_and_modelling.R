setwd("~/Documents/Dev/Python Programming/Data Science/data_science_with_python/HDDS/Round_4_Nigeria")


# Load the neccessary libraries
library(gtsummary)
library(dplyr)
# library(haven)
library(tidyverse)
library(survey)
library("haven")


#--------- Load the data ----------------------
hdds_data <- read.csv("../../data/DIEM_NG/hdds_round4_data.csv")

# ------ Demographic and Socioeconomic Descriptive----- 

hdds_data$hdds_class <- factor(hdds_data$hdds_class)


# --------- Turn categorical variables to factor ------
# subset categorical variables
names <- c(1:4, 7, 9:29,31, 42)



# Convert chr columns to categorical
hdds_data <- hdds_data %>%
  mutate(across(all_of(names), as.factor))

str(hdds_data)


# ------------ Normalize reorder 
# Z-score normalization income variable

# Z-score normalization cultivated landsize variable
min_max_normalize <- function(x) {
  return((x - min(x)) / (max(x) - min(x)))
}


hdds_data$income_dollar_normalized <- min_max_normalize(hdds_data$tot_income_dollar)



# Normalize land size using Min-Max normalization
hdds_data$land_size_normalized <- min_max_normalize(hdds_data$crp_landsize_ha)

# Convert the response variable to an ordered factor
hdds_data$response <- ordered(hdds_data$hdds_class, levels = c("Low", "Medium", "High"))

str(hdds_data)
# ----- Descriptive for FCS- -----------
# 0 - 21 : Poor
# 21.5 - 35 : Borderline
# >35 : Acceptable
hdds_data$fcg_cat <- factor(hdds_data$fcg,
                            levels = c(1,2,3),
                            labels = c("0-21: Poor", "21.5-35: Borderline", " >35: Acceptable"))

# --- Reset the levels
hdds_data$hh_agricactivity <- relevel(hdds_data$hh_agricactivity, ref = "No")

# hdds_data$income_main_cat <- relevel(hdds_data$income_main_cat, ref = "No Employment")


# Recode TRUE/FALSE to Yes/No
# hdds_data$shock_climate <- fct_recode(hdds_data$shock_climate, Yes = "True", No = "False")


# Add Labels
attributes(hdds_data$hh_agricactivity)$label <- "HH Agricultural Activity"
attributes(hdds_data$crp_landsize_ha)$label <- "Cultivated land size"
attributes(hdds_data$land_size_normalized)$label <- "Normalized Cultivated land size"
attributes(hdds_data$hh_size)$label <- "Household size"
attributes(hdds_data$hh_age)$label <- "Household Age"
attributes(hdds_data$hh_gender)$label <- "Household Head gender"
attributes(hdds_data$hh_education)$label <- "Education Level"
attributes(hdds_data$tot_income)$label <- "Total Income"
attributes(hdds_data$tot_income_dollar)$label <- "Total Income($)"
attributes(hdds_data$income_dollar_normalized)$label <- "Total Income Normalized ($)"
attributes(hdds_data$shock_higherfoodprices)$label <- "Shock from higer food price"
attributes(hdds_data$shock_drought)$label <- "Shock from Drought"
attributes(hdds_data$shock_flood)$label <- "Shock from flood"
attributes(hdds_data$shock_plantdisease)$label <- "Shock from plant disease"
attributes(hdds_data$shock_animaldisease)$label <- "Shock from animal disease"
attributes(hdds_data$shock_violenceinsecconf)$label <- "Shock from conflict"
attributes(hdds_data$shock_climate)$label <- "Shock from climate"
attributes(hdds_data$response)$label <- "HDDS category"
attributes(hdds_data$hdds_score)$label <- "HDDS score"
attributes(hdds_data$fcg)$label <- "FCS Categories: 21/35 thresholds"
attributes(hdds_data$FI_0_6)$label <- "Food insecurity scale"
attributes(hdds_data$fies_cat)$label <- "Food insecurity category"

# attributes(hdds_data$hh_wealth_light2)$label <- "Access to Electricity"
# attributes(hdds_data$hh_wealth_water2)$label <- "Access to Safe Water"
# attributes(hdds_data$hh_wealth_toilet2)$label <- "Access to Sanitation"

# ------------Set reference -----
hdds_data$hh_agricactivity <- relevel(hdds_data$hh_agricactivity, ref = "No")
# hdds_data$income_main_control <- relevel(hdds_data$income_main_control, ref = "2")
hdds_data$hh_education <- relevel(hdds_data$hh_education, ref = "No Education")
# hdds_data$income_main_cat <- relevel(hdds_data$income_main_cat, ref = "No Employment")




# # Select the column of interest
# col_of_interest <- hdds_data %>% select(state,crp_landsize_ha, hh_size, hh_gender,hh_age,
#                                         hh_agricactivity, hh_education,tot_income,tot_income_dollar,
#                                         shock_higherfoodprices, shock_drought,
#                                         shock_flood, shock_plantdisease, shock_animaldisease,
#                                         shock_violenceinsecconf, hdds_score, hdds_class, fcg)




design.hdds <- svydesign(id=~1, weights=~weight_final, data=hdds_data)


# ---------- Weighted Descriptive Statistics by State and without----------------------------------------#
design.hdds %>% 
  tbl_svysummary(
    # Use a character variable here. A factor leads to an error
    by = state,
    # Use include to select variables
    include = c(state, crp_landsize_ha,land_size_normalized,
                hh_size, tot_income, tot_income_dollar,
                hh_age, hh_gender, hh_agricactivity, hh_education,
                FI_0_6,fies_cat,
                hdds_score, response,
                shock_climate),
    statistic = list(all_continuous()  ~ "{mean} ± {sd}",
                     all_categorical() ~ "{n}    ({p}%)"),
    digits = list(all_categorical() ~ c(0, 1)),
    missing = "no"
  ) %>%
  modify_header(label = "**Variable**",
                all_stat_cols() ~ "**{level}**<br>N = {n} ({style_percent(p, digits=1)}%)") %>%
  modify_caption("Weighted descriptive statistics,") %>%
  
  bold_labels()



# ------------------- Weighted Descriptive FCG ---------------------

design.hdds %>% 
  tbl_svysummary(
    # Use a character variable here. A factor leads to an error
    # by = state,
    # Use include to select variables
    include = c(fcg_cat),
    statistic = list(all_continuous()  ~ "{mean} ± {sd}",
                     all_categorical() ~ "{n}    ({p}%)"),
    digits = list(all_categorical() ~ c(0, 1)),
    missing = "no"
  ) %>%
  modify_header(label = "**Variable**",
                all_stat_cols() ~ "**{level}**<br>N = {n} ({style_percent(p, digits=1)}%)") %>%
  modify_caption("Weighted descriptive statistics,") %>%
  
  bold_labels()
  # add_overall()




#------ Table 1: Comparison of household dietary diversity categories HDDS (categorical explanatory variables)
design.hdds %>% 
  tbl_svysummary(
    # Use a character variable here. A factor leads to an error
    by = hdds_class,
    # Use include to select variables
    include = c(state, hh_age,hh_gender, hh_agricactivity, hh_education,
                tot_income, tot_income_dollar,
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



#------ Table 4: Weighted descriptive Household dietary diversity category -----
design.hdds %>% 
  tbl_svysummary(
    # Use a character variable here. A factor leads to an error
    # by = state,
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



# -------------------- Univariate Poisson regression --------



tbl_uvregression(
  hdds_data[c("hdds_score",
              "state",
              "hh_age",
              "hh_size",
              "land_size_normalized",
              # "tot_income_dollar",
              "income_dollar_normalized",
              "hh_agricactivity",
              "hh_gender",
              "hh_education",
              "shock_climate",
              "FI_0_6"
              )],
  method = glm,
  y = hdds_score,
  method.args = list(family = poisson(), weights = hdds_data$weight_final,
                     na.action = na.omit ),
  exponentiate = TRUE
) %>% 
bold_labels()


# --------------------- Poisson Multivariate regression ----------------------------
#Poisson regression can be run. This is a type of count model (meaning that the outcome variable should be a count).

hdds_poison <- svyglm(hdds_score~
                        state+
                        hh_size +
                        hh_agricactivity +
                        hh_education +
                        income_dollar_normalized +
                        shock_climate+
                        FI_0_6,
               design=design.hdds, family=poisson())



summary(hdds_poison, df.resid = degf(design.hdds))

# Calculating the VIF
library(car)
vif_values <- vif(hdds_poison)
#----------------- Tidy the model summary
library(broom)
library(knitr)
library(dplyr)
library(kableExtra)


tidy_hdds<- tidy(hdds_poison)

# Add asterisks for different significance levels and combine estimate and standard error with HTML line breaks
tidy_hdds <- tidy_hdds %>%
  mutate(
    p.value = round(p.value, 4),
    estimate_se = case_when(
      p.value < 0.001 ~ paste0(format(round(estimate, 4), nsmall = 4), "***", "<br>(", round(std.error, 4), ")"),
      p.value < 0.01 ~ paste0(format(round(estimate, 4), nsmall = 4), "**", "<br>(", round(std.error, 4), ")"),
      p.value < 0.05 ~ paste0(format(round(estimate, 4), nsmall = 4), "*", "<br>(", round(std.error, 4), ")"),
      p.value > 0.05 ~ paste0(format(round(estimate, 4), nsmall = 4), "<br>(", round(std.error, 4), ")"),
      p.value > 0.05 ~ paste0(format(round(estimate, 4), nsmall = 4), "<br>(", round(std.error, 4), ")"),
      TRUE ~ format(round(estimate, 4), nsmall = 4)
    ),
    statistic = round(statistic, 4)
  )

# Select and arrange columns for the final table
tidy_hdds <- tidy_hdds %>%
  select(term, estimate_se, p.value)

# Format the table using kable and kableExtra for additional styling
tidy_hdds %>%
  kable(
    format = "html",
    escape = FALSE, # Allow HTML tags
    col.names = c("Term", "Estimate<br>(Std Error)", "P value"),
    caption = "Logistic Regression Results"
  ) %>%
  kable_styling(full_width = FALSE, position = "center")



# ----------------Ordinal Least Square Regression ----------------
ols_hdds <- svyglm(hdds_score~
                        state+
                        hh_size +
                        hh_agricactivity +
                        hh_education +
                        income_dollar_normalized +
                        shock_climate+
                        FI_0_6,
                      design=design.hdds)

tidy_ols_hdds<- tidy(ols_hdds)

tidy_ols_hdds <- tidy_ols_hdds %>%
  mutate(
    p.value = round(p.value, 4),
    estimate_se = case_when(
      p.value < 0.001 ~ paste0(format(round(estimate, 4), nsmall = 4), "***", "<br>(", round(std.error, 4), ")"),
      p.value < 0.01 ~ paste0(format(round(estimate, 4), nsmall = 4), "**", "<br>(", round(std.error, 4), ")"),
      p.value < 0.05 ~ paste0(format(round(estimate, 4), nsmall = 4), "*", "<br>(", round(std.error, 4), ")"),
      p.value > 0.05 ~ paste0(format(round(estimate, 4), nsmall = 4), "<br>(", round(std.error, 4), ")"),
      p.value > 0.05 ~ paste0(format(round(estimate, 4), nsmall = 4), "<br>(", round(std.error, 4), ")"),
      TRUE ~ format(round(estimate, 4), nsmall = 4)
    ),
    statistic = round(statistic, 4)
  )

# Select and arrange columns for the final table
tidy_ols_hdds <- tidy_ols_hdds %>%
  select(term, estimate_se, p.value)

# Format the table using kable and kableExtra for additional styling
tidy_ols_hdds %>%
  kable(
    format = "html",
    escape = FALSE, # Allow HTML tags
    col.names = c("Term", "Estimate<br>(Std Error)", "P value"),
    caption = "OLS Regression Results for determinant of HDDS"
  ) %>%
  kable_styling(full_width = FALSE, position = "center")

# ------ End of OLS regression -------------




# --------- Magnitude and Determinant of Animal Source Food---------

# Create a new variable animal source food `asf`
hdds_data <- hdds_data %>% 
  mutate(asf = case_when(hdds_meat == "1" | hdds_eggs == "1" | hdds_fish == "1" ~ "1",
                         TRUE ~ "0" ))

# Turn to factor
hdds_data$asf <- factor(hdds_data$asf)

design.hdds <- svydesign(id=~1, weights=~weight_final, data=hdds_data)

# 
# ---------------- Multivariate Rgression with Specific food group as dependent variables --
library(broom)
library(knitr)
library(dplyr)
library(kableExtra)

# hdds_meat
# hdds_eggs
# hdds_fish
# hdds_legumes
# hdds_fruits
# hdds_milkdairy

str(hdds_data)

model_1 <- glm(hdds_milkdairy ~
                state+
                hh_age+
                hh_size +
                land_size_normalized+
                relevel(hh_agricactivity, ref="No") +
                hh_gender +
                 relevel(hh_education, ref="No Education") +
                land_size_normalized+
                income_dollar_normalized +
                FI_0_6 +
                shock_climate,
                na.action = na.omit,
                weights = weight_final,
                data = hdds_data, family = "binomial")


# Tidy the model summary
tidy_log_model <- tidy(model_1)

# Add asterisks for different significance levels and combine estimate and standard error with HTML line breaks
tidy_log_model <- tidy_log_model %>%
  mutate(
    p.value = case_when(
      p.value < 0.001 ~ paste0(format(round(p.value, 4), nsmall = 4), "***"),
      p.value < 0.01 ~ paste0(format(round(p.value, 4), nsmall = 4), "**"),
      p.value < 0.05 ~ paste0(format(round(p.value, 4), nsmall = 4), "*"),
      TRUE ~ format(round(p.value, 4), nsmall = 4)
    ),
    estimate_se = paste0(round(estimate, 4), "<br>(", round(std.error, 4), ")"),
    statistic = round(statistic, 4)
  )

# Select and arrange columns for the final table
tidy_log_model <- tidy_log_model %>%
  select(term, estimate_se, p.value)

# Format the table using kable and kableExtra for additional styling
publication_ready_table <- tidy_log_model %>%
  kable(
    format = "html",
    escape = FALSE, # Allow HTML tags
    col.names = c("Term", "Estimate<br>(Std Error)", "P value"),
    caption = "Logistic Regression Results"
  ) %>%
  kable_styling(full_width = FALSE, position = "center")

# Print the table
publication_ready_table
