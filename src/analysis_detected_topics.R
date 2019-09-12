"
  analysis_detected_topics.R
  Author:
      Jake J. Dalli (jake.dalli.10@um.edu.mt)
  Description:
    In this script we perform an analysis on the detected topics, after detecting the topics.
    The main purpose of this script is to extract visualisations and aggregates from the analysis_topic_detection.R script.
    The structure of this script closley mirrors the structure of the documentation.
    # Section 1 - Are there particular topics which make it more often to the front page?
    # Section 2 - Are some articles over-represented in the top rank?
    We also perfrom the statistical tests mentioned in the paper, inside this script.
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
library(stringr)
library(stringi)
library(dplyr)
library(ggpubr)
library(MASS)

# Load The Data
df <- read.csv(file="./data-results-topicmodel/final-annotated-topic-document-matrix.csv", header=TRUE, sep=",")
df$points <- as.numeric(df$points)
df$comments <- as.numeric(df$comments)

#############################################################################
# Section 1 - Are there particular topics which make it more often to the front page?
#############################################################################

# Plot Detected topics by Points and Comments
topics_by_metrics <- setNames( aggregate(list(points=df$points,comments=df$comments), by=list(Category=df$top_story_topic_annotation)
                                         , FUN=median)
                                   , c("Topic", "Points", "Comments") )  
topics_by_metrics$is_noisy <- ifelse(grepl("Noisy",topics_by_metrics$Topic) | grepl("Nosiy",topics_by_metrics$Topic), 1, 0)

topics_by_metrics <- subset(topics_by_metrics, topics_by_metrics$is_noisy != 1)
viz_topic_metrics <- ggplot(topics_by_metrics, aes(x=Comments, y=Points)) +
  geom_text(data=subset(topics_by_metrics, topics_by_metrics$Points > 250 | topics_by_metrics$Comments > 150)
            , aes(x=Comments, y=Points, label=Topic )
            , size=3.5
            , nudge_y = -4
            , nudge_x = -2
            , check_overlap = TRUE
            , color= "darkblue" ) +
  geom_point(size=2, shape=20, color= ifelse(topics_by_metrics$Points > 250 | topics_by_metrics$Comments > 150,
                                             "darkblue","#A62D37") ) +
  theme_economist(base_family="sans") +
  labs(title="Top Topics by Avg. Points (Median)", x="Comments", y="Points")
ggsave('./viz/topic_model_02_alltopics.png', plot = viz_topic_metrics, dpi = 300, scale = 1)

# Get Top Topics
tab_top_topics <- head(topics_by_metrics[order(topics_by_metrics$Points, decreasing = TRUE),],5) %>%
  dplyr::select(Top_Topic = Topic, Med_Points = Points) 

top_topics_articles_points <- data.frame(Top_topic = character(), Story = character())
for(topic in tab_top_topics$Top_Topic){
  temp_df = subset(df,df$top_story_topic_annotation == topic) %>% 
    dplyr::select(top_story_topic_annotation, story, points) %>% 
    top_n(n=3,wt=points) %>%
    arrange(top_story_topic_annotation,desc(points))
  top_topics_articles_points <- rbind(top_topics_articles_points,temp_df)
}
top_topics_articles_points <-top_topics_articles_points %>% dplyr::select(annotation = top_story_topic_annotation, story, points)
write.csv(top_topics_articles_points,"./viz/topic_model_02_top_topics_points.csv", row.names = FALSE)


# Get Top Commented Topics
tab_top_topics_comments <- head(topics_by_metrics[order(topics_by_metrics$Comments, decreasing = TRUE),],5) %>%
  dplyr::select(Top_Topic = Topic, Med_Points = Comments) 


top_topics_articles_comments <- data.frame(Top_topic = character(), Story = character())
for(topic in tab_top_topics_comments$Top_Topic){
  temp_df = subset(df,df$top_story_topic_annotation == topic) %>% 
    dplyr::select(top_story_topic_annotation, story, comments) %>% 
    top_n(n=3,wt=comments) %>%
    arrange(top_story_topic_annotation,desc(comments))
  top_topics_articles_comments <- rbind(top_topics_articles_comments,temp_df)
}
top_topics_articles_comments <-top_topics_articles_comments %>% dplyr::select(annotation = top_story_topic_annotation, story, comments)
write.csv(top_topics_articles_comments,"./viz/topic_model_02_top_topics_comments.csv", row.names = FALSE)

