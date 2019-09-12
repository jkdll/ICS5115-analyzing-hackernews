"
  preparation_generate_dataset.R
    Author:
        Jake J. Dalli (jake.dalli.10@um.edu.mt)
    Description:
      In this script we extract the data from the hckrnews pages and save it into a csv.
      The data we extract is strictly limited to the leaderboard, the final dataset includes:
        - Story Name (The Headline for the story)
        - Number of Points (Number of Points associated to the article)
        - Number of Comments (Number of Comments)
        - Source Link (The link to the story source)
        - Thread Link (The link to the HN thread)
        - Source Domain (The internet domain from which the source originates)
        - Rank (The rank of the article for that specific day)
        - Published Date (The datetime for when the story was submitted to hackernews)
"

library(rvest)
library(anytime)
library(dplyr)
library(stringr)
# For some reason R converts strings to factors when creating dataframes.
# We don't want this behaviour at all, in fact I think it should default to false.
options(stringsAsFactors = FALSE)

# Get the index page from the archive and read in the HTML
raw_article_list <- read_xml('./data-raw/hckrnews_top50pc_20181201_20190511/index.html', as_html = TRUE)

# Get Nodes for Entries
html_entries <- html_nodes(raw_article_list, xpath='//*[contains(concat( " ", @class, " " ), concat( " ", "span15", " " )) and contains(concat( " ", @class, " " ), concat( " ", "story", " " ))]')

# Get Story Name from HTML Entries
story <- html_entries %>% html_text(trim=TRUE)

# Get Link from HTML Entries
link <- html_entries %>% html_attr(name="href")

# Get Points Values
# The xpath we're using also errenously selects the header, so we remove the first row.
points <- html_nodes(raw_article_list, xpath='//*[contains(concat( " ", @class, " " ), concat( " ", "span1", " " ))]') %>% html_text(trim=TRUE)
points <- points[-1]

# Get Number of Comments
# The xpath we're using also errenously selects the header, so we remove the first row.
comments <- html_nodes(raw_article_list, xpath='//*[contains(concat( " ", @class, " " ), concat( " ", "span2", " " ))]') %>% html_text(trim=TRUE)
comments <- comments[-1]

# Get Link to HackerNews Thread
threads <- html_nodes(raw_article_list,xpath='//*[contains(concat( " ", @class, " " ), concat( " ", "span1", " " ))]/ancestor::a') %>% html_attr("href")

# Get the published datetime (which is in unix epoch format)
published_epoch <- html_nodes(raw_article_list, xpath='//*[contains(concat( " ", @class, " " ), concat( " ", "span3", " " )) and contains(concat( " ", @class, " " ), concat( " ", "story", " " ))]') %>% html_attr('data-date')

# Create Clean Dataset with Hackernews Board, define column Names
df <- data.frame(story,link,points,comments,threads,published_epoch)
column_names <- c("story","link_story","points","comments","link_thread","published_epoch")
colnames(df) <- column_names

# Convert Published Epoch to Datetime
# Extract another column only containing date.
df$published_datetime <- as.POSIXct(as.numeric(as.character(df$published_epoch)),origin="1970-01-01",tz="GMT")
df$published_date <- as.Date(df$published_datetime)

# Build Source domain column, first populate with NA (a few columns have no source domain i.e AskHN threads)
df$source_domain <- NA
# Then Apply regex on the title and update rows
for (i in 1:nrow(df)){
  if(str_detect(str_to_lower(df$story[i]),"ask hn:")){
    df$source_domain[i] <- 'AskHn'
  } else if(str_detect(str_to_lower(df$story[i]),"show hn:")){
    df$source_domain[i] <- 'ShowHn'
    } else if(!str_detect(str_to_lower(df$story[i])," \\(")){
      df$source_domain[i] <- 'N/A'
    } else {
    df$source_domain[i] <- sub("\\).*", "", sub(".*\\(", "", df$story[i]))
    df$source_domain[i] <- sub('www.','',df$source_domain[i])
  }
}

# Convert points to numeric and replace any na values with 0, we need this to calculate ranks
df$points <- replace(as.numeric(df$points),is.na(df$points),0)

# Order the dataset by date and points
df <- df[with(df, order(published_date, points, decreasing = TRUE)), ]

# Run a row count and rank the articles by points
df$rank <- sapply(1:nrow(df), 
                    function(i) sum(df[1:i, c('published_date')]==df$published_date[i]))

# Select stories ranked top 30
df <- subset(df, rank <= 30)

# Remove anything within parenthesis
df$story <- gsub("\\s*\\([^\\)]+\\)","",as.character(df$story))

# Write Data to CSV
write.csv(df,"./data-clean/hackernews_board.csv", row.names = FALSE)
