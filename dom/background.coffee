# youtube polling
# Key = 'AIzaSyCOgZXFd0wj49anj5THC0bJva_oNjaBilQ'
# get comments
# https://gdata.youtube.com/feeds/api/videos/AJDUHq2mJx0/comments?start-index=26&max-results=25

# get # comments
# https://www.googleapis.com/youtube/v3/videos?part=statistics&id=sTPtBvcYkO8&key={YOUR_API_KEY}
# grab teacup
teacup = window.window.teacup
{span, div, a, h1, h3, p, iframe, raw, script, coffeescript, link, input, img} = teacup

locInterval = (time, next) ->
  setInterval next, time * 1000

timeToSeconds = (time) ->
  seconds = 0
  elements = time.split(':').reverse()
  seconds += parseInt(elements[0]) if elements[0]
  seconds += parseInt(elements[1]) * 60 if elements[1]
  seconds += parseInt(elements[2]) * 60 * 60 if elements[2]
  seconds += parseInt(elements[3]) * 24 * 60 * 60 if elements[3]
  return seconds

# bug here need a waiting script
current_time = $('#movie_player > div.html5-video-controls > div.html5-player-chrome > span > div.ytp-time-display.html5-control > span.ytp-time-current')
duration = $('#movie_player > div.html5-video-controls > div.html5-player-chrome > span > div.ytp-time-display.html5-control > span.ytp-time-duration')

locInterval 1, ->
  return unless $("#content").length
  # initilization

  console.log $("#content #overlay-wrapper"), 'wtf'
  if not $("#content #overlay-wrapper").length
    console.log "INITIALIZED"
    $("#content").prepend teacup.render ( =>
      div '#overlay-wrapper', ->
        div '.images'
        div '.comment', ->
          img src: 'https://gp3.googleusercontent.com/-pmGKuLJC7qU/AAAAAAAAAAI/AAAAAAAAABg/aItmNTS9xEY/s48-c-k-no/photo.jpg'
          span -> 'The stuff he starts playing at 9:47 and onwards. Could someone please give me some advice to learning this style? books?﻿'
    )
  else

    console.log 'BEFORE', current_time.text()
    current_seconds = timeToSeconds(current_time.text())
    console.log $('a[rel="nofollow"]')



