
/*
  src/result-set.coffee
 */

(function() {
  var ResultSet, _;

  _ = require('underscore-plus');

  module.exports = ResultSet = (function() {
    function ResultSet(rules, results) {
      this.rules = rules != null ? rules : {};
      this.results = results != null ? results : [];
    }

    ResultSet.prototype.setPath = function(path) {
      return this.rules.path = path;
    };

    ResultSet.prototype.setRegex = function(regex) {
      return this.rules.regex = regex;
    };

    ResultSet.prototype.setScope = function(id) {
      return this.rules.scope = scope;
    };

    ResultSet.prototype.addRule = function(rule, val) {
      return this.rules[rule] = val;
    };

    ResultSet.prototype.addResult = function(result) {
      return this.results.push(result);
    };


    /*
    resultSet.addResult
      type:   'symbol'
      weight: 1
      symbol: 'xxx'
     */

    return ResultSet;

  })();

}).call(this);
