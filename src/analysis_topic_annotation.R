"
  analysis_topic_annotation.R
   Author:
      Jake J. Dalli (jake.dalli.10@um.edu.mt)
    Description:
      This script is used to perform the manual annotation process described in the paper.
      We looked at every one of the 114 topics, evaluate their quality, and assign a tag to each topic.
      This tag is used for better understanding and evaluation.
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

# Load The Data from the Topic document matrix
mat <- read.csv(file="./data-results-topicmodel/topic-document-matrix.csv", header=TRUE, sep=",")
# Load the Topics and labels
labels <- read.csv(file="./data-results-topicmodel/topic-labels.csv", header=TRUE, sep=",")
colnames(labels) <- c('story_topic','top_topic_keywords')
df_annot <- merge(x = mat, y = labels, by = "story_topic", all.x = TRUE)
df_annot <- df_annot %>% select(story, story_topic, top_topic_keywords, points)
# Now We go through the VERY manual process of giving the topics a proper name
# This serves as validation and analysis
# We repeatedly run a command of the format unique(subset(df_annot, story_topic == 1)$story) etc.
# Then we look at the output and decide an adequate topic name
# Alternatively, output a CSV for better reading
# write.csv(df_annot,"./data-results-topicmodel/annot_temp.csv", row.names = FALSE)
labels$story_annotation <- ''
# And now for the automated tagging...
labels$topic_annotation[1] = "Youtube"
labels$topic_annotation[2] = "Boeing 737 & Aviation"
labels$topic_annotation[3] = "Geopolitics"
labels$topic_annotation[4] = "Mobile Devices & Apps"
labels$topic_annotation[5] = "Self Improvement"
labels$topic_annotation[6] = "Rust Lang."
labels$topic_annotation[7] = "Environmental Concerns"
labels$topic_annotation[8] = "Space Exploration"
labels$topic_annotation[9] = "VC,IPOs & Money"
labels$topic_annotation[10] = "IDEs"
labels$topic_annotation[11] = "Making Money"
labels$topic_annotation[12] = "Quitting Jobs & Toxic SV Culture"
labels$topic_annotation[13] = "Noisy Topic 1"
labels$topic_annotation[14] = "CPUs, Performance & Advances"
labels$topic_annotation[15] = "Corporate Revenue & Transactions"
labels$topic_annotation[16] = "Academia"
labels$topic_annotation[17] = "Lawmaking, Policy & Trump"
labels$topic_annotation[18] = "Tool UI, Automation & Devops"
labels$topic_annotation[19] = "Alt. Energy"
labels$topic_annotation[20] = "Movies & Entertainment"
labels$topic_annotation[21] = "Noisy Topic B"
labels$topic_annotation[22] = "Japanese Tech."
labels$topic_annotation[23] = "C-Level Execs, Recruitment & Layoffs"
labels$topic_annotation[24] = "Web Browsers & Plugins"
labels$topic_annotation[25] = "Computer Graphics & Cameras"
labels$topic_annotation[26] = "Fast & Efficient Porgramming"
labels$topic_annotation[27] = "Terrorism & General Crime"
labels$topic_annotation[28] = "User Privacy & Notifications"
labels$topic_annotation[29] = "Security, Privacy & Tracking"
labels$topic_annotation[30] = "Demographic Statistics"
labels$topic_annotation[31] = "Nosiy Topic C"
labels$topic_annotation[32] = "Consumer Devices & Microcontrollers"
labels$topic_annotation[33] = "Interpreted Prog. Languages"
labels$topic_annotation[34] = "Noisy Topic D"
labels$topic_annotation[35] = "Generic articles Talking about Problems & The Past, a bit Noisy"
labels$topic_annotation[36] = "Learning, DL/ML/AI"
labels$topic_annotation[37] = "Corporate Tax"
labels$topic_annotation[38] = "Pychology, Loneliness & Productivity"
labels$topic_annotation[39] = "Security & Data Breaches"
labels$topic_annotation[40] = "Ruby Lang."
labels$topic_annotation[41] = "College Education & Career"
labels$topic_annotation[42] = "Secure Protocols"
labels$topic_annotation[43] = "Payment Companies & Investments"
labels$topic_annotation[44] = "Nosiy Topic E"
labels$topic_annotation[45] = "Democracy & Voting"
labels$topic_annotation[46] = "Noisy Topic F"
labels$topic_annotation[47] = "Math, Simulations & Trading"
labels$topic_annotation[48] = "Housing & Accom"
labels$topic_annotation[49] = "Biology, Disease & Medicine"
labels$topic_annotation[50] = "Government Surveillance"
labels$topic_annotation[51] = "Noisy Topic G"
labels$topic_annotation[52] = "Bug Fixes & New SW"
labels$topic_annotation[53] = "Functional Lagnuages"
labels$topic_annotation[54] = "Software Usability & User Interfaces"
labels$topic_annotation[55] = "Malicious Company Behaviour"
labels$topic_annotation[56] = "Github & New OSS"
labels$topic_annotation[57] = "Concurrency & Parallel Programming"
labels$topic_annotation[58] = "Wikileaks & Law"
labels$topic_annotation[59] = "Problem Solving & Thinking"
labels$topic_annotation[60] = "Noisy Topic H"
labels$topic_annotation[61] = "Startup Ideas & Freelancing"
labels$topic_annotation[62] = "Containers, Orch & Cloud"
labels$topic_annotation[63] = "BizDev"
labels$topic_annotation[64] = "Theoretical Physics"
labels$topic_annotation[65] = "Noisy topic I"
labels$topic_annotation[66] = "Climate Change & Pollution"
labels$topic_annotation[67] = "Copyright & Web Security"
labels$topic_annotation[68] = "Noisy Topic J"
labels$topic_annotation[69] = "Programming Languages Principles"
labels$topic_annotation[70] = "Journo, Media & Ads"
labels$topic_annotation[71] = "Corp. Lawsuits"
labels$topic_annotation[72] = "Space Exploration Companies"
labels$topic_annotation[73] = "Linguistics NLP & ML"
labels$topic_annotation[74] = "User Data Privacy"
labels$topic_annotation[75] = "Online Publishing & Docs"
labels$topic_annotation[76] = "Apple Corp."
labels$topic_annotation[77] = "Nature, Animals & Insects"
labels$topic_annotation[78] = "Hiring & Careers"
labels$topic_annotation[79] = "AV & SDV"
labels$topic_annotation[80] = "Low-Level Programming"
labels$topic_annotation[81] = "Facebook Privacy Concerns"
labels$topic_annotation[82] = "Google Corp."
labels$topic_annotation[83] = "Censorship"
labels$topic_annotation[84] = "New Software Releases"
labels$topic_annotation[85] = "Noisy Topic K"
labels$topic_annotation[86] = "Matainability & OOP"
labels$topic_annotation[87] = "Front-End Dev"
labels$topic_annotation[88] = "Mapping & Diagrams"
labels$topic_annotation[89] = "Huawei & China"
labels$topic_annotation[90] = "Noisy Topic L"
labels$topic_annotation[91] = "Weather & Natural Disasters"
labels$topic_annotation[92] = "Music Streaming & Multimiedia"
labels$topic_annotation[93] = "Stats. & Charts"
labels$topic_annotation[94] = "Chess & Games & Board Games"
labels$topic_annotation[95] =  "Software Vulnerability & Hacking"
labels$topic_annotation[96] =  "Web Protocols & APIs"
labels$topic_annotation[97] =  "ML/AI & Society"
labels$topic_annotation[98] =  "Noisy Topic M"
labels$topic_annotation[99] =  "Health, Drugs & Pharama"
labels$topic_annotation[100] = "Noisy Topic N"
labels$topic_annotation[101] = "Instant Messaging"
labels$topic_annotation[102] = "Living in Cali"
labels$topic_annotation[103] = "DB Tech"
labels$topic_annotation[104] = "Noisy Topic O (Bloomberg Blocked Sites)"
labels$topic_annotation[105] = "Blockchain & DLT"
labels$topic_annotation[106] = "General Society"
labels$topic_annotation[107] = "Math & CS"
labels$topic_annotation[108] = "Amazon"
labels$topic_annotation[109] = "Noisy Topic P"
labels$topic_annotation[110] = "Noisy Topic Q"
labels$topic_annotation[111] = "Noisy Topic R"
labels$topic_annotation[112] = "Numerical Computing & DL"
labels$topic_annotation[113] = "Family Issues & Happiness"
labels$topic_annotation[114] = "Food Consumption & Diet"

