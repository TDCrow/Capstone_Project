source("exploratory_analysis_helpers.R")
data <- fread(file.path("intermediateData", "cleanedData.csv"))

monogramsFrequency <- getFrequency(getData(data, 1))
bigramsFrequency <- getFrequency(getData(data, 2))
trigramsFrequency <- getFrequency(getData(data, 3))

fwrite(monogramsFrequency, file.path("intermediateData", "monogramsFrequency.csv"))
fwrite(bigramsFrequency, file.path("intermediateData", "bigramsFrequency.csv"))
fwrite(trigramsFrequency, file.path("intermediateData", "trigramsFrequency.csv"))
