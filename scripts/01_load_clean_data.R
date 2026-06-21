# scripts/01_load_clean_data.R

# Purpose: Load raw Steam game data, do initial cleaning, and save a cleaned dataset.

library(tidyverse)
library(lubridate)
dir.create("data/processed", recursive = TRUE, showWarnings = FALSE)
dir.create("results", recursive = TRUE, showWarnings = FALSE)

# Load raw data
raw_data <- read_csv("data/raw/steam_games.csv", show_col_types = FALSE)
message("Raw data loaded:")
message("Rows: ", nrow(raw_data))
message("Columns: ", ncol(raw_data))

# Check missing values by column
missing_summary <- raw_data %>%
  summarise(across(everything(), ~ sum(is.na(.)))) %>%
  pivot_longer(
    cols = everything(),
    names_to = "column",
    values_to = "missing_count"
  ) %>%
  arrange(desc(missing_count))

write_csv(missing_summary, "results/missing_value_summary.csv")

# Metacritic = 0 likely means score unavailable, not an actual critic score.
# Keep only games with valid Metacritic scores for modeling.


valid_metacritic_data <- raw_data %>%
  filter(!is.na(Metacritic), Metacritic > 0)


## Parse release date and extract year, convert IsFree to logical, and ensure genre columns are logical.

clean_data <- valid_metacritic_data %>%
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
    nrow(valid_metacritic_data),
    nrow(clean_data),
    nrow(raw_data) - nrow(valid_metacritic_data),
    nrow(valid_metacritic_data) - nrow(clean_data)
  )
)

write_csv(cleaning_summary, "results/cleaning_summary.csv")

message("Cleaning complete.")
message("Cleaned rows: ", nrow(clean_data))
message("Saved cleaned data to data/processed/steam_games_clean.csv")
message("Saved cleaning summary to results/cleaning_summary.csv")