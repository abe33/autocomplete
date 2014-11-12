###
  lib/responder/provider.coffee
###

pathUtil = require 'util'
{AutocompleteComm} = require 'autocomplete-api'
comm = new AutocompleteComm

module.exports =
class Provider
  
  constructor: (path) ->
    @name = pathUtil.basename path
    @module require path
    
    @child = spawn 'node', [path]
    
    stdoutSub = child.stdout.on 'data', (data) => 
      recvObjs = comm.recvDemuxObj data, (err, line) ->  
        console.log 'provider', @name + ':', line
      for obj in recvObjs then @recv obj
          
    @subs = [stdoutSub]
    comm.handleProcessErrors @subs, child, 'Responder'
    
  send: (msg) ->
    # console.log 'processIO send', msg
    @child.stdin.write JSON.stringify({msg}) + '\n'

  recv: (msg) ->
    console.log 'MSG from provider:', msg

  destroy: ->
    @child.disconnect()
    for subscription in @subs
      subscription.off?()
      subscription.dispose?()
    delete @subs
  
