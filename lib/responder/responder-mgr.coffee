###
  lib/responder/responder.coffee
  Unlike other files in the responder folder this runs in the Atom process
  It provides the interface from atom to the responder process
###

_            = require 'underscore-plus'
Api          = require '../api/api'

module.exports =
class ResponderMgr 
  
  constructor: (@api) ->
    
    for provider in atom.views.providers
      if (TextEditor = provider.modelConstructor).name is 'TextEditor'
        break
    
    @subs = []
    
    @responder = @api.createProcess 'js/responder-process.js', 'atom', 'responder'
    
    @api.recvFromChild @responder, 'responder', (message) ->
      console.log 'DEBUG: received this from the responder process:\n', message
      
    @subs.push atom.workspaceView.eachEditorView (editorView) =>
      if not editorView.attached or editorView.mini then return
      
      @subs.push atom.workspace.onDidChangeActivePaneItem (editor) =>
        if editor instanceof TextEditor
          @api.sendToChild @responder, 
            cmd:    'newEditor'
            path:   editor.getPath()
            text:   editor.getText()
            cursor: editor.getLastCursor().getBufferPosition()
        else
          @api.sendToChild @responder,  cmd: 'noActiveEditor' 
          
      @subs.push editorSub = (editor = editorView.getModel()).onDidChange (evt) =>
        @api.sendToChild @responder, 
          cmd:    'bufferEdit' 
          text:   editor.getTextInBufferRange [[evt.start, 0],[evt.end+1, 0]]
          event:  evt
          cursor: editor.getLastCursor().getBufferPosition()
        
      @subs.push editorView.on 'editor:will-be-removed', -> editorSub.off()
    
  destroy: ->
    @responder.disconnect()
    for subscription in @subs
      subscription.off?()
      subscription.dispose?()
    delete @subs
        