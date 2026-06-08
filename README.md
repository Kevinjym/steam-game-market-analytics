# Steam Game Market Analytics

A product analytics case study in R exploring how Steam game metadata relates to Metacritic scores and critical reception.

## Project Overview

Steam is one of the largest digital distribution platforms for PC games. With thousands of games available, players, publishers, and platform stakeholders often rely on review signals such as Metacritic scores to evaluate game quality and market reception.

This project analyzes Steam game metadata to understand which product features are associated with stronger critical reception and whether structured platform data can provide an early signal of Metacritic performance.

The original version of this project was completed as a university statistical modeling project. This repository rebuilds it into an industry-facing analytics case study with clearer business framing, reproducible code, and actionable interpretation.

## Business Context

For game publishers, developers, and platform analysts, understanding the factors associated with stronger critical reception can support product positioning, pricing strategy, market research, and launch planning.

This project focuses on a practical analytics question:

> How much can structured Steam metadata tell us about a game's critical reception?

Rather than treating the model as a perfect prediction engine, this analysis evaluates both the usefulness and the limitations of metadata-based prediction.

## Key Questions

- Which Steam game attributes are associated with higher Metacritic scores?
- How do price, release timing, recommendation count, and genre categories relate to critical reception?
- Can structured game metadata predict Metacritic scores with reasonable accuracy?
- What are the limitations of using platform metadata to estimate review performance?

## Dataset

The dataset contains Steam game metadata collected through the Steam API and published on Kaggle.

Key variables include:

- `Metacritic`: critic score from 0 to 100
- `ReleaseDate`: game release date
- `RecommendationCount`: number of Steam recommendations
- `PriceInitial`: initial game price
- `IsFree`: whether the game is free
- Genre/category indicators such as `GenreIsAction`, `GenreIsIndie`, `GenreIsAdventure`, `GenreIsStrategy`, and others

## Methods

This project uses R for data cleaning, exploratory data analysis, and predictive modeling.

Planned workflow:

1. Load and clean Steam game metadata
2. Remove invalid or missing Metacritic scores
3. Transform release date into usable time-based features
4. Explore relationships between game attributes and Metacritic scores
5. Build and evaluate regression models
6. Translate model results into business insights and limitations

## Initial Modeling Approach

The original analysis compared multiple regression-based approaches:

- Full multiple linear regression
- Forward-selected reduced linear regression
- LASSO regression

Model performance was evaluated using RMSE on a test set. The original models produced RMSE values around 10.5–11 points on the 0–100 Metacritic scale.

This suggests that structured metadata can provide a rough directional signal, but it is not sufficient for highly precise prediction. Important drivers of review scores may include factors not captured in the dataset, such as gameplay quality, studio reputation, marketing, technical performance, critic expectations, and launch timing.

## Repository Structure

```text
steam-game-market-analytics/
├── data/
│   ├── raw/
│   └── processed/
├── figures/
├── notebooks/
├── reports/
├── results/
├── scripts/
│   ├── 01_load_clean_data.R
│   ├── 02_eda.R
│   ├── 03_modeling.R
│   └── 04_evaluation.R
└── README.md
```

## Tools

* R
* tidyverse
* ggplot2
* broom
* glmnet
* leaps
* caret or rsample


## Responsible Interpretation

This project should not be interpreted as a tool that can fully determine whether a game will be critically successful. Metacritic scores are influenced by many qualitative factors that are difficult to capture in structured metadata.

The model is best understood as a market research and decision-support tool, not as a replacement for game quality assessment, user research, or expert review.

## Next Steps

* Rebuild the original analysis into modular R scripts
* Add stronger exploratory visualizations
* Add clearer business recommendations
* Compare baseline and regularized regression models
* Improve documentation and reproducibility


## Project Background and Attribution

This project was originally completed as a group coursework project during my undergraduate studies at UBC. The original analysis focused on predicting Steam games' Metacritic scores using statistical modeling techniques.

This repository is a personal reconstruction and extension of the original project. I rebuilt the project into an industry-facing analytics case study by restructuring the repository, rewriting the business context, improving documentation, expanding the analysis workflow, and reframing the results for product and market analytics use cases.

Credit is given to the original course project team for the initial project foundation.