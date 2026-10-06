# Final Project ----
# Comparing model performance - All Models (Simple + Complex Recipes)

# load packages ----
library(tidyverse)
library(tidymodels)
library(here)

# handle common conflicts ----
tidymodels_prefer()

# load simple recipe results and runtimes ----
load(here("results/attempt1_null_rec1_fit.rda"))
load(here("results/attempt1_lm_rec3_fit.rda"))
load(here("results/attempt1_rf_rec2_tuned.rda"))
load(here("results/attempt1_bt_rec2_tuned.rda"))
load(here("results/attempt1_en_rec3_tuned.rda"))
load(here("results/attempt1_knn_rec3_tuned.rda"))
load(here("results/attempt1_mars_rec2_tuned.rda"))
load(here("results/attempt1_nn_rec3_tuned.rda"))
load(here("results/attempt1_svm_poly_rec3_tuned.rda"))
load(here("results/attempt1_svm_rad_rec3_tuned.rda"))
load(here("results/attempt1_ensemble_rec3rec2_tuned.rda"))
load(here("results/simple_runtimes.rda"))

# load complex recipe results and runtimes ----
load(here("results/attempt1_rf_rec4_tuned.rda"))
load(here("results/attempt1_bt_rec4_tuned.rda"))
load(here("results/attempt1_en_rec5_tuned.rda"))
load(here("results/attempt1_knn_rec5_tuned.rda"))
load(here("results/attempt1_mars_rec4_tuned.rda"))
load(here("results/attempt1_lm_rec5_fit.rda"))
load(here("results/attempt1_nn_rec5_tuned.rda"))
load(here("results/attempt1_svm_poly_rec5_tuned.rda"))
load(here("results/attempt1_svm_rad_rec5_tuned.rda"))
load(here("results/attempt1_ensemble_rec5rec4_tuned.rda"))
load(here("results/complex_runtimes.rda"))

# workflow set - simple recipes ----
attempt1_model_results_simple <- as_workflow_set(
  `Null (rec1)` = attempt1_null_rec1_fit,
  `Linear Regression (rec3)` = attempt1_lm_rec3_fit,
  `Random Forest (rec2)` = attempt1_rf_rec2_tuned,
  `Boosted Tree (rec2)` = attempt1_bt_rec2_tuned,
  `Elastic Net (rec3)` = attempt1_en_rec3_tuned,
  `KNN (rec3)` = attempt1_knn_rec3_tuned,
  `MARS (rec2)` = attempt1_mars_rec2_tuned,
  `Neural Network (rec3)` = attempt1_nn_rec3_tuned,
  `SVM Polynomial (rec3)` = attempt1_svm_poly_rec3_tuned,
  `SVM Radial (rec3)` = attempt1_svm_rad_rec3_tuned,
)

# ensemble - simple
attempt1_ensemble_results_simple <- attempt1_ensemble_rec3rec2_tuned$metrics |>
  filter(.metric == "rmse") |>
  slice_min(mean) |>
  mutate(recipe_type = "Simple", wflow_id = "Ensemble KNN & BT (rec3rec2)") |> 
  select(wflow_id, recipe_type, mean, std_err)

# workflow set - complex recipes ----
attempt1_model_results_complex <- as_workflow_set(
  `Linear Regression (rec5)` = attempt1_lm_rec5_fit,
  `Random Forest (rec4)` = attempt1_rf_rec4_tuned,
  `Boosted Tree (rec4)` = attempt1_bt_rec4_tuned,
  `Elastic Net (rec5)` = attempt1_en_rec5_tuned,
  `KNN (rec5)` = attempt1_knn_rec5_tuned,
  `MARS (rec4)` = attempt1_mars_rec4_tuned,
  `Neural Network (rec5)` = attempt1_nn_rec5_tuned,
  `SVM Polynomial (rec5)` = attempt1_svm_poly_rec5_tuned,
  `SVM Radial (rec5)` = attempt1_svm_rad_rec5_tuned
)

