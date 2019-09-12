# ICS5115 (Statistics for Data Scientists) - Final Assignment

This repository contains deliverables presented for the final assignment of the ICS5115 - Statistics for Data Scientists course as part of the MSc. Artificial Intelligence programme at the University of Malta (October 2018 Intake)

In this assignment we use Latent Dirchlet Allocation (LDA) to detect topics from the new bulletin board Hacker News.

**Problem Defintion:** It is easier to make it to the top post in Hackernews using some topics instead of others – Y-Combinator’s Hackernews 2 is a news aggregation site for the technically-abled. People vote for the most interesting articles which make it to the top of the ranking. Some topics appear to be over-represented in the top post. You are required to verify whether this is true. Also, are there particular topics which make it more often to the
front page?
 

 a news aggregation site for the technically-abled. People vote for the most interesting articles
which make it to the top of the ranking. Some topics appear to be over-
represented in the top post. You are required to verify whether this is

## Problem Outline



## Abstract

The online link aggregator Hacker News has emerged as one of the prime rallying points for startup
founders, venture capitalists and technology workers; grasping the attention of this cohort of internet users
carries intrinsic value. In this paper, we should how certain topics more likely to make it to the front page and that
specific topics are definitely over-represented within the top post. We frame the problem as a topic mining challenge,
applying a bayesian generative statistical model, Latent Dirichlet Allocation (LDA), and subsequently analyzing it
to draw our conclusions.

This github repository contains the coursework presented for 



----
This is the assignment source code presented for the ICS5115 - Statistics for Data Scientists course as part of the MSc. Artificial Intelligence programme at the University of Malta. Below is a summary of the deliverables.

Author: Jake J. Dalli
E-Mail: jake.dalli.10@um.edu.mt
Submission Date: 21/06/2019
Running Instructions: If you are viewing the version uploaded to the UoM VLE, the raw data and the RStudio environment will be missing. To download them access this link:
https://drive.google.com/drive/folders/1a_tBChunesEsNyeRRXChDwvjiAFgcIwU?usp=sharing
(NOTE You must be able to log into the UoM Google Drive to access the link)
Then follow the instructions in the pre-requisites section. 

