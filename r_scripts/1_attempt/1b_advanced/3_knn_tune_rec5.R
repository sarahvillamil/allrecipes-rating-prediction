# Final Project ----
# Fit KNN Model
# load packages ----
library(tidymodels)
library(tidyverse)
library(here)
library(stacks)
library(future)

# handle common conflicts ----
tidymodels_prefer()

# parallel processing ----
num_cores <- parallel::detectCores(logical = TRUE) / 2
plan(multisession, workers = num_cores)

# load necessary objects ----
load(here("recipes/complex_recipes.rda"))
load(here("data/recipes_split.rda"))

# knn model ----
knn_spec <- nearest_neighbor(
  neighbors = tune()
) |>
  set_engine("kknn") |>
  set_mode("regression")

knn_wkflow <- workflow() |>
  add_model(knn_spec) |>
  add_recipe(recipe_distance_complex)

# hyperparameters ----
knn_params <- extract_parameter_set_dials(knn_spec) |>
  update(
    neighbors = neighbors(range = c(1, 20))
  )

knn_grid <- grid_regular(knn_params, levels = 10)

# fit model ----
set.seed(3013)
attempt1_knn_rec5_tuned <- knn_wkflow |>
  tune_grid(
    resamples = recipes_folds,
    grid = knn_grid,
    control = control_stack_grid(),
    metrics = metric_set(rmse)
  )

save(attempt1_knn_rec5_tuned, file = here("results/attempt1_knn_rec5_tuned.rda"))