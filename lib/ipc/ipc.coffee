###
  lib/ipc/ipc.coffee
  ipc means "Inter Process Communications"
  This is required in every process including the main Atom process
###
 
{spawn} = require 'child_process'
_       = require 'underscore-plus'
jsPath  = require('path').normalize __dirname, '../../js'

module.exports =
class Ipc
  
  constructor: (@name)->
    process.stdin.resume();
    process.on 'SIGTERM', => 
      if @name then console.log 'Exiting', @name + 'process'
      process.exit 0
      @childProcessTerminated = yes
    @subs = []    
    
  createProcess: (path, parentName, childName) ->
    
    childProcess = spawn 'node', [path, jsPath]
    
    procEvt = (src, event, msg) =>
      msg ?= event
      @subs.push src.on event, (data) ->
        console.log parentName, 'received process', msg, 'from', 
          (if data then [childName + ':', data.toString()] \
                   else [childName])...
    
    procEvt childProcess,        'error'
    procEvt childProcess,        'message'
    procEvt childProcess,        'disconnect'
    procEvt childProcess,        'close'
    procEvt childProcess.stderr, 'data', 'stderr'
    # procEvt childProcess,        'exit'
    # procEvt childProcess.stdout, 'end',  'stdout end'
    # procEvt childProcess.stderr, 'end',  'stderr end'
    
    childProcess
  
  demuxMessages: (data, partialData, badParseMsg) ->
    lines = data.toString().split '\n'
    if lines.length is 1
      partialData += lines[0]
      return [partialData, []]
    lines[0] = partialData + lines[0]
    partialData = _.last lines
    lines = _.initial lines
    msgs = []
    for line in lines
      try
        msg = JSON.parse line
      catch err 
        console.log badParseMsg + ':', line
        continue
      msgs.push msg.msg
    [partialData, msgs]
  
  recvFromParent: (parentName, callback) ->
    partialData = ''
    @subs.push process.stdin.on 'data', (data) =>
      [partialData, msgs] = @demuxMessages data, partialData, 
        'ipc parse error from parent process', parentName
      for msg in msgs then callback msg 

  recvFromChild: (childProcess, processName, callback) ->
    partialData = ''
    @subs.push childProcess.stdout.on 'data', (data) => 
      [partialData, msgs] = @demuxMessages data, partialData, 
        processName.toUpperCase()
      for msg in msgs then callback msg 

  sendToParent: (msg) ->
    try
      process.stdout.write JSON.stringify({msg}) + '\n'
    catch e
      console.log 'ipc sendToParent error', e.message
    
  sendToChild: (childProcess, msg) ->
    if @childProcessTerminated then return
    try
      childProcess.stdin.write JSON.stringify({msg}) + '\n'
    catch e
      console.log 'ipc sendToChild error', e.message

  destroy: ->
    for subscription in @subs
      subscription.off?()
      subscription.dispose?()
    delete @subs

