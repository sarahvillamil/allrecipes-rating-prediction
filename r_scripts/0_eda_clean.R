# Final Project ----
# Initial eda and transformations

## load packages ----
library(tidyverse)
library(tidymodels)
library(here)
library(naniar)
library(skimr)

# common conflicts
tidymodels_prefer()

# load in all_recipes data
all_recipes <- read_csv("data/all_recipes.csv")

# skimr check
skim_without_charts(all_recipes) 
# 14426 obs, 16 vars
# 4 character, 1 date, 11 numeric
# From the skim there appears to be more missingness in the numeric variables. 

missingness_overall <- all_recipes|>
  gg_miss_var() + 
  labs(
    title = "General Missingness of AllRecipes Dataset")

missingness_top <- all_recipes |> 
  miss_var_summary() |>
  filter(n_miss > 0) |> rename(`Percent Missed` = pct_miss, `Number Missed` = n_miss, `Variable` = variable) |>
  knitr::kable()

save(missingness_top, missingness_overall, file = here("plots/missingness.rda"))

# avg_rating eda
fig_target_distro <- all_recipes |>
  ggplot(aes(x = avg_rating)) +
  geom_histogram() +
  labs(
    x = "Average Rating",
    y = "Count",
    title = "Distribution of Average Rating"
  )

tbl_target_distro <- all_recipes |>
  summarize(
    mean = mean(avg_rating, na.rm = TRUE),
    median = median(avg_rating, na.rm = TRUE),
    min = min(avg_rating, na.rm = TRUE),
    max = max(avg_rating, na.rm = TRUE)
  ) |>
  knitr::kable(
    col.names = c("Mean", "Median", "Minimum", "Maximum")
  )

save(fig_target_distro, tbl_target_distro, file = here("plots/target_var_analysis.rda"))

## fix date var ----
# models cannot fit with date variables - make it into days_since_published
all_recipes <- all_recipes |> 
  filter(!is.na(avg_rating)) |> 
  mutate(days_since_published = as.numeric(Sys.Date() - date_published))

# INGREDIENT VAR ----


## n_ingredients ----
# ingredients is a raw comma-separated string — not usable for modeling directly
# count commas + 1 as a proxy for recipe complexity
# note: slightly inflated because descriptors like "chopped", "softened" 
# also follow commas within a single ingredient entry

all_recipes <- all_recipes |> 
  mutate(n_ingredients = str_count(ingredients, ",") + 1)

## is_vegetarian ----
# classify recipes as vegetarian using meat/seafood keyword detection
# word boundaries (\\b) prevent false positives e.g. "roasted" matching "roast"
# limitation: uncommon meat ingredients not in list may be misclassified
meat_keywords <- c(
  # poultry
  "chicken", "turkey", "duck", "hen", "quail", "goose", "pheasant",
  # red meat
  "beef", "pork", "lamb", "veal", "bison", "venison", "elk", "boar",
  # processed meat
  "bacon", "ham", "sausage", "pepperoni", "salami", "pastrami",
  "prosciutto", "pancetta", "chorizo", "hot dog", "bratwurst",
  "bologna", "mortadella", "lard", "spam", "jerky", "liverwurst",
  # seafood - fish
  "salmon", "tuna", "cod", "tilapia", "halibut", "anchovy", "sardine",
  "mahi", "catfish", "trout", "herring", "bass", "snapper", "flounder",
  "mackerel", "swordfish", "grouper", "pollock", "perch", "pike",
  # seafood - shellfish
  "shrimp", "crab", "lobster", "clam", "oyster", "scallop",
  "mussel", "squid", "octopus", "crawfish", "crayfish",
  # general/catch-all
  "meat", "steak", "roast", "ground beef", "ground turkey",
  "ground pork", "ground lamb", "rib", "brisket", "sirloin",
  "filet", "fillet", "drumstick", "wing", "thigh", "breast"
)

meat_pattern <- str_c("\\b", meat_keywords, "\\b", collapse = "|")

all_recipes <- all_recipes |> 
  mutate(is_vegetarian = as.numeric(!str_detect(str_to_lower(ingredients), meat_pattern)))

# misc plots
n_ingredients_plot <- all_recipes |>
  ggplot(aes(x = n_ingredients)) +
  geom_histogram(binwidth = 2, fill = "steelblue", color = "white") +
  labs(
    title = "Distribution of Number of Ingredients",
    x = "Number of Ingredients",
    y = "Count"
  )

