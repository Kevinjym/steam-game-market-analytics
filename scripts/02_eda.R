# scripts/02_eda.R

# Purpose: Explore the cleaned Steam game data and save key summary outputs.

library(tidyverse)

# Make sure output folders exist
dir.create("figures", recursive = TRUE, showWarnings = FALSE)
dir.create("results", recursive = TRUE, showWarnings = FALSE)

# Load cleaned data
steam_clean <- read_csv("data/processed/steam_games_clean.csv", show_col_types = FALSE)

message("Cleaned data loaded:")
message("Rows: ", nrow(steam_clean))
message("Columns: ", ncol(steam_clean))

# Basic summary of key numeric variables
eda_summary <- steam_clean %>%
  summarise(
    n_games = n(),
    mean_metacritic = mean(Metacritic, na.rm = TRUE),
    median_metacritic = median(Metacritic, na.rm = TRUE),
    sd_metacritic = sd(Metacritic, na.rm = TRUE),
    mean_price = mean(PriceInitial, na.rm = TRUE),
    median_price = median(PriceInitial, na.rm = TRUE),
    mean_recommendations = mean(RecommendationCount, na.rm = TRUE),
    median_recommendations = median(RecommendationCount, na.rm = TRUE),
    earliest_release_year = min(ReleaseYear, na.rm = TRUE),
    latest_release_year = max(ReleaseYear, na.rm = TRUE)
  )

write_csv(eda_summary, "results/eda_summary.csv")

# Add log recommendation count for easier plotting
steam_eda <- steam_clean %>%
  mutate(
    LogRecommendationCount = log1p(RecommendationCount)
  )

# Figure 1: Distribution of Metacritic scores
p_metacritic_dist <- ggplot(steam_eda, aes(x = Metacritic)) +
  geom_histogram(bins = 30) +
  labs(
    title = "Distribution of Metacritic Scores",
    x = "Metacritic Score",
    y = "Number of Games"
  ) +
  theme_minimal()

ggsave(
  filename = "figures/metacritic_distribution.png",
  plot = p_metacritic_dist,
  width = 8,
  height = 5
)



# Figure 2: Metacritic score by release year
yearly_metacritic <- steam_eda %>%
  group_by(ReleaseYear) %>%
  summarise(
    n_games = n(),
    mean_metacritic = mean(Metacritic, na.rm = TRUE),
    .groups = "drop"
  ) %>%
  filter(n_games >= 10)

write_csv(yearly_metacritic, "results/yearly_metacritic_summary.csv")


p_year <- ggplot(yearly_metacritic, aes(x = ReleaseYear, y = mean_metacritic)) +
  geom_line() +
  geom_point() +
  labs(
    title = "Average Metacritic Score by Release Year",
    x = "Release Year",
    y = "Average Metacritic Score"
  ) +
  theme_minimal()


ggsave(
  filename = "figures/average_metacritic_by_release_year.png",
  plot = p_year,
  width = 8,
  height = 5
)



# Figure 3: Metacritic score vs initial price
p_price <- ggplot(steam_eda, aes(x = PriceInitial, y = Metacritic)) +
  geom_point(alpha = 0.4) +
  geom_smooth(method = "lm", se = FALSE) +
  labs(
    title = "Metacritic Score vs Initial Price",
    x = "Initial Price",
    y = "Metacritic Score"
  ) +
  theme_minimal()

ggsave(
  filename = "figures/metacritic_vs_price.png",
  plot = p_price,
  width = 8,
  height = 5
)

# Figure 4: Metacritic score vs log recommendation count
p_recommendations <- ggplot(steam_eda, aes(x = LogRecommendationCount, y = Metacritic)) +
  geom_point(alpha = 0.4) +
  geom_smooth(method = "lm", se = FALSE) +
  labs(
    title = "Metacritic Score vs Log Recommendation Count",
    x = "Log(Recommendation Count + 1)",
    y = "Metacritic Score"
  ) +
  theme_minimal()

ggsave(
  filename = "figures/metacritic_vs_log_recommendations.png",
  plot = p_recommendations,
  width = 8,
  height = 5
)



## Figure 5: Average Metacritic score by genre

genre_summary <- steam_eda %>%
  select(Metacritic, starts_with("Genre")) %>%
  pivot_longer(
    cols = starts_with("Genre"),
    names_to = "genre",
    values_to = "is_genre" 
  ) %>%
  filter(is_genre == TRUE) %>%
  mutate(
    genre_label = str_remove(genre, "GenreIs"), ## Remove "GenreIs" prefix for cleaner labels
    genre_label = str_replace_all(genre_label, "([a-z])([A-Z])", "\\1 \\2")
  ) %>%
  group_by(genre_label) %>%
  summarise(
    avg_metacritic = mean(Metacritic, na.rm = TRUE),
    avg_metacritic_display = round(avg_metacritic, 2),
    game_count = n(),
    .groups = "drop"
  ) %>%
  filter(game_count >= 20) %>%
  arrange(desc(avg_metacritic))

write_csv(genre_summary, "results/genre_summary.csv")



p_genre <- ggplot(
  genre_summary,
  aes(x = reorder(genre_label, avg_metacritic), y = avg_metacritic)
) +
  geom_col() +
  geom_text(
    aes(label = paste0(avg_metacritic, " (n=", game_count, ")")),
    hjust = -0.05,
    size = 4
  ) +
  coord_flip() +
  expand_limits(y = max(genre_summary$avg_metacritic) + 2) +
  labs(
    title = "Average Metacritic Score by Genre",
    subtitle = "Only genres with at least 20 games are included",
    x = "Genre",
    y = "Average Metacritic Score"
  ) +
  theme_minimal()
  



ggsave(
  filename = "figures/average_metacritic_by_genre.png",
  plot = p_genre,
  width = 10,
    height = 6
)




message("EDA complete.")
message("Saved EDA summary to results/eda_summary.csv")
message("Saved figures to figures/")