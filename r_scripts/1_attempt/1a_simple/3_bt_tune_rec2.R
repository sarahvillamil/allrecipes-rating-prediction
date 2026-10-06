# Final Project ----
# Fit Boosted Tree Model

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

# load necessary objects
load(here("recipes/recipes.rda"))
load(here("data/recipes_split.rda"))

# rf model ----
bt_mod <- boost_tree(
  min_n = tune(), 
  mtry = tune(), 
  trees = tune(),
  learn_rate = tune()
) |>
  set_engine("xgboost") |> 
  set_mode("regression")

bt_wkflow <- workflow() |> 
  add_model(bt_mod) |> 
  add_recipe(recipe_tree)

# hyperparameters ----
bt_params <- extract_parameter_set_dials(bt_mod) |> 
  update(
    min_n = min_n(range = c(2,20)),
    mtry = mtry(c(1, 6)),
    trees = trees(range = c(250, 750)),
    learn_rate = learn_rate(range = c(-5, -0.2))
  )

bt_grid <- grid_regular(bt_params, levels = c(5, 3, 5, 5))

# fit model ----
set.seed(3013)

attempt1_bt_rec2_tuned <- bt_wkflow |> 
  tune_grid(
    resamples = recipes_folds, 
    grid = bt_grid, 
    control = control_stack_grid(),
    metrics = metric_set(rmse)
  )

save(attempt1_bt_rec2_tuned, file = here("results/attempt1_bt_rec2_tuned.rda"))

# best parameters/ autoplots -----
select_best(attempt1_bt_rec2_tuned, metric = "rmse")
attempt1_bt_rec2_autoplot <- autoplot(attempt1_bt_rec2_tuned)

save(attempt1_bt_rec2_autoplot, file = here("plots/attempt1_bt_rec2_autoplot.rda"))


