setwd("~/Documents/Dev/Python Programming/Data Science/data_science_with_python/FIES")

# Import the necessary libraries

library(gtsummary)
library(car)
library(ggplot2)
library(sjPlot)
# library(MASS)
# library(lmtest)
# library(caret)
# 
library( "censReg" )
library(dplyr)



# Load the data 
fies_data <- read.csv("../FIES/FAO_NG_6/data/26052024_model_ready_data.csv")


# Categorize rawscore to 0-3, 4-6, 7-8

# Define the breaks for grouping
breaks <- c(-Inf, 3, 6, Inf)

# Define labels for the groups
labels <- c("0-3", "4-6", "7-8")

# Bin the data into groups
fies_data$fies_cat2<- cut(fies_data$fies_rawscore, breaks = breaks, labels = labels, right = TRUE)



# subset categorical variables
names <- c(1:4, 6:7,9:46,54)

# Convert chr columns to categorical
fies_data <- fies_data %>%
  mutate(across(all_of(names), as.factor))


# View the description of the data
str(fies_data)



# ------ Create a new column with the reduced levels ----
# hh_wealth electricity
fies_data <- fies_data %>%
  mutate(hh_wealth_light2 = case_when(
    hh_wealth_light %in% c("1") ~ "Power grid/generator",
    hh_wealth_light %in% c("2", "3", "5", "4", "666") ~ "Other Sources"
  ))

# hh_wealth toilet
fies_data <- fies_data %>%
  mutate(hh_wealth_toilet2 = case_when(
    hh_wealth_toilet %in% c("1") ~ "Toilet with water",
    hh_wealth_toilet %in% c("2", "3", "4") ~ "Toilet without water",
    hh_wealth_toilet %in% c("777") ~ "Bush"
  ))

# hh_wealth water
fies_data <- fies_data %>%
  mutate(hh_wealth_water2 = case_when(
    hh_wealth_water %in% c("1", "2", "3", "4", "5") ~ "Tap or other safe source",
    hh_wealth_water %in% c("6", "7", "8", "9", "10") ~ "Unsafe sources",

  ))

# Employment
fies_data <- fies_data %>%
  mutate(income_main_cat2 = case_when(
    income_main_cat %in% c("Agricultural employment") ~ "Agricutlture",
    income_main_cat %in% c("Income from charity and remittance", 
                           "Non Agricultural employment") ~ "Other Source",
    income_main_cat %in% c("No Employment") ~ "Unemployed",
    
  ))

str(fies_data$income_main_cat2)
# Convert the new variable to factor
# fies_data$hh_wealth_light2 <- factor(fies_data$hh_wealth_light2)
# fies_data$hh_wealth_toilet2 <- factor(fies_data$hh_wealth_toilet2)
# fies_data$hh_wealth_water2 <- factor(fies_data$hh_wealth_water2)
fies_data$income_main_cat2 <- factor(fies_data$income_main_cat2)

fies_data$state <- factor(fies_data$state)

str(fies_data)

# Drop certain columns
# fies_data <- fies_data %>%  drop


# Partition data 80% train and 20% test
set.seed(733445)
# index_set <- sample(2, nrow(fies_data), replace = T, prob = c(0.8, 0.2))
# train <- fies_data[index_set == 1,]
# test <- fies_data[index_set == 2,]

##------------- Logistic Model -------------

str(fies_data$income_main_cat2)
table(fies_data$income_main_cat2)


## --------------------------- Uni variate ----------------------------------
fies_data$hh_agricactivity <- relevel(fies_data$hh_agricactivity, ref = "No")
fies_data$income_main_control <- relevel(fies_data$income_main_control, ref = "2")
fies_data$hh_education <- relevel(fies_data$hh_education, ref = "No Education")

fies_data$income_main_cat <- relevel(fies_data$income_main_cat, ref = "No Employment")

fies_data$land_by_hh_size<- fies_data$crp_landsize_ha / fies_data$hh_size

model_ds <- fies_data[c("dichotomized_prob_sev", 
            "state",
            "hh_size",
            "hh_age",
            "crp_landsize_ha",
            "land_by_hh_size",
            "hh_agricactivity",
            "hh_gender",
            "hh_education",
            "income_main_cat",
            "income_more_than_one",
            "income_main_control",
            "wealth_quintile",
            "hh_maritalstat_clean",
            "shock_higherfoodprices",
            "shock_drought",
            "shock_flood",
            "shock_plantdisease",
            "shock_animaldisease",
            "shock_violenceinsecconf",
            "weight_final")]
# clean_data <- na.omit(model_ds)

