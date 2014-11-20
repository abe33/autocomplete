###
  lib/provider/api.coffee
  
  This is only used by providers
###

Scope = require './scope'

module.exports =
class Api 
  constructor: (@ipc, registerOptions)-> 
    @serviceCallbacks = {}
    @providerName  = registerOptions.providerName
    providerModule = require registerOptions.providerPath
    providerModule.initialize this 
    console.log @providerName, 'initialized'
    
  getScopeClass: -> Scope
    
  on: (serviceName, callback) ->
    console.log @providerName, 'subscribed to', serviceName
    @serviceCallbacks[serviceName] = callback
  
  recvFromResponder: (msg) ->
    switch msg.cmd
      when 'startTask' 
        if (callback = @serviceCallbacks[msg.task.serviceName])
          callback msg.task
      else console.log 'unknown command from responder', msg

  taskDone: (task) -> 
    @ipc.sendToParent
      cmd:         'taskDone'
      providerName: @providerName
      serviceName:  task.serviceName
      meta:         task.meta
      results:      task.results
      
