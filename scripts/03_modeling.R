# scripts/03_modeling.R
# Purpose: Build a linear regression model to predict Metacritic scores based on game features.

library(tidyverse) 
library(broom)
library(caret)
library(leaps)
library(glmnet)
dir.create("results", recursive = TRUE, showWarnings = FALSE)



# Load cleaned data
steam_clean <- read_csv("data/processed/steam_games_clean.csv", show_col_types = FALSE)



# Build a linear regression model to predict Metacritic score based on key features:
model_data <- steam_clean %>%
  select(
    Metacritic,
    PriceInitial,
    RecommendationCount,
    ReleaseYear,
    IsFree,
    GenreIsIndie,
    GenreIsAction,
    GenreIsAdventure,
    GenreIsCasual,
    GenreIsStrategy,
    GenreIsRPG,
    GenreIsSimulation,
    GenreIsEarlyAccess,
    GenreIsFreeToPlay,
    GenreIsSports,
    GenreIsRacing,
    GenreIsMassivelyMultiplayer
  ) %>%
  drop_na()


set.seed(301)

train_index <- createDataPartition(
  model_data$Metacritic,
  p = 0.8,
  list = FALSE
)


train_data <- model_data[train_index, ]
test_data <- model_data[-train_index, ]


# Helper function: calculate RMSE
rmse <- function(actual, predicted) {
  sqrt(mean((actual - predicted)^2, na.rm = TRUE))

}

# Helper function: predict from regsubsets model
predict_regsubsets <- function(object, newdata, id) {
  formula <- as.formula(object$call[[2]])
  model_matrix <- model.matrix(formula, newdata)
  coefficients <- coef(object, id = id)
  variables <- names(coefficients)
  model_matrix[, variables] %*% coefficients
}


## 1. Build a linear regression model using FULL features

full_lm <- lm(
  Metacritic ~ 
    PriceInitial +
    log1p(RecommendationCount) +
    ReleaseYear +
    IsFree +
    GenreIsIndie +
    GenreIsAction +
    GenreIsAdventure +
    GenreIsCasual +
    GenreIsStrategy +
    GenreIsRPG +
    GenreIsSimulation +
    GenreIsEarlyAccess +
    GenreIsFreeToPlay +
    GenreIsSports +
    GenreIsRacing +
    GenreIsMassivelyMultiplayer,
  data = train_data
)


## Evaluate model performance on test set using RMSE

full_pred <- predict(full_lm, newdata = test_data)
full_rmse <- rmse(test_data$Metacritic, full_pred)


## save model summary and RMSE to results folder
full_model_summary <- tidy(full_lm) %>%
  select(term, estimate, std.error, statistic, p.value)

write_csv(full_model_summary, "results/full_model_summary.csv")


model_performance <- tibble(
    model = "full_linear_regression",
    rmse = full_rmse
)

write_csv(model_performance, "results/model_performance.csv")



## 2. Forward selection for feature selection

forward_model <- regsubsets(
  Metacritic ~ 
    PriceInitial +
    log1p(RecommendationCount) +
    ReleaseYear +
    IsFree +
    GenreIsIndie +
    GenreIsAction +
    GenreIsAdventure +
    GenreIsCasual +
    GenreIsStrategy +
    GenreIsRPG +
    GenreIsSimulation +
    GenreIsEarlyAccess +
    GenreIsFreeToPlay +
    GenreIsSports +
    GenreIsRacing +
    GenreIsMassivelyMultiplayer,
  data = train_data,
  nvmax = 16,
  method = "forward"
)

fwd_model_summary <- summary(forward_model)

best_model_size <- which.min(fwd_model_summary$bic)

forward_pred <- predict_regsubsets(
  object = forward_model,
  newdata = test_data,
  id = best_model_size
)

forward_rmse <- rmse(
  actual = test_data$Metacritic,
  predicted = as.numeric(forward_pred)
)

forward_model_performance <- tibble(
  model = "forward_selected_reduced_regression",
  rmse = forward_rmse
)

forward_selection_summary <- tibble(
  selected_model_size = best_model_size,
  bic = fwd_model_summary$bic[best_model_size]
)

write_csv(forward_selection_summary, "results/forward_selection_summary.csv")
write_csv(forward_model_performance, "results/forward_selection_model_performance.csv")




## 3. LASSO regression for feature selection

## Train Lasso Regression
x_train <- model.matrix(
  Metacritic ~ 
    PriceInitial +
    log1p(RecommendationCount) +
    ReleaseYear +
    IsFree +
    GenreIsIndie +
    GenreIsAction +
    GenreIsAdventure +
    GenreIsCasual +
    GenreIsStrategy +
    GenreIsRPG +
    GenreIsSimulation +
    GenreIsEarlyAccess +
    GenreIsFreeToPlay +
    GenreIsSports +
    GenreIsRacing +
    GenreIsMassivelyMultiplayer,
  data = train_data
)[, -1]

y_train <- train_data$Metacritic

## Test Lasso Regression
x_test <- model.matrix(
  Metacritic ~ 
    PriceInitial +
    log1p(RecommendationCount) +
    ReleaseYear +
    IsFree +
    GenreIsIndie +
    GenreIsAction +
    GenreIsAdventure +
    GenreIsCasual +
    GenreIsStrategy +
    GenreIsRPG +
    GenreIsSimulation +
    GenreIsEarlyAccess +
    GenreIsFreeToPlay +
    GenreIsSports +
    GenreIsRacing +
    GenreIsMassivelyMultiplayer,
  data = test_data
)[, -1]

set.seed(123)

## Use cross-validation to find optimal lambda for Lasso
lasso_cv <- cv.glmnet(
  x = x_train,
  y = y_train,
  alpha = 1
)

## Evaluate Lasso model performance on test set
lasso_pred <- predict(lasso_cv, newx = x_test, s = "lambda.min")
lasso_rmse <- rmse(test_data$Metacritic, as.numeric(lasso_pred))

## Save Lasso model performance
## Extract non-zero coefficients from Lasso model for interpretation
lasso_model_summary <- coef(lasso_cv, s = "lambda.min") %>%
  as.matrix() %>%
  as.data.frame() %>%
  rownames_to_column("term") %>%
  rename(estimate = 2) %>%
  filter(estimate != 0)


lasso_model_performance <- tibble(
    model = "lasso_regression",
    rmse = lasso_rmse
)   

write_csv(lasso_model_performance, "results/lasso_model_performance.csv")
write_csv(lasso_model_summary, "results/lasso_model_summary.csv")


## Compare model performance across all models

model_metrics <- tibble(
  model = c(
    "full_linear_regression",
    "forward_selected_reduced_regression",
    "lasso_regression"
  ),
  rmse = c(
    full_rmse,
    forward_rmse,
    lasso_rmse
  )
) %>%
  arrange(rmse)


write_csv(model_metrics, "results/model_metrics.csv")


message("Modeling complete.")