# ensemble - complex
attempt1_ensemble_results_complex <- attempt1_ensemble_rec5rec4_tuned$metrics |>
  filter(.metric == "rmse") |>
  slice_min(mean) |>
  mutate(recipe_type = "Complex", wflow_id = "Ensemble KNN & BT (rec5rec4)") |> 
  select(wflow_id, recipe_type, mean, std_err)

# combined results ----
attempt1_simple_tbl <- attempt1_model_results_simple |>
  collect_metrics() |>
  filter(.metric == "rmse") |>
  slice_min(mean, by = wflow_id) |>
  mutate(recipe_type = "Simple")

attempt1_complex_tbl <- attempt1_model_results_complex |>
  collect_metrics() |>
  filter(.metric == "rmse") |>
  slice_min(mean, by = wflow_id) |>
  mutate(recipe_type = "Complex")

attempt1_results <- bind_rows(attempt1_simple_tbl, attempt1_complex_tbl, attempt1_ensemble_results_simple, attempt1_ensemble_results_complex)

# runtimes ----
attempt1_runtimes <- simple_runtimes |>
  bind_rows(complex_runtimes) |>
  mutate(
    wflow_id = case_when(
      model == "null" ~ "Null (rec1)",
      model == "lm simple" ~ "Linear Regression (rec3)",
      model == "lm complex" ~ "Linear Regression (rec5)",
      model == "rf simple" ~ "Random Forest (rec2)",
      model == "rf complex" ~ "Random Forest (rec4)",
      model == "bt simple" ~ "Boosted Tree (rec2)",
      model == "bt complex" ~ "Boosted Tree (rec4)",
      model == "en simple" ~ "Elastic Net (rec3)",
      model == "en complex" ~ "Elastic Net (rec5)",
      model == "knn simple" ~ "KNN (rec3)",
      model == "knn complex" ~ "KNN (rec5)",
      model == "mars simple" ~ "MARS (rec2)",
      model == "mars complex" ~ "MARS (rec4)",
      model == "nn simple" ~ "Neural Network (rec3)",
      model == "nn complex" ~ "Neural Network (rec5)",
      model == "svm poly simple" ~ "SVM Polynomial (rec3)",
      model == "svm poly complex" ~ "SVM Polynomial (rec5)",
      model == "svm rad simple" ~ "SVM Radial (rec3)",
      model == "svm rad complex" ~ "SVM Radial (rec5)",
      model == "ensemble knn/bt simple" ~ "Ensemble KNN & BT (rec3rec2)",
      model == "ensemble knn/bt complex" ~ "Ensemble KNN & BT (rec5rec4)"
    )
  ) |>
  select(-model)

# table - recipe type, rmse, standard error, and runtimes per model ----
attempt1_results_table <- attempt1_results |>
  left_join(attempt1_runtimes, by = "wflow_id") |>
  arrange(mean) |>
  select(
    `Model Type` = wflow_id,
    `Recipe Type` = recipe_type,
    RMSE = mean,
    `Std Error` = std_err,
    `Per Model Runtime` = avg_runtime,
    `Total Runtime` = total_runtime
  ) |>
  knitr::kable(digits = c(NA, NA, 3, 4, 1, 1))

# plot - best rmse per model ----
attempt1_results_plot <- attempt1_results |>
  select(
    `Model Type` = wflow_id,
    `Recipe Type` = recipe_type,
    RMSE = mean,
    `Std Error` = std_err
  ) |>
  ggplot(
    aes(
      x = RMSE,
      y = reorder(`Model Type`, -RMSE),
      color = `Recipe Type`
      )
    ) +
  geom_point(size = 3) +
  geom_errorbar(
    aes(
      xmin = RMSE - `Std Error`,
      xmax = RMSE + `Std Error`),
    width = 0.2, orientation = "y"
    ) +
  theme_minimal() +
  labs(
    title = "Best RMSE by Model Type and Recipe",
    x = "RMSE",
    y = NULL,
    color = "Recipe Type"
  )

# save out new file/object names ----
save(attempt1_results, file = here("results/attempt1_results.rda"))
save(attempt1_results_table, file = here("plots/attempt1_results_table.rda"))
save(attempt1_results_plot, file = here("plots/attempt1_results_plot.rda"))
