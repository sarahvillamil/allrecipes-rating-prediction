## Repo Organization 
### Sub-directories 
- [data/](data): contains all data and data splitting for this project.
- [plots/](plots): contains plots used in project reports.
- [r_scripts/](r_scripts): contains all R scripts for this project.
- [recipes/](recipes): contains all model recipes for this project.
- [results/](results): contains all fitted/tuned model results for this project.

### Reports
-   'SLAC_executive_summary.qmd': file for creating executive summary
-   'SLAC_executive_summary.html': rendered html for executive summary
-   'SLAC_final_report.qmd': file for creating final report
-   'SLAC_final_report.html': rendered html for final report


# What Makes a Recipe Great? Predicting AllRecipes Ratings
## Overview
In this project, we explored what factors contribute to highly rated recipes on AllRecipes.com and developed machine learning models to predict a recipe's average user rating.
Using recipe metadata, nutritional information, and ingredient data, we investigated relationships between recipe characteristics and user ratings while evaluating a variety of predictive modeling approaches.
After cleaning the dataset and removing observations with missing outcome values, our final modeling dataset contained 13,454 recipes.
## Dataset
- Source: AllRecipes.com
- Original Dataset: 14,426 recipes
- Final Modeling Dataset: 13,454 recipes
- Outcome Variable: Average Recipe Rating (1–5 Stars)
---
## Research Question
Can we accurately predict a recipe's average user rating using information about its ingredients, nutritional content, preparation requirements, and publication history?
## Feature Engineering
We created several new features from the raw dataset, including:
- Number of ingredients
- Vegetarian indicator
- Vegan indicator
- Sweet recipe indicator
- Spicy recipe indicator
- Alcohol indicator
- Expensive ingredient indicator
- Quick-to-make indicator
- Days since publication 
Many of these variables were derived from ingredient text using regex-based feature extraction.
---
## Modeling Approach
We evaluated a variety of regression models, including:
- Linear Regression
- Elastic Net
- K-Nearest Neighbors (KNN)
- MARS
- Neural Networks
- Random Forest
- Boosted Trees
- SVM (Radial)
- SVM (Polynomial)
- Ensemble Models

Model training utilized:
- 80/20 Train-Test Split
- 5-Fold Cross Validation
- 3 Repeats
- Hyperparameter Tuning
--- 
## Best Model
### Ensemble MARS + Boosted Tree
Our best-performing model was an ensemble combining:
- Multivariate Adaptive Regression Splines (MARS)
- Boosted Trees
### Performance
| Metric | Value |
|----------|----------|
| Validation RMSE | 0.390 |
| Test RMSE | 0.395 |
---
## Key Findings
- Ensemble methods outperformed individual models.
- Feature engineering from recipe ingredients provided useful predictive information.
- More complex preprocessing techniques produced minimal improvements over simpler approaches.
- The heavily skewed distribution of recipe ratings made accurate prediction of extremely high and low ratings difficult.
---
## Technologies Used
- R
- Tidymodels
- MARS
- Boosted Trees
- Random Forest
- Machine Learning
- Feature Engineering
- Cross Validation
- Ensemble Modeling
---
## Contributors
- Sarah Villamil
- Lillian Valk
- Avryl Carmona
- Cameron Lara
---
