# Determinants of Household Food Insecurity Amongst Urban Household in Nigeria
A multilvel multinorminal logistic regression and mixed effect analysis to assess factors associated with household food insecurity in Urban Nigeria

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
        
## Predictors/Explanatory Variables
The explanatory variables used in the analysis were selected based on a comprehensive review
of the literature, their biological plausibility in the exposure-outcome relationship, and their
availability in the survey data studied.
* Wealth index
* Zone (eg South South, South East...)
* Household size
* Household head gender, age, education
* Household own dwelling
* Household ownership of agricultural land and livestock
* Number of women
* Number of men
* Number of children under 5 year
* Number of children between 5-15 years
* Household women who attended school (hh_wm_attended_sch_num)
* Household women average age (hh_wm_mean_age_yrs)
* Number of women who attended at least secondary school
* Household women mean life satisfaction (hh_wm_mean_life_satisfaction)
* Household men who attended school (hh_mn_attended_sch_num)
* Number of men who attended at least secondary school
* Household men mean life satisfaction (hh_mn_mean_life_satisfaction)


## Dependent Variables (FIES)
The outcome of this study was food insecurity. The MICS measures
household FI using the standardized eight-item Food Insecurity Experience Scale (FIES). The
FIES was developed by the United Nations Food and Agriculture Organization (UN FAO)[[1]](https://openknowledge.fao.org/items/e26bf231-39f4-423d-b3a9-49e0f5d9aef9) to
provide internationally comparable estimates of the magnitude of FI experience in accordance
with the Sustainable Development Goal (SDG) indicator 2.1.2 - “prevalence of moderate or
severe FI in the population, based on the Food Insecurity Experience Scale (FIES)” 

Raw house-hold FI scores (0–8) were computed as the total number of affirmative responses, and partici-
pants were categorized into three levels of FI based on their scores. Scores ranging from 0 to 3 indicate food secure, scores ranging from 4 to 6 indicate moderate FI, and scores ranging from
7 to 8 indicate severe FI based on previous literature [[2]](https://pubmed.ncbi.nlm.nih.gov/33937614/)


### FIES analysis methodology

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


## Modelling
Several weighted multilevel multinomial logistic regression models were fitted to
assess the association between individual-/household-s level and community-level charac-
teristics with FI. We estimated and reported both fixed effects and random effects to mea-
sure the associations and variations, respectively.

## Results
The prevalence FI among urban household in Nigeria was high as determined by the Rasch model (at 75% mean reliance), with nearly 67% of the respondents reporting moderate to severe FI in the past 12 months (95% CI = 66.3%-70.8%) with 41.5 % at severe level of FI in 2021.

<!-- Multivariate analysis revealed that higher parity, households with 5 or more members, household wealth index,
urban residence, and community-level poverty were significantly associated with FI. Our
study demonstrates a significantly high prevalence of FI among pregnant women in Nigeria
in 2021. Given the negative consequences of FI on maternal and child health, implementing
interventions to address FI during pregnancy remains critical to improving pregnancy
outcomes. -->




## References
1. [FAO. 2016. Methods for estimating comparable rates of food insecurity experienced by adults throughout the world. Rome, FAO](https://openknowledge.fao.org/items/e26bf231-39f4-423d-b3a9-49e0f5d9aef9)
2. [Sheikomar OB, Dean W, Ghattas H, Sahyoun NR. Validity of the FI Experience Scale (FIES) for Use in
League of Arab States (LAS) and Characteristics of Food Insecure Individuals by the Human Develop-
ment Index (HDI). Curr Dev Nutr. 2021; 5(4):nzab017.](https://pubmed.ncbi.nlm.nih.gov/33937614/)
3. [Ujah OI, Olaore P, Ogbu CE, Okopi J-A, Kirby RS (2023) Prevalence and determinants of
food insecurity among pregnant women in Nigeria: A multilevel mixed effects analysis. PLOS Glob
Public Health 3(10): e00023](https://doi.org/10.1371/journal.pgph.0002363)


