chrome.runtime.onMessage.addListener (request, sender, sendResponse) ->
  base_url = "http://nodejs-questionsapi.rhcloud.com/youtube-api"
  switch request.type
    when 'youtube-comments'
      $.getJSON "#{base_url}/youtube_comments?id=#{request.id}", (data) =>
        sendResponse data
    when 'youtube-stats'
      $.getJSON "#{base_url}/youtube_stats?id=#{request.id}", (data) =>
        sendResponse data
  return true
