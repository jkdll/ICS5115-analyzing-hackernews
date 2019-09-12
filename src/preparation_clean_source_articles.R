"
  preparation_get_source_articles_clean.R
    Author:
        Jake J. Dalli (jake.dalli.10@um.edu.mt)
    Description:
      In this script, we pick up the raw HTMl documents extracted from the hackernews data sources.
      Next, we run these documents through a HTML boilerplate code removal tool (boilerpipe).
      We use the ArticleExtractor boilerpipe function which is trained on news articles.
      Finally, we only pick the first 800 words for the article to save.
"
library(rJava)
library(boilerpipeR)
library(NLP)
library(tm)
library(openNLP)

# Paths for input and output
input_files_path <- './data-raw/story-data/'
input_files <- list.files(path=input_files_path)
output_files_path <- './data-raw/story-text-summarized/'

# Naive Summarize function - given a text x, extract the first y words
summarize <- function(x,y) {
  ul = unlist(strsplit(x, split = "\\s+"))[1:y]
  paste(ul,collapse=" ")
}

# Loop over files
for (f in input_files){
  # Get webpage code
  input_full_path <- paste0(input_files_path,f)
  webpage_code <- readChar(input_full_path,file.info(input_full_path)$size, useBytes = TRUE)
  
  # Run article extractor and remove any NAs introduced in the process
  article_extract <- ArticleExtractor(webpage_code)
  article_extract <- sub( " NA ", "", na.omit( summarize(article_extract,800) ))
  
  # Extract Only Nouns
  temp_text = unlist(article_extract) %>% paste(collapse=' ') %>% as.String
  init_s_w <- annotate(temp_text, list(Maxent_Sent_Token_Annotator(),Maxent_Word_Token_Annotator()))
  pos_res <- annotate(temp_text, Maxent_POS_Tag_Annotator(), init_s_w)
  word_subset <- subset(pos_res, type=='word')
  tags = sapply(word_subset$features , '[[', "POS")
  temp_text_pos <- data.frame(word=temp_text[word_subset], pos=tags) %>% filter(!str_detect(pos, pattern='[[:punct:]]'))
  temp_text_pos <- subset(temp_text_pos,temp_text_pos$pos %in% c('NN','NNP','NNS','NNPS'))
  final_text <- paste0(temp_text_pos$word, collapse = " ")
  
  # Output the file
  output_full_path <- paste0(output_files_path,gsub('.html', '.txt', f))
  output_file_conn <- file(output_full_path)
  write(final_text, output_file_conn)
  close(output_file_conn)
}