# 🏀FTRvsDEFRating

During the recent Toronto Raptors vs. Houston Rockets game, the broadcast commentator highlighted an intriguing strategic element contributing to the Rockets' elite defensive performance this season. Specifically, they noted that Houston’s ability to limit opponents’ transition opportunities is partially facilitated by their opponents’ high free-throw rate (FTR). The rationale is that after a made free throw, teams are often forced to inbound the ball from a dead-ball situation, allowing the Rockets to set their half-court defense, a scenario where they excel. 

**Research Question:** Does a higher opponent free-throw rate correlate with improved defensive efficiency?


# 🏀SetUp

Utilizing the HoopR package in R, I was able to access NBA team stats (nba_leaguedashteamstats), game log stats (nba_leaguegamelog), and advanced boxscore game log stats (nba_boxscoreadvancedv2) from the last 20 years, from which I obtained the statistics needed to conduct this analysis. Initially, I scraped the defensive rating and free-throw rates of each game for the last 20 years; however, single-game statistics have extremely high variability, as one game’s outcome is noisy. Moving on, I used the team's season defensive rating and free-throw rate to minimize the variability. 

# 🏀Analysis

Starting with the game log analysis, 

![image](https://github.com/user-attachments/assets/c44cf5fa-06ba-4e45-8e40-e0c25b71b53d)

The mean FTr was used as a benchmark to group the game FTr as high FTr or low Ftr. The distributions for both groups are nearly identical, with the mean Defensive Rating being 108.02 for high FTr games and 108.23 for low FTr games—a negligible difference of just 0.21 points. Both groups show similar spreads, medians, and ranges, with considerable overlap and the presence of outliers. This suggests that, at the game level, a team’s ability to draw free throws does not meaningfully distinguish its defensive performance. While statistically significant in large-sample regressions, the practical impact of FTr on Defensive Rating in individual games appears minimal. 

===============================================
                        Dependent variable:    
                    ---------------------------
                            DEF_RATING         
-----------------------------------------------
FTR                          -0.015***         
                              (0.005)          
                                               
Constant                    108.564***         
                              (0.158)          
                                               
-----------------------------------------------
Observations                  47,120           
R2                            0.0002           
Adjusted R2                   0.0002           
Residual Std. Error     11.700 (df = 47118)    
F Statistic          8.379*** (df = 1; 47118)  
===============================================
Note:               *p<0.1; **p<0.05; ***p<0.01

As we can see from the regression summary, the large sample of games (47k+ games) causes high variability and noise which results in a low R2 value. 


Due to the issues of game-log statisitcs and its randomness, I decided to look at each teams season's statistics. 


===============================================
                        Dependent variable:    
                    ---------------------------
                            def_rating         
-----------------------------------------------
freethrow_rate               -0.370***         
                              (0.038)          
                                               
NET_RATING                   -0.432***         
                              (0.030)          
                                               
Constant                    118.337***         
                              (1.068)          
                                               
-----------------------------------------------
Observations                    600            
R2                             0.354           
Adjusted R2                    0.352           
Residual Std. Error      3.537 (df = 597)      
F Statistic          163.393*** (df = 2; 597)  
===============================================
Note:               *p<0.1; **p<0.05; ***p<0.01


![image](https://github.com/user-attachments/assets/c46f7300-c160-4128-8295-52e67e161798)






