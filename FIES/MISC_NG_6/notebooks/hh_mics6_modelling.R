setwd("~/Documents/Dev/Python Programming/Data Science/data_science_with_python/FIES/MISC_NG_6")

# Load the required packages
require(flexplot)
library(tidyverse)
library(jtools)
library(lme4)    # for multilevel models

# Read in the data
data <- read_csv("../MISC_NG_6/processed_data/df_r.csv")


# Convert character and cluster column to factor
data <- data %>%
  mutate(across(where(is.character), as.factor))

data <- data %>%
  mutate(across(c("SFI","FI_Food_Insecure", "MSI", "FS", "hh1" ), as.factor))

data %>%
  group_by(hh1) %>%
  summarise(PROP = sum(prob_sev)/n()) %>% 
  ungroup() %>% 
  plot()

str(data)

## Build Base model: null two-level model

model <- glmer(formula = MSI ~ (1|hh1),
               family = binomial("logit"),
               data = data,
               weights = hhweightmics,
               )
summary(model)

# The likelihood ratio statistic for testing the null hypothesis, can be
# calculated by comparing the two-level model, with the corresponding single-level
# model without the level 2 random effects.
fita <- glm(MSI ~ 1, data = data, weights =hhweightmics,  family = binomial("logit"))
logLik(fita)-logLik(model)

# The test statistic is 1697.5874 (-2*(-848.7937)) with 1 degree of freedom, so there is
# strong evidence that the between-community variance is non-zero.


### Model I: Model containing only individual/household-level predictors

model1 <- glmer(formula = MSI ~ hhsex + hh_age_cat + hh_siz_cat  + 
               helevel + hh_own_dwelling + urban_wi_quintile_mics + 
               + hh_agricultural_land + hh_own_animal +num_child_under5_cat+
               (1|hh1),
               family = binomial,
               data = data,
               weights = hhweightmics,
               # control = glmerControl(optimizer = "bobyqa", optCtrl = list(maxfun=2e5))
               )

summ(model1, exp = T, pvals=TRUE)

### Model II: Model containing only Community-level predictors

model2 <- glmer(formula = MSI ~ zone+cluster_wi_category+(1|hh1),
               family = binomial,
               data = data,
               weights = hhweightmics,
               control = glmerControl(optimizer = "bobyqa", optCtrl = list(maxfun=2e5)))

summ(model2, exp = T, pvals=TRUE)


### Model III: Model containing only Community-level predictors

model3 <- glmer(formula = MSI ~ hhsex + hh_age_cat + hh_siz_cat  + 
                  helevel + hh_own_dwelling + urban_wi_quintile_mics + 
                  hh_agricultural_land + hh_own_animal + num_child_under5_cat+ 
                  zone+cluster_wi_category+
                  (1+cluster_wi_category|hh1),
                family = binomial,
                data = data,
                weights = hhweightmics,
                control = glmerControl(optimizer = "bobyqa", optCtrl = list(maxfun=2e5)))


summ(model3, exp = T, pvals=TRUE)


anova(model, model1,model2, model3, test="Chisq")
