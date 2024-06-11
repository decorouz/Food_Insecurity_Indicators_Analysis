setwd("~/Documents/Dev/Python Programming/Data Science/data_science_with_python")

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
fies_data <- read.csv("data/26052024_model_ready_data.csv")

# Categorize rawscore to 0-3, 4-6, 7-8

# Define the breaks for grouping
breaks <- c(-Inf, 3, 6, Inf)

# Define labels for the groups
labels <- c("0-3", "4-6", "7-8")

# Bin the data into groups
fies_data$fies_cat2<- cut(fies_data$fies_rawscore, breaks = breaks, labels = labels, right = TRUE)


str(fies_data)
# subset categorical variables
names <- c(1:4, 6:7,9:46,49)

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
    income_main_cat %in% c("Agricultural employment") ~ "Agric Employed",
    income_main_cat %in% c("Income from charity and remittance", 
                           "Non Agricultural employment") ~ "No Agric Employed",
    income_main_cat %in% c("No Employment") ~ "Unemployed",
    
  ))

# Convert the new variable to factor
fies_data$hh_wealth_light2 <- factor(fies_data$hh_wealth_light2)
fies_data$hh_wealth_toilet2 <- factor(fies_data$hh_wealth_toilet2)
fies_data$hh_wealth_water2 <- factor(fies_data$hh_wealth_water2)
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
summary(glm(FI_0_6 ~hh_gender,
    na.action = na.omit,
    weights = weight_final,
    data = fies_data, family = "binomial"))

model_06 <- glm(FI_0_6 ~
                  state+
                  hh_size +
                  crp_landsize_ha +
                  relevel(hh_agricactivity, ref="No") +
                  hh_gender +
                  hh_education +
                  # relevel(income_main_cat2, ref="Unemployed")+
                  relevel(income_main_cat, ref="No Employment")+
                  income_more_than_one +
                  income_main_control+
                  hh_maritalstat_clean +
                  shock_higherfoodprices +
                  shock_drought + 
                  shock_flood +
                  shock_plantdisease +
                  shock_animaldisease +
                  shock_violenceinsecconf,
              na.action = na.omit,
              weights = weight_final,
              data = fies_data, family = "binomial")

summary(model_06)

tbl_regression(model_06, exponentiate = TRUE)



# Improve the model with stepAIC
model3 <- step(model_06, direction = "both")


tbl_regression(model3, exponentiate = TRUE)



## ---------------- Omnibus Test -----------------

# Fit the null model (intercept only)
null_model <- glm(FI_0_6 ~ 1, data = fies_data, family = binomial)

# Perform the omnibus test using the likelihood ratio test
anova(null_model, model_06, test = "Chisq")



## ------------------------ No Multicollinearity -------------------
vif(model3)


## --------------------------- Uni variate ----------------------------------
fies_data %>%
  select(state, 
         FI_0_6) %>%
  tbl_uvregression(
    method = glm,
    y = FI_0_6,
    method.args = list(family = binomial),
    exponentiate = TRUE,
    pvalue_fun = ~ style_pvalue(.x, digits = 2)
  ) %>%
  add_global_p() %>% # add global p-value
  add_nevent() %>% # add number of events of the outcome
  bold_p() %>% # bold p-values under a given threshold (default 0.05)
  bold_labels()
#> add_q: Adjusting p-values with
#> `stats::p.adjust(x$table_body$p.value, method = "fdr")`



