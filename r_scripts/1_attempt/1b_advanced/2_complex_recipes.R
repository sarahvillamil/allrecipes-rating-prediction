# Final Project ----
# Complex Recipes
# load packages ----
library(tidymodels)
library(tidyverse)
library(here)

# handle common conflicts ----
tidymodels_prefer()

# load split data ----
load(here("data/recipes_split.rda"))

# RECIPE 4: Complex tree recipe ----
# builds on recipe_tree with interaction terms and polynomial features
recipe_tree_complex <- recipe(avg_rating ~ ., data = recipes_train) |>
  step_rm(url, ingredients, name, author, total_ratings, reviews) |>
  step_date(date_published, features = c("year", "month")) |>
  step_rm(date_published) |>
  step_novel(all_nominal_predictors()) |>
  step_other(all_nominal_predictors(), threshold = 0.02) |>
  step_dummy(all_nominal_predictors()) |>
  step_nzv(all_predictors()) |>
  step_impute_median(all_numeric_predictors()) |>
  step_poly(n_ingredients, total_time, degree = 2)

# RECIPE 5: Complex distance recipe ----
# builds on recipe_distance with same additions plus normalization
recipe_distance_complex <- recipe(avg_rating ~ ., data = recipes_train) |>
  step_rm(url, ingredients, name, author, total_ratings, reviews) |>
  step_date(date_published, features = c("year", "month")) |>
  step_rm(date_published) |>
  step_novel(all_nominal_predictors()) |>
  step_other(all_nominal_predictors(), threshold = 0.02) |>
  step_dummy(all_nominal_predictors()) |>
  step_nzv(all_predictors()) |>
  step_impute_median(all_numeric_predictors()) |>
  step_poly(n_ingredients, total_time, degree = 2) |>
  step_interact(terms = ~ is_sweet:is_spicy + is_vegetarian:has_expensive_ingredient) |>
  step_normalize(all_numeric_predictors())

# save ----
save(
  recipe_tree_complex,
  recipe_distance_complex,
  file = here("recipes/complex_recipes.rda")
)