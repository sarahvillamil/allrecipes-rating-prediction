# Final Project ----
# Linear model fit

# load packages ----
library(tidymodels)
library(tidyverse)
library(here)

# handle common conflicts ----
tidymodels_prefer()

# load necessary objects
load(here("recipes/complex_recipes.rda"))
load(here("data/recipes_split.rda"))

# linear model ----
lm_spec <- linear_reg() |>  
  set_engine("lm") |> 
  set_mode("regression")

lm_wkflow <- workflow() |> 
  add_model(lm_spec) |> 
  add_recipe(recipe_distance_complex)

set.seed(3013)
attempt1_lm_rec5_tuned <- lm_wkflow |> 
  fit_resamples(
    resamples = recipes_folds, 
    control = control_resamples(save_workflow = TRUE),
    metrics = metric_set(rmse)
  )

save(attempt1_lm_rec5_tuned, file = here("results/attempt1_lm_rec5_tuned.rda"))