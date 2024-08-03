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
* The original household dateset(`hh`) comprises of 41532 dataset.
* Of these households, `33631` household didn't provide content.
* The dataset contains data from two seperate surveys (MICS and NCIS). We filter by **MICS** survey only.
* Women, men, and children data merged with the household dataset.
* After initial data preprocessing, we reduced the variables from over 300 variables to 34.