vegetarian_rating_plot <- all_recipes |>
  filter(!is.na(avg_rating)) |>
  mutate(is_vegetarian = if_else(is_vegetarian, "Vegetarian", "Non-Vegetarian")) |>
  ggplot(aes(x = is_vegetarian, y = avg_rating, fill = is_vegetarian)) +
  geom_boxplot(show.legend = FALSE) +
  labs(
    title = "Average Rating by Vegetarian Status",
    x = "",
    y = "Average Rating"
  )

save(n_ingredients_plot, vegetarian_rating_plot, file = here("plots/misc_plots.rda"))

## has_expensive_ingredient ----
# flag recipes containing luxury/high-end ingredients
# could signal higher effort recipes which may correlate with ratings
# note: allrecipes is a home cooking site so effect may be weaker than expected

luxury_keywords <- c(
  # fancy cheeses
  "manchego", "gruyere", "brie", "burrata", "gorgonzola", 
  "roquefort", "camembert", "pecorino", "taleggio", "epoisses",
  # fancy meats
  "wagyu", "kobe", "veal", "duck", "venison", "bison", "foie gras",
  "bone marrow", "sweetbread",
  # fancy seafood
  "lobster", "caviar", "sea urchin", "uni", "bluefin", "branzino", 
  "halibut", "dover sole", "scallop", "oyster", "crab",
  # fancy fungi
  "truffle", "morel", "chanterelle", "porcini", "matsutake",
  # fancy produce
  "saffron", "vanilla bean", "dragon fruit", "rambutan", "yuzu",
  "pomegranate", "fig", "artichoke",
  # fancy alcohol
  "champagne", "cognac", "bourbon", "port", "marsala", "cointreau", 
  "grand marnier", "prosecco", "armagnac",
  # other luxury
  "gold leaf", "matcha", "tahini", "miso", "sumac", "za'atar",
  "harissa", "preserved lemon", "rose water"
)

luxury_pattern <- str_c("\\b", luxury_keywords, "\\b", collapse = "|")

all_recipes <- all_recipes |> 
  mutate(has_expensive_ingredient = as.numeric(str_detect(str_to_lower(ingredients), luxury_pattern)))

## avg rating by luxury ingredient status ----
# explore whether recipes with expensive ingredients rate differently

luxury_rating_plot <- all_recipes |>
  filter(!is.na(avg_rating)) |>
  mutate(has_expensive_ingredient = if_else(has_expensive_ingredient, 
                                            "Luxury", "Standard")) |>
 
  ggplot(aes(x = has_expensive_ingredient, y = avg_rating, fill = has_expensive_ingredient)) +
  geom_boxplot(show.legend = FALSE) +
  labs(
    title = "Average Rating by Ingredient Luxury Status",
    x = "",
    y = "Average Rating"
  )

save(n_ingredients_plot, vegetarian_rating_plot, luxury_rating_plot, 
     file = here("plots/misc_plots.rda"))

# see most common ingredient words
all_recipes |>
  pull(ingredients) |>
  str_to_lower() |>
  str_split(",") |>
  unlist() |>
  str_trim() |>
  table() |>
  sort(decreasing = TRUE) |>
  head(100)

# getting rid of words that are not ing
all_recipes |>
  pull(ingredients) |>
  str_to_lower() |>
  str_split("\\s+") |>
  unlist() |>
  str_trim() |>
  (\(x) x[!str_detect(x, "^[0-9¼½¾⅓⅔]+$")])() |>
  (\(x) x[!x %in% c("cup", "cups", "tablespoon", "tablespoons", "teaspoon", "teaspoons",
                    "chopped", "diced", "minced", "sliced", "divided", "melted", "beaten",
                    "softened", "drained", "thawed", "peeled", "crushed", "cubed",
                    "and", "or", "to", "of", "the", "a", "an", "as", "at", "in",
                    "large", "small", "medium", "fresh", "dried", "ground", "pound",
                    "ounce", "ounces", "package", "can", "taste", "needed")])() |>
  table() |>
  sort(decreasing = TRUE) |>
  head(150)


## is_sweet ----
# flag recipes containing sweet/dessert ingredients
# cinnamon and vanilla included as strong dessert signals
sweet_keywords <- c(
  "sugar", "honey", "maple syrup", "molasses", "brown sugar",
  "powdered sugar", "caramel", "chocolate", "candy", "syrup",
  "agave", "condensed milk", "nutella", "jam", "jelly",
  "cinnamon", "vanilla", "confectioners"
)
sweet_pattern <- str_c("\\b", sweet_keywords, "\\b", collapse = "|")

