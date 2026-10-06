# Final Project ----
# Recipes

# load packages ----
library(tidymodels)
library(tidyverse)
library(here)

# handle common conflicts ----
tidymodels_prefer()

# load split data ----
load(here("data/recipes_split.rda"))

# variables to exclude ----
# url, ingredients: identifiers/raw text (features already extracted)
# name, author: too high cardinality
# total_ratings, reviews: leakage (consequence of avg_rating)
exclude_vars <- c("url", "ingredients", "name", "author", "total_ratings", "reviews")

# RECIPE 1: Null recipe ----
# baseline — no preprocessing, just remove excluded vars
recipe_null <- recipe(avg_rating ~ ., data = recipes_train) |>
  step_rm(url, ingredients, name, author, total_ratings, reviews, date_published)

# RECIPE 2: Tree-based recipe ----
# for models like random forest, boosted trees
# trees don't need normalization but need careful factor handling
recipe_tree <- recipe(avg_rating ~ ., data = recipes_train) |>
  step_rm(url, ingredients, name, author, total_ratings, reviews) |>
  step_date(date_published, features = c("year", "month")) |>
  step_rm(date_published) |>
  step_novel(all_nominal_predictors()) |>
  step_other(all_nominal_predictors(), threshold = 0.05) |>
  step_dummy(all_nominal_predictors()) |>
  step_nzv(all_predictors()) |>
  step_impute_median(all_numeric_predictors())

# RECIPE 3: Distance/linear recipe ----
# for models like KNN, SVM, linear regression, elastic net
# needs normalization on top of everything in tree recipe
recipe_distance <- recipe(avg_rating ~ ., data = recipes_train) |>
  step_rm(url, ingredients, name, author, total_ratings, reviews) |>
  step_date(date_published, features = c("year", "month")) |>
  step_rm(date_published) |>
  step_novel(all_nominal_predictors()) |>
  step_other(all_nominal_predictors(), threshold = 0.05) |>
  step_dummy(all_nominal_predictors()) |>
  step_nzv(all_predictors()) |>
  step_impute_median(all_numeric_predictors()) |>
  step_normalize(all_numeric_predictors())

# save ----
save(
  recipe_null,
  recipe_tree,
  recipe_distance,
  file = here("recipes/recipes.rda")
)


recipe_tree |> prep() |> bake(new_data = NULL) |> glimpse()
