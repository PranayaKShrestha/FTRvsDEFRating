library(hoopR)
library(dplyr)
library(ggplot2)

dat = data.frame(Team_ID = 0, Team = "",  #dummy data frame
                 season_id = "", freethrow_rate = 0, def_rating = 0)
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
  season_def$freethrow_rate = as.numeric(season_def$LeagueDashTeamStats.FTA)/as.numeric(season_def$LeagueDashTeamStats.FGA) *100
  season_def$Team_ID <- as.numeric(season_def$LeagueDashTeamStats.TEAM_ID)
  season_def$Team <- season_def$LeagueDashTeamStats.TEAM_NAME.x
  season_def$def_rating <- as.numeric(season_def$LeagueDashTeamStats.DEF_RATING)
  dat = union(dat, dplyr::select(season_def, 'Team_ID', 'Team',
                          'season_id', 'freethrow_rate', 'def_rating'))
}

dat <- dat[-c(1),] 

regression_model <- lm(def_rating ~ freethrow_rate, data = dat)
r_square <- summary(regression_model)$r.squared
cor.test(dat$def_rating, dat$freethrow_rate)

ggplot(dat, aes(x=freethrow_rate, y = def_rating)) +
  geom_point() +
  geom_smooth(method = , color = 'red', se = FALSE) +
  labs(title ="Team Free Throw Rate vs Team Defensive Rating ",
       subtitle = "Since 2012-2013 Season",
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
  labs(title ="Team Free Throw Rate vs Team Defensive Rating ",
       subtitle = "Since 2012-2013 Season",
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
