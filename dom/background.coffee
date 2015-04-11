# youtube polling
youtube_key = 'AIzaSyCOgZXFd0wj49anj5THC0bJva_oNjaBilQ'
# get comments
# https://gdata.youtube.com/feeds/api/videos/AJDUHq2mJx0/comments?start-index=26&max-results=25

# get # comments
# https://www.googleapis.com/youtube/v3/videos?part=statistics&id=sTPtBvcYkO8&key=AIzaSyCOgZXFd0wj49anj5THC0bJva_oNjaBilQ
# grab teacup

teacup = window.window.teacup
{span, div, a, h1, h3, p, iframe, raw, script, coffeescript, link, input, img} = teacup
youtube_video = ///
  (youtube.com|youtu\.be)               # youtube domain
  \/                                    # forward slash
  (watch\?|embed\/|v\/|e\/|)            # potential routes
  (v=)?                                 # optional v=
  ([^\#\&\?]*)                          # the video id
///i
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

renderComment = (data) =>
  console.log 'render', data
  $("#content > #overlay-wrapper").html teacup.render ( =>
    div '#overlay-wrapper', ->
      div '.comment', ->
        div -> data[0]?.name
        span -> data[0]?.text
      if data[0]?.reply?.object?.content
        div -> raw "answer: #{data[0]?.reply?.object?.content}"

  )

# bug here need a waiting script
current_time = $('#movie_player > div.html5-video-controls > div.html5-player-chrome > span > div.ytp-time-display.html5-control > span.ytp-time-current')
duration = $('#movie_player > div.html5-video-controls > div.html5-player-chrome > span > div.ytp-time-display.html5-control > span.ytp-time-duration')

entries = []
main_video_id = youtube_video.exec(window.location.href)[4]


initalized = false
old_entry = null
locInterval .9, ->
  return unless $("#content").length

  # initilization
  video_id = youtube_video.exec(window.location.href)[4]
  if video_id isnt main_video_id
   initalized = false

  if not initalized
    initalized = true
    console.log 'INITIALIZED'
    main_video_id = youtube_video.exec(window.location.href)[4]

    $("#content").prepend teacup.render ( =>
      div '#overlay-wrapper', ->
        div '.images'
        div '.comment', ->
          img src: 'https://gp3.googleusercontent.com/-pmGKuLJC7qU/AAAAAAAAAAI/AAAAAAAAABg/aItmNTS9xEY/s48-c-k-no/photo.jpg'
          span -> 'The stuff he starts playing at 9:47 and onwards. Could someone please give me some advice to learning this style? books?﻿'
    )


    getComments = (num = 368) =>
      calls = []
      count = 0
      video_id = 'AJDUHq2mJx0'

      while num > 0
        start_index = (count * 50) + 1
        calls[count] = "https://gdata.youtube.com/feeds/api/videos/#{main_video_id}/comments?start-index=#{start_index}&max-results=50&alt=json"
        num -= 50
        count++



      entries = []
      async.each calls, ((call, next) ->
        console.log call
        $.getJSON call, (data) =>
          console.log 'success,data'
          return next() unless data?.feed?.entry?.length
          console.log 'inside'
          for entry in data?.feed?.entry
            content = entry.content.$t
            spot = content.match(/(\d+:[\d:]+)/)?[1]
            continue unless spot
            seconds = timeToSeconds(spot)
            entries[seconds] ?= []
            entries[seconds].push {
              text: entry.content?.$t
              name: entry.author[0].name?.$t
              image_link: entry.author[0]?.uri?.$t
              total: entry
            }

          next()
      ), (err, finish) ->
        keys_1 = Object.keys(entries)
        async.each keys_1, ((index, outer_next) ->
          entry = entries[index]

          keys_2 = Object.keys(entry)
          async.each keys_2, ((index_2, sub_next) ->
            do =>
              sub_entry = entries[index][index_2]
              {name, text, image_link, total} = sub_entry
              console.log 'THE HELL?'
              if /\?|song/.test(text) and total.yt$replyCount.$t != 0
                id = total.id.$t.match(/comments(.+)$/)?[1]
                console.log id, 'ID WOOO'
                $.getJSON "https://www.googleapis.com/plus/v1/activities#{id}/comments?key=#{youtube_key}", (data) =>
                  sub_entry.reply = data?.items[0]
                  sub_next()
              else
                sub_next()
          ), (err, finish) ->
            console.log "WAHT"
            outer_next()
        ), (err, finish) ->
          console.log entries, '123', 'WAKKA'

    getComments()



  else
    current_seconds = timeToSeconds(current_time.text())
    console.log current_seconds, '3212323'
    new_entry = entries[current_seconds]
    if new_entry and old_entry isnt new_entry
      old_entry = new_entry
      renderComment new_entry



