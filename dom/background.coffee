# youtube polling
# get comments
# https://gdata.youtube.com/feeds/api/videos/AJDUHq2mJx0/comments?start-index=26&max-results=25

# get # comments
# https://www.googleapis.com/youtube/v3/videos?part=statistics&id=sTPtBvcYkO8&key=AIzaSyCOgZXFd0wj49anj5THC0bJva_oNjaBilQ
# grab teacup

teacup = window.window.teacup
{span, div, a, h1, h3, p, iframe, raw, script, coffeescript, link, input, img} = teacup
old_entry = null

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


commentTemplate = (data) =>
  return teacup.render ( =>
    div '.animated fadeIn', ->
      span -> "#{data[0]?.name}: "
      span -> data[0]?.text
      if data[0]?.reply?.object?.content
        div -> raw "answer: #{data[0]?.reply?.object?.content}"
  )
timeoutID = null
renderComment = (data) =>
  console.log 'render', data
  $comment = $("#player-api > #overlay-wrapper .comment")
  $comment.html commentTemplate data
  clearTimeout timeoutID if timeoutID
  timeoutID = setTimeout (->
    $fadeIn = $comment.find('.fadeIn')
    $fadeIn.toggleClass('fadeIn fadeOut')
    $fadeIn.one 'webkitAnimationEnd mozAnimationEnd MSAnimationEnd oanimationend animationend', ->
      $(this).remove()
      old_entry = null
  ), 8000


# bug here need a waiting script
current_time = $('#movie_player > div.html5-video-controls > div.html5-player-chrome > span > div.ytp-time-display.html5-control > span.ytp-time-current')
duration = $('#movie_player > div.html5-video-controls > div.html5-player-chrome > span > div.ytp-time-display.html5-control > span.ytp-time-duration')

entries = []
main_video_id = youtube_video.exec(window.location.href)[4]


initalized = false
finished_loading = false
retryAttempt = null

locInterval .9, ->
  return unless $("#player-api").length
  return unless duration.length
  return unless current_time.length

  # initilization
  video_id = youtube_video.exec(window.location.href)[4]
  if video_id isnt main_video_id
   initalized = false

  if not initalized
    #SOMETHING BAD HAPPENED GIVE IT 1 MORE GO
    clearTimeout retryAttempt if retryAttempt
    retryAttempt = setTimeout (->
      if (finished_loading is false)
        console.log 'init failed trying again'
        retryCount--
        initalized = finished_loading
      else
        console.log 'init succeeded'
    ), 8000

    $("#player-api > #overlay-wrapper").remove()
    $('html').removeClass('youtube-social')
    initalized = true
    console.log 'INITIALIZED'
    main_video_id = youtube_video.exec(window.location.href)[4]

    getComments = (num = 368) =>
      calls = []
      count = 0
      while num > 0
        start_index = (count * 50) + 1
        calls[count] = "https://gdata.youtube.com/feeds/api/videos/#{main_video_id}/comments?start-index=#{start_index}&max-results=50&alt=json"
        num -= 50
        count++



      entries = []
      async.each calls, ((call, next) ->
        console.log call
        $.getJSON call, (data) =>
          return next() unless data?.feed?.entry?.length
          for entry in data?.feed?.entry
            content = entry.content.$t
            matches = content.match(/(\d+:[\d:]+)/m)
            spot = matches?[1]
            continue unless spot
            continue if matches?.length > 2
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

              # fix image and get the best reply to questions
              async.parallel {
                reply: (inner_next) ->
                  if /\?|song/gi.test(text)
                    sub_entry.type = 'reply'
                    if total.yt$replyCount.$t != 0
                      id = total.id.$t.match(/comments\/(.+)$/)?[1]
                      chrome.runtime.sendMessage {id: id, type: 'youtube-comments'}, (data) ->
                        sub_entry.reply = data?.items[0]
                        inner_next()
                    else
                      delete entries[index]
                      inner_next()

                  else
                    sub_entry.type = 'message'
                    inner_next()
                image_fix: (inner_next) ->
                  $.ajax {
                    url: "#{image_link}?alt=json"
                    dataType: 'json'
                    success: (data) =>
                      sub_entry.image = data?.entry?.media$thumbnail?.url
                      inner_next()
                    error: (data) ->
                      inner_next()
                  }
              }, (err, results) ->
                sub_next()

          ), (err, finish) ->
            outer_next()
        ), (err, finish) ->
          finished_loading = true
          console.log entries, 'entries'
          $("#player-api > #overlay-wrapper").remove()
          $("#player-api").append teacup.render ( =>
            div '#overlay-wrapper', =>
              div '.images', =>
                for key, entry of entries
                  continue unless entry
                  left = (key / timeToSeconds(duration.text())) * 100
                  if entry[0].image
                    div '.image', 'key':key, style: "left: #{left}%;", ->
                      img src: "#{entry[0].image}"
                      div '.image-hover', ->
                        img src: "#{entry[0].image}"
              div '.comment-wrapper', ->
                div '.comment'
                div '.hover-comment'
          )
          # only do this at the end
          if keys_1.length
            $('html').addClass('youtube-social')
          else
            $('html').removeClass('youtube-social')
          $image = $("#player-api #overlay-wrapper .images > .image")
          $image.mouseenter (e) ->
            $el = $ e.currentTarget
            console.log $el.attr('key'), "THIS IS THE KEY"
            data = entries[$el.attr('key')]
            $hover = $el.closest('#overlay-wrapper').find('.hover-comment')
            $hover.html commentTemplate(data)
            $hover.siblings('.comment').hide()


          $image.mouseleave (e) ->
            $el = $ e.currentTarget
            $hover = $el.closest('#overlay-wrapper').find('.hover-comment')
            $fadeIn = $hover.find('.fadeIn')
            $fadeIn.toggleClass('fadeIn fadeOut')
            $fadeIn.one 'webkitAnimationEnd mozAnimationEnd MSAnimationEnd oanimationend animationend', ->
              $(this).remove()
              $hover.siblings('.comment').show()
    chrome.runtime.sendMessage {id: main_video_id, type: 'youtube-stats'}, (data) ->
      comments = Math.max 1000, data?.items[0]?.statistics?.commentCount
      getComments()



  else
    current_seconds = timeToSeconds(current_time.text())
    new_entry = entries[current_seconds]
    if new_entry and old_entry isnt new_entry
      old_entry = new_entry
      renderComment new_entry

