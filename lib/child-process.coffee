###
  lib/child-process.coffee
###

_ = require 'underscore-plus'

localUtils = require './local-utils'

send = (msg) ->
  process.stdout.write JSON.stringify({msg}) + '\n'
  
recv = (msg) -> console.log 'MSG to child:', msg

process.stdin.on 'data', (data) ->
  for obj in localUtils.recvDemuxObj data, yes then recv obj
  
send 'child-process spawned'
