
_      = require 'underscore-plus'
semver = require 'semver'
AutocompleteView = require './autocomplete-view'

module.exports =
  configDefaults:
    includeCompletionsFromAllBuffers: false

  autocompleteViews: []
  editorSubscription: null
  version: require('../package.json').version

  activate: ->
    @responderIO = require './responder-io'
    
    # @editorSubscription = atom.workspaceView.eachEditorView (editor) =>
    #   if editor.attached and not editor.mini
    #     autocompleteView = new AutocompleteView(editor)
    #     editor.on 'editor:will-be-removed', =>
    #       autocompleteView.remove() unless autocompleteView.hasParent()
    #       _.remove(@autocompleteViews, autocompleteView)
    #     @autocompleteViews.push(autocompleteView)

  versionMatch: (expectedVersion) -> semver.satisfies(@version, expectedVersion)

  registerProvider: (name, path) ->
    @responderIO.registerProvider name, path
    
  deactivate: ->
    @editorSubscription?.off()
    @editorSubscription = null
    @autocompleteViews.forEach (autocompleteView) -> autocompleteView.remove()
    @autocompleteViews = []
