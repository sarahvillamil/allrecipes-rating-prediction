# Final Project ----
# Fit SVM Radial Model
# load packages ----
library(tidymodels)
library(tidyverse)
library(here)

# handle common conflicts ----
tidymodels_prefer()

# load necessary objects ----
load(here("recipes/complex_recipes.rda"))
load(here("data/recipes_split.rda"))

# svm radial model ----
svm_rad_spec <- svm_rbf(
  cost = tune(),
  rbf_sigma = tune()
) |>
  set_engine("kernlab") |>
  set_mode("regression")

svm_rad_wkflow <- workflow() |>
  add_model(svm_rad_spec) |>
  add_recipe(recipe_distance_complex)

# hyperparameters ----
svm_rad_params <- extract_parameter_set_dials(svm_rad_spec) |>
  update(
    cost = cost(range = c(-3, 3)),
    rbf_sigma = rbf_sigma(range = c(-5, -1))
  )

svm_rad_grid <- grid_regular(svm_rad_params, levels = 5)

# tune model ----
set.seed(3013)
attempt1_svm_rad_rec5_tuned <- svm_rad_wkflow |>
  tune_grid(
    resamples = recipes_folds,
    grid = svm_rad_grid,
    control = control_resamples(save_workflow = TRUE),
    metrics = metric_set(rmse)
  )

save(attempt1_svm_rad_rec5_tuned, file = here("results/attempt1_svm_rad_rec5_tuned.rda"))