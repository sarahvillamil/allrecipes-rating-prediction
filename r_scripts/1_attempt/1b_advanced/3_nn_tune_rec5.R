# Final Project ----
# Fit Neural Network Model
# load packages ----
library(tidymodels)
library(tidyverse)
library(here)

# handle common conflicts ----
tidymodels_prefer()

# load necessary objects ----
load(here("recipes/complex_recipes.rda"))
load(here("data/recipes_split.rda"))

# neural network model ----
nn_spec <- mlp(
  hidden_units = tune(),
  penalty = tune(),
  epochs = tune()
) |>
  set_engine("nnet") |>
  set_mode("regression")

nn_wkflow <- workflow() |>
  add_model(nn_spec) |>
  add_recipe(recipe_distance_complex)

# hyperparameters ----
nn_params <- extract_parameter_set_dials(nn_spec) |>
  update(
    hidden_units = hidden_units(range = c(1, 10)),
    penalty = penalty(range = c(-5, 0)),
    epochs = epochs(range = c(50, 500))
  )

nn_grid <- grid_regular(nn_params, levels = 3)

# fit model ----
set.seed(3013)
attempt1_nn_rec5_tuned <- nn_wkflow |>
  tune_grid(
    resamples = recipes_folds,
    grid = nn_grid,
    control = control_resamples(save_workflow = TRUE),
    metrics = metric_set(rmse)
  )

save(attempt1_nn_rec5_tuned, file = here("results/attempt1_nn_rec5_tuned.rda"))