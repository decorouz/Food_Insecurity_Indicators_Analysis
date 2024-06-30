setwd("~/Documents/Dev/Python Programming/Data Science/data_science_with_python")

# Load the neccessary libraries
library(gtsummary)
library(dplyr)
# library(haven)
library(tidyverse)
library(survey)

# ------ Demographic and Socioeconomic Descriptive----- 

fies_data$FI_cat <- factor(fies_data$FI_0_6)
fies_data$FI_cat_03 <- factor(fies_data$FI_0_3)

# Add Labels
attributes(fies_data$hh_agricactivity)$label <- "HH Agricultural Activity"
attributes(fies_data$crp_landsize_ha)$label <- "Cultivated land size"
attributes(fies_data$hh_size)$label <- "Household size"
attributes(fies_data$hh_age)$label <- "Household Age"
attributes(fies_data$hh_gender)$label <- "Household Head gender"
attributes(fies_data$hh_education)$label <- "Education Level"
attributes(fies_data$income_main_cat)$label <- "Main Income Source"
attributes(fies_data$income_more_than_one)$label <- "More than one income source"
attributes(fies_data$income_main_control)$label <- "Main Income control"
attributes(fies_data$hh_maritalstat_clean)$label <- "Marital Status"
attributes(fies_data$shock_higherfoodprices)$label <- "Shock from higer food price"
attributes(fies_data$shock_drought)$label <- "Shock from Drought"
attributes(fies_data$shock_flood)$label <- "Shock from flood"
attributes(fies_data$shock_plantdisease)$label <- "Shock from plant disease"
attributes(fies_data$shock_animaldisease)$label <- "Shock from animal disease"
attributes(fies_data$shock_violenceinsecconf)$label <- "Shock from conflict"
attributes(fies_data$rcsi_class)$label <- "Coping Strategy"
# attributes(fies_data$hh_wealth_light2)$label <- "Access to Electricity"
# attributes(fies_data$hh_wealth_water2)$label <- "Access to Safe Water"
# attributes(fies_data$hh_wealth_toilet2)$label <- "Access to Sanitation"
attributes(fies_data$FI_cat)$label <- "Food insecurity 1"
attributes(fies_data$FI_cat_03)$label <- "Food insecurity 2"
attributes(fies_data$fies_cat2)$label <- "Food insecurity categories"

# Select the column of interest
col_of_interest <- fies_data %>% select(state,crp_landsize_ha, hh_size, hh_gender,hh_age,
                              hh_agricactivity, hh_education,hh_maritalstat_clean,
                              income_main_cat, income_more_than_one, income_main_control,
                              rcsi_class, shock_higherfoodprices, shock_drought,
                              shock_flood, shock_plantdisease, shock_animaldisease,
                              shock_violenceinsecconf,
                              FI_cat, fies_cat2)
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

table(fies_data$income_more_than_one)

# ------------------- Weighted Descriptive ---------------------
design.fies <- svydesign(id=~1, weights=~weight_final, data=fies_data)

# help(svydesign)
design.fies %>% 
  tbl_svysummary(
    # Use a character variable here. A factor leads to an error
    # by = fies_cat2,
    # Use include to select variables
    include = c(state, crp_landsize_ha, hh_size,hh_age,
                hh_agricactivity, hh_education,hh_maritalstat_clean,hh_gender,
                income_main_cat, income_more_than_one,income_main_control,
                shock_higherfoodprices, rcsi_class, shock_drought,
                shock_flood, shock_plantdisease, shock_animaldisease,
                shock_violenceinsecconf,
                FI_cat, fies_cat2),
    statistic = list(all_continuous()  ~ "{mean} ± {sd}",
                     all_categorical() ~ "{n}    ({p}%)"),
    digits = list(all_categorical() ~ c(0, 1)),
    missing = "no"
  ) %>%
  modify_header(label = "**Variable**",
                all_stat_cols() ~ "**{level}**<br>N = {n} ({style_percent(p, digits=1)}%)") %>%
  modify_caption("Weighted descriptive statistics,") %>%

  bold_labels()




# ------------------- Weighted Descriptive by FIES---------------------
design.fies <- svydesign(id=~1, weights=~weight_final, data=fies_data)


design.fies %>% 
  tbl_svysummary(
    # Use a character variable here. A factor leads to an error
    by = fies_cat2,
    # Use include to select variables
    include = c(state, crp_landsize_ha, hh_size,hh_gender,hh_age,
                hh_agricactivity, hh_education,hh_maritalstat_clean,
                income_main_cat, income_more_than_one, income_main_control,
                shock_higherfoodprices, shock_drought,
                shock_flood, shock_plantdisease, shock_animaldisease,
                shock_violenceinsecconf,
                hh_wealth_light2, hh_wealth_water2, hh_wealth_toilet2,
                
                ),
    statistic = list(all_continuous()  ~ "{mean} ({sd})",
                     all_categorical() ~ "{n}    ({p}%)"),
    digits = list(all_categorical() ~ c(0, 1)),
    missing = "no"
  ) %>%
  modify_header(label = "**Variable**",
                all_stat_cols() ~ "**{level}**<br>N = {n} ({style_percent(p, digits=1)}%)") %>%
  modify_caption("Weighted descriptive statistics, by smoking status") %>%
  bold_labels()


