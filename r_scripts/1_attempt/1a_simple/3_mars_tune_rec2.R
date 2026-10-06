# Final Project ----
# Fit MARS Model
# load packages ----
library(tidymodels)
library(tidyverse)
library(here)

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

# hyperparameters ----
mars_params <- extract_parameter_set_dials(mars_spec) |>
  update(
    num_terms = num_terms(range = c(1, 20)),
    prod_degree = prod_degree(range = c(1, 2))
  )

mars_grid <- grid_regular(mars_params, levels = 5)

# fit model ----
set.seed(3013)
attempt1_mars_rec2_tuned <- mars_wkflow |>
  tune_grid(
    resamples = recipes_folds,
    grid = mars_grid,
    control = control_resamples(save_workflow = TRUE),
    metrics = metric_set(rmse)
  )

save(attempt1_mars_rec2_tuned, file = here("results/attempt1_mars_rec2_tuned.rda"))

# best parameters/ autoplots -----
select_best(attempt1_mars_rec2_tuned, metric = "rmse")
attempt1_mars_rec2_autplot <- autoplot(attempt1_mars_rec2_tuned)

save(attempt1_mars_rec2_autplot, file = here("plots/attempt1_mars_rec2_autplot.rda"))