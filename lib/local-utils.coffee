###
  lib/utils.coffee
###

_ = require 'underscore-plus'

class LocalUtils
  constructor: -> @partialStreamData = ''
  
  recvDemuxObj: (streamData, child) ->
    lines = streamData.toString().split '\n'
    if lines.length is 1
      @partialStreamData += lines[0]
      return
    else 
      lines[0] = @partialStreamData + lines[0]
      @partialStreamData = _.last lines
      lines = _.initial lines
      
    results = []
    for line in lines when line
      try
        msg = JSON.parse line
      catch err 
        if child then console.log 'CHILD error line:' + '\n', line, '\n', err.message
        else console.log 'PROCIO line:', line
        continue
      results.push msg.msg
    results
    
module.exports = new LocalUtils
