library(shiny)

# Define UI for application that draws a histogram
shinyUI(fluidPage(
    withMathJax(),
    theme = shinythemes::shinytheme("flatly"),
    
    titlePanel("Predicting the next word"),
    tabsetPanel(
        tabPanel("App",
                 sidebarLayout(
                     sidebarPanel(
                         textInput("text","Input text here", value = "The cat sat on the"),
                         br(),
                         sliderInput("resultnumber", label = "Number of Results", min = 1, max = 10, value = 3)
                         ),
                     mainPanel(
                         fluidRow(align = "left", tableOutput("words"))
                         )
                     )
                 ),
        tabPanel("Documentation",
                 h2("Approach"),
                 p("This app estimates the next word in a sentence by extracting the ngram history (the last \"n\" words in the sentence) and comparing them to already-calculated ngram probabilities. It then returns the most likely words to follow, as well as those words' probabilities."),
                 h3("Methodology"),
                 p("This app uses the Modified Kneser-Ney Smoothing Algorithm, as presented in Chen and Goodman (1998) to estimate the probabilities of the next word. Kneser-Ney Smoothing is an extension of absolute discounting, where the lower order distribution is not based on the number of occurences of a word, but instead is based on the number of different words that it follows."),
                 p("The highest order ngrams used in this model are four-grams, and they are derived from a corpus of twitter, blogs, and news articles. This data was collected by web-crawler from publically available sources. It was provided by John Hopkins as part of the Coursera Data Science Capstone and was downloaded from the Coursera website."),
                 br(),
                 column(width = 12,align = "center", 
                        actionButton("textButton", "Mathematical Details for the Modified Kneser-Ney Smoothing Algorithm")),
                 br(),
                 br(),
                 uiOutput("equation1"),
                 h3("Repository"),
                 p("The code for this app can be found at: ", a("https://github.com/TDCrow/Capstone_Project")),
                 h3("References"),
                 p("Chen, Stanley F. and Joshua Goodman. 1998. An Empirical Study of Smoothing Techniques for Language Modeling. ", em("Harvard Computer Science Group Technical Report TR-10-98"), ". ", a("http://nrs.harvard.edu/urn-3:HUL.InstRepos:25104739 "))
        )
    )
))
