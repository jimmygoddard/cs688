# Module 5 - Twitter

#### Section 2.2

# Use your own Twitter Developer API Key and Secret
t.api.key <- "xxxxxxxxxxx"
t.api.secret <- "yyyyyyyyyy"

# # ---------  version 1.1.7 --------- 
# # OAuth parameters
# t.reqURL <- "https://api.twitter.com/oauth/request_token"
# t.accessURL <- "https://api.twitter.com/oauth/access_token"
# t.authURL <- "https://api.twitter.com/oauth/authorize"                                  
# 
# # Register credentials
# t.credentials <- OAuthFactory$new(consumerKey=t.api.key,
#                                   consumerSecret=t.api.secret, 
#                                   requestURL=t.reqURL,
#                                   accessURL=t.accessURL,
#                                   authURL=t.authURL)
# t.credentials$handshake()
# registerTwitterOAuth(t.credentials) # # for version is 1.1.7
# save(list="t.credentials", file="twitter_credentials")
# load("twitter_credentials")
# registerTwitterOAuth(t.credentials)
# # ---------------------------------- 

# ---------  version 1.1.8 --------- 
setup_twitter_oauth(t.api.key, t.api.secret, access_token=NULL, access_secret=NULL)
# setup_twitter_oauth(t.api.key, t.api.secret, access_token=t.access.token, access_secret=t.access.secret) # Alternate
save(list=(c("t.api.key","t.api.secret")), file="twitter_credentials.RData")
# ---------------------------------- 


# ---- 1)  Twitter User Information ------------
start<-getUser("cnnbrk")

# ---- 1.1 Twitter User Information ------------
# The function returns an object of the class user that models the information about a user on Twitter. 
# Using the user object, the name, screenName, id, and description of the user can be obtained as follows.

start$name
start$screenName
start$id
start$description

# The same information can be accessed using the get methods or the direct methods as shown below.
# Using get methods
start$getName()
start$getScreenName()
start$getId()
start$getDescription()

# Using direct methods
start$name
start$screenName
start$id
start$description

# ---- 1.2 Twitter User Information ------------
# ---- Counts ---
# The followersCount gives the number of followers for the specified user. 
start$followersCount

# The favoritesCount gives the number of favorites for this user. 
start$favoritesCount

# The friendsCount shows the number of followees for this user. 
start$friendsCount

# The location of the user can also be obtained.
start$location

# The number of status updates for the specified user and the last status update of this user can be obtained as follows.
start$statusesCount
start$lastStatus


# ---- Status --
# The status object is the container for Twitter status messages and has the information about the text of the tweet, 
# when it was created, how many times it has been retweeted, etc.
status <- start$lastStatus
status$text
status$created
status$retweetCount

# ---- 1.3 Twitter User Information ------------
# ---- Followers and Friends ---
# The twitter IDs of the followers of the specified user can be obtained using the getFollowerIDs method. 
# The argument n is used for limiting the number of values retrieved. 
# If the argument is omitted, all the followers are returned.

start$getFollowerIDs(n=10) # Followers IDs

start$getFollowers(n=5) # Followers ScreenName

start$getFriendIDs(n=10) # Friends IDs

start$getFriends(n=5) # Friends ScreenName


# ---- 2) Searching for Tweets ------------
# The searchTwitter method is used for searching Twitter using the specified search string. 
# The method returns a list of twitter status objects. The status object is the container for the tweet. 
# The optional argument n (default value 25) specifies the maximum number of tweets to be returned by the search.

# ---- 2.1 Tweets by tag ------------ 
tweets1 <- searchTwitter('#bigdata', n = 5)

tweets1

# The following user defined function can be used to display the information about each tweet, 
# showing the screen name of the associated user and the text of the tweet.
display.tweet <- function (tweet) {
  cat("Screen name:", tweet$getScreenName(), 
      "\nText:", tweet$getText(), "\n\n")
}

for (t in tweets1) {
  display.tweet(t)
}


# ---- 2.2 Tweets by user ------------ 
# The tweets from a specific user’s timeline can be retrieved using the userTimeline function. 
# In the following example, the first five tweets from the twitter user “kdnuggets” are retrieved. 

tweets2 <- userTimeline("kdnuggets", n = 5)

tweets2

for (t in tweets2) {
  display.tweet(t)
}

