
timeToSeconds = (time = "02:58 xDDD﻿") ->
  seconds = 0
  elements = time.split(':').reverse()
  seconds += parseInt(elements[0]) if elements[0]
  seconds += parseInt(elements[1]) * 60 if elements[1]
  seconds += parseInt(elements[2]) * 60 * 60 if elements[2]
  seconds += parseInt(elements[3]) * 24 * 60 * 60 if elements[3]
  return seconds

console.log timeToSeconds()
