library(shiny); library(scales); library(dplyr); library(data.table); library(stringr);library(scales)
source("helpers.R")

allgramData <- fread("data/testData.csv")

shinyServer(function(input, output) {
    output$words <- renderTable({
        knNextWord(text = input$text, ngram = 4, resultnumber = input$resultnumber, allgram = allgramData)
    },
    spacing = "m")
    output$equation1 <- renderUI({
        if(!input$textButton) return()
        withMathJax(
            helpText(br(),
                     br(),
                     "The Kneser-Ney probability of word \\(w_i\\) given history \\(w_{i-n+1}\\),\\(w_{i-n+2}\\), ... , \\(w_{i-1}\\) (written as \\(w_{i-n+1}^{i-1}\\)) is defined as:",
                     br(),
                     "$$p_{KN}(w_i|w_{i-n+1}^{i-1}) =
                            \\frac{c(w_{i-n+1}^i)-D(c(w_{i-n+1}^i))}{\\sum_{w_i}x(w_{i-n+1}^i)} +
                            \\gamma(w_{i-n+1}^{i-1})p_{KN}(w_i|w_{i-n+2}^{i-1})$$",
                     br(),
                     "where \\(c(w_{i-n+1}^i)\\) is the ", em("count")," observed for the highest order ngram, and is the ", em("number of different words than have been observed to proceed")," the final word \\(w_i\\) for all lower order ngrams.",
                     "D is the discount, of which there are three different values that are applied to n-grams with one, two, or more than two counts respectively:",
                     "$$D(c) = \\begin{cases} 0 & \\mbox{if } c = 0\\\\
                            D_1 & \\mbox{if } c = 1\\\\
                            D_2 & \\mbox{if } c = 2\\\\
                            D_3 & \\mbox{if } c < 2\\end{cases}$$",
                     "the values of D are based on the relative frequency of ngrams with one, two, and three counts, and the different values for the different counts are motivated by empirical evidence that the ideal average discount for ngrams with one or two counts is significantly different from the ideal average discount for ngrams with higher counts. They are defined as follows:",
                     "$$Y = \\frac{n_1}{n+1 + 2n_2}$$",
                     "$$D_1 = 1 - 2Y\\frac{n_2}{n_1}$$",
                     "$$D_2 = 2 - 3Y\\frac{n_3}{n_2}$$",
                     "$$D_{3+} = 3 - 4Y\\frac{n_4}{n_3}$$",
                     br(),
                     "Gamma is the left-over probability for the lower order ngrams and is defined as:",
                     "$$\\gamma(w_{i-n+1}^{i-1}) =
                            \\frac{D_1N_1(w_{i-n+1}^{i-1}\\bullet)+D_2N_2(w_{i-n+1}^{i-1}\\bullet) + D_3N_3(w_{i-n+1}^{i-1}\\bullet)}{\\sum_{w_i}c(w_{w-n+1}^i)}$$",
                     "where \\(N_j(w_{i-n+1}^{i-1}\\bullet)\\) is the number of different words that can follow the observed history \\(w_{i-n+1}^{i-1}\\) with count j (where j is either 1, 2, or 3). I.e. gamma is the weighted average of the discounts already subtracted.")
            )
        
    })
})
