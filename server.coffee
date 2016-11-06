console.log 'Starting Server'
express = require 'express'
config = require './.config'
Twit = require 'twit'
# sentiment = require 'sentiment-spanish'
sentiment = require 'sentiment'

app = express();
T = new Twit(config)

app.set('view engine', 'jade')
app.use(express.static(__dirname + '/public'));

server = app.listen 3000, () ->
  console.log 'listening of port 3000'


app.get '/tweets/geo/:city', (req, res)->
  T.get 'geo/search', {q:req.params.city}, (err, data, resp) ->
    res.send data

app.get '/tweets/:query', (req, res) ->

  params = { q:req.params.query, count:5 }
  response = {tweets: []}
  parse = (tweet) -> 
    tw = {
      score:sentiment(tweet.text).score,
      text: tweet.text,
      lang: tweet.lang
      geo: tweet.geo
    }
    response.tweets.push(tw)

  T.get 'search/tweets', params, (err, data, rest) ->
    parse tweet for tweet in data.statuses 
    res.render('index.jade', {data:response}) 

app.get '/map', (req, res) -> 
