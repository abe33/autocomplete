###
  lib/responder/responder-process.coffee
###

api      = new (require(process.argv[2]))('responder')
buffer   = new (require('./responder-buffer'))
Provider = require './provider'

providers = []

send = (msg) -> api.sendToParent msg

api.recvFromParent 'responder', (msg) ->
  if not providers then return
  
  console.log '----', msg.cmd, '----'
  # if msg.text then console.log msg.text.replace(/\n/g, '\\n')[0..80]
  switch msg.cmd
    when 'register' then providers.push new Provider api, 
                         msg.options.providerName, msg.options.providerPath
    when 'newEditor'      then buffer = new ResponderBuffer msg.text
    when 'bufferEdit'     then buffer.applyChg msg
    when 'noActiveEditor' then buffer = null
    when 'kill' 
      for provider in providers
        console.log 'Killing', provider.getName()
        provider.destroy()
      providers = null
      setTimeout (->process.exit 0), 300
    else console.log 'responder, unknown msg cmd:', msg
      
console.log 'hello'