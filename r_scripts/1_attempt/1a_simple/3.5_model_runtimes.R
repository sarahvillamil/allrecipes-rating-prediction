# Final Project ----
# Calculate simple model runtimes

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

# load data objects ----
load(here("recipes/recipes.rda"))
load(here("data/recipes_split.rda"))
load(here("results/attempt1_bt_rec2_tuned.rda"))
load(here("results/attempt1_en_rec3_tuned.rda"))
load(here("results/attempt1_knn_rec3_tuned.rda"))
load(here("results/attempt1_mars_rec2_tuned.rda"))
load(here("results/attempt1_nn_rec3_tuned.rda"))
load(here("results/attempt1_rf_rec2_tuned.rda"))
load(here("results/attempt1_svm_poly_rec3_tuned.rda"))
load(here("results/attempt1_svm_rad_rec3_tuned.rda"))

# boosted tree ----
## best parameters
select_best(attempt1_bt_rec2_tuned, metric = "rmse")

## workflow
bt_mod <- boost_tree(
  min_n = 15, 
  mtry = 1, 
  trees = 250,
  learn_rate = 0.0398
) |>
  set_engine("xgboost") |> 
  set_mode("regression")

bt_wkflow <- workflow() |> 
  add_model(bt_mod) |> 
  add_recipe(recipe_tree)

## best model runtime
tic.clearlog()
tic("bt simple")

set.seed(3013)

bt_fit <- bt_wkflow |> 
  fit(recipes_train)

toc(log = TRUE)

time_log <- tic.log(format = FALSE)

bt_tictoc <- tibble(
  model = time_log[[1]]$msg,
  start_time = time_log[[1]]$tic,
  end_time = time_log[[1]]$toc,
  avg_runtime = end_time - start_time
)

## 5 folds * 3 repeats * (5 * 3 * 5 * 5) grid levels = 5625 models
bt_runtime <- bt_tictoc |>
  select(model, avg_runtime) |>
  mutate(total_runtime = (5625 * avg_runtime) / 8)

# elastic net ----
## best parameters
select_best(attempt1_en_rec3_tuned, metric = "rmse")

## workflow
en_spec <- linear_reg(
  penalty = 0.00316,
  mixture = 0.5
) |>
  set_engine("glmnet") |>
  set_mode("regression")

en_wkflow <- workflow() |>
  add_model(en_spec) |>
  add_recipe(recipe_distance)

## best model runtime
tic.clearlog()
tic("en simple")

set.seed(3013)

en_fit <- en_wkflow |> 
  fit(recipes_train)

toc(log = TRUE)

time_log <- tic.log(format = FALSE)

en_tictoc <- tibble(
  model = time_log[[1]]$msg,
  start_time = time_log[[1]]$tic,
  end_time = time_log[[1]]$toc,
  avg_runtime = end_time - start_time
)

## 5 folds * 3 repeats * (5 * 5) grid levels = 375 models
en_runtime <- en_tictoc |>
  select(model, avg_runtime) |>
  mutate(total_runtime = (375 * avg_runtime) / 8)

# knn ----
## best parameters
select_best(attempt1_knn_rec3_tuned, metric = "rmse")

## workflow
knn_spec <- nearest_neighbor(
  neighbors = 20
) |>
  set_engine("kknn") |>
  set_mode("regression")

knn_wkflow <- workflow() |>
  add_model(knn_spec) |>
  add_recipe(recipe_distance)

## best model runtime
tic.clearlog()
tic("knn simple")

set.seed(3013)

knn_fit <- knn_wkflow |> 
  fit(recipes_train)

toc(log = TRUE)

time_log <- tic.log(format = FALSE)

knn_tictoc <- tibble(
  model = time_log[[1]]$msg,
  start_time = time_log[[1]]$tic,
  end_time = time_log[[1]]$toc,
  avg_runtime = end_time - start_time
)

## 5 folds * 3 repeats * 10 grid levels = 150 models
knn_runtime <- knn_tictoc |>
  select(model, avg_runtime) |>
  mutate(total_runtime = (150 * avg_runtime) / 8)

# linear reg ----
## workflow
lm_spec <- linear_reg() |>  
  set_engine("lm") |> 
  set_mode("regression")

