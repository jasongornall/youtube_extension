// Generated by CoffeeScript 1.8.0
(function() {
  var a, coffeescript, current_time, div, duration, entries, h1, h3, iframe, img, initalized, input, link, locInterval, main_video_id, old_entry, p, raw, renderComment, script, span, teacup, timeToSeconds, youtube_key, youtube_video;

  youtube_key = 'AIzaSyCOgZXFd0wj49anj5THC0bJva_oNjaBilQ';

  teacup = window.window.teacup;

  span = teacup.span, div = teacup.div, a = teacup.a, h1 = teacup.h1, h3 = teacup.h3, p = teacup.p, iframe = teacup.iframe, raw = teacup.raw, script = teacup.script, coffeescript = teacup.coffeescript, link = teacup.link, input = teacup.input, img = teacup.img;

  youtube_video = /(youtube.com|youtu\.be)\/(watch\?|embed\/|v\/|e\/|)(v=)?([^\#\&\?]*)/i;

  locInterval = function(time, next) {
    return setInterval(next, time * 1000);
  };

  timeToSeconds = function(time) {
    var elements, seconds;
    seconds = 0;
    elements = time.split(':').reverse();
    if (elements[0]) {
      seconds += parseInt(elements[0]);
    }
    if (elements[1]) {
      seconds += parseInt(elements[1]) * 60;
    }
    if (elements[2]) {
      seconds += parseInt(elements[2]) * 60 * 60;
    }
    if (elements[3]) {
      seconds += parseInt(elements[3]) * 24 * 60 * 60;
    }
    return seconds;
  };

  renderComment = (function(_this) {
    return function(data) {
      console.log('render', data);
      return $("#content > #overlay-wrapper").html(teacup.render((function() {
        return div('#overlay-wrapper', function() {
          return div('.comment', function() {
            div(function() {
              var _ref;
              return (_ref = data[0]) != null ? _ref.name : void 0;
            });
            return span(function() {
              var _ref;
              return (_ref = data[0]) != null ? _ref.text : void 0;
            });
          });
        });
      })));
    };
  })(this);

  current_time = $('#movie_player > div.html5-video-controls > div.html5-player-chrome > span > div.ytp-time-display.html5-control > span.ytp-time-current');

  duration = $('#movie_player > div.html5-video-controls > div.html5-player-chrome > span > div.ytp-time-display.html5-control > span.ytp-time-duration');

  entries = [];

  main_video_id = youtube_video.exec(window.location.href)[4];

  initalized = false;

  old_entry = null;

  locInterval(.9, function() {
    var current_seconds, getComments, new_entry, video_id;
    if (!$("#content").length) {
      return;
    }
    video_id = youtube_video.exec(window.location.href)[4];
    if (video_id !== main_video_id) {
      initalized = false;
    }
    if (!initalized) {
      initalized = true;
      console.log('INITIALIZED');
      main_video_id = youtube_video.exec(window.location.href)[4];
      $("#content").prepend(teacup.render(((function(_this) {
        return function() {
          return div('#overlay-wrapper', function() {
            div('.images');
            return div('.comment', function() {
              img({
                src: 'https://gp3.googleusercontent.com/-pmGKuLJC7qU/AAAAAAAAAAI/AAAAAAAAABg/aItmNTS9xEY/s48-c-k-no/photo.jpg'
              });
              return span(function() {
                return 'The stuff he starts playing at 9:47 and onwards. Could someone please give me some advice to learning this style? books?﻿';
              });
            });
          });
        };
      })(this))));
      getComments = (function(_this) {
        return function(num) {
          var calls, count, start_index;
          if (num == null) {
            num = 368;
          }
          calls = [];
          count = 0;
          video_id = 'AJDUHq2mJx0';
          while (num > 0) {
            start_index = (count * 50) + 1;
            calls[count] = "https://gdata.youtube.com/feeds/api/videos/" + main_video_id + "/comments?start-index=" + start_index + "&max-results=50&alt=json";
            num -= 50;
            count++;
          }
          entries = [];
          return async.each(calls, (function(call, next) {
            console.log(call);
            return $.getJSON(call, (function(_this) {
              return function(data) {
                var content, entry, seconds, spot, _i, _len, _ref, _ref1, _ref2, _ref3, _ref4, _ref5, _ref6, _ref7, _ref8;
                console.log('success,data');
                if (!(data != null ? (_ref = data.feed) != null ? (_ref1 = _ref.entry) != null ? _ref1.length : void 0 : void 0 : void 0)) {
                  return next();
                }
                console.log('inside');
                _ref3 = data != null ? (_ref2 = data.feed) != null ? _ref2.entry : void 0 : void 0;
                for (_i = 0, _len = _ref3.length; _i < _len; _i++) {
                  entry = _ref3[_i];
                  content = entry.content.$t;
                  spot = (_ref4 = content.match(/(\d+:[\d:]+)/)) != null ? _ref4[1] : void 0;
                  if (!spot) {
                    continue;
                  }
                  seconds = timeToSeconds(spot);
                  if (entries[seconds] == null) {
                    entries[seconds] = [];
                  }
                  entries[seconds].push({
                    text: (_ref5 = entry.content) != null ? _ref5.$t : void 0,
                    name: (_ref6 = entry.author[0].name) != null ? _ref6.$t : void 0,
                    image_link: (_ref7 = entry.author[0]) != null ? (_ref8 = _ref7.uri) != null ? _ref8.$t : void 0 : void 0,
                    total: entry
                  });
                }
                return next();
              };
            })(this));
          }), function(err, finish) {
            var keys_1;
            keys_1 = Object.keys(entries);
            return async.each(keys_1, (function(index, outer_next) {
              var entry, keys_2;
              entry = entries[index];
              keys_2 = Object.keys(entry);
              return async.each(keys_2, (function(index_2, sub_next) {
                return (function(_this) {
                  return function() {
                    var id, image_link, name, sub_entry, text, total, _ref;
                    sub_entry = entries[index][index_2];
                    name = sub_entry.name, text = sub_entry.text, image_link = sub_entry.image_link, total = sub_entry.total;
                    console.log('THE HELL?');
                    if (text.indexOf('?') !== -1 && total.yt$replyCount.$t !== 0) {
                      id = (_ref = total.id.$t.match(/comments(.+)$/)) != null ? _ref[1] : void 0;
                      console.log(id, 'ID WOOO');
                      return $.getJSON("https://www.googleapis.com/plus/v1/activities" + id + "/comments?key=" + youtube_key, function(data) {
                        sub_entry.reply = data != null ? data.items[0] : void 0;
                        return sub_next();
                      });
                    } else {
                      return sub_next();
                    }
                  };
                })(this)();
              }), function(err, finish) {
                console.log("WAHT");
                return outer_next();
              });
            }), function(err, finish) {
              return console.log(entries, '123', 'WAKKA');
            });
          });
        };
      })(this);
      return getComments();
    } else {
      current_seconds = timeToSeconds(current_time.text());
      console.log(current_seconds, '3212323');
      new_entry = entries[current_seconds];
      if (new_entry && old_entry !== new_entry) {
        old_entry = new_entry;
        return renderComment(new_entry);
      }
    }
  });

}).call(this);
