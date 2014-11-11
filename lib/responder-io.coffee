###
  lib/responder.coffee
###

fs           = require 'fs'
{spawn}      = require 'child_process'
{TextEditor} = require 'atom'
_            = require 'underscore-plus'

AutocompleteUtils = require '../js/autocomplete-utils'
utils = new AutocompleteUtils

class ProcessIO 
  constructor: ->
    @subs = []
    
    @child = spawn 'node', ['js/responder-process.js']
    @setupChildEvents()
      
    @subs.push atom.workspaceView.eachEditorView (editorView) =>
      if not editorView.attached or editorView.mini then return
      
      atom.workspace.onDidChangeActivePaneItem (editor) =>
        if editor instanceof editor.constructor
          @send
            cmd:    'newEditor' 
            text:   editor.getText()
            cursor: editor.getLastCursor().getBufferPosition()
        else
          @send cmd: 'noActiveEditor' 
          
      editorSub = (editor = editorView.getModel()).onDidChange (evt) =>
        @send
          cmd:    'bufferEdit' 
          text:   editor.getTextInBufferRange [[evt.start, 0],[evt.end+1, 0]]
          event:  evt
          cursor: editor.getLastCursor().getBufferPosition()
        
      @subs.push editorSub
      @subs.push editorView.on 'editor:will-be-removed', -> editorSub.off()

  send: (msg) ->
    # console.log 'processIO send', msg, (Date.now() % 10000)
    @child.stdin.write JSON.stringify({msg}) + '\n'

  recv: (msg) ->
    console.log 'MSG from child:', msg, (Date.now() % 10000)
    
  setupChildEvents: ->
    @subs.push @child.stdout.on 'data', (data) => 
      # console.log 'data from child:', data.toString(), (Date.now() % 10000)
      for res in utils.recvDemuxObj data then @recv res

    # these events should never happen
    @subs.push @child.on 'error', (evt) -> 
      console.log 'process-io responder error:', evt
    @subs.push @child.on 'disconnect', (evt) -> 
      console.log 'process-io responder disconnect:', evt
    @subs.push @child.on 'exit', (evt) -> 
      console.log 'process-io responder exit:', evt
    @subs.push @child.on 'close', (evt) -> 
      console.log 'process-io responder close:', evt
    @subs.push @child.stdout.on 'end', ->
      console.log 'process-io: unexpected stdout end from responder'
    @subs.push @child.stderr.on 'data', (data) ->
      console.log 'process-io: Responder Error', data.toString()
    @subs.push @child.stderr.on 'end', ->
      console.log 'process-io: unexpected stderr end from responder'

  destroy: ->
    @child.disconnect()
    for subscription in @subs
      subscription.off?()
      subscription.dispose?()
    delete @subs
        
new ProcessIO
