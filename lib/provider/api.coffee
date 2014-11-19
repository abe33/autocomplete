###
  lib/provider/api.coffee
  
  This is only used by providers
###

_ = require 'underscore-plus'

ipc   = new (require(process.argv[2]))('api')
Scope = require './scope'

module.exports =
class Api 
  constructor: (@name)->    
  
  on: (serviceName, callback) ->
    if not @serviceCallbacks
      @serviceCallbacks = {}
      
      ipc.recvFromParent 'responder', (msg) =>
        switch msg.cmd
          when 'startTask' then @serviceCallbacks[msg.serviceName] msg.task
          else console.log 'unknown command from responder', msg
            
    @serviceCallbacks[serviceName] = callback
    
  getScopeClass: -> Scope
    
  taskResults: (results) -> 
    ipc.sendToParent _.extend results, cmd: 'taskResults'
    
