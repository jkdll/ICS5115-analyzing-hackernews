# ICS5115 (Statistics for Data Scientists) - Final Assignment

This repository contains deliverables presented for the final assignment of the ICS5115 - Statistics for Data Scientists course as part of the MSc. Artificial Intelligence programme at the University of Malta (October 2018 Intake)

In this assignment we use Latent Dirchlet Allocation (LDA) to detect topics from the new bulletin board Hacker News.

**Problem Defintion:** It is easier to make it to the top post in Hackernews using some topics instead of others – Y-Combinator’s Hackernews 2 is a news aggregation site for the technically-abled. People vote for the most interesting articles which make it to the top of the ranking. Some topics appear to be over-represented in the top post. You are required to verify whether this is true. Also, are there particular topics which make it more often to the
front page?


## Abstract

The online link aggregator Hacker News has emerged as one of the prime rallying points for startup
founders, venture capitalists and technology workers; grasping the attention of this cohort of internet users
carries intrinsic value. In this paper, we should how certain topics more likely to make it to the front page and that
specific topics are definitely over-represented within the top post. We frame the problem as a topic mining challenge,
applying a bayesian generative statistical model, Latent Dirichlet Allocation (LDA), and subsequently analyzing it
to draw our conclusions.


[Read the full paper here.](paper.pdf)


## Dependencies
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

