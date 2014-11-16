
/*
  lib/responder/responder-buffer.coffee
 */

(function() {
  var ResponderBuffer, _,
    __slice = [].slice;

  _ = require('underscore-plus');

  module.exports = ResponderBuffer = (function() {
    function ResponderBuffer(msg) {
      var text;
      text = msg.text, this.grammar = msg.grammar;
      this.lines = (text ? text.split('\n') : []);
    }

    ResponderBuffer.prototype.setScopeTree = function(scopeTree) {
      this.scopeTree = scopeTree;
    };

    ResponderBuffer.prototype.applyChg = function(chg) {
      var bufferDelta, chgdLineEnd, chgdLineStart, cmd, cursor, cursorColumn, cursorRow, event, text, wordFragment, _ref, _ref1;
      cmd = chg.cmd, text = chg.text, event = chg.event, cursor = chg.cursor;
      cursorRow = cursor.row, cursorColumn = cursor.column;
      chgdLineStart = event.start, chgdLineEnd = event.end, bufferDelta = event.bufferDelta;
      console.log('buffer applyChg', {
        chgdLineStart: chgdLineStart,
        cursorRow: cursorRow,
        cursorColumn: cursorColumn
      });
      text = text.replace(/\n$/, '');
      this.chgdLines = text.split('\n');
      (_ref = this.lines).splice.apply(_ref, [chgdLineStart, this.chgdLines.length - bufferDelta].concat(__slice.call(this.chgdLines)));
      if (bufferDelta === 0 && chgdLineStart === chgdLineEnd) {
        if ((wordFragment = (_ref1 = /[a-z_\-$]+$/i.exec(this.lines[chgdLineStart].slice(0, cursorColumn))) != null ? _ref1[0] : void 0)) {
          console.log('wordFragment:', wordFragment);
        }
      }
    };

    ResponderBuffer.prototype.getText = function() {
      return this.lines.join('\n');
    };

    ResponderBuffer.prototype.getGrammar = function() {
      return this.grammar;
    };

    return ResponderBuffer;

  })();

}).call(this);
