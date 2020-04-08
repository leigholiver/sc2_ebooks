import os, random, tweepy

def lambda_handler(event, context):
    auth = tweepy.OAuthHandler(os.getenv('CONSUMER_KEY'), os.getenv('CONSUMER_SECRET'))
    auth.set_access_token(os.getenv('ACCESS_KEY'), os.getenv('ACCESS_SECRET'))
    api = tweepy.API(auth)

    quotes=list(open('sc2quotes.txt', encoding="utf-8-sig"))
    quote=random.choice(quotes)
    api.update_status(quote)