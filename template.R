library(dplyr)
library(MatchIt)
library(janitor)

# MODIFY ONLY THESE LINES
player_name <- "Anthony Davis"
new_team    <- "Lakers"
old_team    <- "Pelicans"
season_year <- 2020

# 1. Load player games
ad_all <- box %>%
  filter(
    athlete_display_name == player_name,
    team_name == new_team,
    season == season_year
  ) %>%
  arrange(game_date) %>%
  filter(minutes > 0)

# 2. Revenge games
ad_revenge_games <- ad_all %>%
  filter(opponent_team_name == old_team) %>%
  arrange(game_date)

ad_all <- ad_all %>%
  mutate(is_revenge = ifelse(game_id %in% ad_revenge_games$game_id, 1, 0))

# 3. Opponent strength
team_games <- load_nba_team_box(seasons = season_year) %>% clean_names()

opp_records <- team_games %>%
  group_by(team_name, season) %>%
  summarise(opp_win_pct = mean(team_winner == FALSE), .groups = "drop")

ad_all <- ad_all %>%
  left_join(
    opp_records,
    by = c("opponent_team_name" = "team_name",
           "season" = "season")
  )

# 4. Prepare for matchit
match_df <- ad_all %>%
  select(
    is_revenge, minutes, field_goals_attempted, home_away, opp_win_pct,
    points, rebounds, assists, game_id, game_date
  ) %>%
  drop_na()

# 5. Run matching
m <- matchit(
  is_revenge ~ minutes + field_goals_attempted + home_away + opp_win_pct,
  data = match_df,
  method = "nearest",
  ratio = 1
)

matched_data <- match.data(m)

comparison_revenge <- matched_data %>% filter(is_revenge == 1)
comparison_games   <- matched_data %>% filter(is_revenge == 0)

# 6. Compute differences (THIS is the key output)
rev_df  <- comparison_revenge %>% arrange(game_date)
base_df <- comparison_games   %>% arrange(game_date)

n <- min(nrow(rev_df), nrow(base_df))
rev_df  <- rev_df[1:n, ]
base_df <- base_df[1:n, ]

diff_df <- data.frame(
  player = player_name,
  season = season_year,
  game_date = rev_df$game_date,
  points_diff   = rev_df$points   - base_df$points,
  rebounds_diff = rev_df$rebounds - base_df$rebounds,
  assists_diff  = rev_df$assists  - base_df$assists
)

# 7. Save their results
write.csv(diff_df, paste0(player_name, "_diff.csv"), row.names = FALSE)

diff_df  # prints in their PDF
