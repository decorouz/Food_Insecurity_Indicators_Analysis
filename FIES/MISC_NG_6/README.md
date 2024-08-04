# Determinants of Household Food Insecurity Amongst Urban Household in Nigeria
A multilvel multinorminal logistic regression and mixed effect analysis to assess factors associated with household food insecurity in Nigeria

## Predictors and Hypothesis
1. Wealth index
3. Household Size
4. Household Head Gender, Age, Education,
4. Household own dwelling
4. Household livestock ownership
5. Number of women
6. Number of men
7. Number of child under 5
8. Household women who attended school`"hh_wm_attended_sch_num",`
9. Household women average age `hh_wm_mean_age_yrs`
10. Number of women who attended as least sec school
11. Household women mean life satisfaction `hh_wm_mean_life_satisfaction`
8. Household men who attended school`"hh_mn_attended_sch_num",`
9. Household men average age `hh_mn_mean_age_yrs`
10. Number of men who attended as least sec school
11. Household men mean life satisfaction `hh_mn_mean_life_satisfaction`


## Data
This study is based on quantitative cross-sectional data derived from the Nigeria 2021 Multiple Indicator Cluster Survey (MICS6), which is a nationally representative survey that collects sociodemographic and health indicators from both household, males and females aged 15–49 years.

The survey utilized a multistage stratified cluster sampling approach that employed a probability proportional to size to select enumeration areas in the first stage based on the 2006 Population and Housing Census of the Federal Republic of Nigeria (NPHC). In the second stage, 20 households were randomly selected within each enumeration area.

The downloaded data include survey data from **MICS** or NICS. For this project we shall use the MICS only.

## Data Processing/Cleaning
**Predictors**
* The original household dateset(`hh`) comprises of 41532 dataset.
* Of these households, `33631` household didn't provide content.
* The dataset contains data from two seperate surveys (MICS and NCIS). We filter by **MICS** survey only.
* Women, men, and children data merged with the household dataset.
* After initial data preprocessing, we reduced the variables from over 300 variables to 34.

**Dependent Variables (FIES)**
* The FIES survey module allows recording of **"don't know" and "refused"** responses to
any of the FIES items. For our analytic purposes, such answers are treated as "missing" and
cases with missing responses for any of the FIES items are excluded from the analysis.

> Statistical validation should always be conducted when the food insecurity scale is
applied for the first time in a given population, and may be repeated for numerous
waves of a survey to ensure that the scale performs consistently well. 

## FIES analysis methodology

This involves applying the Rasch Model to the FIES response data and assessing whether the data
conform to the model’s assumptions. If the data do conform to the assumptions, we can conclude
that the data can be used to calculate a valid measure of food insecurity.

**What are the model assumptions?**

The Rasch model is based upon four key assumptions:

1. Only one dimension is represented by the response data. For the FIES, this is the access dimension
of food security.
2. An individual’s responses to the eight FIES items are correlated with each other only because they are all
conditioned by the severity of food insecurity of that individual.
3. The greater the severity of food insecurity experienced by a respondent, the higher the likelihood
that he or she will respond affirmatively to each item.
4. All items are equally strongly related to the latent trait of food insecurity and differ only in severity.






## References

FAO. 2016. Methods for estimating comparable rates of food insecurity experienced by adults throughout the world. Rome, FAO._