---
## Table of Contents
1. [Directories](#directories)
2. [Installation Pre-requisites](#Pre-requisites)
3. [Data Sets](#Data-Sets)
4. [Data Pipeline](#Data-Pipeline)
---
## Directories
The parent directory contains everything that is necessary to evaluate the project including the project report and the presentation. The code for producing these are in the below directories:
1. `./src/` contains all the source code and data used for our analysis. 
    1. `./src/data-clean/` Datasets post-cleaning/preparation. 
    2. `./src/data-raw/` Datasets from extraction.
    3. `./src/env/` Backup of the Rstudio enverionment containing our LDA model.
    4. `./src/data-results-topicmodel` Datasets extracted from our topic model, containing the results of our topic model.
    5. `./src/viz/` visualisations and CSV extracts for tables and figures used within our documentation.
2. `./doc/` Repository containing the project specification and the LaTeX template for our report.

For more information, have a look at the sections about the Data Pipeline and Datasets.
## Pre-requisites
The project was developed on a machine running Ubuntu 18.04.2 LTS using RStudio Version 1.2.1335 and R version 3.6 (the latest version), which should be compatible with 3.5.4. Prior to running the scripts, you must ensure that you have the required libraries installed. 
On Ubuntu, you must install the following packages:
```
bash
sudo apt-get install libcurl4-openssl-dev libssl-dev
sudo apt-get install libxml2-dev
sudo add-apt-repository ppa:marutter/c2d4u3.5
sudo apt-get update
sudo apt-get install r-cran-rjava
sudo apt-get install libgsl0-dev

```

The following R libraries are required to run the scripts:
```
R
# R Library Requirements
install.packages("topicmodels")
install.packages("doParallel")
install.packages("foreach")
install.packages("psych")
install.packages("zoo")
install.packages("plyr")
install.packages("lubridate")
install.packages("corrplot")
install.packages("GGally")
install.packages("ggwordcloud")
install.packages("wordcloud")
install.packages("stringi")
install.packages("ggpubr")
install.packages("MASS")
install.packages("digest")
install.packages("doParallel")
install.packages("rvest")
install.packages("anytime")
install.packages("dplyr")
install.packages("stringr")
install.packages("rJava")
install.packages("boilerpipeR")
install.packages("NLP")
install.packages("tm")
install.packages("openNLP")
install.packages("ggplot2")
install.packages("ggthemes")
install.packages("scales")
install.packages("gridExtra")
install.packages("grid")
install.packages("xml2")
install.packages("anytime")
install.packages("SnowballC")

```

## Data-Sets
This repository contains the following datasets:
1. Data Sources
    - **Hacker News Board**: This is the data soure extracted from HckrNews roughly spanning from November 2018 till June 2019. It is composed of a single HTML dump. Location: `./src/data-raw/hckrnews_top50pc_20181201_20190511/index.html`
    - **Source Stories**: This is a folder containing HTML dumps for data source links within the Hacker News board. They were extracting by scraping the source pages using RVest. Location: `./src/data-raw/story-data/*`
    - **Source Text**: This is a folder containing the cleaned versions of the stories, stories were cleaned by extracting the noun phrases and verb phrases from the source stories as described in the paper. Location: `./src/data-raw/story-text/*`
2. Clean Source Dataset: Hacker News Board
    - **Hacker News Board**:  `./src/data-clean/hackernews_board.csv` which is a CSV file of stories from our data source. The CSV file is composed of the story name, story link, source domain, thread link, number of comments and number of points. *This is the dataset used within our descriptive analysis.*
    - **Hacker News Board**: `./src/data-clean/hackernews_board_content.csv` which is a CSV file of stories from our data source. The CSV file is composed of the story name, story link, source domain, thread link, number of comments and number of points, story headline keywords and story text.
3. Result Datasets
    - **Detected Topics List:** `./src/data-results-topicmodel/detected-topics-list.csv` - a csv file containing the raw datected topics outputted from our model.
    - **Annotated Topics List:** `./src/data-results-topicmodel/topic-labels.csv` - a CSV file containing the topics detected by our model, including a topic annotation produced by a human during our evaluation.
    - **Topic Document Matrix:** `./src/data-results-topicmodel/topic-document-matrix` a CSV file containing our storie sas per the clean source datset, plus columns indicating the probability of association to each of the 114 topics (columns X1..X114).
    - **Final Annotated Topic Document Matrix:** This identical to the topic document matrix, with the addition of a number of columns to facilitate analysis. The additional columsna are the three topics for each story (topic with the highest probability for each story), the top three topic keywords for each story, and the top three topic annotaitons for each story (as per the annotated topics list dataset). *This is the dataset used within our topic analysis presented within the paper*

## Data-Pipeline
The data pipeline is composed of the following scripts (to be run in the following order):

1. *preparation_generate_dataset_boardonly.R* and *preparation_generate_dataset_withcontent.R*
    - **Description:** These scripts extract data from the raw data repositories (HckNews and Story Text) respectively essentially converting an HTML document to a clean CSV file.
    - Note that the output of this file is already saved in `./src/data-clean/*.csv` thus you can view the results there.
2. *preparation_get_source_articles.R*
    - **Description:** For every row in `./src/data-clean/hackernews_board.csv` we scrape the data source for a story and output the result to `./src/data-raw/story-data/` as an HTML document.
    - Note that this script takes **very** long to run, uses multiple cores, and is heavy on the network. Remember we are scraping (literally) thousands of websites. **We do not recommend that you run this script if you do not have time to waste,** instead you can view the output here: `./src/data-raw/story-data/`
3. *preeparation_clean_source_articles.R*
    - **Description:** This script grabs the HTML outputtes from step 2 and performs the cleaning described in the paper. Mainly, we extract noun phrases and verb phrases from the first 800 words of each data source. You can view the output in `./src/data-raw/story-text/`
4. *analysis_topic_detection.R*
    - **Description:** This script performs the K-selection for the LDA model, trains an LDA model on our corpus, and extracts the covariance matrix - as described in the paper.
    - Note that this script takes **very** long to run and uses multiple cores. We are training over 122 LDA models in this script to select K, using the corpus of over ~5,900 documents. It took us approximately 18 hours perform k selection. **We suggest that you do not attempt running this script.** Instead, it is suggested that you load the environment resulting from the script, which is backed up in `./src/env/` which is a dump of the R environment used during training and look at it using R studio.
    - Moreover, you can view the results for this script in `./src/data-results-topicmodel/`
5. *analysis_topic_annotation.R*
    - **Description:** This script is the result of our human annotation process, we simply load the topics extracted from the analysis_topic_detection.R and annotate them manually.
6. *analysis_descriptive.R*
    - **Description:** This is the script which was used to create the visualisations for the descriptive analysis presented within the paper.
7. *analysis_detected_topic.R*
    - **Description:** This is the script which was used to create the visualisations for the topic analysis presented within the paper. 

