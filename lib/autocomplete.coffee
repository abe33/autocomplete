###
  lib/autocomplete.coffee
###

module.exports =
  configDefaults:
    includeCompletionsFromAllBuffers: false

  autocompleteViews: []
  editorSubscription: null

  activate: ->
    process.nextTick =>
      @api          = new (require('../js/api'))
      @responderMgr = new (require('./responder/responder-mgr'))(@api)
    
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

  registerProvider: (options) ->
    semver  = require 'semver'
    version = require('../package.json').version
    if not semver.satisfies version, options.autocompleteVersion
      console.log 'The package at', options.modulePath, 
                  'requires autocomplete package version', options.autocompleteVersion,
                  'but this version is', version
      return
    @api.sendToChild @responderMgr.getProcess(), {cmd: 'register', options}

  deactivate: ->
    @responderMgr.destroy()
    @editorSubscription?.off()
    @editorSubscription = null
    @autocompleteViews.forEach (autocompleteView) -> autocompleteView.remove()
    @autocompleteViews = []
