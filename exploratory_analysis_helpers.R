library(tidytext)
getData <- function(data, n = 1) {
    data %>%
        unnest_tokens(token, text, token = "ngrams", n = n, to_lower = FALSE)
}

getFrequency <- function(data) {
    data <- data.table(data)
    data[,word_count := .N, by = .(type, token)][, `:=` (total_count = .N, percentage_count = word_count/.N), by = type]
    data <- unique(data, by = c("type", "token"))
    data <- data[order(type, -percentage_count),]
    data[, `:=` (cumulative = cumsum(percentage_count),
                 rowID = .SD[,.I]), by = type]
}

plotGrams <- function(data) {
    data %>%
        group_by(type) %>%
        top_n(20, percentage_count) %>%
        ungroup() %>%
        mutate(token = reorder_within(token, -percentage_count, type)) %>%
        ggplot(aes(token, percentage_count)) +
        geom_col(aes(fill = percentage_count), show.legend = FALSE) +
        facet_wrap(~type, scales = "free_x") +
        theme(axis.text.x = element_text(angle = 90)) +
        scale_x_reordered() +
        scale_y_continuous(labels = percent)
}

summaryNgrams <- function(data) {
    data %>%
        group_by(type) %>%
        mutate(x_50 = if_else(cumulative > 0.5, rowID, max(rowID)),
               x_90 = if_else(cumulative > 0.9, rowID, max(rowID)),
               x_95 = if_else(cumulative > 0.95, rowID, max(rowID)),
               x_99 = if_else(cumulative > 0.99, rowID, max(rowID))) %>%
        summarise(`50th Percentile` = min(x_50),
                  `90th Percentile` = min(x_90),
                  `95th Percentile` = min(x_95),
                  `99th Percentile` = min(x_99),
                  `number of unique ngrams` = max(rowID))
}