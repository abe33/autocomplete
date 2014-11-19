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
  
  startParseTasks = (providerIn) ->
    if buffer
      for provider in (if providerIn then [providerIn] else providers)
        provider.startTask 'parse', buffer,
          filePath:    buffer.getPath()
          sourceLines: buffer.getLines()
          grammar:     buffer.getGrammar()
          
  console.log '----', msg.cmd, '----'
  # if msg.text then console.log msg.text.replace(/\n/g, '\\n')[0..80]
    
  switch msg.cmd
    
    when 'register' 
      providers.push (provider = new Provider ipc, options)
      startParseTasks provider
      
    when 'newActiveEditor'      
      # console.log 'newActiveEditor:', msg.title
      buffer = new ResponderBuffer(msg)
      startParseTasks()
      
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