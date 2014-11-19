
/*
  lib/provider/scope.coffee
 */

(function() {
  var Scope, XRegExp;

  XRegExp = require('xregexp').XRegExp;

  module.exports = Scope = (function() {
    function Scope(_arg) {
      this.word = _arg.word, this.type = _arg.type, this.file = _arg.file, this.startLine = _arg.startLine, this.endLine = _arg.endLine, this.prefixCaptures = _arg.prefixCaptures, this.weight = _arg.weight, this.label = _arg.label, this.hint = _arg.hint;
    }

    Scope.prototype.match = function(scope) {
      return JSON.stringify([this.word, this.type, this.file, this.startLine, this.endLine, this.prefixCaptures]) === JSON.stringify([scope.word, scope.type, scope.file, scope.startLine, scope.endLine, scope.prefixCaptures]);
    };

    Scope.prototype.mergeToList = function(list) {
      var scope, _i, _len;
      for (_i = 0, _len = list.length; _i < _len; _i++) {
        scope = list[_i];
        if (this.match(scope)) {
          scope.weight += this.weight;
          return;
        }
      }
      return list.push(this);
    };

    Scope.prototype.mergeToResultListWeighted = function(lineNum, prefix, resultList) {
      var adjustWeight, captureName, captureSpecs, captureStr, endLine, hint, label, lastRes, match, prefixCaptures, prefixRegex, scopeWeight, startLine, weight, word;
      resultList.sort(function(res1, res2) {
        if (res1.word > res2.word) {
          return 1;
        } else {
          return -1;
        }
      });
      adjustWeight = function(weight, incMul) {
        var inc, mul;
        inc = incMul[0], mul = incMul[1];
        weight *= mul != null ? mul : 1;
        return weight += inc;
      };
      word = this.word, startLine = this.startLine, endLine = this.endLine, scopeWeight = this.scopeWeight, prefixRegex = this.prefixRegex, prefixCaptures = this.prefixCaptures, label = this.label, hint = this.hint, weight = this.weight;
      if ((startLine != null) && ((startLine <= lineNum && lineNum <= endLine))) {
        weight = adjustWeight(weight, scopeWeight);
      }
      if (prefixRegex) {
        console.log(1);
        if ((match = (new XRegExp(prefixRegex + '$', 'i')).exec(prefix))) {
          console.log(2);
          for (captureName in prefixCaptures) {
            captureSpecs = prefixCaptures[captureName];
            console.log(3);
            if ((captureStr = match[captureName]) && (new RegExp(captureSpecs[0])).test(captureStr)) {
              console.log(4);
              weight = adjustWeight(weight, captureSpecs.slice(1, 3));
            }
          }
        }
      }
      if ((lastRes = resultList.slice(-1)[0]) && lastRes[1].word === word) {
        return lastRes[0] += weight;
      } else {
        return resultList.push([
          weight, {
            word: word,
            label: label,
            hint: hint
          }
        ]);
      }
    };

    return Scope;

  })();

}).call(this);
