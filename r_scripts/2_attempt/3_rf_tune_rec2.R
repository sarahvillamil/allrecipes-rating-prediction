# Final Project ----
# Fit Random Forest Model - Attempt 2 (Refined Hyperparameters)

# load packages ----
library(tidymodels)
library(tidyverse)
library(here)
library(future)
library(tictoc)

# handle common conflicts ----
tidymodels_prefer()

# parallel processing ----
num_cores <- parallel::detectCores(logical = TRUE)/2
plan(multisession, workers = num_cores)

# load necessary objects ----
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

# refined hyperparameters ----
# best from attempt 1: mtry=3, trees=500, min_n=20 (hit ceiling)
# extending min_n range and narrowing around best values
rf_params <- extract_parameter_set_dials(rf_spec) |> 
  update(
    mtry = mtry(c(2, 5)),
    trees = trees(range = c(400, 700)),
    min_n = min_n(range = c(15, 30))
  )

rf_grid <- grid_regular(rf_params, levels = c(4, 4, 4))

# fit model ----
set.seed(3013)
tic.clearlog() # clear log
tic("Random Forest: Rec 2") # start clock
attempt2_rf_rec2_tuned <- rf_wkflow |> 
  tune_grid(
    resamples = recipes_folds, 
    grid = rf_grid, 
    control = control_resamples(save_workflow = TRUE),
    metrics = metric_set(rmse)
  )
toc(log = TRUE) # stop clock

# Extract runtime info
time_log <- tic.log(format = FALSE)

attempt2_rf_rec2_tictoc <- tibble(
  model = time_log[[1]]$msg,
  start_time = time_log[[1]]$tic,
  end_time = time_log[[1]]$toc,
  runtime = end_time - start_time
)

# save out results
save(attempt2_rf_rec2_tuned, file = here("results/attempt2_rf_rec2_tuned.rda"))
save(attempt2_rf_rec2_tictoc, file = here("results/attempt2_rf_rec2_tictoc.rda"))