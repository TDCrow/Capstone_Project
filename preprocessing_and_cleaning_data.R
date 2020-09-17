#Preprocessing and cleaning the data
###################################

#libraries
library(dplyr)
library(tidyr)
library(stringr)

#step 1: collate all the data into one datatable
enBlogsDataTib <- tibble(enBlogsData)
enNewsDataTib <- tibble(enNewsData)
enTwitterDataTib <- tibble(enTwitterData)
rawData <- bind_rows(enBlogsDataTib %>%
                         mutate(type = "blogs") %>%
                         rename(text = enBlogsData),
                     enNewsDataTib %>%
                         mutate(type = "news") %>%
                         rename(text = enNewsData),
                     enTwitterDataTib %>%
                         mutate(type = "twitter") %>%
                         rename(text = enTwitterData))

#Cleaning the data
##################

#only keeping letters and apostrophies - no numbers or symbols
data <- rawData %>%
    mutate(text = tolower(text)) %>%
    mutate(text = str_replace_all(text, "[^a-z']", " ")) %>% #replace all text with " " except lower case letters a-z 
    mutate(text = str_replace_all(text, " {2,}", " ")) #remove double spaces

write.csv(data, "cleanedData.csv")






