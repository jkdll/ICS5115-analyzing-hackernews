"
  preparation_augment_dataset_storytext.R
    Author:
        Jake J. Dalli (jake.dalli.10@um.edu.mt)
    Description:
      This is a small script to grab the story summaries and add them to the original dataset within a field called 'column'.
      Thus we augment the original dataset to create one unified datset containg both story headlines and text.
"
library(stringr)
library(dplyr)
library(NLP)
library(tm)
library(openNLP)

# Import Original Dataset
df <- read.csv(file="./data-clean/hackernews_board.csv", header=TRUE, sep=",")

# This is the function which does all the work
get_story_text <- function (x){
  # Get list of available files
  story_text_path <- './data-raw/story-text-summarized/'
  available_files <- list.files(path=story_text_path)
  # Get Hackernews Id and compute filename
  hn_id <- str_extract(x,'([0-9]+)')
  relevant_file <- paste0(hn_id,'.txt')
  
  # If a text for the story exists, read it and return the text
  # Otherwise return an empty string
  if(is.element(relevant_file,available_files)){
    # Only for Debugging Purposes
    # print(paste0('Found :',relevant_file))
    story_path_full <- paste0(story_text_path,relevant_file)
    text <- readChar(story_path_full, file.info(story_path_full)$size, useByte = TRUE)
    text < trimws(text)
    text <- gsub("[\r\n]", "", text)
    return(text)
  } else {
    # Only for debugging purposes
    # print(paste0('Not Found :',relevant_file))
    return('')
  }
}
# Call function and add to story_text
# df <- df %>% rowwise() %>% mutate(story_text = get_story_text(link_thread))

create_headline_keywords <- function(x){
  temp_text = unlist(x) %>% paste(collapse=' ') %>% as.String
  init_s_w <- annotate(temp_text, list(Maxent_Sent_Token_Annotator(),Maxent_Word_Token_Annotator()))
  pos_res <- annotate(temp_text, Maxent_POS_Tag_Annotator(), init_s_w)
  word_subset <- subset(pos_res, type=='word')
  tags = sapply(word_subset$features , '[[', "POS")
  temp_text_pos <- data.frame(word=temp_text[word_subset], pos=tags) %>% filter(!str_detect(pos, pattern='[[:punct:]]'))
  temp_text_pos <- subset(temp_text_pos,temp_text_pos$pos %in% c('NN','NNP','NNS','NNPS','VB','VBD','VBG','VBN','VBP','VBZ'))
  final_text <- paste0(temp_text_pos$word, collapse = " ")
  final_text <- tolower(final_text)
  final_text <-stemDocument(final_text)
  return(final_text)
}

df <- df %>% rowwise() %>% mutate(story_keywords = create_headline_keywords(story)) 

# Write out the dataframe to CSV
write.csv(df,"./data-clean/hackernews_board_content.csv", row.names = FALSE)