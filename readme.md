# Food Security: : Determinants of Household Food Insecurity

Social Determinants of the prevalence of moderate or severe household food insecurity in 5 states in Northern Nigeria, based on the Food
Insecurity Experience Scale (FIES)

![network header](assets/fies.png)

## Dataset

The dataset for this project is the round 6 survey of 3441 households from 5 states, collected between January and February 2024 using the Food Insecurity Experience Scale survey module (FIES-SM) developed by
FAO. The can data can be requested can be requested for at [FAO Data in Emergencies Hub](https://data-in-emergencies.fao.org) (CC BY-NC-SA 3.0 License). 

The DIEM-Monitoring system was established under the Food and Agriculture Organization (FAO) of the United Nations. The main purpose of the DIEM-Monitoring system is to collect data from households and key informants in countries prone to multiple shocks.

## FIES Questions
The current FIES-SM module include eight questions as in the table below.

| Questions                     | Severity of Food Insecurity                         |Label           |
|-------------------------------|-----------------------------------------------------|----------------|
| **Q1.** During the last 30 days, was there a time when you or others in your household were worried about not having enough food to eat because of lack of money or other resources?| Mild| Worried|
| **Q2.** During the last 30 days, was there a time when you or others in your household were unable to eat healthy and nutritious food because of lack of money or other resources?| Mild |Healthy|
| **Q3.** During the last 30 days, was there a time when you or others in your household ate only a few kinds of foods because of lack of money or other resources? | Mild|FewFoods|
| **Q4.** During the last 30 days, was there a time when you or others in your household had to skip a meal because of lack of money or other resources to get food? | Moderate |Skipped|
| **Q5.** During the last 30 days, was there a time when you or others in your household ate less than you thought you should because of lack of money or other resources?| Moderate |Ateless|
| **Q6.** In the past 30 days, was there ever no food to eat of any kind in your house because of lack of resources to get food? | Moderate |Ranout|
| **Q7.** In the past 30 days, did you or any household member ever go to sleep at night hungry because there was not enough food? | Severe |Hungry|
| **Q8.** In the past 30 days, did you or any household member ever go a whole day and night without eating anything at all because there was not enough food?| Severe |Whlday|


## Objectives

The main objective of this project is:

> **To investigate the social determinants of severe household food insecurity in 5 northern states in Nigeria.**

To achieve this objective, it was further broken down into the following 5 technical sub-objectives:

0. Perform data cleaning
1. [X] Perform quality assurance through testing of adherence to `Rasch` model assumptions. 
2. To perform in-depth exploratory data analysis of the datasets.
3. To engineer new predictive features from the available datasets.
4. To develop a supervised model(s) to classify household into food secure and food insecure.
5. To create an API endpoint for the trained model and deploy it.

## Main Insights
### Quality Assurance
From the quality assurance analysis with Rasch Model to verify the validity and reliability of the FIES data, we found the following:

* The weighted **infit** statistics for the FIES data in our study were within the acceptable range of [0.7–1.2], which verified that the FIES data is a reliable and valid measure to assess food insecurity in this population.
* Mean Rasch Model `reliability` was 0.752. These levels of reliability for a scale comprising just eight items reflect reasonably good model fit.

### EDA
From the exploratory data analysis, we found out that anomalous behavviour patterns are cahracterised by:

* Insight about anomaly vs normal #1
* Insight about anomaly vs normal #2
* Insight about anomaly vs normal #3

## Covariaites
| Variables                     | Description    |
|-------------------------------|--------------|
| Median Response Time          | 0.1 seconds  |
| 99th Percentile Response Time | 0.9 seconds  |
| Max Response Time             | 0.95 seconds |

## Engineered Features

From the provided networks, the following features were extracted:

* Feature 1 - this feature helps us to measure *X* activity and is expected to be much higher in anomalies/normal behaviour
* Feature 2 - this feature helps us to measure *X* activity and is expected to be much higher in anomalies/normal behaviour
* Feature 3 - this feature helps us to measure *X* activity and is expected to be much higher in anomalies/normal behaviour

As a result of this feature engineering work, the ROC AUC for the final model has increased by 30% and has improved F1 score uplift from the baseline model from 1.5 to 1.8.

## Model Selection

Models were compared between each other using ROC AUC since we're dealing with binary classification task and the label distribution is relatively balanced.
2 models (XGBoost and LightGBM) were tuned for 50 iterations. The best performing model is LightGBM with the following parameters:

```json
{
    colsample_by_tree: 0.2,
    num_trees: 2454,
    learning_rate: 0.02,
    subsample: 0.5
}
```


LightGBM has outperformed XGBoost by *X%* in terms of ROC AUC. From the PR AUC curves, we can also see that it can give use gigher level of recall with the same precision at most of the thresholds, so this model is selected for deployment.

### Model Explainability


The selected model has a well balanced feature improtance distribution, with top 3 features being *X, Y, and ~*. The directions of SHAP values are intuitive, since we expect that anomalies have larger rate of *X* and *Y* and smaller number of *Z*
Notably, the engineered features are also considered to be important (4th, 5th and 7th place), which means that the feature engineering effort was successful.

## Business Metrics

To determine the achieved business metrics, we first need to set the threshold for our classifier.


From the threshold analysis, we can see that the maximum F1 score we can achieve is *X* across a variety of thresholds. For the purpose of this project, we can assume that the business is more interested in obtaining higher recall than precision, so we'll set the threshold at *X* which gives us the following metrics *(numbers are made up)*:

| Threshold  | 0.25 |
|------------|------|
| Precision  | 0.7  |
| Recall     | 0.9  |
| F1 Score   | 0.85 |
| Alert Rate | 0.02 |

## Prediction Service

For this project, the assumtpion is that feature engineering will be handled by another serivce, so the deployment part is responsible purely for the model inference.
To create the API locally, you'll need to use Docker.

### Step 1: Build Docker Image

Clone the repository and go to the folder with the Dockerfile. Then run the following command to build the image.

```shell
docker build -t prediction-service:latest .
```

To check if the image was created successfully, run `docker images` in you CLI and you should see `prediction-service` listed.

### Step 2: Send the Request

To test if the API is working, you can run the `ping.py` file in the `app` folder. You'll need Python installed on your computer.

```shell
python app/ping.py
```

### Step 3: Measuring Response Time

The following response times were measured locally by sending 100 requests per second from 1 user:

| Response Time                 | Measure      |
|-------------------------------|--------------|
| Median Response Time          | 0.1 seconds  |
| 99th Percentile Response Time | 0.9 seconds  |
| Max Response Time             | 0.95 seconds |

To run these tests on your machine, you'll need to run the `measure_response.py` script

```shell
python app/measure_response.py
```

## Authors

* [Adeyemi Biola](https://github.com/decorouz)
