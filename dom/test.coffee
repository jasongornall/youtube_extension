require './async.min.js'
require './jquery.min.js'


getComments = (num = 368) =>
  calls = []
  count = 0
  video_id = 'AJDUHq2mJx0'

  while num > 0
    start_index = (count * 50) + 1
    calls[count] = "https://gdata.youtube.com/feeds/api/videos/AJDUHq2mJx0/comments?start-index=#{start_index}&max-results=50"
    num -= 50
    count++
    break

  async.map calls, ((call, done) ->
    console.log call, '213'
    $.ajax {
      url: call
      dataType: "xml"
      success: (data) =>
        $(data).find('entry').each (index, el) =>
          $el = $(el)
          data = {
            data_url: "http://gdata.youtube.com/feeds/api/users/#{$el.find('yt:channelId').text()}?fields=yt:username,media:thumbnail,title"
            comment: $el.find('content[type="text"]').text()
          }
    }
  ), (err, finish) ->
    console.log finish, '123'

getComments()
