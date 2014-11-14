
/*
  lib/responder/responder-buffer.coffee
 */

(function() {
  var ResponderBuffer, _,
    __slice = [].slice;

  _ = require('underscore-plus');

  module.exports = ResponderBuffer = (function() {
    function ResponderBuffer(text) {
      this.lines = (text ? text.split('\n') : []);
    }

    ResponderBuffer.prototype.applyChg = function(chg) {
      var bufferDelta, chgdLineEnd, chgdLineStart, cmd, cursor, cursorColumn, cursorRow, event, text, _ref;
      cmd = chg.cmd, text = chg.text, event = chg.event, cursor = chg.cursor;
      cursorRow = cursor.row, cursorColumn = cursor.column;
      chgdLineStart = event.start, chgdLineEnd = event.end, bufferDelta = event.bufferDelta;
      text = text.replace(/\n$/, '');
      this.chgdLines = text.split('\n');
      return (_ref = this.lines).splice.apply(_ref, [chgdLineStart, this.chgdLines.length - bufferDelta].concat(__slice.call(this.chgdLines)));
    };

    return ResponderBuffer;

  })();

}).call(this);
