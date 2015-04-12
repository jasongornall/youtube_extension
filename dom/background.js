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
      return $("#player-api > #overlay-wrapper > .comment").html(teacup.render((function() {
        var _ref, _ref1, _ref2;
        span(function() {
          var _ref;
          return (_ref = data[0]) != null ? _ref.name : void 0;
        });
        span(function() {
          var _ref;
          return (_ref = data[0]) != null ? _ref.text : void 0;
        });
        if ((_ref = data[0]) != null ? (_ref1 = _ref.reply) != null ? (_ref2 = _ref1.object) != null ? _ref2.content : void 0 : void 0 : void 0) {
          return div(function() {
            var _ref3, _ref4, _ref5;
            return raw("answer: " + ((_ref3 = data[0]) != null ? (_ref4 = _ref3.reply) != null ? (_ref5 = _ref4.object) != null ? _ref5.content : void 0 : void 0 : void 0));
          });
        }
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
    if (!$("#player-api").length) {
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
      getComments = (function(_this) {
        return function(num) {
          var calls, count, start_index;
          if (num == null) {
            num = 368;
          }
          calls = [];
          count = 0;
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
                    var image_link, name, sub_entry, text, total;
                    sub_entry = entries[index][index_2];
                    name = sub_entry.name, text = sub_entry.text, image_link = sub_entry.image_link, total = sub_entry.total;
                    console.log('THE HELL?');
                    return async.parallel({
                      reply: function(inner_next) {
                        var id, _ref;
                        if (/\?|song/gi.test(text) && total.yt$replyCount.$t !== 0) {
                          id = (_ref = total.id.$t.match(/comments(.+)$/)) != null ? _ref[1] : void 0;
                          console.log(id, 'ID WOOO');
                          return $.getJSON("https://www.googleapis.com/plus/v1/activities" + id + "/comments?key=" + youtube_key, (function(_this) {
                            return function(data) {
                              sub_entry.reply = data != null ? data.items[0] : void 0;
                              return inner_next();
                            };
                          })(this));
                        } else {
                          return inner_next();
                        }
                      },
                      image_fix: function(inner_next) {
                        return $.getJSON("" + image_link + "?alt=json", (function(_this) {
                          return function(data) {
                            var _ref, _ref1;
                            sub_entry.image = data != null ? (_ref = data.entry) != null ? (_ref1 = _ref.media$thumbnail) != null ? _ref1.url : void 0 : void 0 : void 0;
                            return inner_next();
                          };
                        })(this));
                      }
                    }, function(err, results) {
                      return sub_next();
                    });
                  };
                })(this)();
              }), function(err, finish) {
                console.log("WAHT");
                return outer_next();
              });
            }), function(err, finish) {
              var $image;
              console.log(entries, 'entries');
              $("#player-api > #overlay-wrapper").remove();
              $("#player-api").append(teacup.render(((function(_this) {
                return function() {
                  return div('#overlay-wrapper', function() {
                    div('.images', function() {
                      var entry, key, left, _results;
                      _results = [];
                      for (key in entries) {
                        entry = entries[key];
                        left = (key / timeToSeconds(duration.text())) * 100;
                        if (entry[0].image) {
                          _results.push(div('.image', {
                            'key': key,
                            style: "left: " + left + "%;"
                          }, function() {
                            img({
                              src: "" + entry[0].image
                            });
                            return div('.image-hover', function() {
                              return img({
                                src: "" + entry[0].image
                              });
                            });
                          }));
                        } else {
                          _results.push(void 0);
                        }
                      }
                      return _results;
                    });
                    return div('.comment-wrapper', function() {
                      div('.comment');
                      return div('.hover-comment');
                    });
                  });
                };
              })(this))));
              $image = $("#player-api #overlay-wrapper .images > .image");
              $image.mouseenter(function(e) {
                var $el, $hover, data;
                $el = $(e.currentTarget);
                console.log($el.attr('key'), "THIS IS THE KEY");
                data = entries[$el.attr('key')];
                $hover = $el.closest('#overlay-wrapper').find('.hover-comment');
                return $hover.html(teacup.render(((function(_this) {
                  return function() {
                    var _ref, _ref1, _ref2;
                    span(function() {
                      var _ref;
                      return (_ref = data[0]) != null ? _ref.name : void 0;
                    });
                    span(function() {
                      var _ref;
                      return (_ref = data[0]) != null ? _ref.text : void 0;
                    });
                    if ((_ref = data[0]) != null ? (_ref1 = _ref.reply) != null ? (_ref2 = _ref1.object) != null ? _ref2.content : void 0 : void 0 : void 0) {
                      return div(function() {
                        var _ref3, _ref4, _ref5;
                        return raw("answer: " + ((_ref3 = data[0]) != null ? (_ref4 = _ref3.reply) != null ? (_ref5 = _ref4.object) != null ? _ref5.content : void 0 : void 0 : void 0));
                      });
                    }
                  };
                })(this))));
              });
              return $image.mouseleave(function(e) {
                var $el, $hover;
                $el = $(e.currentTarget);
                $hover = $el.closest('#overlay-wrapper').find('.hover-comment');
                return $hover.empty();
              });
            });
          });
        };
      })(this);
      return $.getJSON("https://www.googleapis.com/youtube/v3/videos?part=statistics&id=" + main_video_id + "&key=" + youtube_key, (function(_this) {
        return function(data) {
          var _ref, _ref1;
          return getComments(data != null ? (_ref = data.items[0]) != null ? (_ref1 = _ref.statistics) != null ? _ref1.commentCount : void 0 : void 0 : void 0);
        };
      })(this));
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
