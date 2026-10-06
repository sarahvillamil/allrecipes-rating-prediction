# Final Project ----
# Fit Boosted Tree Model - Attempt 2 (Refined Hyperparameters)

# load packages ----
library(tidymodels)
library(tidyverse)
library(here)
library(future)
library(tictoc)
library(stacks)

# handle common conflicts ----
tidymodels_prefer()

# parallel processing ----
num_cores <- parallel::detectCores(logical = TRUE) / 2
plan(multisession, workers = num_cores)

# load necessary objects ----
load(here("recipes/recipes.rda"))
load(here("data/recipes_split.rda"))

# bt model ----
bt_mod <- boost_tree(
  min_n = tune(), 
  mtry = tune(), 
  trees = tune(),
  learn_rate = tune(),
  tree_depth = tune()
) |>
  set_engine("xgboost") |> 
  set_mode("regression")

bt_wkflow <- workflow() |> 
  add_model(bt_mod) |> 
  add_recipe(recipe_tree)

# refined hyperparameters ----
# best from attempt 1: mtry=1, trees=250, min_n=15, learn_rate=0.0398
# adding tree_depth, narrowing grid around best values
bt_params <- extract_parameter_set_dials(bt_mod) |> 
  update(
    mtry = mtry(c(1, 3)),
    trees = trees(range = c(200, 400)),
    min_n = min_n(range = c(10, 20)),
    learn_rate = learn_rate(range = c(-2, -1)),
    tree_depth = tree_depth(range = c(1, 8))
  )

bt_grid <- grid_regular(bt_params, levels = c(3, 3, 3, 3, 3))

# fit model ----
set.seed(3013)
tic.clearlog() # clear log
tic("Boosted Tree: Rec 2") # start clock
attempt2_bt_rec2_tuned <- bt_wkflow |> 
  tune_grid(
    resamples = recipes_folds, 
    grid = bt_grid, 
    control = control_stack_grid(),
    metrics = metric_set(rmse)
  )
toc(log = TRUE) # stop clock

# Extract runtime info
time_log <- tic.log(format = FALSE)

attempt2_bt_rec2_tictoc <- tibble(
  model = time_log[[1]]$msg,
  start_time = time_log[[1]]$tic,
  end_time = time_log[[1]]$toc,
  runtime = end_time - start_time
)

# save out results
save(attempt2_bt_rec2_tuned, file = here("results/attempt2_bt_rec2_tuned.rda"))
save(attempt2_bt_rec2_tictoc, file = here("results/attempt2_bt_rec2_tictoc.rda"))