// Generated by CoffeeScript 1.8.0
(function() {
  var a, coffeescript, commentTemplate, current_time, div, duration, entries, finished_loading, h1, h3, iframe, img, initalized, input, link, locInterval, main_video_id, old_entry, p, raw, renderComment, retryAttempt, script, span, teacup, timeToSeconds, timeoutID, youtube_video;

  teacup = window.window.teacup;

  span = teacup.span, div = teacup.div, a = teacup.a, h1 = teacup.h1, h3 = teacup.h3, p = teacup.p, iframe = teacup.iframe, raw = teacup.raw, script = teacup.script, coffeescript = teacup.coffeescript, link = teacup.link, input = teacup.input, img = teacup.img;

  old_entry = null;

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

  commentTemplate = (function(_this) {
    return function(data) {
      return teacup.render((function() {
        return div('.animated fadeIn', function() {
          var _ref, _ref1, _ref2, _ref3, _ref4, _ref5;
          a('.name', {
            href: "/channel/" + ((_ref = data[0]) != null ? (_ref1 = _ref.total) != null ? (_ref2 = _ref1.yt$channelId) != null ? _ref2.$t : void 0 : void 0 : void 0)
          }, function() {
            var _ref3;
            return "" + ((_ref3 = data[0]) != null ? _ref3.name : void 0);
          });
          span('.description', function() {
            var _ref3;
            return (_ref3 = data[0]) != null ? _ref3.text : void 0;
          });
          if ((_ref3 = data[0]) != null ? (_ref4 = _ref3.reply) != null ? (_ref5 = _ref4.object) != null ? _ref5.content : void 0 : void 0 : void 0) {
            return div('.reply', function() {
              span('.name', function() {
                var _ref6, _ref7, _ref8;
                return "" + ((_ref6 = data[0]) != null ? (_ref7 = _ref6.reply) != null ? (_ref8 = _ref7.actor) != null ? _ref8.displayName : void 0 : void 0 : void 0) + ": ";
              });
              return span(function() {
                var _ref6, _ref7, _ref8;
                return raw("" + ((_ref6 = data[0]) != null ? (_ref7 = _ref6.reply) != null ? (_ref8 = _ref7.object) != null ? _ref8.content : void 0 : void 0 : void 0));
              });
            });
          }
        });
      }));
    };
  })(this);

  timeoutID = null;

  renderComment = (function(_this) {
    return function(data) {
      var $comment;
      $comment = $("#player-api > #overlay-wrapper .comment");
      $comment.html(commentTemplate(data));
      if (timeoutID) {
        clearTimeout(timeoutID);
      }
      return timeoutID = setTimeout((function() {
        var $fadeIn;
        $fadeIn = $comment.find('.fadeIn');
        $fadeIn.toggleClass('fadeIn fadeOut');
        return $fadeIn.one('webkitAnimationEnd mozAnimationEnd MSAnimationEnd oanimationend animationend', function() {
          $(this).remove();
          return old_entry = null;
        });
      }), 8000);
    };
  })(this);

  current_time = $('#movie_player > div.html5-video-controls > div.html5-player-chrome > span > div.ytp-time-display.html5-control > span.ytp-time-current');

  duration = $('#movie_player > div.html5-video-controls > div.html5-player-chrome > span > div.ytp-time-display.html5-control > span.ytp-time-duration');

  entries = [];

  main_video_id = youtube_video.exec(window.location.href)[4];

  initalized = false;

  finished_loading = false;

  retryAttempt = null;

  locInterval(.9, function() {
    var current_seconds, getComments, new_entry, video_id;
    if (!$("#player-api").length) {
      return;
    }
    if (!duration.length) {
      return;
    }
    if (!current_time.length) {
      return;
    }
    video_id = youtube_video.exec(window.location.href)[4];
    if (video_id !== main_video_id) {
      initalized = false;
    }
    if (!initalized) {
      if (retryAttempt) {
        clearTimeout(retryAttempt);
      }
      retryAttempt = setTimeout((function() {
        if (finished_loading === false) {
          console.log('init failed trying again');
          return initalized = finished_loading;
        } else {
          return console.log('init succeeded');
        }
      }), 8000);
      $("#player-api > #overlay-wrapper").remove();
      $('html').removeClass('youtube-social');
      initalized = true;
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
            return $.getJSON(call, (function(_this) {
              return function(data) {
                var content, entry, matches, seconds, spot, _i, _len, _ref, _ref1, _ref2, _ref3, _ref4, _ref5, _ref6, _ref7;
                if (!(data != null ? (_ref = data.feed) != null ? (_ref1 = _ref.entry) != null ? _ref1.length : void 0 : void 0 : void 0)) {
                  return next();
                }
                _ref3 = data != null ? (_ref2 = data.feed) != null ? _ref2.entry : void 0 : void 0;
                for (_i = 0, _len = _ref3.length; _i < _len; _i++) {
                  entry = _ref3[_i];
                  content = entry.content.$t;
                  matches = content.match(/(\d+:[\d:]+)/g);
                  spot = matches != null ? matches[0] : void 0;
                  if (!spot) {
                    continue;
                  }
                  if ((matches != null ? matches.length : void 0) > 1) {
                    continue;
                  }
                  seconds = timeToSeconds(spot);
                  if (entries[seconds] == null) {
                    entries[seconds] = [];
                  }
                  entries[seconds].push({
                    text: (_ref4 = entry.content) != null ? _ref4.$t : void 0,
                    name: (_ref5 = entry.author[0].name) != null ? _ref5.$t : void 0,
                    image_link: (_ref6 = entry.author[0]) != null ? (_ref7 = _ref6.uri) != null ? _ref7.$t : void 0 : void 0,
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
                    return async.parallel({
                      reply: function(inner_next) {
                        var id, _ref;
                        if (/\?|song/gi.test(text) && total.yt$replyCount.$t !== 0) {
                          sub_entry.type = 'reply';
                          id = (_ref = total.id.$t.match(/comments\/(.+)$/)) != null ? _ref[1] : void 0;
                          return chrome.runtime.sendMessage({
                            id: id,
                            type: 'youtube-comments'
                          }, function(data) {
                            sub_entry.reply = data != null ? data.items[0] : void 0;
                            return inner_next();
                          });
                        } else {
                          sub_entry.type = 'message';
                          return inner_next();
                        }
                      },
                      image_fix: function(inner_next) {
                        return $.ajax({
                          url: "" + image_link + "?alt=json",
                          dataType: 'json',
                          success: (function(_this) {
                            return function(data) {
                              var _ref, _ref1;
                              sub_entry.image = data != null ? (_ref = data.entry) != null ? (_ref1 = _ref.media$thumbnail) != null ? _ref1.url : void 0 : void 0 : void 0;
                              return inner_next();
                            };
                          })(this),
                          error: function(data) {
                            return inner_next();
                          }
                        });
                      }
                    }, function(err, results) {
                      return sub_next();
                    });
                  };
                })(this)();
              }), function(err, finish) {
                return outer_next();
              });
            }), function(err, finish) {
              var $image;
              finished_loading = true;
              $("#player-api > #overlay-wrapper").remove();
              $("#player-api").append(teacup.render(((function(_this) {
                return function() {
                  return div('#overlay-wrapper', function() {
                    div('.images', function() {
                      var entry, key, left, _results;
                      _results = [];
                      for (key in entries) {
                        entry = entries[key];
                        if (!entry) {
                          continue;
                        }
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
              if (keys_1.length) {
                $('html').addClass('youtube-social');
              } else {
                $('html').removeClass('youtube-social');
              }
              $image = $("#player-api #overlay-wrapper .images > .image");
              $image.mouseenter(function(e) {
                var $el, $hover, data;
                $el = $(e.currentTarget);
                data = entries[$el.attr('key')];
                $hover = $el.closest('#overlay-wrapper').find('.hover-comment');
                $hover.html(commentTemplate(data));
                return $hover.siblings('.comment').hide();
              });
              return $image.mouseleave(function(e) {
                var $el, $fadeIn, $hover;
                $el = $(e.currentTarget);
                $hover = $el.closest('#overlay-wrapper').find('.hover-comment');
                $fadeIn = $hover.find('.fadeIn');
                $fadeIn.toggleClass('fadeIn fadeOut');
                return $fadeIn.one('webkitAnimationEnd mozAnimationEnd MSAnimationEnd oanimationend animationend', function() {
                  $(this).remove();
                  return $hover.siblings('.comment').show();
                });
              });
            });
          });
        };
      })(this);
      return chrome.runtime.sendMessage({
        id: main_video_id,
        type: 'youtube-stats'
      }, function(data) {
        var comments, _ref, _ref1;
        comments = Math.max(1000, data != null ? (_ref = data.items[0]) != null ? (_ref1 = _ref.statistics) != null ? _ref1.commentCount : void 0 : void 0 : void 0);
        return getComments();
      });
    } else {
      current_seconds = timeToSeconds(current_time.text());
      new_entry = entries[current_seconds];
      if (new_entry && old_entry !== new_entry) {
        old_entry = new_entry;
        return renderComment(new_entry);
      }
    }
  });

}).call(this);
