# Final Project ----
# Fit Elastic Net Model
# load packages ----
library(tidymodels)
library(tidyverse)
library(here)

# handle common conflicts ----
tidymodels_prefer()

# load necessary objects ----
load(here("recipes/complex_recipes.rda"))
load(here("data/recipes_split.rda"))

# elastic net model ----
en_spec <- linear_reg(
  penalty = tune(),
  mixture = tune()
) |>
  set_engine("glmnet") |>
  set_mode("regression")

en_wkflow <- workflow() |>
  add_model(en_spec) |>
  add_recipe(recipe_distance_complex)

# hyperparameters ----
en_params <- extract_parameter_set_dials(en_spec) |>
  update(
    penalty = penalty(range = c(-5, 0)),
    mixture = mixture(range = c(0, 1))
  )

en_grid <- grid_regular(en_params, levels = 5)

# fit model ----
set.seed(3013)
attempt1_en_rec5_tuned <- en_wkflow |>
  tune_grid(
    resamples = recipes_folds,
    grid = en_grid,
    control = control_resamples(save_workflow = TRUE),
    metrics = metric_set(rmse)
  )

save(attempt1_en_rec5_tuned, file = here("results/attempt1_en_rec5_tuned.rda"))