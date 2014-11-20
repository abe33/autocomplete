###
  lib/responder-interface.coffee
  this runs in the Atom process
  It provides the interface from atom to the responder process
###
 
_        = require 'underscore-plus'
ipc      = new (require('../js/ipc'))
pathUtil = require('path')

module.exports =
class ResponderInterface
  
  constructor: ->
    {TextEditorView} = require 'atom'
    TextEditor = new TextEditorView({}).getEditor().constructor
    @subs = []
    
    execPath = pathUtil.resolve __dirname, '../js/responder-process.js'
    @responderProcess = ipc.createProcess execPath, 'atom', 'responder'
    
    setActiveEditor = (editor) =>
        if editor instanceof TextEditor
          if editor isnt @currentEditor
            @currentEditor = editor
            ipc.sendToChild @responderProcess, 
              cmd:    'newActiveEditor'
              title:   editor.getTitle()
              path:    editor.getPath()
              text:    editor.getText()
              grammar: editor.getGrammar().scopeName
              cursor:  editor.getLastCursor().getBufferPosition()
        else if @currentEditor
          ipc.sendToChild @responderProcess, cmd: 'noActiveEditor' 
          @currentEditor = null
      
    @subs.push atom.workspaceView.eachEditorView (editorView) =>
      if not editorView.attached or editorView.mini then return
      editor = editorView.getModel()
      
      # require('fs').writeFileSync __dirname + '/grmr.txt', 
      #               require('util').inspect editor.getGrammar(), depth: 99

      # todo
      # grammar.onDidUpdate(callback) 
      # editor.observeGrammar(callback) 
      # editor.onDidChangeGrammar(callback) 
      # editor.onDidDestroy(callback) 
      
      if editorView.getPaneView().is '.active' then setActiveEditor editor
      
      @subs.push atom.workspace.onDidChangeActivePaneItem setActiveEditor
          
      @subs.push editorSub = editor.onDidChange (evt) =>
        ipc.sendToChild @responderProcess, 
          cmd:    'bufferEdit'
          text:   editor.getTextInBufferRange [[evt.start, 0],[evt.end+1, 0]]
          event:  evt
          cursor: editor.getLastCursor().getBufferPosition()
        
      @subs.push editorView.on 'editor:will-be-removed', -> editorSub.off()
      
    ipc.recvFromChild @responderProcess, 'responder', (msg) =>
      # console.log 'autocomplete: received a message from the responder:\n', msg
      switch msg.cmd
        when 'suggestionList'
          console.log 'Suggestion list for view ...\n', 
                       require('util').inspect msg.list, depth: null

  registerProvider: (options) ->
    version = require('../package.json').version
    if not require('semver').satisfies version, options.autocompleteVersion
      console.log 'The package at', options.modulePath, 
                  'requires autocomplete package version', options.autocompleteVersion,
                  'but this version is', version
      return
    ipc.sendToChild @responderProcess, {cmd: 'register', options}
  
  destroy: ->
    ipc.sendToChild @responderProcess, cmd: 'kill'
    ipc.destroy()
    for subscription in @subs
      subscription.off?()
      subscription.dispose?()
    delete @subs
  