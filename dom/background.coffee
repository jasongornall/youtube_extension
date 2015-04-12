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


commentTemplate = (data) =>
  return teacup.render ( =>
    div '.animated fadeIn', ->
      span -> "#{data[0]?.name}: "
      span -> data[0]?.text
      if data[0]?.reply?.object?.content
        div -> raw "answer: #{data[0]?.reply?.object?.content}"
  )
renderComment = (data) =>
  console.log 'render', data
  $comment = $("#player-api > #overlay-wrapper .comment")
  $comment.html commentTemplate data
  setTimeout (->
    $fadeIn = $comment.find('.fadeIn')
    $fadeIn.toggleClass('fadeIn fadeOut')
    $fadeIn.one 'webkitAnimationEnd mozAnimationEnd MSAnimationEnd oanimationend animationend', ->
      $(this).remove()
  ), 8000


# bug here need a waiting script
current_time = $('#movie_player > div.html5-video-controls > div.html5-player-chrome > span > div.ytp-time-display.html5-control > span.ytp-time-current')
duration = $('#movie_player > div.html5-video-controls > div.html5-player-chrome > span > div.ytp-time-display.html5-control > span.ytp-time-duration')

entries = []
main_video_id = youtube_video.exec(window.location.href)[4]


initalized = false
old_entry = null
locInterval .9, ->
  return unless $("#player-api").length

  # initilization
  video_id = youtube_video.exec(window.location.href)[4]
  if video_id isnt main_video_id
   initalized = false

  if not initalized
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

        if keys_1.length
          $('html').addClass('youtube-social')
        else
          $('html').removeClass('youtube-social')
        async.each keys_1, ((index, outer_next) ->
          entry = entries[index]

          keys_2 = Object.keys(entry)
          async.each keys_2, ((index_2, sub_next) ->
            do =>
              sub_entry = entries[index][index_2]
              {name, text, image_link, total} = sub_entry
              console.log 'THE HELL?'

              # fix image and get the best reply to questions
              async.parallel {
                reply: (inner_next) ->
                  if /\?|song/gi.test(text) and total.yt$replyCount.$t != 0
                    id = total.id.$t.match(/comments(.+)$/)?[1]
                    console.log id, 'ID WOOO'
                    $.getJSON "https://www.googleapis.com/plus/v1/activities#{id}/comments?key=#{youtube_key}", (data) =>
                      sub_entry.reply = data?.items[0]
                      inner_next()
                  else
                    inner_next()
                image_fix: (inner_next) ->
                  $.getJSON "#{image_link}?alt=json", (data) =>
                    sub_entry.image = data?.entry?.media$thumbnail?.url
                    inner_next()
              }, (err, results) ->
                sub_next()

          ), (err, finish) ->
            console.log "WAHT"
            outer_next()
        ), (err, finish) ->
          console.log entries, 'entries'
          $("#player-api > #overlay-wrapper").remove()
          $("#player-api").append teacup.render ( =>
            div '#overlay-wrapper', =>
              div '.images', =>
                for key, entry of entries
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

    $.getJSON "https://www.googleapis.com/youtube/v3/videos?part=statistics&id=#{main_video_id}&key=#{youtube_key}", (data) =>
      comments = Math.max 1000, data?.items[0]?.statistics?.commentCount
      getComments()



  else
    current_seconds = timeToSeconds(current_time.text())
    console.log current_seconds, '3212323'
    new_entry = entries[current_seconds]
    if new_entry and old_entry isnt new_entry
      old_entry = new_entry
      renderComment new_entry