# Get Clusters of Topics Identified by Visual Inspection
df_c1 <- unique(subset(df,df$top_topic_id %in% c(17,50,3,51,11,43,30,37,23,9,15)) %>%
         dplyr::select(top_topic_id, top_story_topic_annotation))
df_c1$cluster_name <- 'Cluster 1'

df_c2 <- unique(subset(df,df$top_topic_id %in% c(12,21,48,22,20,27,35)) %>%
         dplyr::select(top_topic_id, top_story_topic_annotation))
df_c2$cluster_name <- 'Cluster 2'

df_c3 <- unique(subset(df,df$top_topic_id %in% c(6,33,53,40,57,47,44,26,31)) %>%
         dplyr::select(top_topic_id, top_story_topic_annotation))
df_c3$cluster_name <- 'Cluster 3'

df_c4 <- unique(subset(df,df$top_topic_id %in% c(77,94,85,113)) %>%
         dplyr::select(top_topic_id, top_story_topic_annotation))
df_c4$cluster_name <- 'Cluster 4'

df_c5 <- unique(subset(df,df$top_topic_id %in% c(89,110,58,71)) %>%
         dplyr::select(top_topic_id, top_story_topic_annotation))
df_c5$cluster_name <- 'Cluster 5'
# Bind Clusters together for output
df_clustered_topics <- rbind(df_c1,df_c2,df_c3,df_c4,df_c5)
write.csv(df_clustered_topics,"./viz/topic_model_02_topic_clusters.csv", row.names = FALSE)


# Join Clustes to Original dataframe
df_clustered_topics$top_topic_id <- as.numeric(df_clustered_topics$top_topic_id)
df$top_topic_id <- as.numeric(df$top_topic_id)
clustered_df <- merge(x = df, y = df_clustered_topics, by.x = c("top_topic_id"), by.y = c("top_topic_id"))
# Visualize Clusters

cl_topics <- setNames( aggregate(list(points=clustered_df$points,comments=clustered_df$comments)
                                         , by=list(Category=clustered_df$top_story_topic_annotation.x)
                                         , FUN=median)
                               , c("Topic", "Points", "Comments") )  

cl_topics <- merge(x = cl_topics, y = df_clustered_topics, by.x = c("Topic"), by.y = c("top_story_topic_annotation"))
cl_topics <- subset(cl_topics,!grepl("Noisy",cl_topics$Topic) & !grepl("Nosiy",cl_topics$Topic))

viz_topic_clusters <- ggplot(cl_topics, aes(x=Comments, y=Points, color=cluster_name)) +
  geom_text(data=cl_topics
            , aes(x=Comments, y=Points, label=sub("Tax","\nTax",
                                                  sub("Languages","\n Languages", sub("& Parallel","\n & Parallel", Topic ))))
            , size=3.5
            , nudge_y = -4
            , check_overlap = TRUE) +
  geom_point(size=2, shape=20) +
  theme_economist(base_family="sans") +
  labs(title="Top Topics and Clusters by Avg. Points (Median)", x="Comments", y="Points", color="Cluster")
ggsave('./viz/topic_model_02_plot_clusters.png', plot = viz_topic_clusters, dpi = 300, scale = 1)

#############################################################################
# Section 2 - Are some articles over-represented in the top rank?
#############################################################################

## Section 1 - Are certain topics over-represented in the top ranked post?

# Test 1 - Are soem topics over represented in the top post?
# Null Hypothesis: The Boolean 'Top Post' Marker is independent of the topic number 
# Hypothesis Rejected
# We Consider all our data
# We bucket the rank into 1 = Top and 0 = Other Rank
chi_selection <- subset(df, df$rank < 30)
chi_selection$rank <- as.character(ifelse(chi_selection$rank == 1,1,0))
chi_selection$top_topic_id <- as.character(chi_selection$top_topic_id)
#  Perform Chi Squared Test
chi_sample <-  subset(chi_selection, select=c("top_topic_id","rank"))
chi_tbl <- table(chi_sample)
chisq.test(chi_tbl) 
"
#### Output:
Pearson's Chi-squared test

data:  chi_tbl
X-squared = 159.48, df = 113, p-value = 0.002634

