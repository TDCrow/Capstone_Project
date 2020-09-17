###########################
#Download and read in data
###########################

#Download data
##############

#set paths
link <- "https://d396qusza40orc.cloudfront.net/dsscapstone/dataset/Coursera-SwiftKey.zip"
rawDataDirectory <- "./rawData"
rawDataFilename <- "rawData.zip"
rawDataFileLocation <- paste(rawDataDirectory,"/", rawDataFilename, sep = "")
dataDirectory <- "./Data"

#download raw data to own folder
if(!file.exists(rawDataDirectory)){
    dir.create(rawDataDirectory)
    download.file(url = link, destfile = rawDataFileLocation, method = "curl")
}
#unzip raw data to own folder
if(!file.exists(dataDirectory)){
    dir.create(dataDirectory)
    unzip(zipfile = rawDataFileLocation, exdir = dataDirectory)
}
filesName <- list.files(path = dataDirectory, recursive = TRUE)

#Read in data
#############

#Explore the data to be read
textFile <- paste(dataDirectory, "/", grep("en_US.twitter", filesName, value = TRUE), sep = "")
con <- file(textFile, "r")
readLines(con, 5)
close(con)

#read in all data
enTwitterDir <- paste(dataDirectory, "/", grep("en_US.twitter", filesName, value = TRUE), sep = "")
enBlogsDir <- paste(dataDirectory, "/", grep("en_US.blogs", filesName, value = TRUE), sep = "")
enNewsDir <- paste(dataDirectory, "/", grep("en_US.news", filesName, value = TRUE), sep = "")

if(!exists("enTwitterData")){
    con <- file(enTwitterDir, "r")
    enTwitterData <- readLines(con)
    close(con)
}

if(!exists("enBlogsData")) {
    con <- file(enBlogsDir, "r")
    enBlogsData <- readLines(con)
    close(con)
}

if(!exists("enNewsData")) {
    con <- file(enNewsDir, "r")
    enNewsData <- readLines(con)
    close(con)
}

