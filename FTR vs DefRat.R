library(hoopR)
library(dplyr)
library(lubridate)
library(zoo)
library(ggplot2)
library(segmented)
library(patchwork) 
library(cluster)
library(tidyr) 
library(car)
library(xtable)
library(stargazer)
library(broom)


game_log_def_FTR <- data.frame()

for (i in 1:20) {
  season_FTR = data.frame(nba_leaguegamelog(league_id = '00', 
                                            season = year_to_season(most_recent_nba_season() - i),
                                            season_type = "Regular Season"))
  FTR_game <- season_FTR %>%
    rename_with(~ gsub("LeagueGameLog.", "", .x)) %>% dplyr::select(SEASON_ID,
                                                                    TEAM_ID, GAME_ID, TEAM_NAME,
                                                                    FTA,FGA)
  FTR_game <- FTR_game %>%
    mutate(FTR = as.numeric(FTA)/as.numeric(FGA) *100)
  
  season_results <- data.frame()
  for (j in 1:nrow(FTR_game)) {
    tryCatch({
      season_DEF <- nba_boxscoreadvancedv2(game_id = FTR_game[j,3])
      season_DEF <- as.data.frame(season_DEF$TeamStats) %>% filter(TEAM_ID == FTR_game[j,2])
      if (nrow(season_DEF) > 0) {
        merged <- inner_join(season_DEF, 
                             FTR_game[j,], by = c("GAME_ID",'TEAM_ID'))
        merged <- merged %>% 
          dplyr::select(SEASON_ID, TEAM_ID, GAME_ID, TEAM_NAME.x,
                        FTA,FGA, FTR, DEF_RATING) %>%
          mutate(across(c(FTR, DEF_RATING), as.numeric))
        season_results <- bind_rows(season_results, merged)
      }
    }, error = function(e) {message("Game ", FTR_game$GAME_ID[j], " failed: ", e$message)}
    )
  }
  game_log_def_FTR <- bind_rows(game_log_def_FTR,  season_results)
}


game_log_def_FTR <- game_log_def_FTR_05_24

game_log_def_FTR_05_24 <- game_log_def_FTR_05_24 %>%
  mutate(FTR_Group = ifelse(FTR > mean(FTR), 'High FTr', 'Low FTr'))

means <- game_log_def_FTR_05_24 %>%
  group_by(FTR_Group) %>%
  summarise(mean_def_rating = mean(DEF_RATING, na.rm = TRUE))


ggplot(game_log_def_FTR_05_24, aes(x=FTR_Group, y = DEF_RATING, fill = FTR_Group)) +
  geom_boxplot() +
  geom_text(data = means,
            aes(x = FTR_Group, y = mean_def_rating + 3,  # offset text above mean
                label = paste0("Mean = ", round(mean_def_rating, 3))),
            color = "black", size = 4) +
  (labs(title = "Defensive Rating vs Free Throw Rate (High vs Low)",
        x = "Free Throw Rate Group",
        y = "Defensive Rating")) +
  theme_classic() +
  theme(plot.title = element_text(size = 15, hjust=0.5))

game_log_reg <- lm(DEF_RATING ~ FTR ,data = game_log_def_FTR_05_24)
summary(game_log_reg)


dat = data.frame(Team_ID = 0, Team = "",  #dummy data frame
                 season_id = "", freethrow_rate = 0, def_rating = 0,
                 W_PCT = 0, NET_RATING = 0 )
for (i in 1:20) {
  season = data.frame(nba_leaguedashteamstats(league_id = '00', season = year_to_season(most_recent_nba_season()-i),
                                              season_type = "Regular Season"))
  season$season_id = year_to_season(most_recent_nba_season()-i)
  def_rating = data.frame(nba_leaguedashteamstats(league_id = '00', season = year_to_season(most_recent_nba_season()-i),
                                                  season_type = "Regular Season", 
                                                  measure_type = "Advanced",
                                                  per_mode = "PerGame"))
  def_rating$season_id = year_to_season(most_recent_nba_season()-i)
  season_def <- merge(season, def_rating, by = c("LeagueDashTeamStats.TEAM_ID", "season_id"), all = TRUE)
  season_def$W_PCT <- as.numeric(season_def$LeagueDashTeamStats.W_PCT.x)
  season_def$NET_RATING <- as.numeric(season_def$LeagueDashTeamStats.NET_RATING)
  season_def$freethrow_rate = as.numeric(season_def$LeagueDashTeamStats.FTA)/as.numeric(season_def$LeagueDashTeamStats.FGA) *100
  season_def$Team_ID <- as.numeric(season_def$LeagueDashTeamStats.TEAM_ID)
  season_def$Team <- season_def$LeagueDashTeamStats.TEAM_NAME.x
  season_def$def_rating <- as.numeric(season_def$LeagueDashTeamStats.DEF_RATING)
  dat = union(dat, dplyr::select(season_def, 'Team_ID', 'Team',
                          'season_id', 'freethrow_rate', 'def_rating',
                          'W_PCT','NET_RATING'))
}

dat <- dat[-c(1),] 

summary(lm(NET_RATING ~ freethrow_rate, data = dat))
cor(dat$freethrow_rate,dat$W_PCT)
plot(dat$freethrow_rate,dat$NET_RAT)


#Regression model with NET_Rating
regression_net_ftr <- lm(def_rating ~ freethrow_rate + NET_RATING,
                         data = dat)