write.csv(labels,"./data-results-topicmodel/detected-topics-list.csv", row.names = FALSE)
# We have a dataset containing the top story topic. But we want at least the top 3 story topics
# We re-create the story-topic for the second and third most likely topic associated to a story

final_mat <- mat 
final_mat$top_topic_id <- 0
final_mat$second_topic_id <- 0
final_mat$third_topic_id <- 0
for(j in 1:nrow(final_mat)){
  x = final_mat[j,]
  # Set Variables for Probabilities and Ids
  top_prob <- 0
  second_prob <- 0
  third_prob <- 0
  top_topic_id <- -1
  second_topic_id <- -1
  third_topic_id <- -1
  # Loop Over Columns to find Top Probabilities and Ids
  for (i in 1:length(names(x)) ){
    # Only Work with Probability Columns
    if ( grepl('X',names(x[i]) ) & nchar(names(x[i])) > 1 ){
      temp_colname <- paste0('X',i)
      temp_prob <- x[i]
      # Calculate top probability
      if (temp_prob > top_prob){
        top_prob <- temp_prob
        top_topic_id <- as.numeric(str_replace(names(x[i])[1],'X',''))
      } else if(temp_prob > second_prob){
        second_prob <- temp_prob
        second_topic_id <- as.numeric(str_replace(names(x[i])[1],'X',''))
      } else if(temp_prob > third_prob){
        third_prob <- temp_prob
        third_topic_id <- as.numeric( str_replace(names(x[i])[1] ,'X',''))
      }
    }
  }
  rn <- length(names(x))
  x$top_topic_id <- top_topic_id
  x$second_topic_id <- second_topic_id
  x$third_topic_id <- third_topic_id
  final_mat[j,] <- x
}

