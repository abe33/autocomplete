###
  lib/responder/responder-process.coffee
###

Api             = require process.argv[2]
Provider        = require './provider'
ResponderBuffer = require './responder-buffer'

api    = new Api
buffer = new ResponderBuffer
providers = []

send = (msg) -> api.sendToParent msg

api.recvFromParent 'responder', (msg) ->
  console.log '----', msg.cmd, '----'
  # if msg.text then console.log msg.text.replace(/\n/g, '\\n')[0..80]
  switch msg.cmd
    when 'register'       then providers.push new Provider api, msg.name, msg.path
    when 'newEditor'      then buffer = new ResponderBuffer msg.text
    when 'bufferEdit'     then buffer.applyChg msg
    when 'noActiveEditor' then buffer = null
    else console.log 'responder, unknown msg cmd:', msg

console.log 'hello from responder process'