Warning message:
In chisq.test(chi_tbl) : Chi-squared approximation may be incorrect
"
# p < 0.05 Therefore we reject the null hypothesis
# We observe that due to very low counts, thus the calculation may be unreliable
# We consider using logistic regression, but we conclude that this will serve no benefit because we have 2 categorical values
# This is the best we can do with the data available

# We now try with a one way annova test
anov <- aov(rank ~ top_story_topic_annotation, data = df)
"
                             Df Sum Sq Mean Sq F value   Pr(>F)    
top_story_topic_annotation  113  16588  146.80   1.996 2.97e-09 ***
Residuals                  5825 428417   73.55                     
---
Signif. codes:  0 ‘***’ 0.001 ‘**’ 0.01 ‘*’ 0.05 ‘.’ 0.1 ‘ ’ 1
"
summary(anov)

##################################################################
# We remove a particular outlier
df_top_post <- subset(df, df$rank == 1 & df$story != 'I Sell Onions on the Internet (www.deepsouthventures.com)')

topics_top_post <- setNames( aggregate(list(points=df_top_post$points,comments=df_top_post$comments), by=list(Category=df_top_post$top_story_topic_annotation)
                                       , FUN=median)
                             , c("Topic", "Points", "Comments") )  
topics_top_post$is_noisy <- ifelse(grepl("Noisy",topics_top_post$Topic) | grepl("Nosiy",topics_top_post$Topic), 1, 0)

topics_top_post <- subset(topics_top_post, topics_top_post$is_noisy != 1)
viz_top_post_topic_metrics <- ggplot(topics_top_post, aes(x=Comments, y=Points)) +
  geom_text(data=subset(topics_top_post, topics_top_post$Points > 1000 | topics_top_post$Comments > 300)
            , aes(x=Comments, y=Points, label= sub( "& ","&\n",Topic) )
            , size=3.5
            , nudge_y = -100
            , check_overlap = TRUE
            , color= "#A62D37" ) +
  geom_point(size=2, shape=20, color= "#A62D37") +
  theme_economist(base_family="sans") +
  labs(title="Top Topics in the Top Rank By by Avg. Points (Median)", x="Comments", y="Points")
ggsave('./viz/topic_model_02_top_post_ranking_med.png', plot = viz_top_post_topic_metrics, dpi = 300, scale = 1)


tab_toprank_topics <- head(topics_top_post[order(topics_top_post$Points, decreasing = TRUE),],5) %>%
  dplyr::select(Top_Topic = Topic, Med_Points = Points) 

top_topics_articles_points <- data.frame(Top_topic = character(), Story = character())
for(topic in tab_toprank_topics$Top_Topic){
  temp_df = subset(df_top_post,df_top_post$top_story_topic_annotation == topic) %>% 
    dplyr::select(top_story_topic_annotation, story, points) %>% 
    top_n(n=3,wt=points) %>%
    arrange(top_story_topic_annotation,desc(points))
  top_topics_articles_points <- rbind(top_topics_articles_points,temp_df)
}
top_topics_articles_points <-top_topics_articles_points %>% dplyr::select(annotation = top_story_topic_annotation, story, points)
write.csv(top_topics_articles_points,"./viz/topic_model_02_toprank_topics_points.csv", row.names = FALSE)

# Due to the high number of 'One Hit Wonder' articles within the top post, we plot by counts
topics_top_post_cnt <-count(df_top_post, "top_story_topic_annotation")  
sum_cnt <- sum(topics_top_post_cnt$freq)
topics_top_post_cnt$prob <- topics_top_post_cnt$freq/sum_cnt
topics_top_post_cnt <- head(topics_top_post_cnt[order(-topics_top_post_cnt$prob),],10)
toprank_freqviz <- ggplot(data=topics_top_post_cnt, aes(x=reorder( gsub(" ", " \n", top_story_topic_annotation), -freq), y=freq)) +
  geom_bar(stat="identity", fill="#A62D37") +
  theme_economist(base_family="sans") +
  labs(title="Top Topics in the Top Rank By by Avg. Points (Median)", x="Comments", y="Points")
write.csv(topics_top_post_cnt,"./viz/topic_model_02_toprank_freqtab.csv", row.names = FALSE)
ggsave('./viz/topic_model_02_toprank_freqtabviz.png', plot = toprank_freqviz, dpi = 300, scale = 1)



