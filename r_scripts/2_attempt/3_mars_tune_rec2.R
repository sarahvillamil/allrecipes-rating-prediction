# Final Project ----
# Fit MARS Model - Attempt 2 (Refined Hyperparameters)

# load packages ----
library(tidymodels)
library(tidyverse)
library(here)
library(tictoc)
library(stacks)

# handle common conflicts ----
tidymodels_prefer()

# load necessary objects ----
load(here("recipes/recipes.rda"))
load(here("data/recipes_split.rda"))

# mars model ----
mars_spec <- mars(
  num_terms = tune(),
  prod_degree = tune()
) |>
  set_engine("earth") |>
  set_mode("regression")

mars_wkflow <- workflow() |>
  add_model(mars_spec) |>
  add_recipe(recipe_tree)

# refined hyperparameters ----
# best from attempt 1: num_terms=20 (hit ceiling), prod_degree=1
# extending num_terms range and exploring prod_degree=2
mars_params <- extract_parameter_set_dials(mars_spec) |>
  update(
    num_terms = num_terms(range = c(15, 40)),
    prod_degree = prod_degree(range = c(1, 2))
  )

mars_grid <- grid_regular(mars_params, levels = c(10, 2))

# fit model ----
set.seed(3013)
tic.clearlog() # clear log
tic("MARS: Rec 2") # start clock
attempt2_mars_rec2_tuned <- mars_wkflow |>
  tune_grid(
    resamples = recipes_folds,
    grid = mars_grid,
    control = control_stack_grid(),
    metrics = metric_set(rmse)
  )
toc(log = TRUE) # stop clock

# Extract runtime info
time_log <- tic.log(format = FALSE)

attempt2_mars_rec2_tictoc <- tibble(
  model = time_log[[1]]$msg,
  start_time = time_log[[1]]$tic,
  end_time = time_log[[1]]$toc,
  runtime = end_time - start_time
)

# save out results
save(attempt2_mars_rec2_tuned, file = here("results/attempt2_mars_rec2_tuned.rda"))
save(attempt2_mars_rec2_tictoc, file = here("results/attempt2_mars_rec2_tictoc.rda"))