summary(regression_net_ftr)

stargazer(regression_net_ftr, type = "text")

r_sq <- 0.3537
newdat <- data.frame(ftr = dat$freethrow_rate, net = dat$NET_RATING)
newdat$pred <- predict(regression_net_ftr, data = newdat)

ggplot(dat, aes(x=freethrow_rate, y = def_rating)) +
  geom_point() +
 geom_line(data = newdat, aes(ftr, y = pred), linewidth = 1, color = 'red') +
  labs(title ="Team Free Throw Rate and Net Rating vs Team Defensive Rating ",
       subtitle = "Since 2005-2006 Season",
       x = "Free Throw Rate",
       y = "Defensive Rating") +
  theme_classic() +
  theme(plot.title = element_text(size = 15, hjust = 0.5), 
        plot.subtitle = element_text(size = 10, hjust = 0.5), 
        axis.title = element_text(size = 10),
        axis.text = element_text(size = 7)) +
  annotate("text", 
           x = max(dat$freethrow_rate)-1, 
           y = max(dat$def_rating),
           label = paste0("R² = ", round(r_sq, 3)),
           size = 5, color = "red") 

##Stratify by Team Quality
dat$QualityTier <- cut(dat$NET_RATING,
                       breaks = quantile(dat$NET_RATING, probs = c(0, 0.33, 0.66, 1)),
                       labels = c("Weak", "Average", "Strong"))

weak_net_rating <- dat %>% filter(QualityTier == 'Weak')
average_net_rating <- dat %>% filter(QualityTier == 'Average')
strong_net_rating <- dat %>% filter(QualityTier == 'Strong')

regression_weak <- lm(def_rating ~ freethrow_rate , dat = weak_net_rating)
regression_avg <- lm(def_rating ~ freethrow_rate, dat = average_net_rating)
regression_str <- lm(def_rating ~ freethrow_rate, dat = strong_net_rating)
summary(regression_weak)
summary(regression_avg)
summary(regression_str)

dat <- dat %>% filter(!is.na(QualityTier))

r2_by_tier <- dat %>%
  group_by(QualityTier) %>%
  do({
    model = lm(def_rating ~ freethrow_rate, data = .)
    data.frame(R2 = summary(model)$r.squared)
  })
r2_by_tier <- r2_by_tier %>%
  mutate(
    label = paste0("R² = ", round(R2, 3))
  )

ggplot(dat, aes(x = freethrow_rate, y = def_rating, color = QualityTier)) +
  geom_point(alpha = 0.3) +
  geom_smooth(method = "lm", se = FALSE) +
  facet_wrap(~QualityTier) +
  geom_text(data = r2_by_tier, aes(x = 38, y = 118, label = label), 
            inherit.aes = FALSE, color = "red", size = 5) +
  labs(title = "FTr vs Defensive Rating by Team Quality Tier",
       x = "Free Throw Rate", y = "Defensive Rating") +
  theme_minimal() +
  theme(plot.title = element_text(size = 15, hjust = 0.5))




#Regression model without Net Rating
regression_model <- lm(def_rating ~ freethrow_rate, data = dat)
summary(regression_model)
r_square <- summary(regression_model)$r.squared
cor.test(dat$def_rating, dat$freethrow_rate)

ggplot(dat, aes(x=freethrow_rate, y = def_rating)) +
  geom_point() +
  geom_smooth(method = lm, color = 'red', se = FALSE) +
  labs(title ="Team Free Throw Rate vs Team Defensive Rating ",
       subtitle = "Since 2005-2006 Season",
       x = "Free Throw Rate",
       y = "Defensive Rating") +
  theme_classic() +
  theme(plot.title = element_text(size = 15, hjust = 0.5), 
        plot.subtitle = element_text(size = 10, hjust = 0.5), 
        axis.title = element_text(size = 10),
        axis.text = element_text(size = 7)) +
  annotate("text", 
           x = max(dat$freethrow_rate)-1, 
           y = max(dat$def_rating),
           label = paste0("R² = ", round(r_square, 3)),
           size = 5, color = "red") 

# Quadratic model
quadratic_model <- lm(def_rating ~ freethrow_rate + I(freethrow_rate^2), data = dat)
summary(quadratic_model)
quad_dat <- data.frame(freethrow_rate = seq(min(dat$freethrow_rate), max(dat$freethrow_rate),
                                 length.out = 30))
r_square_quad <- 0.1352
quad_dat$DR <- predict(quadratic_model, newdata = quad_dat)


ggplot(dat, aes(x=freethrow_rate, y = def_rating)) +
  geom_point() +
  geom_line(  # Segmented regression line
    data = quad_dat,
    aes(x = freethrow_rate, y = DR),
    color = "red",
    linewidth = 1
  ) +
  labs(title ="Team Free Throw Rate vs Team Defensive Rating (Quadratic)",
       subtitle = "Since 2005-2006 Season",
       x = "Free Throw Rate",
       y = "Defensive Rating") +
  theme_classic() +
  theme(plot.title = element_text(size = 15, hjust = 0.5), 
        plot.subtitle = element_text(size = 10, hjust = 0.5), 
        axis.title = element_text(size = 10),
        axis.text = element_text(size = 7)) +
  annotate("text", 
           x = max(dat$freethrow_rate)-1, 
           y = max(dat$def_rating),
           label = paste0("R² = ", round(r_square_quad, 3)),
           size = 5, color = "red") 

