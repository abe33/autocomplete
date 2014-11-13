###
  src/result-set.coffee
###

_ = require 'underscore-plus'

module.exports =
class ResultSet
  
  constructor: (@rules = {}, @results = []) ->
  
  setPath:   (path)      -> @rules.path  = path
  setRegex:  (regex)     -> @rules.regex = regex
  setScope:  (id)        -> @rules.scope = scope
  addRule:   (rule, val) -> @rules[rule] = val
  addResult: (result)    -> @results.push result
  ###
  resultSet.addResult
    type:   'symbol'
    weight: 1
    symbol: 'xxx'
  ###
  