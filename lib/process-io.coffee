###
  lib/process-io.coffee
###

fs         = require 'fs'
{spawn}    = require 'child_process'
_          = require 'underscore-plus'
localUtils = require './local-utils'

class ProcessIO 
  constructor: ->
    @subs = []
    
    @child = spawn 'node', ['child-js/child-process.js']
    @setupChildEvents()
      
    @subs.push atom.workspaceView.eachEditorView (editorView) =>
      if not editorView.attached or editorView.mini then return
      
      editorSub = (editor = editorView.getModel()).onDidChange (evt) =>
        chgObj =
          cmd:    'bufferDidChange' 
          text:   editor.getTextInBufferRange [evt.start, 0, evt.end+1, 0]
          event:  evt
          cursor: editor.getLastCursor().getBufferPosition()
        @send chgObj
        console.log 'process-io buffer change:', chgObj
        
      @subs.push editorSub
      @subs.push editorView.on 'editor:will-be-removed', -> editorSub.off()

  send: (msg) ->
    @child.stdin.write JSON.stringify({msg}) + '\n'

  recv: (msg) ->
    console.log 'MSG from child:', msg
    
  setupChildEvents: ->
    @subs.push @child.stdout.on 'data', (data) => 
      for res in localUtils.recvDemuxObj data then @recv res

    # these events should never happen
    @subs.push @child.on 'error', (evt) -> 
      console.log 'process-io child error:', evt
    @subs.push @child.on 'disconnect', (evt) -> 
      console.log 'process-io child disconnect:', evt
    @subs.push @child.on 'exit', (evt) -> 
      console.log 'process-io child exit:', evt
    @subs.push @child.on 'close', (evt) -> 
      console.log 'process-io child close:', evt
    @subs.push @child.stdout.on 'end', ->
      console.log 'process-io: unexpected stdout end from child'
    @subs.push @child.stderr.on 'data', (data) ->
      console.log 'process-io: unexpected stderr data from child', data.toString()
    @subs.push @child.stderr.on 'end', ->
      console.log 'process-io: unexpected stderr end from child'

  destroy: ->
    @child.disconnect()
    for subscription in @subs
      subscription.off?()
      subscription.dispose?()
    delete @subs
        
new ProcessIO
