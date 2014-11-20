###
  lib/responder/provider.coffee
###

module.exports =
class Provider
  constructor: (@ipc, @responder, registerOptions) ->
    {@providerName, @services} = registerOptions
    @providerProcess = @responder.providerProcess
    @ipc.sendToChild @providerProcess, {cmd: 'register', registerOptions}
      
  sendToProcess: (msg) -> 
    msg.providerName = @providerName
    @ipc.sendToChild @providerProcess, msg
  
  startTask: (task) ->
    @sendToProcess {cmd: 'startTask', task}
    
  recvFromProcess: (msg) ->
    switch msg.cmd
      when 'taskDone'
        {serviceName, meta, results} = msg
        switch serviceName
          when 'parse' 
            @responder.addScopesToTrie meta.filePath, results
  
  getName: -> @providerName
  
  hasService: (serviceName) -> @services[serviceName]?
  
  supportsGrammar: (serviceName, grammar) -> 
    (grammarSpec = @services[serviceName]?.grammar) and
    (grammarSpec is '*' or grammar is grammarSpec)
  