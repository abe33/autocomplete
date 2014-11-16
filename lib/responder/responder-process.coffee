###
  lib/responder/responder-process.coffee
###

ipc             = new (require(process.argv[2]))('responder')
ResponderBuffer = require './responder-buffer'
Provider        = require './provider'
  
buffer = null
providers = []

send = (msg) -> ipc.sendToParent msg

ipc.recvFromParent 'responder', (msg) ->
  if not providers then return
  {options} = msg
   
  console.log '----', msg.cmd, '----'
  # if msg.text then console.log msg.text.replace(/\n/g, '\\n')[0..80]
    
  switch msg.cmd
    when 'register' 
      providers.push (provider = new Provider ipc, options)
      # console.log 'register:', provider.getName(), msg
      if buffer
        console.log 'register startTask parse', 
                     provider.getName(), buffer.getGrammar(), buffer.getText().length
        provider.startTask 'parse', buffer.getGrammar(), source: buffer.getText()
      
    when 'newActiveEditor'      
      # console.log 'newActiveEditor:', msg.title
      buffer = new ResponderBuffer(msg)
      for provider in providers
        console.log 'newActiveEditor startTask parse', 
                     provider.getName(), buffer.getGrammar(), buffer.getText().length
        provider.startTask 'parse', buffer.getGrammar(), source: buffer.getText()
      
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