tbl_uv_ex1 <-
  tbl_uvregression(
    fies_data[c("dichotomized_prob_sev", 
                "state",
                "hh_size",
                "hh_age",
                "crp_landsize_ha",
                "land_by_hh_size",
                "hh_agricactivity",
                "hh_gender",
                "hh_education",
                "income_main_cat",
                "income_more_than_one",
                "income_main_control",
                "wealth_quintile",
                "hh_maritalstat_clean",
                "shock_higherfoodprices",
                "shock_drought",
                "shock_flood",
                "shock_plantdisease",
                "shock_animaldisease",
                "shock_violenceinsecconf")],
    method = glm,
    y = dichotomized_prob_sev,
    method.args = list(family = binomial, weights = fies_data$weight_final,
                       # na.action = na.omit 
                       ),
    exponentiate = TRUE
  ) %>% 
  bold_labels()
tbl_uv_ex1


# ------------------ Multivariate Logistic Regression ------------

model_prob <- glm(dichotomized_prob_sev ~ state + 
                    hh_size +
                    hh_age +
                    crp_landsize_ha +
                    # land_by_hh_size+
                    hh_agricactivity + 
                    hh_gender +
                    hh_education +
                    income_more_than_one +
                    C(income_main_control) +
                    hh_maritalstat_clean + 
                    # shock_higherfoodprices +
                    shock_drought + 
                    shock_plantdisease +
                    shock_animaldisease +
                    shock_violenceinsecconf,
                  na.action = na.omit,
                  weights = weight_final,
                  data = fies_data, family = "binomial")

tbl_regression(model_prob, exponentiate = TRUE)


## ---------------- Omnibus Test -----------------


# Fit the null model (intercept only)
null_model <- glm(dichotomized_prob_sev ~ 1, data = clean_data, family = binomial)


# Perform the omnibus test using the likelihood ratio test
anova(null_model, model_prob, test = "Chisq")

## ------------------------ No Multicollinearity -------------------
vif(model_prob)


# model_06 <- glm(dichotomized_prob_sev ~
#                   state+
#                   # hh_size +
#                   crp_landsize_ha +
#                   hh_agricactivity+
#                   # wealth_quintile +
#                   hh_gender +
#                   # hh_age + 
#                   hh_education +
#                   # income_main_cat2+
#                   # # relevel(income_main_cat2, ref="Not Agric Employed")+
#                   # # relevel(income_main_cat, ref="No Employment")+
#                   income_more_than_one +
#                   income_main_control+
#                   # hh_maritalstat_clean +
#                   shock_higherfoodprices +
#                   shock_drought + 
#                   # shock_flood +
#                   shock_plantdisease +
#                   shock_animaldisease +
#                   shock_violenceinsecconf,
#               na.action = na.omit,
#               weights = weight_final,
#               data = fies_data, family = "binomial")
# tbl_regression(model_06, exponentiate = TRUE)









## ---------------------------Chi Test Statistical test for coping strategies and FIES----------------------------------

fies_data$rcsi_lpf <- factor(ifelse(fies_data$rcsi_less_preferred_foods > 0, 1, 0), 
                             levels = c(0, 1), labels = c("No", "Yes"))
fies_data$rcsi_bf <- factor(ifelse(fies_data$rcsi_borrowed_food > 0, 1, 0), 
                            levels = c(0, 1), labels = c("No", "Yes"))
fies_data$rcsi_rdm <- factor(ifelse(fies_data$rcsi_reduce_number_meals > 0, 1, 0), 
                              levels = c(0, 1), labels = c("No", "Yes"))
fies_data$rcsi_lp <- factor(ifelse(fies_data$rcsi_limit_portions > 0, 1, 0), 
                            levels = c(0, 1), labels = c("No", "Yes"))
fies_data$rcsi_rad <- factor(ifelse(fies_data$rcsi_restrict_adult_consumpt > 0, 1, 0), 
                             levels = c(0, 1), labels = c("No", "Yes"))

# Create a contingency table
rcsi_tab_1 = table(fies_data$rcsi_lpf, fies_data$dichotomized_prob_sev)

chisq.test(rcsi_tab_1)

rcsi_tab_2 = table(fies_data$rcsi_bf , fies_data$dichotomized_prob_sev)
chisq.test(rcsi_tab_2)
rcsi_tab_2

rcsi_tab_3 = table(fies_data$rcsi_rdm, fies_data$dichotomized_prob_sev)
chisq.test(rcsi_tab_3)

rcsi_tab_4 = table(fies_data$rcsi_lp, fies_data$dichotomized_prob_sev)
chisq.test(rcsi_tab_4)

rcsi_tab_5 = table(fies_data$rcsi_rad, fies_data$dichotomized_prob_sev)
chisq.test(rcsi_tab_5)



tbl <-
  fies_data %>%
  select(rcsi_lpf, rcsi_bf, rcsi_rdm, rcsi_lp, rcsi_rad, dichotomized_prob_sev) %>%
  tbl_summary(by = dichotomized_prob_sev) %>%
  add_p(test = all_categorical() ~ "chisq.test") %>%
  # add a header to the statistic column, which is hidden by default
  # adding the header will also unhide the column
  modify_header(statistic ~ "**Test Statistic**") %>%
  modify_fmt_fun(statistic ~ style_sigfig)
tbl

