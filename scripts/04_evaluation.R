# scripts/04_evaluation.R
# Purpose: Compare model performance and save final evaluation outputs.

library(tidyverse)

dir.create("figures", recursive = TRUE, showWarnings = FALSE)
dir.create("results", recursive = TRUE, showWarnings = FALSE)

# Load model performance metrics
model_metrics <- read_csv("results/model_metrics.csv", show_col_types = FALSE)

# Clean model labels for reporting
model_metrics_clean <- model_metrics %>%
  mutate(
    model_label = case_when(
      model == "full_linear_regression" ~ "Full Linear Regression",
      model == "forward_selected_reduced_regression" ~ "Forward-Selected Reduced Regression",
      model == "lasso_regression" ~ "LASSO Regression",
      TRUE ~ model
    )
  ) %>%
  arrange(rmse)

# Save final model comparison table
write_csv(
  model_metrics_clean,
  "results/final_model_comparison.csv"
)

# Identify best-performing model
best_model <- model_metrics_clean %>%
  slice_min(rmse, n = 1)

write_csv(
  best_model,
  "results/best_model_summary.csv"
)

# Plot RMSE comparison
p_model_rmse <- ggplot(
  model_metrics_clean,
  aes(x = reorder(model_label, rmse), y = rmse)
) +
  geom_col() +
  geom_text(
    aes(label = round(rmse, 3)),
    hjust = -0.1,
    size = 4
  ) +
  coord_flip() +
  expand_limits(y = max(model_metrics_clean$rmse) + 0.5) +
  labs(
    title = "Model Performance Comparison",
    subtitle = "Lower RMSE indicates better predictive performance on the test set",
    x = "Model",
    y = "Test RMSE"
  ) +
  theme_minimal()

ggsave(
  filename = "figures/model_rmse_comparison.png",
  plot = p_model_rmse,
  width = 8,
  height = 5
)

message("Evaluation complete.")
message("Best model: ", best_model$model_label)
message("Best RMSE: ", round(best_model$rmse, 3))
message("Saved final model comparison to results/final_model_comparison.csv")
message("Saved RMSE comparison figure to figures/model_rmse_comparison.png")