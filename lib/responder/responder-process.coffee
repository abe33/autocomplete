###
  lib/responder/responder-process.coffee
###

jsPath = process.argv[2]
 
ipc             = new (require(jsPath + '/ipc.js'))('responder')
ResponderBuffer = require './responder-buffer'
Provider        = require './provider'
  
buffer    = null
killed    = no
providers = {}

# todo -- change this to a singleton class?
responder = {}

responder.providerProcess = providerProcess = 
  ipc.createProcess jsPath+'/provider-process.js', 'responder', 'provider'

sendToAtom = (msg) -> ipc.sendToParent msg

ipc.recvFromParent 'responder', (msg) ->
  if killed then return
  
  startParseTask = (provider) ->
    if provider.supportsGrammar 'parse', buffer.getGrammar()
      provider.startTask
        serviceName: 'parse'
        sourceLines:  buffer.getLines()
        meta: 
          filePath: buffer.getPath()
  
  # console.log '----', msg.cmd, '----'
  # if msg.text then console.log msg.text.replace(/\n/g, '\\n')[0..80]
  
  switch msg.cmd
    
    when 'register' 
      provider = new Provider ipc, responder, msg.options
      providers[msg.options.providerName] = provider
      if buffer then startParseTask provider

    when 'newActiveEditor'      
      # console.log 'newActiveEditor:', msg.title
      buffer = new ResponderBuffer(msg, sendToAtom)
      for providerName, provider of providers
        startParseTask provider
      
    when 'bufferEdit'
      if not buffer 
        console.log 'Received bufferEdit command when no buffer'
        return
      buffer.onBufferChange msg
       
    when 'noActiveEditor' 
      buffer = null
      
    when 'kill' 
      providerProcess.kill 'SIGTERM'
      killed = true
      setTimeout (->process.exit 0), 1000
      
    else console.log 'responder, unknown command:', msg

ipc.recvFromChild providerProcess, 'provider', (msg) ->
    providers[msg.providerName].recvFromProcess msg
    
responder.addScopesToTrie = (filePath, scopeList) ->
  buffer?.addScopesToTrie filePath, scopeList

console.log 'hello'