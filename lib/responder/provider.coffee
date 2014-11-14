###
  lib/responder/provider.coffee
###

module.exports =
class Provider
   
  constructor: (@api, @name, @path) ->
    
    @process = @api.createProcess @path, 'responder', @name
    
    @api.recvFromChild @process, @name, (message) =>
      console.log 'message from provider:', message
  
  getName: -> @name
        
  send: (message) -> @api.sendToChild @process, message

  destroy: -> 
    @process.kill 'SIGTERM'
    @process = null
