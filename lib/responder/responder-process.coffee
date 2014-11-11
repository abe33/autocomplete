###
  lib/responder/responder-process.coffee
###

_ = require 'underscore-plus'

AutocompleteUtils = require '../js/autocomplete-utils'
ResponderBuffer   = require '../js/responder-buffer'
utils  = new AutocompleteUtils
buffer = new ResponderBuffer

send = (msg) ->
  process.stdout.write JSON.stringify({msg}) + '\n'
   
recv = (msg) -> 
  console.log '----', msg.cmd, '----'
  console.log msg.text.replace /\n/g, '\\n'
  switch msg.cmd
    when 'bufferEdit'     then buffer.applyChg msg
    when 'newEditor'      then buffer = new ResponderBuffer msg.text
    when 'noActiveEditor' then buffer = null
    else console.log 'responder, unknown msg cmd:', msg

process.stdin.on 'data', (data) ->
  for obj in utils.recvDemuxObj data, yes then recv obj

send 'child-process spawned'
