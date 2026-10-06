# Final Project ----
# Random Forest fit

# load packages ----
library(tidymodels)
library(tidyverse)
library(here)
library(future)

# handle common conflicts ----
tidymodels_prefer()

# parallel processing ----
num_cores <- parallel::detectCores(logical = TRUE)/2
plan(multisession, workers = num_cores)

# load necessary objects
load(here("recipes/recipes.rda"))
load(here("data/recipes_split.rda"))

# rf model ----
rf_spec <- rand_forest(
  min_n = tune(), 
  mtry = tune(), 
  trees = tune()
) |>
  set_engine("ranger") |> 
  set_mode("regression")

rf_wkflow <- workflow() |> 
  add_model(rf_spec) |> 
  add_recipe(recipe_tree)

# hyperparameters ----
rf_params <- extract_parameter_set_dials(rf_spec) |> 
  update(mtry = mtry(c(1, 6)), 
         trees = trees(range = c(250, 750)), 
         min_n = min_n(range = c(2,20)))

rf_grid <- grid_regular(rf_params, levels = c(3, 5, 5))

# fit model ----
set.seed(3013)
attempt1_rf_rec2_tuned <- rf_wkflow |> 
  tune_grid(
    resamples = recipes_folds, 
    grid = rf_grid, 
    control = control_resamples(save_workflow = TRUE),
    metrics = metric_set(rmse)
  )

save(attempt1_rf_rec2_tuned, file = here("results/attempt1_rf_rec2_tuned.rda"))

# best parameters/ autoplots -----
select_best(attempt1_rf_rec2_tuned, metric = "rmse")
attempt1_rf_rec2_autoplot <- autoplot(attempt1_rf_rec2_tuned)

save(attempt1_rf_rec2_autoplot, file = here("plots/attempt1_rf_rec2_autoplot.rda"))
