# Final Project ----
# Analyzing performance of the final model

# Load package(s)
library(tidymodels)
library(tidyverse)
library(here)

# handle common conflicts
tidymodels_prefer()

# load testing data
load(here("data/recipes_split.rda"))

# load best fit model
load(here("results/final_fit.rda"))

# add predictions to test data
final_results <- recipes_test |> 
  select(avg_rating) |> 
  bind_cols(predict(final_fit, recipes_test)) |>
  rename(predicted = .pred)

final_metrics <- metric_set(rmse)

final_rmse <- final_metrics(final_results, truth = avg_rating, estimate = predicted) |> 
  select(metric = .metric,
         estimate = .estimate) |> 
  mutate(`Model Type` = "Ensemble MARS & BT") |> 
  select(`Model Type`, metric, estimate) |>
  knitr::kable(digits = 3)

# figure visualization
final_graph <- final_results |> 
  ggplot(aes(x = avg_rating, y = predicted)) +
  geom_abline(lty = 2) + 
  geom_point(alpha = 0.25) + 
  labs(y = "Predicted Average Rating", 
       x = "Actual Average Rating",
       title = "Predicted vs. Actual Average Recipe Ratings") +
  coord_obs_pred() +
  theme_bw()

# best parameters ----
final_fit_autplot <- autoplot(final_fit)

save(final_graph, final_rmse, final_fit_autplot, file = here("plots/final_tbls_graphs.rda"))
