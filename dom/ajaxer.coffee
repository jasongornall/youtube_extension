chrome.runtime.onMessage.addListener (request, sender, sendResponse) ->
  base_url = "http://nodejs-questionsapi.rhcloud.com/youtube-api"
  switch request.type
    when 'youtube-comments'
      console.log 'b'
      $.getJSON "#{base_url}/youtube_comments?id=#{request.id}", (data) =>
        sendResponse data
    when 'youtube-stats'
      console.log 'a'
      $.getJSON "#{base_url}/youtube_stats?id=#{request.id}", (data) =>
        sendResponse data
  return true