# Restructure Labels Joining
top_topic_labels <- labels
names(top_topic_labels)[names(top_topic_labels) == "story_topic"] <- "top_story_topic"
names(top_topic_labels)[names(top_topic_labels) == "top_topic_keywords"] <- "top_story_topic_keywords"
names(top_topic_labels)[names(top_topic_labels) == "topic_annotation"] <- "top_story_topic_annotation"
# Add to Final Matrix
final_mat$top_topic_id <- as.numeric(final_mat$top_topic_id)
top_topic_labels$top_story_topic <- as.numeric(top_topic_labels$top_story_topic)
final_mat <- merge(x = final_mat, y = top_topic_labels, by.x = c("top_topic_id"), by.y = c("top_story_topic"), all.x = TRUE)

# Repeat the Same Process for Second Top Topic
second_topic_labels <- labels
names(second_topic_labels)[names(second_topic_labels) == "story_topic"] <- "second_story_topic"
names(second_topic_labels)[names(second_topic_labels) == "top_topic_keywords"] <- "second_story_topic_keywords"
names(second_topic_labels)[names(second_topic_labels) == "topic_annotation"] <- "second_story_topic_annotation"
final_mat <- merge(x = final_mat, y = second_topic_labels, by.x = c("second_topic_id"), by.y = c("second_story_topic"), all.x = TRUE)

# Repeat the Same Process for Third Top Topic
third_topic_labels <- labels
names(third_topic_labels)[names(third_topic_labels) == "story_topic"] <- "third_story_topic"
names(third_topic_labels)[names(third_topic_labels) == "top_topic_keywords"] <- "third_story_topic_keywords"
names(third_topic_labels)[names(third_topic_labels) == "topic_annotation"] <- "third_story_topic_annotation"
final_mat <- merge(x = final_mat, y = third_topic_labels, by.x = c("third_topic_id"), by.y = c("third_story_topic"), all.x = TRUE)

write.csv(final_mat,"./data-results-topicmodel/final-annotated-topic-document-matrix.csv", row.names = FALSE)
