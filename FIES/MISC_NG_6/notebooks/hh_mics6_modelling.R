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
# create the table as an R object
msi_age_table <- table(data$MSI, data$hh_age_cat)
# Multiply by 100
prop.table(msi_age_table) * 100

# chi square test
chisq.test(msi_age_table)

library(vcd)
assocstats(msi_age_table)

#  3 Two variable table glbcc~ideology+gend
mdi_v1 <- table(data$MSI, data$hh_age_cat, data$hhsex) 
mdi_v1
#  Percentages by Column for Women 
prop.table(mdi_v1[,,2], 2) * 100  
chisq.test(mdi_v1[,,2])
assocstats(mdi_v1[,,2])




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

u0 <- ranef(model, postVar = TRUE)
u0se <- sqrt(attr(u0[[1]], "postVar")[1, , ])
commid <- as.numeric(rownames(u0[[1]]))
u0tab <- cbind("commid" = commid, "u0" = u0[[1]], "u0se" = u0se)
colnames(u0tab)[2] <- "u0"
u0tab <- u0tab[order(u0tab$u0), ]
u0tab <- cbind(u0tab, c(1:dim(u0tab)[1]))
u0tab <- u0tab[order(u0tab$commid), ]
colnames(u0tab)[4] <- "u0rank" 

plot(u0tab$u0rank, u0tab$u0, type = "n", xlab = "u_rank", ylab = "conditional
modes of r.e. for comm_id:_cons", ylim = c(-4, 4)) 

segments(u0tab$u0rank, u0tab$u0 - 1.96*u0tab$u0se, u0tab$u0rank, u0tab$u0 +
           1.96*u0tab$u0se)
points(u0tab$u0rank, u0tab$u0, col = "blue")
abline(h = 0, col = "red")
str(data)
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
data$hh_age_cat <- relevel(as.factor(data$hh_age_cat), ref = "16-25")
data$helevel <- relevel(as.factor(data$helevel), ref = "No Education")
data$urban_wi_quintile_mics <- relevel(as.factor(data$urban_wi_quintile_mics), ref = "Poorest")

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



# Extract model results
model_results <- broom.mixed::tidy(model3, effects = "fixed", conf.int = TRUE)

# Convert log-odds to odds ratios (exponentiate estimates & CI)
model_results <- model_results %>%
  mutate(OR = exp(estimate),
         lower_CI = exp(conf.low),
         upper_CI = exp(conf.high),
         Significance = ifelse(p.value < 0.05, "Significant", "Not Significant"))

# Filter out the intercept
model_results <- model_results %>%
  filter(term != "(Intercept)")

# Create a mapping of variable names for better readability
var_labels <- c(
  # "urban_wi_quintile_micsPoorest" = "Urban Wealth Index: Poorest",
  "urban_wi_quintile_micsSecond" = "Urban Wealth Index: Second Quintile",
  "urban_wi_quintile_micsMiddle" = "Urban Wealth Index: Middle Quintile",
  "urban_wi_quintile_micsRichest" = "Urban Wealth Index: Richest Quintile",
  "urban_wi_quintile_micsFourth" = "Urban Wealth Index: Fourth Quintile",
  "zoneSouth East" = "Zone: South East",
  "zoneSouth South" = "Zone: South South",
  "zoneSouth West" = "Zone: South West",
  "zoneNorth West" = "Zone: North West",
  "zoneNorth East" = "Zone: North East",
  "hh_siz_cat>5" = "Household Size: > 5",
  "helevelPrimary" = "Education Level: Primary",
  "helevelJunior secondary" = "Education Level: Junior Secondary",
  "helevelSenior secondary" = "Education Level: Senior Secondary",
  "helevelHigher/tertiary" = "Education Level: Higher Education",
  "helevelNo Education" = "Education Level: No Education",
  "hh_age_cat>45" = "Household Head Age: > 45",
  "hh_age_cat26-35" = "Household Head Age: 26-35",
  "hh_age_cat36-45" = "Household Head Age: 36-45",
  "hh_own_dwellingRENT" = "Household Dwelling: Rented",
  "hh_own_dwellingOWN" = "Household Dwelling: Owned",
  "hhsexMale" = "Household Head Sex: Male",
  "hh_agricultural_landYES" = "Owns Agricultural Land: Yes",
  "hh_own_animalYES" = "Owns Animal: Yes",
  "cluster_wi_categoryMiddle" = "Community Wealth Index: Middle",
  "cluster_wi_categoryLow" = "Community Wealth Index: Low",
  "num_child_under5_catYes" = "Has Children Under 5: Yes"
)

# Replace variable names with readable labels
model_results$term <- recode(model_results$term, !!!var_labels)

# Create the enhanced forest plot with confidence intervals
forest_plot <- ggplot(model_results, aes(x = OR, y = term, color = Significance)) +
  geom_point(size = 6) +  # Large points for visibility
  geom_errorbarh(aes(xmin = lower_CI, xmax = upper_CI), height = 0.3, size = 1.2) +  # Confidence intervals
  geom_vline(xintercept = 1, linetype = "dashed", color = "black", size = 1) +  # OR = 1 reference line
  scale_color_manual(values = c("Significant" = "red", "Not Significant" = "gray")) +
  labs(x = "Odds Ratio (95% CI)",
       y = "Variables",
       color = "Statistical Significance") +
  theme_minimal() +
  theme(
    text = element_text(family = "Arial Nova", size = 28, color = "black"),  # Set text color to black
    legend.position = "bottom",
    axis.text.y = element_text( color = "black"),  # Ensure y-axis text is bold and black
    axis.text.x = element_text( color = "black"),  # Ensure x-axis text is bold and black
  
  )

# Save a high-resolution version for printing
ggsave("forest_plot_poster_with_new.png", plot = forest_plot, width = 16, height = 10, dpi = 300)
anova(model, model1,model2, model3, test="Chisq")
