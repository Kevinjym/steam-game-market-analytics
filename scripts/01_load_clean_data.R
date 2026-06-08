# 01_load_clean_data.R
# Purpose: Load raw Steam games data, perform initial cleaning, and export a cleaned dataset.

library(tidyverse)
library(lubridate)

# Load raw data
raw_data <- read_csv("data/raw/steam_games.csv")

# Basic data checks
glimpse(raw_data)
summary(raw_data)

# Check missing values by column
missing_summary <- raw_data %>%
  summarise(across(everything(), ~ sum(is.na(.)))) %>%
  pivot_longer(
    cols = everything(),
    names_to = "column",
    values_to = "missing_count"
  ) %>%
  arrange(desc(missing_count))

print(missing_summary)

# Metacritic = 0 likely means score unavailable, not an actual critic score.
# Keep only games with valid Metacritic scores for modeling.
clean_data <- raw_data %>%
  filter(Metacritic > 0) %>%
  mutate(
    ReleaseDateParsed = mdy(ReleaseDate),
    ReleaseYear = year(ReleaseDateParsed),
    IsFree = as.logical(IsFree),
    across(starts_with("Genre"), as.logical)
  ) %>%
  filter(!is.na(ReleaseDateParsed))

# Save cleaned data
write_csv(clean_data, "data/processed/steam_games_clean.csv")

# Save cleaning summary
cleaning_summary <- tibble(
  metric = c(
    "raw_rows",
    "raw_columns",
    "valid_metacritic_rows",
    "cleaned_rows",
    "removed_due_to_metacritic_zero_or_missing",
    "removed_due_to_invalid_release_date"
  ),
  value = c(
    nrow(raw_data),
    ncol(raw_data),
    nrow(raw_data %>% filter(Metacritic > 0)),
    nrow(clean_data),
    nrow(raw_data) - nrow(raw_data %>% filter(Metacritic > 0)),
    nrow(raw_data %>% filter(Metacritic > 0)) - nrow(clean_data)
  )
)

write_csv(cleaning_summary, "results/cleaning_summary.csv")

print(cleaning_summary)