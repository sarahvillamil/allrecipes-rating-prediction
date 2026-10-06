# Final Project ----
# Comparing model performance - All Refined Models

# load packages ----
library(tidyverse)
library(tidymodels)
library(here)

# handle common conflicts ----
tidymodels_prefer()

# load results
load(here("results/attempt2_bt_rec2_tuned.rda"))
load(here("results/attempt2_rf_rec2_tuned.rda"))
load(here("results/attempt2_mars_rec2_tuned.rda"))
load(here("results/attempt2_ensemble_rec2_tuned.rda"))

# load runtime results
load(here("results/attempt2_bt_rec2_tictoc.rda"))
load(here("results/attempt2_rf_rec2_tictoc.rda"))
load(here("results/attempt2_mars_rec2_tictoc.rda"))
load(here("results/attempt2_ensemble_rec2_tictoc.rda"))

# workflow set
model_results <- as_workflow_set(
  `Boosted Tree (rec2)` = attempt2_bt_rec2_tuned,
  `Random Forest (rec2)` = attempt2_rf_rec2_tuned,
  `MARS (rec2)` = attempt2_mars_rec2_tuned
)

# ensemble 
attempt2_ensemble_results <- attempt2_ensemble_rec2_tuned$metrics |>
  filter(.metric == "rmse") |>
  slice_min(mean) |>
  mutate(recipe_type = "Simple", wflow_id = "Ensemble MARS & BT (rec2)") |> 
  select(wflow_id, recipe_type, mean, std_err)

# make a dataframe of runtime results
tictoc_results <- bind_rows(list(
  attempt2_bt_rec2_tictoc,
  attempt2_rf_rec2_tictoc,
  attempt2_mars_rec2_tictoc,
  attempt2_ensemble_rec2_tictoc
)) |> 
  select(Runtime = runtime)

attempt2_results <- model_results |>
  collect_metrics() |>
  filter(.metric == "rmse") |>
  slice_min(mean, by = wflow_id) |> 
  slice_head(n = 3) |> 
  mutate(recipe_type = "Simple") |> 
  bind_rows(attempt2_ensemble_results) |>
  bind_cols(tictoc_results) |>
  arrange(mean)

attempt2_results_table <- attempt2_results |>
  select(
    `Model Type` = wflow_id,
    `Recipe Type` = recipe_type,
    RMSE = mean,
    `Std Error` = std_err,
    `Total Runtime` = Runtime
    ) |>
  knitr::kable(digits = c(NA, NA, 3, 4, 1))

attempt2_results_plot <- attempt2_results |>
  select(
    `Model Type` = wflow_id,
    `Recipe Type` = recipe_type,
    RMSE = mean,
    `Std Error` = std_err
  ) |>
  ggplot(
    aes(
      x = RMSE,
      y = reorder(`Model Type`, -RMSE),
      color = `Recipe Type`
    )
  ) +
  geom_point(
    size = 3,
    show.legend = FALSE
    ) +
  geom_errorbar(
    aes(
      xmin = RMSE - `Std Error`,
      xmax = RMSE + `Std Error`),
    width = 0.2, orientation = "y",
    show.legend = FALSE
  ) +
  theme_minimal() +
  labs(
    title = "Best RMSE by Model Type and Recipe",
    x = "RMSE",
    y = NULL
  )

# save out new file/object names ----
save(attempt2_results_table, file = here("plots/attempt2_results_table.rda"))
save(attempt2_results_plot, file = here("plots/attempt2_results_plot.rda"))

# ensemble autoplot ----
attempt2_ensemble_autoplot <- autoplot(attempt2_ensemble_rec2_tuned)
save(attempt2_ensemble_autoplot, file = here("plots/attempt2_ensemble_rec2_autoplot.rda"))