# Next Word Text Prediction

## Summary
This application takes a word or phrase as an input and predicts the most likely word to follow. It uses a **Modified Kneser-Ney Smoothing algorithm**, as presented in Chen and Goodman (1998), which computes probabilities from observed ngrams that are dervied from a existing body of text (corpus). In this case, the corpus consists of sampled data from 3 corpora collected from publically available sources (twitter, blogs, and news).

The app can be found at https://tdcrow.shinyapps.io/WordPrediction/ 

## Data
The corpora consists of publically available sources collected by web-crawler. There are three sources, twitter, blogs, and news, all in the English Language. The data was provided by John Hopkins as part of the Coursera Data Science Capstone and was downloaded from the Coursera website.

## Approach
This application uses ngrams of sizes 1-4 (unigrams, bigrams, trigrams and fourgrams) to estiamte the following word, however the code is flexible enough to be applied to a dataset of any length ngram.
To estimate the word probabilities several different smoothing approaches were considered, and the code for all these approaches are contained in this repository. These are:
*1. Additive smoothing - Laplace and Lidstone smoothing*
*2. Good-Turing estimate*
*3. Katz smoothing (backoff)*
*4. Kneser-Ney smoothing*
*5. Modified Kneser-Ney smoothing (Chen and Goodman, 1998)*

## Files
#### Downloading and Preprocessing
* download_data.R
* preprocessing_and_cleaning_data.R

#### Functions
* function_extracting_ngrams.R
* function_smoothing_techniques.R
* function_predict_algo.R

#### App
* ui.R
* server.R
* helpers.R

## References
Chen, Stanley F. and Joshua Goodman. 1998. An Empirical Study of Smoothing Techniques for Language Modeling. Harvard Computer Science Group Technical Report TR-10-98. http://nrs.harvard.edu/urn-3:HUL.InstRepos:25104739 

Daniel Jurafsky and James H. Martin. 2019. Speech and Language Processing: An Introduction to Natural Language Processing, Computational Linguistics, and Speech Recognition (1st. ed.). Prentice Hall PTR, USA. https://web.stanford.edu/~jurafsky/slp3/3.pdf