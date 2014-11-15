###
  lib/responder/responder.coffee
  Unlike other files in the responder folder this runs in the Atom process
  It provides the interface from atom to the responder process
###

_   = require 'underscore-plus'
Api = require '../api/api'

module.exports =
class ResponderMgr 
  
  constructor: (@api) ->
    {TextEditorView} = require 'atom'
    TextEditor = new TextEditorView({}).getEditor().constructor
    @subs = []
    
    execPath = require('path').resolve __dirname, '../../js/responder-process.js'
    @responder = @api.createProcess execPath, 'atom', 'responder'
    
    @api.recvFromChild @responder, 'responder', (message) ->
      console.log 'DEBUG: received this from the responder process:\n', message
      
    setActiveEditorCmd = (editor) =>
        if editor instanceof TextEditor
          if editor isnt @currentEditor
            @currentEditor = editor
            @api.sendToChild @responder, 
              cmd:    'newActiveEditor'
              title:   editor.getTitle()
              path:    editor.getPath()
              text:    editor.getText()
              grammar: editor.getGrammar().scopeName
              cursor:  editor.getLastCursor().getBufferPosition()
        else if @currentEditor
          @api.sendToChild @responder, cmd: 'noActiveEditor' 
          @currentEditor = null
      
    @subs.push atom.workspaceView.eachEditorView (editorView) =>
      if not editorView.attached or editorView.mini then return
      editor = editorView.getModel()
      
      # todo
      # grammar.onDidUpdate(callback) 
      # editor.observeGrammar(callback) 
      # editor.onDidChangeGrammar(callback) 
      # editor.onDidDestroy(callback) 
      
      if editorView.getPaneView().is '.active' then setActiveEditorCmd editor
      
      @subs.push atom.workspace.onDidChangeActivePaneItem setActiveEditorCmd
          
      @subs.push editorSub = editor.onDidChange (evt) =>
        @api.sendToChild @responder, 
          cmd:    'bufferEdit' 
          text:   editor.getTextInBufferRange [[evt.start, 0],[evt.end+1, 0]]
          event:  evt
          cursor: editor.getLastCursor().getBufferPosition()
        
      @subs.push editorView.on 'editor:will-be-removed', -> editorSub.off()
      
  registerProvider: (options) ->
    version = require('../../package.json').version
    if not require('semver').satisfies version, options.autocompleteVersion
      console.log 'The package at', options.modulePath, 
                  'requires autocomplete package version', options.autocompleteVersion,
                  'but this version is', version
      return
    @api.sendToChild @responder, {cmd: 'register', options}
  
  destroy: ->
    @api.sendToChild @responder, cmd: 'kill'
    @api.destroy()
    for subscription in @subs
      subscription.off?()
      subscription.dispose?()
    delete @subs
  