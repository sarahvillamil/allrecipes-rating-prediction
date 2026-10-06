# Final Project ----
# Data splitting

# load packages ----
library(tidymodels)
library(tidyverse)
library(naniar)
library(here)

# handle common conflicts ----
tidymodels_prefer()

# load cleaned data ----
load(here("data/all_recipes_clean.rda"))

# initial inspection ----
skimr::skim_without_charts(all_recipes)

# check outcome distribution ----
all_recipes |>
  ggplot(aes(x = avg_rating)) +
  geom_histogram() +
  labs(title = "Distribution of avg_rating")

# missingness EDA ----
miss_var_summary(all_recipes)
gg_miss_var(all_recipes, show_pct = TRUE)

# initial split ----
set.seed(3013)
recipes_split <- initial_split(
  all_recipes,
  prop = 0.8,
  strata = avg_rating
)

recipes_train <- recipes_split |> training()
recipes_test  <- recipes_split |> testing()

# create folds ----
set.seed(3013)
recipes_folds <- vfold_cv(
  recipes_train,
  v = 5,
  repeats = 3,
  strata = avg_rating
)

# save ----
save(
  recipes_train,
  recipes_test,
  recipes_folds,
  file = here("data/recipes_split.rda")
)