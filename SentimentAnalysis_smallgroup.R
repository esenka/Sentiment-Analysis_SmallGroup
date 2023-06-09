# Read the CSV file
data <- read.csv("/Users/esenka/Desktop/Event Lab PhD/Sentiment Analysis/Small Group Experiment/SmallGroupData_combined.csv", stringsAsFactors = FALSE)

install.packages("tidyverse")
install.packages("tidytext")
install.packages("syuzhet")

library(tidyverse)
library(tidytext)
library(syuzhet)


install.packages("vader")
library(sentimentr)
library(vader)
library(SentimentAnalysis)

#lowercase set up
text.data <- tibble(text = str_to_lower(data$essay))

#analyze sentiments in syuzhet based on the NRC sentiment dictionary
emotions <- get_nrc_sentiment(text.data$text)
emo_bar <- colSums(emotions)
emo_sum <- data.frame(count=emo_bar, emotion=names(emo_bar))

#create a barplot showing the counts for each of eith different emotions and positive/negative rating
ggplot(emo_sum, aes(x = reorder(emotion, -count), y=count)) +
  geom_bar(stat = 'identity')


#sentiment analysis with the tidytext package using the 'bing' lexicon
bing_word_counts <- text.data %>% unnest_tokens(output = word, input = text) %>%
  inner_join(get_sentiments("bing")) %>%
  count(word, sentiment, sort = TRUE)

#select top 10 words by sentiment
bing_top_10_words_by_sentiment <- bing_word_counts %>%
  group_by(sentiment) %>%
  slice_max(order_by = n, n =10) %>%
  ungroup() %>%
  mutate(word = reorder(word,n))
bing_top_10_words_by_sentiment

#create a barplot showing contribution of words to sentiment
bing_top_10_words_by_sentiment %>%
  ggplot(aes(word, n, fill = sentiment)) +
  geom_col(show.legend = FALSE) +
  facet_wrap(~sentiment, scales = "free_y") +
  labs(y = "Contribution to sentiment", x =NULL) +
  coord_flip()


#sentiment analysis with the tidytext package using the 'bing' lexicon
loughran_word_counts <- text.data %>% unnest_tokens(output = word, input = text) %>%
  inner_join(get_sentiments("loughran")) %>%
  count(word, sentiment, sort = TRUE)


#select top 10 words by sentiment
loughran_top_10_words_by_sentiment <- loughran_word_counts %>%
  group_by(sentiment) %>%
  slice_max(order_by = n, n =10) %>%
  ungroup() %>%
  mutate(word = reorder(word,n))
loughran_top_10_words_by_sentiment

#create a barplot showing contribution of words to sentiment
loughran_top_10_words_by_sentiment %>%
  ggplot(aes(word, n, fill = sentiment)) +
  geom_col(show.legend = FALSE) +
  facet_wrap(~sentiment, scales = "free_y") +
  labs(y = "Contribution to sentiment", x =NULL) +
  coord_flip()


#sentimentr
sc2 <- sentimentr::get_sentences(data)
sente2 <- sentiment_by(sc2)

#syuzhet
sentze2 <- syuzhet::get_sentiment(data)

#SentimentAnalysis
sentsae2 <- analyzeSentiment(data)
sentsae2 <- sentsae2$SentimentQDAP

#vader
sentve2 <- vader_df(data)

#make a n*4 matrix of the sentiment scores and standardize them
Xe2 <- matrix(c(sente2$ave_sentiment,sentve2$compound,sentze2,sentsae2),nrow=49, ncol = 4, byrow = FALSE)
Ze2 <- scale(Xe2)

#find the means and standard deviations
apply(Xe2,2,mean)
apply(Xe2,2,sd)

#find the correlations
library("Hmisc")
rr <- rcorr(Xe2)
rr$r #correlations
rr$P # significance

#histograms
hist(Xe2[,1],xlab= substitute(paste(italic("sr"))),ylab="frequency", main="",cex.lab=1.5,cex.axis=1)
hist(Xe2[,2],xlab= substitute(paste(italic("sv"))),ylab="frequency", main="",cex.lab=1.5,cex.axis=1)
hist(Xe2[,3],xlab= substitute(paste(italic("sz"))),ylab="frequency", main="",cex.lab=1.5,cex.axis=1)
hist(Xe2[,4],xlab= substitute(paste(italic("sa"))),ylab="frequency", main="",cex.lab=1.5,cex.axis=1)

#clustering
set.seed(8512)
ce42 <- kmeans(Ze2, 4)

library(factoextra)

fviz_cluster(ce42, data = Ze2,
             #palette = c("1","2","3","4"), 
             geom = "point",
             ellipse.type = "convex", 
             ggtheme = theme_bw(),
             main = ""
)

reorderCluster <- function(k, cluster, actualorder){
  #cluster is the given cluster assignments per sentence - e.g. c4$cluster with k levels
  #inorder is their order with respect to the cluster plot where they are arbitrary labelled as 1,2,...
  #If k == 4 then we want actualorder[1]...actualorder[k] -> [1,2,...,k]
  #E.g., [1,3,4,2] -> [1,2,3,4]
  