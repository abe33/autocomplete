###
  lib/responder/provider.coffee
###

module.exports =
class Provider
   
  constructor: (@api, options) ->
    services = []
    {providerName: @name, providerPath: @path, @services} = options
    
    @process = @api.createProcess @path, 'responder', @name
    
    @api.recvFromChild @process, @name, (message) =>
      switch message.cmd
        when 'registerService' then services.push message.serviceName
      
  send: (message) -> @api.sendToChild @process, message
  
  startTask: (serviceName, grammar, task) ->
    if (service = @services[serviceName]) and service.grammar is grammar
      console.log 'provider startTask', @name, serviceName
      @send {cmd: 'startTask', serviceName, task}
  
  getName: -> @name

  destroy: -> 
    @process.kill 'SIGTERM'
    @process = null
