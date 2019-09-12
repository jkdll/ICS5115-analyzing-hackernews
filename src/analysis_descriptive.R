"
  analysis_descriptive.R
    Author:
      Jake J. Dalli (jake.dalli.10@um.edu.mt)
    Description:
      In this script we perform a descriptive analysis of the source dataset. We look at:
        - [SECTION 1] The relationship between Points and Comments
        - [SECTION 1] Investigate the standing on top sources and top stories in relation to each other.
        - [SECTION 2] The relationship between top stories and the day and time they are posted to hacker news
        - [SECTION 3] Find the top terms in the dataset
      Visualisations are saved to the viz directory
"
library(gridExtra)
library(grid)
library(dplyr)
library(psych)
library(ggplot2)
library(ggthemes)
library(gridExtra)
library(grid)
library(zoo)
library(plyr)
library(lubridate)
library(ggpubr)
library(corrplot)
library(GGally)
library(ggwordcloud)
library(tm)
library(wordcloud)

# Load The Data
df <- read.csv(file="./data-clean/hackernews_board.csv", header=TRUE, sep=",")
# Create A meta column which marks the stories ranked 1-5
df$is_top <- lapply(df$rank,function (x) { as.character(ifelse(as.numeric(x) <= 5, as.character(x), 'Other') ) })



#####################################################################
# SECTION 1
# Investigate the relationship between Points and Comments
# Investigate top stories and top sources
#####################################################################

# Visualize the Stories by Points and Comments within Density Buckets                     
viz_bin <- ggplot(df, aes(x=comments, y=points), conf.int = TRUE) +
  geom_bin2d(bins=100) +
  geom_smooth(method=lm, se=FALSE, color='#F20505', linetype="dashed") +
  theme_economist(base_family="sans") + 
  theme(legend.position=c(0,1), legend.justification=c(0,1)) +
  labs(title="Stories by Comments and Points", x="Comments", y="Points", fill = "Count") +
  stat_cor( method = "pearson", label.x=1200, label.y = 3200, color='#F20505' )
ggsave('./viz/descriptive_01_sources_bin.png', plot = viz_bin, dpi = 300, scale = 1)


# Visualize the Stories by Points and Comments - Indicating which are the top ranked posts by colour
viz_rank <- ggplot(df, aes(x=comments, y=points, color=as.character(is_top) ) , conf.int = TRUE) +
  geom_smooth(method=lm, se=TRUE, linetype="dashed", fullrange = TRUE) +
  geom_point(data=df, size=3, shape=20) +
  theme_economist(base_family="sans") + 
  theme(legend.position=c(0,1), legend.justification=c(0,1)) +
  labs(title="Stories by Comments and Points - Top Ranked Stories", x="Comments", y="Points", color="Rank") +
  stat_cor( aes(color = as.character(is_top) ), method = "pearson", label.x=1200)
ggsave('./viz/descriptive_02_sources_rank.png', plot = viz_rank, dpi = 300, scale = 1)

# Create a Density Graph for Comments and points
density_comments <- ggplot(df, aes(comments)) + 
  geom_density(alpha=.5, color="#A62D37", size=1) + 
  scale_colour_economist() + 
  theme(legend.position = "none") +
  theme_economist(base_family="sans") +
  labs(title="Comments Density", x="Comments", y="Density", fill="Rank")

density_points <- ggplot(df, aes(points)) + 
  geom_density(alpha=.5, color="#A62D37", size=1) + 
  scale_colour_economist() +
  theme(legend.position = "none") +
  theme_economist(base_family="sans") +
  labs(title="Points Density", x="Points", y="Density") 

# Place Both plots in one
viz_density <- grid.arrange(density_points, density_comments, ncol=2)
ggsave('./viz/descriptive_03_var_density.png', plot = viz_density, dpi = 300, scale = 1)

# Calculate Top Sources by Total Points
sources_by_points_sum <- setNames( aggregate(list(points=df$points,comments=df$comments), by=list(Category=df$source_domain), FUN=sum)
                               , c("Source", "Points", "Comments") )  

viz_source_scatter_sum <- ggplot(sources_by_points_sum, aes(x=Comments, y=Points)) +
  geom_text(data=subset(sources_by_points_sum, sources_by_points_sum$Points > 20000)
            , aes(x=Comments, y=Points, label=Source)
            , nudge_x = -1000
            , nudge_y = -2000 
            , size=4
            , check_overlap = TRUE
            , color="#A62D37") +
  geom_point(size=2, shape=20, color="#A62D37" ) +
  theme_economist(base_family="sans") +
  geom_smooth(method=lm, se=FALSE, linetype="dashed") +
  labs(title="Top Sources by Total Points (Sum)", x="Comments", y="Points")  +
  stat_cor( aes(color = as.character(is_top) ), method = "pearson", label.x=1200, color="blue")

ggsave('./viz/descriptive_04_source_sum.png', plot = viz_source_scatter_sum, dpi = 300, scale = 1)

# Calculate Top Sources by Median Points
sources_by_points_med <- setNames( aggregate(list(points=df$points,comments=df$comments), by=list(Category=df$source_domain), FUN=median)
                                   , c("Source", "Points", "Comments") )  

