"
  preparation_get_source_articles.R
    Author:
        Jake J. Dalli (jake.dalli.10@um.edu.mt)
    Description:
      This script reads the stories extracted within the story dataset, and scrapes the source websites to extract the web page.
      This is an extraction step which is later followed up with further pre-processing.
    
    !! WARNING !! 
      This script takes VERY long to terminate and consumes multiple CPU cores.
      Remember we are scraping thousands of websites.
      Moreover, thanks to GDPR and paywalls, we may need to manually intervene by re-running this script repeatedly.
      Your PC may freeze up when running it. You have been warned.
    !! WARNING !! 
"

library(digest)
library(rvest)
library(stringr)
require(doParallel)
registerDoParallel(cores=1)

# Read the dataset
df <- read.csv(file="./data-clean/hackernews_board.csv", header=TRUE, sep=",")

# Get the file list
files <- list.files(path='./data-raw/story-data/')
files <- gsub(".html", "", files)

# We don't want to read strings as factors
options(stringsAsFactors = FALSE)
# Set UserAgent
options(HTTPUserAgent = 'Mozilla/5.0 (X11; Ubuntu; Linux x86_64; rv:67.0) Gecko/20100101 Firefox/67.0')

# For every article, scrape the website
for(i in 1:nrow(df)){
  url <- df$link_story[i]
  possibleError <- tryCatch({
    #sess <- html_session(url)
    file_name <- str_extract(df$link_thread[i],'([0-9]+)')
    if (is.element(file_name,files)){
      next
    } else {
      print(url)
      Sys.sleep(5)
      download.file(url, paste0('./data-raw/story-data/',file_name,'.html'), 'wget', quiet = TRUE, mode = 'w',
                    cacheOK = TRUE,
                    extra = getOption('download.file.extra'))
    }
  }, error=function(e){
    print(paste('Error Extracting ',url,sep=""))
    print(e)
    error_log <-file('./data-raw/story-data-errors.txt')
    write(url, error_log, append=TRUE, sep='\n')
    close(error_log)
  })
  if(inherits(possibleError,'error')) next
}







