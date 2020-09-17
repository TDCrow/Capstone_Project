library(shiny); library(scales); library(dplyr); library(data.table); library(stringr);library(scales)
source("helpers.R")

allgramData <- fread("data/testData.csv")

# Define server logic required to draw a histogram
shinyServer(function(input, output) {
    output$words <- renderTable({
        knNextWord(text = input$text, ngram = 4, resultnumber = input$resultnumber, allgram = allgramData)
    },
    spacing = "m")
})
