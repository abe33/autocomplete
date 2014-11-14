
/*
  lib/responder/responder.coffee
  Unlike other files in the responder folder this runs in the Atom process
  It provides the interface from atom to the responder process
 */

(function() {
  var Api, ResponderMgr, _;

  _ = require('underscore-plus');

  Api = require('../api/api');

  module.exports = ResponderMgr = (function() {
    function ResponderMgr(api) {
      var TextEditor, TextEditorView, execPath;
      this.api = api;
      TextEditorView = require('atom').TextEditorView;
      TextEditor = new TextEditorView({}).getEditor().constructor;
      this.subs = [];
      execPath = require('path').resolve(__dirname, '../../js/responder-process.js');
      this.responder = this.api.createProcess(execPath, 'atom', 'responder');
      this.api.recvFromChild(this.responder, 'responder', function(message) {
        return console.log('DEBUG: received this from the responder process:\n', message);
      });
      this.subs.push(atom.workspaceView.eachEditorView((function(_this) {
        return function(editorView) {
          var editor, editorSub;
          if (!editorView.attached || editorView.mini) {
            return;
          }
          _this.subs.push(atom.workspace.onDidChangeActivePaneItem(function(editor) {
            if (editor instanceof TextEditor) {
              return _this.api.sendToChild(_this.responder, {
                cmd: 'newEditor',
                path: editor.getPath(),
                text: editor.getText(),
                cursor: editor.getLastCursor().getBufferPosition()
              });
            } else {
              return _this.api.sendToChild(_this.responder, {
                cmd: 'noActiveEditor'
              });
            }
          }));
          _this.subs.push(editorSub = (editor = editorView.getModel()).onDidChange(function(evt) {
            return _this.api.sendToChild(_this.responder, {
              cmd: 'bufferEdit',
              text: editor.getTextInBufferRange([[evt.start, 0], [evt.end + 1, 0]]),
              event: evt,
              cursor: editor.getLastCursor().getBufferPosition()
            });
          }));
          return _this.subs.push(editorView.on('editor:will-be-removed', function() {
            return editorSub.off();
          }));
        };
      })(this)));
    }

    ResponderMgr.prototype.registerProvider = function(options) {
      var version;
      version = require('../../package.json').version;
      if (!require('semver').satisfies(version, options.autocompleteVersion)) {
        console.log('The package at', options.modulePath, 'requires autocomplete package version', options.autocompleteVersion, 'but this version is', version);
        return;
      }
      return this.api.sendToChild(this.responder, {
        cmd: 'register',
        options: options
      });
    };

    ResponderMgr.prototype.destroy = function() {
      var subscription, _i, _len, _ref;
      this.api.sendToChild(this.responder, {
        cmd: 'kill'
      });
      _ref = this.subs;
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        subscription = _ref[_i];
        if (typeof subscription.off === "function") {
          subscription.off();
        }
        if (typeof subscription.dispose === "function") {
          subscription.dispose();
        }
      }
      return delete this.subs;
    };

    return ResponderMgr;

  })();

}).call(this);
