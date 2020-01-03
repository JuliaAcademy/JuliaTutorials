using TextAnalysis

model = TextAnalysis.SentimentAnalyzer()

model(StringDocument("hello world"))

model(StringDocument("an incredibly boring film"))

model(StringDocument("a highly enjoyable ride"))

model(StringDocument("a great film"))


