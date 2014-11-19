
/*
  lib/provider/scope.coffee
 */

(function() {
  var Scope, XRegExp;

  XRegExp = require('xregexp').XRegExp;

  module.exports = Scope = (function() {
    function Scope(init) {
      var k, v;
      for (k in init) {
        v = init[k];
        if (v) {
          this[k] = v;
        }
      }
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
      var adjustWeight, captureName, captureSpec, captureSpecs, captureStr, endLine, hint, label, lastRes, match, prefixCaptures, prefixRegex, scopeWeight, startLine, weight, word, xregex, _i, _len;
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
        weight *= +(mul != null ? mul : 1);
        return weight += +inc;
      };
      word = this.word, startLine = this.startLine, endLine = this.endLine, scopeWeight = this.scopeWeight, prefixRegex = this.prefixRegex, prefixCaptures = this.prefixCaptures, label = this.label, hint = this.hint, weight = this.weight;
      if ((startLine != null) && ((startLine <= lineNum && lineNum <= endLine))) {
        weight = adjustWeight(weight, scopeWeight);
      }
      if (prefixRegex) {
        xregex = XRegExp(prefixRegex + '$', 'i');
        if ((match = XRegExp.exec(prefix, xregex))) {
          for (captureName in prefixCaptures) {
            captureSpecs = prefixCaptures[captureName];
            if ((captureStr = match[captureName])) {
              for (_i = 0, _len = captureSpecs.length; _i < _len; _i++) {
                captureSpec = captureSpecs[_i];
                if ((new RegExp(captureSpec[0])).test(captureStr)) {
                  weight = adjustWeight(weight, captureSpec.slice(1, 3));
                  break;
                }
              }
            }
          }
        }
      }
      if ((lastRes = resultList.slice(-1)[0]) && lastRes.word === word) {
        return lastRes.weight += weight;
      } else {
        return resultList.push({
          weight: weight,
          word: word,
          label: label,
          hint: hint
        });
      }
    };

    return Scope;

  })();

}).call(this);