# ------------- Plot of insecurity ------------

# Recode FIES variables to factor
# fies_questions <- fies_data %>% 
#   mutate(across(c(1:8), as.factor))

# # Create a survey design 
# # fies.survey_design <- svydesign(ids=~1, weights=~weight_final, nest=FALSE, data=fies.data)
# fies.survey_design  <- diem_ng %>% as_survey_design(ids = 1, weights = weight_final)

# Weighted Percentages for response to FIES question in long format
fies_questions <- fies_data %>%
  select(c("fies_worried": "fies_whlday", "weight_final"))


fies.long <- pivot_longer(fies_questions, 
                              cols = starts_with("fies"),
                              names_to = "FIES",
                              values_to = "Response") 

fies.long$FIES[fies.long$FIES == "fies_worried"] <- "Worried about not having enough food to eat"
fies.long$FIES[fies.long$FIES == "fies_healthy"] <- "Unable to eat healthy & nutritious food"
fies.long$FIES[fies.long$FIES == "fies_fewfoods"] <- "Ate only a few kinds of foods"
fies.long$FIES[fies.long$FIES == "fies_skipped"] <- "Had to skip a meal"
fies.long$FIES[fies.long$FIES == "fies_ateless"] <- "Ate less than you thought you should"
fies.long$FIES[fies.long$FIES == "fies_ranout"] <- "No food to eat of any kind"
fies.long$FIES[fies.long$FIES == "fies_hungry"] <- "Go to sleep at night hungry"
fies.long$FIES[fies.long$FIES == "fies_whlday"] <- "Go a whole day and night wihouth eating anything at all"



#  Define survey design with srvyr
fies.long.design <- svydesign(ids=~1, weights=~weight_final, nest=FALSE, data=fies.long)
# fies.long.design <- fies.long %>% as_survey_design(ids = 1, weights=weight_final)

# Plot 
svytable(~FIES+Response, design = fies.long.design) %>% 
  data.frame()%>% 
  group_by(FIES) %>% 
  mutate(n_response = sum(Freq), Prop_fies = round((Freq / sum(Freq)*100), 1)) %>% 
  ggplot(aes(x = FIES, y = Prop_fies)) +
  geom_col(aes(fill = Response)) + 
  geom_text(aes(label = Prop_fies, group =Response), color = "black", size = 3,
            position = position_stack(vjust = 0.5))+
  coord_flip() +
  theme_minimal()+
  theme(axis.text.x = element_blank(),
        axis.title.x = element_blank(),
        text = element_text(family = "Times New Roman", face = "bold", size = 11, color = "black"),
        legend.text = element_text(family = "Times New Roman",face = "bold", size = 11, color = "black"),
        legend.title = element_text(family = "Times New Roman",face = "bold", size = 11, color = "black"),
        axis.text.y = element_text(family = "Times New Roman",face = "bold", size = 11, color = "black"),
        plot.title = element_text(family = "Times New Roman", face = "bold",size = 11, color = "black"),
        plot.subtitle = element_text(family = "Times New Roman", face = "bold",size = 11, color = "black"),
        plot.caption = element_text(family = "Times New Roman", face = "bold",size = 11, color = "black"))+
  scale_fill_manual(values = c("0" = "darkgreen", "1" = "darkorange"), # Specify colors for 0 and 1
                    labels = c("0" = "No", "1" = "Yes")) # Replace 0 with "No" and 1 with "Yes"
help("geom_text")

# survey::svydesign(~1, data = as.data.frame(fies_data), weights = ~weight_final) %>%
#   tbl_svysummary(digits = list(all_categorical() ~ c(0, 1),
#                                all_continuous() ~ c(1, 1)),
#                  label = list(fies.worried = "Worried about not having enough food to eat",
#                               fies.healthy = "Unable to eat healthy & nutritious food",
#                               fies.fewfoods = "Ate only a few kinds of foods",
#                               fies.skipped.meal = "Had to skip a meal",
#                               fies.ateless = "Ate less than you thought you should",
#                               fies.ranout = "No food to eat of any kind",
#                               fies.hungry = "Go to sleep at night hungry",
#                               fies.whole.day = "Go a whole day and night wihouth eating anything at all"),
#                  missing = "no")

