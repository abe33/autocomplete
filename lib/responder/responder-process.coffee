###
  lib/responder/responder-process.coffee
###

_ = require 'underscore-plus'

{AutocompleteComm} = require 'autocomplete-api'
ResponderBuffer    = require './responder-buffer'
comm   = new AutocompleteComm
buffer = new ResponderBuffer

send = (msg) ->
  process.stdout.write JSON.stringify({msg}) + '\n'
   
process.stdin.on 'data', (data) ->
  recvObjs = comm.recvDemuxObj data, (err, line) ->
    console.log 'recv json parse error:' + '\n', line, '\n', err.message
    
  for msg in recvObjs
    # console.log '----', msg.cmd, '----'
    # console.log msg.text.replace(/\n/g, '\\n')[0..80]
    switch msg.cmd
      when 'bufferEdit'     then buffer.applyChg msg
      when 'newEditor'      then buffer = new ResponderBuffer msg.text
      when 'noActiveEditor' then buffer = null
      else console.log 'responder, unknown msg cmd:', msg

    