viz_source_scatter_med <- ggplot(sources_by_points_med, aes(x=Comments, y=Points)) +
  geom_text(data=subset(sources_by_points_med, sources_by_points_med$Points > 1300 |  sources_by_points_med$Comments > 700 )
            , aes(x=Comments, y=Points, label=Source)
            , size=3
            , nudge_x = 80
            , nudge_y = 100
            , check_overlap = TRUE
            , color="#A62D37") +
  geom_point(size=2, shape=20, color="#A62D37" ) +
  theme_economist(base_family="sans") +
  geom_smooth(method=lm, se=FALSE, linetype="dashed") +
  labs(title="Top Sources By Average (Median) Points", x="Comments", y="Points")  +
  stat_cor( aes(color = as.character(is_top) ), method = "pearson", label.x=1200, color="blue")
ggsave('./viz/descriptive_05_source_med.png', plot = viz_source_scatter_med, dpi = 300, scale = 1)

#####################################################################
# SECTION 2
# Investigate the relationship between published date and top stories
# Investigate the relationship between published hour and top stories
#####################################################################

# Calculate Date Meta-data (day/month/year) etc.
df$day <- factor(strftime(df$published_date,format="%a"),levels=rev(c("Mon","Tue","Wed","Thu","Fri","Sat","Sun")))
#df$monthweek <- as.numeric(ceiling(as.numeric(strftime(df$published_date, format="%e"))/7))
df$monthweek <- ifelse( ceiling(mday(df$published_date)/7)==5, 4, ceiling(mday(df$published_date)/7) )
df$month <- factor(strftime(df$published_date,format="%B"),levels=c("November","December","January","Febuary","March", "April", "May", "June"))

months_by_points <- setNames( aggregate(list(points=df$points,comments=df$comments), by=list(df$month, df$monthweek, df$day), FUN=median)
                                   , c("Month", "MonthWeek", "Day", "Points", "Comments"))  
months_by_points <- subset(months_by_points, Month != 'November' & Month != 'June')

viz_dayofweek <- ggplot(months_by_points, aes(months_by_points$MonthWeek,months_by_points$Day, fill = months_by_points$Points)) +
  geom_tile(colour = "blue") +
  geom_text(aes(label=ceiling(as.numeric(months_by_points$Points))), color="white", size=3, fontface="bold")+
  facet_grid(months_by_points$Month) +
  scale_colour_economist() +
  theme_economist(base_family="sans") +
  labs(title="Median Points by Month and Day of Week (12/18 - 05/19)", x="Week of Month", y="Day of Week", fill="Median Points") +
  theme(legend.position = "bottom", legend.key.width = unit(2.5, "cm"))

ggsave('./viz/descriptive_06_dayofweek.png', plot = viz_dayofweek, dpi = 300, scale = 1)


df$hour <- format(strptime(df$published_datetime,"%Y-%m-%d %H:%M:%S"),'%H')

hours_by_points <- setNames( aggregate(list(points=df$points,comments=df$comments), by=list(df$hour), FUN=sum)
                              , c("Hour", "Points", "Comments"))  

viz_points_by_hour <- ggplot(data=subset(hours_by_points, hours_by_points$Rank != 'Other'), aes(x=hours_by_points$Hour, y=hours_by_points$Points/1000)) +
  geom_bar(stat="identity", size=0.5, fill='darkred') +
  scale_colour_economist()  +
  labs(title="Total Points for Top Posts by Publishing Hour (Rank > 5)", x="Hour of Day", y="Total points (K)") +
  theme_economist(base_family="sans") 
ggsave('./viz/descriptive_07_pointsbyhour.png', plot = viz_points_by_hour, dpi = 300, scale = 1)

#####################################################################
# SECTION 3
# Finally we analyze the word composition of headlines
#####################################################################
# Create Documents Corpus from Story Column
term_docs <- Corpus(VectorSource(df$story))
# Remove Punctuation Marks, Transform to Lower Case and Strip Digits
term_docs <- tm_map(term_docs, removePunctuation)
term_docs <- tm_map(term_docs, removeNumbers)
term_docs <- tm_map(term_docs,tolower)
# Remove Stopwords - We test with two different stopword lists
term_docs <- tm_map(term_docs, removeWords, stopwords("en"))
term_docs <- tm_map(term_docs, removeWords, stopwords("SMART"))
term_docs <- tm_map(term_docs, removeWords, c("–","show","hn"))
term_docs <- tm_map(term_docs, stripWhitespace)
term_docs <- tm_map(term_docs,stemDocument)
term_matrix <- DocumentTermMatrix(term_docs)
term_matrix <- removeSparseTerms(term_matrix, 0.999)
# Find all documents with 0 words and remove them (probably unnecessary but left as a precaution)
rowTotals <- apply(term_matrix , 1, sum) 
term_matrix <- term_matrix[rowTotals> 0, ]
# Find Most Frequent Terms and create wordcloud
findFreqTerms(term_matrix, 50)
freq = data.frame(sort(colSums(as.matrix(term_matrix)), decreasing=TRUE))
viz_wordcloud <- wordcloud(rownames(freq), freq[,1], max.words=150, colors=brewer.pal(9, "Dark2"))

dev.copy(png,'viz/descriptive_08_wordcloud.png')
dev.off()