lm_wkflow <- workflow() |> 
  add_model(lm_spec) |> 
  add_recipe(recipe_distance)

## model runtime
tic.clearlog()
tic("lm simple")

set.seed(3013)

lm_fit <- lm_wkflow |> 
  fit(recipes_train)

toc(log = TRUE)

time_log <- tic.log(format = FALSE)

lm_tictoc <- tibble(
  model = time_log[[1]]$msg,
  start_time = time_log[[1]]$tic,
  end_time = time_log[[1]]$toc,
  avg_runtime = end_time - start_time
)

## 5 folds * 3 repeats = 15 models
lm_runtime <- lm_tictoc |>
  select(model, avg_runtime) |>
  mutate(total_runtime = (15 * avg_runtime) / 8)

# mars ----
## best parameters
select_best(attempt1_mars_rec2_tuned, metric = "rmse")

## workflow
mars_spec <- mars(
  num_terms = 20,
  prod_degree = 1
) |>
  set_engine("earth") |>
  set_mode("regression")

mars_wkflow <- workflow() |>
  add_model(mars_spec) |>
  add_recipe(recipe_tree)

## best model runtime
tic.clearlog()
tic("mars simple")

set.seed(3013)

mars_fit <- mars_wkflow |> 
  fit(recipes_train)

toc(log = TRUE)

time_log <- tic.log(format = FALSE)

mars_tictoc <- tibble(
  model = time_log[[1]]$msg,
  start_time = time_log[[1]]$tic,
  end_time = time_log[[1]]$toc,
  avg_runtime = end_time - start_time
)

## 5 folds * 3 repeats * (5 * 5) grid levels = 375 models
mars_runtime <- mars_tictoc |>
  select(model, avg_runtime) |>
  mutate(total_runtime = (375 * avg_runtime) / 8)

# neural network ----
## best parameters
select_best(attempt1_nn_rec3_tuned, metric = "rmse")

## workflow
nn_spec <- mlp(
  hidden_units = 1,
  penalty = 1,
  epochs = 275
) |>
  set_engine("nnet") |>
  set_mode("regression")

nn_wkflow <- workflow() |>
  add_model(nn_spec) |>
  add_recipe(recipe_distance)

## best model runtime
tic.clearlog()
tic("nn simple")

set.seed(3013)

nn_fit <- nn_wkflow |> 
  fit(recipes_train)

toc(log = TRUE)

time_log <- tic.log(format = FALSE)

nn_tictoc <- tibble(
  model = time_log[[1]]$msg,
  start_time = time_log[[1]]$tic,
  end_time = time_log[[1]]$toc,
  avg_runtime = end_time - start_time
)

## 5 folds * 3 repeats * (3 * 3 * 3) grid levels = 405 models
nn_runtime <- nn_tictoc |>
  select(model, avg_runtime) |>
  mutate(total_runtime = (405 * avg_runtime) / 8)

# null ----
## workflow
null_spec <- null_model() |>  
  set_engine("parsnip") |> 
  set_mode("regression")

null_wkflow <- workflow() |> 
  add_model(null_spec) |> 
  add_recipe(recipe_null)

## best model runtime
tic.clearlog()
tic("null")

set.seed(3013)

null_fit <- null_wkflow |> 
  fit(recipes_train)

toc(log = TRUE)

time_log <- tic.log(format = FALSE)

null_tictoc <- tibble(
  model = time_log[[1]]$msg,
  start_time = time_log[[1]]$tic,
  end_time = time_log[[1]]$toc,
  avg_runtime = end_time - start_time
)

## 5 folds * 3 repeats = 15 models
null_runtime <- null_tictoc |>
  select(model, avg_runtime) |>
  mutate(total_runtime = (15 * avg_runtime) / 8)

# random forest ----
## best parameters
select_best(attempt1_rf_rec2_tuned, metric = "rmse")

## workflow
rf_spec <- rand_forest(
  min_n = 20, 
  mtry = 3, 
  trees = 500
) |>
  set_engine("ranger") |> 
  set_mode("regression")

rf_wkflow <- workflow() |> 
  add_model(rf_spec) |> 
  add_recipe(recipe_tree)

## best model runtime
tic.clearlog()
tic("rf simple")

set.seed(3013)

