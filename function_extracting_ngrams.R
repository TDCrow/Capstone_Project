library(dplyr); library(tidyr); library(tidytext)

gramdata <- function(data, ngram = 1, fraction = 0.1, minCount = 10) {
    result <- data %>%
        select(text) %>%
        unnest_tokens(token, text, token = "ngrams", n = ngram, to_lower = FALSE) %>%
        sample_frac(fraction) %>%
        count(token, sort = TRUE, name = "count") %>%
        filter(count >= minCount) %>%
        select(token, count) %>%
        mutate(gram_number = ngram) %>%
        separate(token, c("history", "finalWord"), sep = " (?=[^ ]+$)")
    return(result)
}