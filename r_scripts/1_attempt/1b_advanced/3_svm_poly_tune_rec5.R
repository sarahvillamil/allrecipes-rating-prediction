# Final Project ----
# Fit SVM Polynomial Model
# load packages ----
library(tidymodels)
library(tidyverse)
library(here)

# handle common conflicts ----
tidymodels_prefer()

# load necessary objects ----
load(here("recipes/complex_recipes.rda"))
load(here("data/recipes_split.rda"))

# svm poly model ----
svm_poly_spec <- svm_poly(
  cost = tune(),
  degree = tune(),
  scale_factor = tune()
) |>
  set_engine("kernlab") |>
  set_mode("regression")

svm_poly_wkflow <- workflow() |>
  add_model(svm_poly_spec) |>
  add_recipe(recipe_distance_complex)

# hyperparameters ----
svm_poly_params <- extract_parameter_set_dials(svm_poly_spec) |>
  update(
    cost = cost(range = c(-3, 3)),
    degree = degree(range = c(1, 3)),
    scale_factor = scale_factor(range = c(-3, -1))
  )

svm_poly_grid <- grid_regular(svm_poly_params, levels = 3)

# tune model ----
set.seed(3013)
attempt1_svm_poly_rec5_tuned <- svm_poly_wkflow |>
  tune_grid(
    resamples = recipes_folds,
    grid = svm_poly_grid,
    control = control_resamples(save_workflow = TRUE),
    metrics = metric_set(rmse)
  )

save(attempt1_svm_poly_rec5_tuned, file = here("results/attempt1_svm_poly_rec5_tuned.rda"))