# 🏀FTRvsDEFRating

During the recent Toronto Raptors vs. Houston Rockets game, the broadcast commentator highlighted an intriguing strategic element contributing to the Rockets' elite defensive performance this season. Specifically, they noted that Houston’s ability to limit opponents’ transition opportunities is partially facilitated by their opponents’ high free-throw rate (FTR). The rationale is that after a made free throw, teams are often forced to inbound the ball from a dead-ball situation, allowing the Rockets to set their half-court defense, a scenario where they excel. 

**Research Question:** Does a higher opponent free-throw rate correlate with improved defensive efficiency?


# 🏀SetUp

Utilizing the HoopR package in R, I was able to get access nba team stats (nba_leaguedashteamstats), where I obtained the team defensive rating and the team free-throw rate by using the formula
for the last 20 years. Furthermore, using linear regression analysis and ggplot2 package, I visualized the data and saw an interesting trend. 

Linear Regression:
ggplot(dat, aes(x=freethrow_rate, y = def_rating)) +
  geom_point() +
  geom_line(  # Segmented regression line
    data = quad_dat,
    aes(x = freethrow_rate, y = DR),
    color = "red",
    linewidth = 1
  ) +
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
           label = paste0("R² = ", round(r_square_quad, 3)),
           size = 5, color = "red") 
![image](https://github.com/user-attachments/assets/a66b7754-54ad-4bea-abd4-bb77140530e4)

Quadratic Regression:
![image](https://github.com/user-attachments/assets/5c77682a-f6a8-4a1f-9b8d-447f6127eb0d)


**next step is find the defensive rating when FTR < mean(FTR) vs FTR > mean(FTR)
