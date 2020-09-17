knNextWord <- function(text, ngram = 3, resultnumber = 10, allgram = allgramData) {
    allgram <- data.table(allgram)
    text <- tolower(text)
    ticker <- ngram
    answer <- data.frame()
    lambda <- 1
    inputWords <- tail(unlist(strsplit(text, split = " ")), ticker - 1)
    if(length(inputWords) < ticker - 1) {ngram = ticker = length(inputWords) + 1}
    if(length(inputWords) == 0) {ngram = ticker = 2}
    while(ticker > 1) {
        inputhistory <- paste(inputWords, collapse = " ") #words up to the last word
        inputremainder = ifelse(ticker > 2, str_remove(inputhistory,'[A-Za-z]+ '), str_remove(inputhistory, '[A-Za-z]+'))
        
        if(ticker == ngram) {
            gram = allgram[which(gram_number == ticker & history == inputhistory),]
            if(nrow(gram) > 0) {
                gram[, prob := hoFirstTerm + hoLambda * loFirstTerm]
                answer = gram[,.(finalWord, prob)]
                lambda <- head(gram$hoLambda,1)
            }
        }
        newgram = allgram[which(gram_number == ticker & remainder == inputremainder)]
        if(nrow(newgram) > 0) {
            selectedgram <- unique(newgram[finalWord %in% answer$finalWord, c("finalWord", "loFirstTerm")], by = "finalWord")
            lambda2 = head(newgram$loLambda, 1)
            if(nrow(selectedgram) > 0) {
                answer <- merge.data.table(answer, selectedgram, by = "finalWord",all.x = TRUE)
                answer[is.na(loFirstTerm),loFirstTerm := 0]
                answer[,prob := prob + lambda * loFirstTerm]
                answer[, loFirstTerm := NULL]
            }
            newgram = newgram[!finalWord %in% answer$finalWord]
            newgram = unique(newgram, by = "lowergram")
            newgram[,prob := lambda * loFirstTerm]
            if(nrow(answer) > 0) {
                answer2 = newgram[,.(finalWord, prob)]
                answer <- rbind(answer, answer2)
            } else {
                answer = newgram[,.(finalWord, prob)]
            }
            lambda = lambda * lambda2
        }
        ticker <- ticker - 1
        inputWords <- tail(unlist(strsplit(text, split = " ")), ticker - 1)
        
    }
    answer %>%
        arrange(desc(prob)) %>%
        top_n(resultnumber) %>%
        mutate(prob = percent(prob, accuracy = 0.1)) %>%
        rename('Predicted words' = finalWord,
               Probability = prob)
}








