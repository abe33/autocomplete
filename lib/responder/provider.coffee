###
  lib/responder/provider.coffee
###

module.exports =
class Provider
   
  constructor: (@ipc, options) ->
    {providerName: @name, providerPath: @path, @services} = options
    
    @process = @ipc.createProcess @path, 'responder', @name
    
    @ipc.recvFromChild @process, @name, (msg) =>
      switch msg.cmd
        
        when 'taskResults' 
          switch msg.service
            when 'parse'
              @buffer.addScopesToTrie msg.filePath, msg.scopeList
      
  send: (message) -> @ipc.sendToChild @process, message
  
  startTask: (serviceName, @buffer, task) ->
    if (service = @services[serviceName]) and service.grammar in [task.grammar, '*']
      @send {cmd: 'startTask', serviceName, task}
  
  getName: -> @name

  destroy: -> 
    @process.kill 'SIGTERM'
    @process = null
