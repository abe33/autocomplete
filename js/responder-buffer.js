
/*
  lib/responder/responder-buffer.coffee
 */

(function() {
  var ResponderBuffer, Trie, _,
    __slice = [].slice;

  _ = require('underscore-plus');

  Trie = require('./trie');

  module.exports = ResponderBuffer = (function() {
    function ResponderBuffer(msg, sendToAtom) {
      var text;
      this.sendToAtom = sendToAtom;
      this.path = msg.path, text = msg.text, this.grammar = msg.grammar;
      this.lines = (text ? text.split('\n') : []);
      this.timeStamp = msg.timeStamp;
    }

    ResponderBuffer.prototype.onBufferChange = function(chg) {
      var bufferDelta, chgdLineEnd, chgdLineStart, cmd, cursor, cursorColumn, cursorRow, event, line, prefix, resultList, text, wordFragment, _ref, _ref1, _ref2;
      cmd = chg.cmd, text = chg.text, event = chg.event, cursor = chg.cursor;
      cursorRow = cursor.row, cursorColumn = cursor.column;
      chgdLineStart = event.start, chgdLineEnd = event.end, bufferDelta = event.bufferDelta;
      text = text.replace(/\n$/, '');
      this.chgdLines = text.split('\n');
      (_ref = this.lines).splice.apply(_ref, [chgdLineStart, this.chgdLines.length - bufferDelta].concat(__slice.call(this.chgdLines)));
      if (bufferDelta === 0 && chgdLineStart === chgdLineEnd) {
        line = this.lines[chgdLineStart];
        if ((wordFragment = (_ref1 = /[a-z\_$]+$/i.exec(line.slice(0, cursorColumn))) != null ? _ref1[0] : void 0)) {
          prefix = line.slice(0, cursorColumn - wordFragment.length);
          if ((resultList = (_ref2 = this.trie) != null ? _ref2.getResultList(chgdLineStart, prefix, wordFragment) : void 0)) {
            resultList.sort(function(res1, res2) {
              var dif;
              if ((dif = res2.weight - res1.weight)) {
                return dif;
              } else {
                return res2.word.length - res1.word.length;
              }
            });
            return this.sendToAtom({
              cmd: 'suggestionList',
              list: resultList
            });
          }
        }
      }
    };

    ResponderBuffer.prototype.getGrammar = function() {
      return this.grammar;
    };

    ResponderBuffer.prototype.getLines = function() {
      return this.lines;
    };

    ResponderBuffer.prototype.getPath = function() {
      return this.path;
    };

    ResponderBuffer.prototype.getTrie = function() {
      return this.trie;
    };

    ResponderBuffer.prototype.addScopesToTrie = function(filePath, scopeList) {
      if (filePath === this.path) {
        return (this.trie != null ? this.trie : this.trie = new Trie).addScopes(scopeList);
      }
    };

    return ResponderBuffer;

  })();

}).call(this);
