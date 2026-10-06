# Simple Recipes - Model Scripts

This folder contains model tuning scripts using the simple recipes (rec1, rec2, rec3).

### R Scripts
- `2_initial_recipes.R`: Defines rec1 (null), rec2 (tree-based), rec3 (distance-based)
- `3_bt_tune_rec2.R`: Boosted tree
- `3_en_tune_rec3.R`: Elastic net
- `3_ensemble_tune_rec3rec2.R`: Ensemble Model (KNN & Boosted Tree)
- `3_knn_tune_rec3.R`: KNN
- `3_lm_fit_rec3.R`: Linear regression
- `3_mars_tune_rec2.R`: MARS
- `3_nn_tune_rec3.R`: Neural network
- `3_null_rec1.R`: Null model baseline
- `3_rf_tune_rec2.R`: Random forest
- `3_svm_poly_tune_rec3.R`: SVM polynomial
- `3_svm_rad_tune_rec3.R`: SVM radial
- `3.5_model_runtimes.R`: Runtimes for simple recipes models