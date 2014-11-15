###
  lib/responder/responder-process.coffee
###

api             = new (require(process.argv[2]))('responder')
ResponderBuffer = require './responder-buffer'
Provider        = require './provider'
  
buffer = null
providers = []

send = (msg) -> api.sendToParent msg

api.recvFromParent 'responder', (msg) ->
  if not providers then return
  {options} = msg
   
  console.log '----', msg.cmd, '----'
  # if msg.text then console.log msg.text.replace(/\n/g, '\\n')[0..80]
    
  switch msg.cmd
    when 'register' 
      providers.push new Provider api, options.providerName, options.providerPath
      
    when 'newActiveEditor'      
      console.log 'Editor:', msg.title
      buffer = new ResponderBuffer(msg.text)
      
    when 'bufferEdit'     
      if not buffer 
        console.log 'Received bufferEdit command when no buffer'
        return
      buffer.applyChg msg
       
    when 'noActiveEditor' 
      buffer = null
      
    when 'kill' 
      for provider in providers
        console.log 'Killing', provider.getName()
        provider.destroy()
      providers = null
      setTimeout (->process.exit 0), 300
      
    else console.log 'responder, unknown command:', msg
      
console.log 'hello'