# Authenticated User timeline (Your tweets)

tweets3 <- homeTimeline(n = 5)

for (t in tweets3) {
  display.tweet(t)
}



# ---- 3) Trends ------------

# The name and the URL for each trend can be displayed using the following user-defined function
display.trend <- function (trend) {
  cat("Name:", trend$name, 
      "\n  url:", trend$url, "\n\n")
}

# The available trend locations can be obtained as shown below. 
# The woeid is a numerical identification code describing a location (Where on Earth ID).
trends.locations <- availableTrendLocations()
head(trends.locations)

# The getTrends function returns the current trends for the specified woeid.
trends.location.woeid <- trends.locations[1, "woeid"] # Try 5 for Montreal Trends 
trends1 <- getTrends(trends.location.woeid)
# The twitter homepage http://trends24.in/ shows the worldwide trends. 


for (i in 1:nrow(trends1)) {
  display.trend(trends1[i,])
}

# For Boston
boston.woeid <- 
  trends.locations[trends.locations$name == "Boston", "woeid"]
trends2 <- getTrends(boston.woeid)

for (i in 1:nrow(trends2)) {
  display.trend(trends2[i,])
}

# ---- 4) Exercise: Graphing of Friends and Followers ------------

user <- getUser("kaggle")
user.name <- user$name 
user.name

friends <- 
  lookupUsers(user$getFriendIDs(n=15))

followers <- 
  lookupUsers(user$getFollowerIDs(n=5))

save(list=c("friends", "followers"),
     file="kaggleFF.RData")

load(file="kaggleFF.RData")

friends.names <- sapply(friends, name)

head(friends.names, n = 2)

followers.names <- sapply(followers, name)

head(followers.names, n = 2)

friends.frame <- 
  data.frame(User=user.name, 
             Follower=friends.names)

head(friends.frame, n = 2)

followers.frame <- 
  data.frame(User=followers.names, 
             Follower=user.name)

head(followers.frame, n = 2)

relations <- 
  merge(friends.frame, 
        followers.frame, all = T)

head(relations, n = 2)

tail(relations, n = 2)

library(igraph)

# Create graph from relations

g <- graph.data.frame(
  relations, directed = T)

V(g)

V(g)[2:6]$color <- 'blue'
V(g)[7:21]$color <- 'red'

# Plot the graph using plot()

plot(g)

# ---- 5) Applying Text Mining to Tweets ------------

library(tm)
library(SnowballC)

tweets <- userTimeline("kaggle", n = 200)

save(list="tweets", 
     file="kaggle.RData")

load(file="kaggle.RData")

tweets.text <- 
  lapply(tweets, 
         function(t) {t$getText()})

head(tweets.text, n = 2)

# Number of retrieved tweets
length(tweets.text)


data.source <- VectorSource(tweets.text)
data.corpus <- Corpus(data.source)

# inspect the first two values
inspect(data.corpus[1:2])

meta(data.corpus[[1]])
content(data.corpus[[1]])

# transformations

data.corpus <- 
  tm_map(data.corpus, 
         content_transformer(tolower))

inspect(data.corpus[1:2])

removeURL <- function(x) {
  gsub("(http[^ ]*)", "", x)
}

data.corpus <- 
  tm_map(data.corpus, 
         content_transformer(removeURL))

inspect(data.corpus[1:2])

data.corpus <- 
  tm_map(data.corpus, 
         content_transformer(removePunctuation))

english.stopwords <- stopwords("en")
head(english.stopwords)

data.corpus <- 
  tm_map(data.corpus,
         content_transformer(removeWords),
         english.stopwords)

# inspect the first two values
inspect(data.corpus[1:2])

removeNumberWords <- function(x) {
  gsub("([[:digit:]]+)([[:alnum:]])*", "", x)
}

data.corpus <- 
  tm_map(data.corpus, 
         content_transformer(removeNumberWords))


# inspect the first two values
inspect(data.corpus[1:2])


data.corpus <- 
  tm_map(data.corpus,
         content_transformer(stemDocument))

data.corpus <- 
  tm_map(data.corpus,
         content_transformer(stripWhitespace))

# inspect the first two values
inspect(data.corpus[1:2])


# Build the term document matrix

tdm <- TermDocumentMatrix(data.corpus)

