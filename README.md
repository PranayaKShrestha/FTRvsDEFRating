# 🏀FTRvsDEFRating

During the recent Toronto Raptors vs. Houston Rockets game, the broadcast commentator highlighted an intriguing strategic element contributing to the Rockets' elite defensive performance this season. Specifically, they noted that Houston’s ability to limit opponents’ transition opportunities is partially facilitated by their opponents’ high free-throw rate (FTR). The rationale is that after a made free throw, teams are often forced to inbound the ball from a dead-ball situation, allowing the Rockets to set their half-court defense, a scenario where they excel. 

**Research Question:** Does a higher opponent free-throw rate correlate with improved defensive efficiency?


# 🏀SetUp

Utilizing the HoopR package in R, I was able to access NBA team stats (nba_leaguedashteamstats), game log stats (nba_leaguegamelog), and advanced boxscore game log stats (nba_boxscoreadvancedv2) from the last 20 years, from which I obtained the statistics needed to conduct this analysis. Initially, I scraped the defensive rating and free-throw rates of each game for the last 20 years; however, single-game statistics have extremely high variability, as one game’s outcome is noisy. Moving on, I used the team's season defensive rating and free-throw rate to minimize the variability. 

# 🏀Analysis

Starting with the game log analysis, 

![image](https://github.com/user-attachments/assets/c44cf5fa-06ba-4e45-8e40-e0c25b71b53d)

The mean FTr was used as a benchmark to group the game FTr as high FTr or low Ftr. The distributions for both groups are nearly identical, with the mean Defensive Rating being 108.02 for high FTr games and 108.23 for low FTr games—a negligible difference of just 0.21 points. Both groups show similar spreads, medians, and ranges, with considerable overlap and the presence of outliers. This suggests that, at the game level, a team’s ability to draw free throws does not meaningfully distinguish its defensive performance. While statistically significant in large-sample regressions, the practical impact of FTr on Defensive Rating in individual games appears minimal. 

![image](https://github.com/user-attachments/assets/6fd6e417-2fc5-4d73-a0b1-df55f7a2a5de)


As we can see from the regression summary, the large sample of games (47k+ games) causes high variability and noise which results in a low R2 value. 


Due to the issues with game-log statistics and their randomness, I decided to examine each team's season statistics. 

Initially, I questioned whether teams with high free-throw rates were simply strong overall teams, and whether their lower defensive ratings were more a reflection of general team quality rather than a meaningful relationship with free-throw rate — suggesting that free-throw rate may be a confounding factor rather than a true driver of defensive performance. However, a simple regression output where Net Rating is the response variable and free throw rate is the explanatory variable shows there is not any relationship (the low R² indicates that it is not a strong determinant of overall team performance). 

![image](https://github.com/user-attachments/assets/f842951b-c578-4491-95ca-ad3d17162071)


Furthermore, I investigated the relationship between Defensive Rating and Free Throw Rate (FTr), and Net Rating as predictor variables. The results showed that while both variables were statistically significant, Free Throw Rate remained a meaningful predictor of Defensive Rating even after controlling for overall team quality via Net Rating.

![image](https://github.com/user-attachments/assets/4c258683-9c71-46e2-acce-49fc6beee562)

![image](https://github.com/user-attachments/assets/c46f7300-c160-4128-8295-52e67e161798)


To better understand how the relationship between Free Throw Rate (FTr) and Defensive Rating varies by team quality, I stratified the dataset into three tiers—Weak, Average, and Strong—based on each team’s season-level Net Rating. Using quantile-based thresholds, teams in the bottom third were labeled as Weak, the middle third as Average, and the top third as Strong. I then ran separate multiple linear regression models within each tier, using both FTr and Net Rating as predictors of Defensive Rating. The results showed that FTr was a statistically significant predictor across all three tiers, suggesting that even among weaker or stronger teams, drawing more fouls is modestly associated with better defensive performance. Interestingly, the strength of the relationship between Net Rating and Defensive Rating varied by tier, being more impactful for Strong and Weak teams but less so for Average teams (p-value = 0.27).









