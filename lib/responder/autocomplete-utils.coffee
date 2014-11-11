###
  lib/responder/autocomplete-utils.coffee
###

_ = require 'underscore-plus'

module.exports =
class AutocompleteUtils
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
    for line in lines
      try
        msg = JSON.parse line
      catch err 
        if child then console.log 'recv json parse error:' + '\n', line, '\n', err.message
        else console.log 'RESPONDER:', line
        continue
      results.push msg.msg
    results
