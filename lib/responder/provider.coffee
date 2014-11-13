###
  lib/responder/provider.coffee
###


module.exports =
class Provider
  
  constructor: (@api, @name, @path) ->
    @process = @api.createProcess @path, 'responder', 'provider ' + @name
    
    @api.recvFromChild @process, 'provider ' + @name, (message) =>
      console.log 'message from provider:', message
        
  send: (message) -> @api.sendToChild @process, message

  destroy: -> @process.disconnect()
  
