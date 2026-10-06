# Final Project ----
# Null model fit

# load packages ----
library(tidymodels)
library(tidyverse)
library(here)

# handle common conflicts ----
tidymodels_prefer()

# load necessary objects
load(here("recipes/recipes.rda"))
load(here("data/recipes_split.rda"))

# null model ----
null_spec <- null_model() |>  
  set_engine("parsnip") |> 
  set_mode("regression")

null_wkflow <- workflow() |> 
  add_model(null_spec) |> 
  add_recipe(recipe_null)

set.seed(3013)
attempt1_null_rec1_fit <- null_wkflow |> 
  fit_resamples(
    resamples = recipes_folds, 
    control = control_resamples(save_workflow = TRUE),
    metrics = metric_set(rmse)
  )

save(attempt1_null_rec1_fit, file = here("results/attempt1_null_rec1_fit.rda"))