
/*
  lib/provider/trie.coffee
 */

(function() {
  var Scope, Trie;

  Scope = require('./scope');

  module.exports = Trie = (function() {
    function Trie() {}

    Trie.prototype.addWord = function(word, scopeList) {
      var char, curNode, idx, list, scope, _i, _j, _len, _len1, _ref, _results;
      curNode = this;
      _ref = word.toLowerCase();
      for (idx = _i = 0, _len = _ref.length; _i < _len; idx = ++_i) {
        char = _ref[idx];
        curNode = curNode[char] != null ? curNode[char] : curNode[char] = {};
      }
      list = (curNode['~'] != null ? curNode['~'] : curNode['~'] = []);
      _results = [];
      for (_j = 0, _len1 = scopeList.length; _j < _len1; _j++) {
        scope = scopeList[_j];
        _results.push((new Scope(scope)).mergeToList(list));
      }
      return _results;
    };

    Trie.prototype.addScopes = function(scopeList) {
      var chkWordBreak, lastWord, list, scope, _i, _len;
      scopeList.sort(function(scope1, scope2) {
        if (scope1.word > scope2.word) {
          return 1;
        } else {
          return -1;
        }
      });
      list = [];
      lastWord = null;
      chkWordBreak = (function(_this) {
        return function(scope) {
          if (lastWord && lastWord !== scope.word) {
            _this.addWord(lastWord, list);
            return list = [];
          }
        };
      })(this);
      for (_i = 0, _len = scopeList.length; _i < _len; _i++) {
        scope = scopeList[_i];
        chkWordBreak(scope);
        list.push(scope);
        lastWord = scope.word;
      }
      return chkWordBreak({});
    };

    Trie.prototype.getResultList = function(lineNum, prefix, wordFragment) {
      var char, resultList, subTree, walkSubTree, _i, _len, _ref;
      resultList = [];
      subTree = this;
      _ref = wordFragment.toLowerCase();
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        char = _ref[_i];
        if (!(subTree = subTree[char])) {
          return;
        }
      }
      (walkSubTree = function(subTree) {
        var node, scope, _results;
        _results = [];
        for (char in subTree) {
          node = subTree[char];
          if (char === '~') {
            _results.push((function() {
              var _j, _len1, _results1;
              _results1 = [];
              for (_j = 0, _len1 = node.length; _j < _len1; _j++) {
                scope = node[_j];
                _results1.push(scope.mergeToResultListWeighted(lineNum, prefix, resultList));
              }
              return _results1;
            })());
          } else {
            _results.push(walkSubTree(node));
          }
        }
        return _results;
      })(subTree);
      return resultList;
    };

    return Trie;

  })();

}).call(this);
