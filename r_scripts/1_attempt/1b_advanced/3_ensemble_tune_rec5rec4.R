# Final Project ----
# Fit Ensemble Model: KNN and BT
# load packages ----
library(tidymodels)
library(tidyverse)
library(here)
library(stacks)
library(future)

# handle common conflicts ----
tidymodels_prefer()

# parallel processing ----
num_cores <- parallel::detectCores(logical = TRUE)/2
plan(multisession, workers = num_cores)

# load necessary objects ----
load(here("recipes/recipes.rda"))
load(here("data/recipes_split.rda"))
load(here("results/attempt1_knn_rec5_tuned.rda"))
load(here("results/attempt1_bt_rec4_tuned.rda"))

# Create data stack ----
ensemble_st <- 
  stacks() |>
  add_candidates(attempt1_knn_rec5_tuned) |>
  add_candidates(attempt1_bt_rec4_tuned)

# Fit the stack ----
blend_penalty <- c(10^(-6:-1), 0.5, 1, 1.5, 2)

set.seed(3013)
ensemble_model_st <-
  ensemble_st |>
  blend_predictions()

# Explore the blended model stack
autoplot(ensemble_model_st)

# fit to training set ----
attempt1_ensemble_rec5rec4_tuned <-
  ensemble_model_st |>
  fit_members()

# Save file
save(attempt1_ensemble_rec5rec4_tuned, file = here("results/attempt1_ensemble_rec5rec4_tuned.rda"))