all_recipes <- all_recipes |>
  mutate(is_sweet = as.numeric(str_detect(str_to_lower(ingredients), sweet_pattern)))

## is_spicy ----
# flag recipes with heat-producing ingredients
# ginger included as it contributes heat in savory dishes
spicy_keywords <- c(
  "chili", "chile", "jalapeño", "jalapeno", "cayenne", "sriracha",
  "habanero", "serrano", "tabasco", "chipotle", "ghost pepper",
  "poblano", "paprika", "hot sauce", "wasabi", "gochujang",
  "sambal", "crushed red pepper", "chili powder", "pepper flakes",
  "ginger", "red pepper"
)
spicy_pattern <- str_c("\\b", spicy_keywords, "\\b", collapse = "|")

all_recipes <- all_recipes |>
  mutate(is_spicy = as.numeric(str_detect(str_to_lower(ingredients), spicy_pattern)))

## is_vegan ----
# builds on is_vegetarian — also excludes dairy, eggs, and other animal products
non_vegan_keywords <- c(
  "milk", "cream", "butter", "cheese", "egg", "eggs", "yogurt",
  "honey", "ghee", "whey", "casein", "gelatin", "mayo", "mayonnaise",
  "parmesan", "cheddar", "mozzarella", "sour cream", "heavy cream"
)
non_vegan_pattern <- str_c("\\b", non_vegan_keywords, "\\b", collapse = "|")

all_recipes <- all_recipes |>
  mutate(is_vegan = as.numeric(is_vegetarian & !str_detect(str_to_lower(ingredients), non_vegan_pattern)))

## is_quick ----
# flag recipes with total time under 30 minutes
all_recipes <- all_recipes |>
  mutate(is_quick = as.numeric(total_time <= 30))

## has_alcohol ----
alcohol_keywords <- c(
  "wine", "beer", "vodka", "rum", "whiskey", "bourbon", "tequila",
  "gin", "brandy", "champagne", "prosecco", "sake", "mirin",
  "kahlua", "baileys", "triple sec", "vermouth", "ale", "stout",
  "lager", "cider", "port", "sherry"
)
alcohol_pattern <- str_c("\\b", alcohol_keywords, "\\b", collapse = "|")

all_recipes <- all_recipes |>
  mutate(has_alcohol = as.numeric(str_detect(str_to_lower(ingredients), alcohol_pattern)))

## save cleaned data ----
save(all_recipes, file = here("data/all_recipes_clean.rda"))

## plots for new variables ----
sweet_rating_plot <- all_recipes |>
  filter(!is.na(avg_rating)) |>
  mutate(is_sweet = if_else(is_sweet, "Sweet", "Not Sweet")) |>
  ggplot(aes(x = is_sweet, y = avg_rating, fill = is_sweet)) +
  geom_boxplot(show.legend = FALSE) +
  labs(title = "Average Rating by Sweetness", x = "", y = "Average Rating")

spicy_rating_plot <- all_recipes |>
  filter(!is.na(avg_rating)) |>
  mutate(is_spicy = if_else(is_spicy, "Spicy", "Not Spicy")) |>
  ggplot(aes(x = is_spicy, y = avg_rating, fill = is_spicy)) +
  geom_boxplot(show.legend = FALSE) +
  labs(title = "Average Rating by Spiciness", x = "", y = "Average Rating")

vegan_rating_plot <- all_recipes |>
  filter(!is.na(avg_rating)) |>
  mutate(is_vegan = if_else(is_vegan, "Vegan", "Not Vegan")) |>
  ggplot(aes(x = is_vegan, y = avg_rating, fill = is_vegan)) +
  geom_boxplot(show.legend = FALSE) +
  labs(title = "Average Rating by Vegan Status", x = "", y = "Average Rating")

alcohol_rating_plot <- all_recipes |>
  filter(!is.na(avg_rating)) |>
  mutate(has_alcohol = if_else(has_alcohol, "Has Alcohol", "No Alcohol")) |>
  ggplot(aes(x = has_alcohol, y = avg_rating, fill = has_alcohol)) +
  geom_boxplot(show.legend = FALSE) +
  labs(title = "Average Rating by Alcohol Presence", x = "", y = "Average Rating")

save(n_ingredients_plot, vegetarian_rating_plot, luxury_rating_plot,
     sweet_rating_plot, spicy_rating_plot, vegan_rating_plot, alcohol_rating_plot,
     file = here("plots/misc_plots.rda"))

all_recipes |>
  select(is_sweet, is_spicy, is_vegan, is_quick, has_alcohol) |>
  summary()
