# 2nd Attempt - Model Refinement

This folder contains scripts for the second modeling attempt, which refines the top 3 performing models from attempt 1 (Random Forest, Boosted Tree, and MARS) using more targeted hyperparameter tuning.

## Scripts

- `3_bt_tune_rec2.R`: Boosted Tree with refined hyperparameter grid — narrowed mtry (1-3), trees (200-400), min_n (10-20), learn_rate, and added tree_depth as a new tuning parameter
- `3_ensemble_tune_rec2.R`: Ensemble Model with MARS and Boosted Tree as candiates - increased blend penalty
- `3_mars_tune_rec2.R`: MARS with extended num_terms range (15-40) since it hit the ceiling at 20 in attempt 1
- `3_rf_tune_rec2.R`: Random Forest with refined hyperparameter grid — narrowed mtry (2-5), trees (400-700), and extended min_n (15-30) since it hit the ceiling in attempt 1
- `4_model_analysis.R`: Model comparison and selection across rec versions for attempt 2