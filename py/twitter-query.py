import tweepy
auth = tweepy.OAuthHandler("owsTgUPtAi6Ic2TqoiCMvo2wD", "KHt4qFmqFeLj8As6rqbZ1fOylLs1C6g5LEaX5A75x3qCGd7KQi")
auth.set_access_token("1202252450083807234-dlsFmwhmZxCyJGcpcMPfzg28MZcH9w", "b25jR3krUpJZEsDB5JlJTYhBEVSAw94UGSYlv08XgYbQ5")

api = tweepy.API(auth)

testSearch = api.search("liebe", count=20)
for result in testSearch:
    print(result.text)
