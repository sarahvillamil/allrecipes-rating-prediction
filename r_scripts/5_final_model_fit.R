# Final Project ----
# Training the best refined/tuned model on training set

# Load package(s)
library(tidymodels)
library(tidyverse)
library(here)
library(stacks)
# handle common conflicts
tidymodels_prefer()

# load training data
load(here("data/recipes_split.rda"))

# load best tuned model
load(here("results/attempt2_ensemble_rec2_tuned.rda"))

## train model
## set seed
set.seed(3013)
final_fit <- attempt2_ensemble_rec2_tuned |>
  fit_members() 

save(final_fit, file = here("results/final_fit.rda"))