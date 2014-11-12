###
  lib/responder.coffee
###

fs      = require 'fs'
{spawn} = require 'child_process'
_       = require 'underscore-plus'

{AutocompleteComm} = require 'autocomplete-api'
comm = new AutocompleteComm

class ResponderIO 
  constructor: ->
    
    for provider in atom.views.providers
      if (TextEditor = provider.modelConstructor).name is 'TextEditor'
        break
      
    @subs = []
    
    @child = spawn 'node', ['js/responder-process.js']
    @setupChildEvents()
      
    @subs.push atom.workspaceView.eachEditorView (editorView) =>
      if not editorView.attached or editorView.mini then return
      
      atom.workspace.onDidChangeActivePaneItem (editor) =>
        if editor instanceof TextEditor
          @send
            cmd:    'newEditor'
            path:   editor.getPath()
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
    # console.log 'processIO send', msg
    @child.stdin.write JSON.stringify({msg}) + '\n'

  recv: (msg) ->
    console.log 'MSG from child:', msg
    
  setupChildEvents: ->
    @subs.push @child.stdout.on 'data', (data) => 
      # console.log 'data from responder:', data.toString()
      recvObjs = comm.recvDemuxObj data, (err, line) ->  
        console.log 'RESPONDER:', line
      for obj in recvObjs then @recv obj
        
    comm.handleProcessErrors @subs, @child, 'Atom'
    
  registerProvider: (name, path) -> @send {cmd: 'register', name, path}

  destroy: ->
    @child.disconnect()
    for subscription in @subs
      subscription.off?()
      subscription.dispose?()
    delete @subs
        
new ResponderIO
