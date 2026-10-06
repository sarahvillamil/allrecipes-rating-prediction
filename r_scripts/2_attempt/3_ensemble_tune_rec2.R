# Final Project ----
# Fit Ensemble Model: MARS and BT - Attempt 2 (Refined Hyperparameters & Model Candidates) 
# load packages ----
library(tidymodels)
library(tidyverse)
library(here)
library(stacks)
library(tictoc)
library(future)

# handle common conflicts ----
tidymodels_prefer()

# parallel processing ----
num_cores <- parallel::detectCores(logical = TRUE)/2
plan(multisession, workers = num_cores)

# load necessary objects ----
load(here("recipes/recipes.rda"))
load(here("data/recipes_split.rda"))
load(here("results/attempt2_mars_rec2_tuned.rda"))
load(here("results/attempt2_bt_rec2_tuned.rda"))

# Create data stack with better performing model types: BT and MARS----
ensemble_st <- 
  stacks() |>
  add_candidates(attempt2_mars_rec2_tuned) |>
  add_candidates(attempt2_bt_rec2_tuned)

# Fit the stack ----
# In first attempt, autoplot showed rmse increase when number of members decreased. 
# It was under-regularized so penalty was increased to prevent overfitting. 
blend_penalty <- c(10^(-6:-4), seq(0.0002, 0.0009, by=0.0001), 
                   seq(0.001, 0.01, by=0.001), 0.05, 0.1, 0.25, 0.5)

# blend predictions ----
set.seed(3013)
tic.clearlog() # clear log
tic("Ensemble: MARS & BT, Rec 2") # start clock
ensemble_model_st <-
  ensemble_st |>
  blend_predictions()

# fit to training set ----
attempt2_ensemble_rec2_tuned <-
  ensemble_model_st |>
  fit_members() 

toc(log = TRUE) # stop clock

# Extract runtime info
time_log <- tic.log(format = FALSE)

attempt2_ensemble_rec2_tictoc <- tibble(
  model = time_log[[1]]$msg,
  start_time = time_log[[1]]$tic,
  end_time = time_log[[1]]$toc,
  runtime = end_time - start_time
)

# Save file
save(attempt2_ensemble_rec2_tuned, file = here("results/attempt2_ensemble_rec2_tuned.rda"))
save(attempt2_ensemble_rec2_tictoc, file = here("results/attempt2_ensemble_rec2_tictoc.rda"))