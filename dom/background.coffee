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
      a '.name', href:"", -> "#{data?.name}"
      span '.description', -> raw data.text
  )
timeoutID = null
renderComment = (data) =>
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
current_time = $('#movie_player > div.html5-video-container > video')
duration = null

entries = []
main_video_id = youtube_video.exec(window.location.href)[4]


initalized = false
finished_loading = false
retryAttempt = null

locInterval .9, ->
  return unless $("#player-api").length
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
        initalized = finished_loading
      else
        console.log 'init succeeded'
    ), 8000

    $("#player-api > #overlay-wrapper").remove()
    $('html').removeClass('youtube-social')
    main_video_id = youtube_video.exec(window.location.href)[4]
    return unless main_video_id
    initalized = true

    getComments = (num) =>
      entries = []
      nextPageToken = null
      calls = [ ]
      for i in [0..5]
        calls.push "https://www.googleapis.com/youtube/v3/commentThreads?part=snippet&order=relevance&maxResults=100&videoId=#{main_video_id}&key=AIzaSyCOgZXFd0wj49anj5THC0bJva_oNjaBilQ"

      async.eachSeries calls, ((call, next) ->


        if nextPageToken
          call += "&pageToken=#{nextPageToken}"

        $.getJSON call, (data) =>
          return next() unless data?.items?.length
          for entry in data?.items
            content = entry.snippet.topLevelComment.snippet.textDisplay
            matches = content.match(/(\d+:[\d:]+)/g)
            spot = matches?[0]
            continue unless spot
            continue if matches?.length > 1
            seconds = timeToSeconds(spot)
            entries[seconds] = {
              text: content
              name: entry.snippet.topLevelComment.snippet.authorDisplayName
              image_link: entry.snippet.topLevelComment.snippet.authorProfileImageUrl
              image: entry.snippet.topLevelComment.snippet.authorProfileImageUrl
              videoId: entry.snippet.videoId
              total: entry
            }
          nextPageToken = data.nextPageToken
          next()

      ), (err, finish) ->
        finished_loading = true
        $("#player-api > #overlay-wrapper").remove()
        $("#player-api").append teacup.render ( =>
          div '#overlay-wrapper', =>
            div '.images', =>
              for key, entry of entries
                continue unless entry
                continue unless entry.videoId is main_video_id
                left = (key / duration) * 100
                if entry.image
                  img_cls = '.image'
                  if left > 100
                    img_cls += '.too-far'
                  div img_cls, 'key':key, style: "left: #{left}%;", ->
                    img src: "#{entry.image}"
                    div '.image-hover', ->
                      img src: "#{entry.image}"
            div '.comment-wrapper', ->
              div '.comment'
              div '.hover-comment'
        )
        # only do this at the end
        if entries.length
          $('html').addClass('youtube-social')
        else
          $('html').removeClass('youtube-social')
        $image = $("#player-api #overlay-wrapper .images > .image")
        $image.mouseenter (e) ->
          $el = $ e.currentTarget
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
    call = "https://www.googleapis.com/youtube/v3/videos?part=contentDetails&id=#{main_video_id}&key=AIzaSyCOgZXFd0wj49anj5THC0bJva_oNjaBilQ"
    $.getJSON call, (data) =>
      YTDurationToSeconds = (dur) ->
        match = dur.match(/PT(\d+H)?(\d+M)?(\d+S)?/)
        hours = parseInt(match[1]) or 0
        minutes = parseInt(match[2]) or 0
        seconds = parseInt(match[3]) or 0
        hours * 3600 + minutes * 60 + seconds
      duration = YTDurationToSeconds data?.items?[0]?.contentDetails?.duration
      if duration
        getComments()



  else
    current_seconds = Math.floor(current_time[0].currentTime)
    current_seconds = 0 if $('.videoAdUiBottomBar').length
    new_entry = entries[current_seconds]
    if new_entry and old_entry isnt new_entry
      old_entry = new_entry
      renderComment new_entry