# inspect part of the matrix

inspect(tdm[150:160, 50:60])

save(list=("tdm"),
     file = "kaggleTDM.RData")

load(file="kaggleTDM.RData")

# convert TDM to a matrix

m <- as.matrix(tdm)

# View portion of the matrix
m[150:160, 51:60]

# calculate the frequency of words 
wordFreq <- rowSums(m)

# Examine part of the frequencies
cbind(wordFreq[150:160])

# Sort the words by descending order of frequency
wordFreq <- sort(wordFreq, decreasing=TRUE)

# Examine the top ten words
cbind(wordFreq[1:10])

# frequent terms
findFreqTerms(tdm, lowfreq=15)

# associations
findAssocs(tdm, "science", 0.4) 

# word cloud

library(wordcloud)

palette <- brewer.pal(8,"Dark2")
palette

set.seed(137)
wordcloud(words=names(wordFreq), 
          freq=wordFreq, 
          min.freq=3, 
          random.order=F,
          colors=palette)


# ---- 6) Sentiment Analysis of Tweets ------------

sentiment <- function(text, pos.words, neg.words) {
  text <- gsub('[[:punct:]]', '', text)
  text <- gsub('[[:cntrl:]]', '', text)
  text <- gsub('\\d+', '', text)
  text <- tolower(text)
  # split the text into a vector of words
  words <- strsplit(text, '\\s+')
  words <- unlist(words)
  # find which words are positive
  pos.matches <- match(words, pos.words)
  pos.matches <- !is.na(pos.matches)
  # find which words are negative
  neg.matches <- match(words, neg.words)
  neg.matches <- !is.na(neg.matches)
  # calculate the sentiment score
  score <- sum(pos.matches) - sum(neg.matches)
  cat (" Positive: ", words[pos.matches], "\n")
  cat (" Negative: ", words[neg.matches], "\n")
  return (score)
}

# Lexicons
pos.words = scan('positive-words.txt',
                 what='character',
                 comment.char=';')

neg.words = scan('negative-words.txt',  
                 what='character', 
                 comment.char=';')

head(pos.words)

head(neg.words)

mbta.tweets <- searchTwitter('@mbta', n=200)

save(list="mbta.tweets",
     file="mbta.RData")

load(file="mbta.RData")

mbta.texts <- 
  lapply(mbta.tweets, 
         function(t) {
           iconv(t$getText(), 
                 "latin1", "ASCII", sub="")
         })

mbta.texts[[1]]

sentiment(mbta.texts[[1]], pos.words, neg.words)

mbta.texts[[5]]

sentiment(mbta.texts[[5]], pos.words, neg.words)

mbta.texts[[116]]

sentiment(mbta.texts[[116]], pos.words, neg.words)

sink(tempfile())
scores <- sapply(mbta.texts, 
                 sentiment, 
                 pos.words, neg.words)
sink()

table(scores)

barplot(table(scores), 
        xlab="Score", ylab="Count",
        col="cyan")

mbta.texts[[4]]

sentiment(mbta.texts[[4]], pos.words, neg.words)


sentiment.na <- function(text, pos.words, neg.words) {
  text <- gsub('[[:punct:]]', '', text)
  text <- gsub('[[:cntrl:]]', '', text)
  text <- gsub('\\d+', '', text)
  text <- tolower(text)
  # split the text into a vector of words
  words <- strsplit(text, '\\s+')
  words <- unlist(words)
  # find which words are positive
  pos.matches <- match(words, pos.words)
  pos.matches <- !is.na(pos.matches)
  # find which words are negative
  neg.matches <- match(words, neg.words)
  neg.matches <- !is.na(neg.matches)
  # calculate the sentiment score
  p <- sum(pos.matches)
  n <- sum(neg.matches)
  if (p == 0 & n == 0)
    return (NA)
  else
    return (p - n)
}

scores.na <- sapply(mbta.texts, 
                    sentiment.na, 
                    pos.words, neg.words)

table(scores.na)

barplot(table(scores.na), 
        xlab="Score", ylab="Count",
        ylim=c(0,40), col="cyan")

# Data frame of scores and tweets

mbta.vector <- sapply(mbta.texts,
                      function (t) {(t)})
x <- data.frame(Score=scores.na, Text=mbta.vector)
View(x)