rf_fit <- rf_wkflow |> 
  fit(recipes_train)

toc(log = TRUE)

time_log <- tic.log(format = FALSE)

rf_tictoc <- tibble(
  model = time_log[[1]]$msg,
  start_time = time_log[[1]]$tic,
  end_time = time_log[[1]]$toc,
  avg_runtime = end_time - start_time
)

## 5 folds * 3 repeats * (3 * 5 * 5) grid levels = 1125 models
rf_runtime <- rf_tictoc |>
  select(model, avg_runtime) |>
  mutate(total_runtime = (1125 * avg_runtime) / 8)

# svm poly ----
## best parameters
select_best(attempt1_svm_poly_rec3_tuned, metric = "rmse")

## workflow
svm_poly_spec <- svm_poly(
  cost = 8,
  degree = 1,
  scale_factor = 0.001
) |>
  set_engine("kernlab") |>
  set_mode("regression")

svm_poly_wkflow <- workflow() |>
  add_model(svm_poly_spec) |>
  add_recipe(recipe_distance)

## best model runtime
tic.clearlog()
tic("svm poly simple")

set.seed(3013)

svm_poly_fit <- svm_poly_wkflow |> 
  fit(recipes_train)

toc(log = TRUE)

time_log <- tic.log(format = FALSE)

svm_poly_tictoc <- tibble(
  model = time_log[[1]]$msg,
  start_time = time_log[[1]]$tic,
  end_time = time_log[[1]]$toc,
  avg_runtime = end_time - start_time
)

## 5 folds * 3 repeats * (3 * 3 * 3) grid levels = 405 models
svm_poly_runtime <- svm_poly_tictoc |>
  select(model, avg_runtime) |>
  mutate(total_runtime = (405 * avg_runtime) / 8)

# svm rad ----
## best parameters
select_best(attempt1_svm_rad_rec3_tuned, metric = "rmse")

## workflow
svm_rad_spec <- svm_rbf(
  cost = 0.354,
  rbf_sigma = 0.01
) |>
  set_engine("kernlab") |>
  set_mode("regression")

svm_rad_wkflow <- workflow() |>
  add_model(svm_rad_spec) |>
  add_recipe(recipe_distance)

## best model runtime
tic.clearlog()
tic("svm rad simple")

set.seed(3013)

svm_rad_fit <- svm_rad_wkflow |> 
  fit(recipes_train)

toc(log = TRUE)

time_log <- tic.log(format = FALSE)

svm_rad_tictoc <- tibble(
  model = time_log[[1]]$msg,
  start_time = time_log[[1]]$tic,
  end_time = time_log[[1]]$toc,
  avg_runtime = end_time - start_time
)

## 5 folds * 3 repeats * (5 * 5) grid levels = 375 models
svm_rad_runtime <- svm_rad_tictoc |>
  select(model, avg_runtime) |>
  mutate(total_runtime = (375 * avg_runtime) / 8)

# ensemble ----
## create data stack
ensemble_st <- stacks() |>
  add_candidates(attempt1_knn_rec3_tuned) |>
  add_candidates(attempt1_bt_rec2_tuned)

## fit stack
blend_penalty <- c(10^(-6:-1), 0.5, 1, 1.5, 2)

set.seed(3013)

ensemble_model_st <- ensemble_st |>
  blend_predictions()

## full ensemble runtime
tic.clearlog()
tic("ensemble knn/bt simple")

attempt1_ensemble_rec3rec2_tuned <- ensemble_model_st |>
  fit_members()

toc(log = TRUE)

time_log <- tic.log(format = FALSE)

ensemble_tictoc <- tibble(
  model = time_log[[1]]$msg,
  start_time = time_log[[1]]$tic,
  end_time = time_log[[1]]$toc,
  total_runtime = end_time - start_time
)

ensemble_runtime <- ensemble_tictoc |>
  select(model, total_runtime)
  
# all model runtimes ----
simple_runtimes <- bt_runtime |>
  bind_rows(en_runtime, knn_runtime, lm_runtime, mars_runtime, nn_runtime, null_runtime, rf_runtime, svm_poly_runtime, svm_rad_runtime, ensemble_runtime)

# save ----
save(simple_runtimes, file = here("results/simple_runtimes.rda"))
