###
  lib/autocomplete.coffee
###

module.exports =
  configDefaults:
    includeCompletionsFromAllBuffers:        no
    includeCompletionsFromAllFilesInProject: no

  autocompleteViews: []
  editorSubscription: null

  activate: ->
    process.nextTick =>
      @responderInterface = new (require('./responder-interface'))
    
    # _ = require 'underscore-plus'
    # AutocompleteView = require './autocomplete-view'
    # 
    # @editorSubscription = atom.workspaceView.eachEditorView (editor) =>
    #   if editor.attached and not editor.mini
    #     autocompleteView = new AutocompleteView(editor)
    #     editor.on 'editor:will-be-removed', =>
    #       autocompleteView.remove() unless autocompleteView.hasParent()
    #       _.remove(@autocompleteViews, autocompleteView)
    #     @autocompleteViews.push(autocompleteView)

  registerProvider: (options) -> @responderInterface.registerProvider options
    
  deactivate: ->
    @responderInterface.destroy()
    @editorSubscription?.off()
    @editorSubscription = null
    @autocompleteViews.forEach (autocompleteView) -> autocompleteView.remove()
    @autocompleteViews = []
