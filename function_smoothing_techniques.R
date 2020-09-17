library(stringr); library(data.table)

#k = 0 is MLE estimation
#k = 1 is laplace smoothing
#k = delta is Lidstone smoothing
V = nrow(mongramData)
simpleSmoothing <- function(data, k = 1){
    data %>%
        group_by(history) %>%
        mutate(prob = (count + k)/(sum(count) +k*V^(gram_number)))
}

#good-turing discounting smoothing
gTSmoothing <- function(data, up_to = 20) {
    N <- sum(data$count)
    prob_table <- data %>%
        group_by(count) %>%
        summarise(freq_of_freq = n()) %>%
        mutate(prob = if_else(count <= up_to, (lead(count)/N) * (lead(freq_of_freq)/freq_of_freq), count/N)) %>%
        mutate(prob = prob * (1 - (head(freq_of_freq,1)/N)) * (1/sum(prob * freq_of_freq))) %>%
        select(count, prob)
    left_join(data, prob_table, by = "count")
}

#Katz back-off model adding GT discount and beta columns
########################################################
#add column for discount
discount <- function(data, cutoff = 5) {
    prob_table <- data %>%
        group_by(count) %>%
        summarise(freq_of_freq = n()) %>%
        mutate(d = ifelse(count <=cutoff, (lead(count)/count) * lead(freq_of_freq)/freq_of_freq, 1)) %>%
        select(count, d)
    left_join(data, prob_table, by = "count")
}
#add column for beta (leftover probability)
beta <- function(data) {
    data %>%
        group_by(history) %>%
        mutate(leftoverprob = 1 - sum(d * count)/sum(count)) %>%
        ungroup()
}

#kboPrediction <- function(text, ngram = 3) {
    #clean input text
    text <- tolower(text)
    inputWords <- tail(unlist(strsplit(text, split = " ")), ngram)
    inputhistory <- paste(inputWords[-length(inputWords)], collapse = " ") #words up to the last word
    lastWord <- inputWords[length(inputWords)] #last word
    
    #starting with trigrams, find a match if possible and calculate the percentage chance
    trigram <- trigramProb %>%
        filter(inputhistory == history)
    trigramMatch <- trigram %>%
            filter(lastWord == finalWord)
    if(nrow(trigramMatch) > 0) {
        finalProb <- (trigramMatch$d * trigramMatch$count)/sum(trigram$count)
        } else {
        beta <- trigram %>%
            select(leftoverprob)
        inputhistory <- paste(inputWords[-c(1, length(inputWords))], collapse = " ")
        bigram <- bigramProb %>%
            filter(inputhistory == history)
        unselectedBigramEndings <- bigram %>%
            filter(!finalWord %in% trigram$finalWord)
        bigramMatch <- bigram %>%
            filter(lastWord == finalWord)
        if(nrow(bigramMatch) > 0) {
            alpha <- beta/(sum((unselectedBigramEndings$d * unselectedBigramEndings$count)/sum(bigram$count)))
            finalProb <- alpha * (bigramMatch$d * bigramMatch$count)/sum(bigram$count)
        } else {
            monogram <- mongramProb %>%
                filter(lastWord == finalWord)
            unselectedMonogramEndings <- monogram %>%
                filter(!finalWord %in% trigram$finalWord)
            alpha <- beta/(sum((unselectedMonogramEndings$d * unselectedMonogramEndings$count)/sum(monogram$count)))
                finalProb <- alpha * (monogram$count * monogram$d/sum(monogram$count))
            }
    }
    
  finalProb  
}

#Kneser-Ney smoothing
#####################
#most basic formulation without recursion
knProbsBasic <- function(data, discount = 0.7) {
  dt <- data.table(data)
  dt <- dt[,firstTerm := pmax(count - discount, 0)/sum(count), by = history]
  dt <- dt[,lambda := (discount/sum(count))*.N, by = history]
  dt <- dt[,pcont := .N/nrow(dt), by = finalWord]
  dt
}
#recursive KN
knProbsRec <- function(data, discount = 0.7) {
  dt <- data.table(data)
  dt <- dt[,':=' (hoFirstTerm = pmax(count - discount, 0)/sum(count),
                  hoLambda = (discount/sum(count))*.N), by = history]
  if(head(dt$gram_number,1) == 2) {
    discount <- 0
  } 
  dt <- dt[,':=' (firstword = str_extract(history, '[A-Za-z]+'),
                  remainder = str_remove(history,'[A-Za-z]+'))]    
  dt <- dt[,N := pmax(.N - discount, 0), by = .(remainder, finalWord)]
  dt <- dt[,':=' (loFirstTerm = N/.N,
                  loLambda = (discount/.N)*uniqueN(finalWord)), by = remainder]
  colsChosen <- c("firstword", "N")
  dt <- dt[,lowergram := paste(remainder, finalWord)]
  dt <- dt[,(colsChosen) := NULL]
  return(dt)
}

#recursive modified kn with goodman and chen
knProbsMod <- function(data) {
  dt <- data.table(data)
  Y <- nrow(dt[count == 1])/(nrow(dt[count == 1]) + 2*nrow(dt[count == 2]))
  d1 <- Y
  d2 <- 2 - 3*Y*(nrow(dt[count == 3])/nrow(dt[count == 2]))
  d3 <- 3 - 4*Y*(nrow(dt[count == 4])/nrow(dt[count == 3]))
  dt[,discount := ifelse(count == 1, d1,
                         ifelse(count == 2, d2, d3))]
  setkey(dt, count)
  dt[, ':=' (temp1 = 0, temp2 = 0)][.(1), temp1 := .N, by = history][.(2), temp2 := .N, by = history][, ':=' (temp1 = max(temp1), temp2 = max(temp2)), by = history][,temp3 := .N - (temp1 + temp2), by = history]
  dt[,':=' (hoFirstTerm = pmax(count - discount, 0)/sum(count),
                  hoLambda = (d1*temp1 + d2*temp2 + d3*temp3)/sum(count)), by = history][, c("temp1", "temp2", "temp3") := NULL]
  if(head(dt$gram_number,1) == 2) {
    discount <- 0
  } 
  dt[,':=' (firstword = str_extract(history, '[A-Za-z]+'),
                  remainder = str_remove(history,'[A-Za-z]+'))]    
  dt[,N := pmax(.N - discount, 0), by = .(remainder, finalWord)]
  dt[, ':=' (temp1 = 0, temp2 = 0)][.(1), temp1 := uniqueN(finalWord), by = remainder][.(2), temp2 := uniqueN(finalWord), by = remainder][, ':=' (temp1 = max(temp1), temp2 = max(temp2)), by = remainder][,temp3 := uniqueN(finalWord) - (temp1 + temp2), by = remainder]
  dt[,':=' (loFirstTerm = N/.N,
                  loLambda = (d1*temp1 + d2*temp2 + d3*temp3)/.N), by = remainder][, c("temp1", "temp2", "temp3") := NULL] #TC note: close enough - problems selecting correct discount when chose "unique"
  colsChosen <- c("firstword", "N", "discount")
  dt[,lowergram := paste(remainder, finalWord)]
  dt[,(colsChosen) := NULL]
  return(dt)
}

