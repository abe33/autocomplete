###
  lib/provider/scope.coffee
###

{XRegExp} = require 'xregexp'

module.exports =
class Scope

  constructor: (init) -> for k, v of init when v then @[k] = v
  
  match: (scope) ->
    JSON.stringify([
      @word          
      @type          
      @file          
      @startLine     
      @endLine       
      @prefixCaptures
    ]) is JSON.stringify([
      scope.word          
      scope.type          
      scope.file          
      scope.startLine     
      scope.endLine       
      scope.prefixCaptures
    ])
    
  mergeToList: (list) ->
    for scope in list
      if @match scope then scope.weight += @weight; return
    list.push this
    
  mergeToResultListWeighted: (lineNum, prefix, resultList) ->
    resultList.sort (res1, res2) -> (if res1.word > res2.word then 1 else -1)
    
    adjustWeight = (weight, incMul) ->
      [inc, mul] = incMul
      weight *= +(mul ? 1)
      weight += +inc
    
    {word, startLine, endLine, scopeWeight, 
    prefixRegex, prefixCaptures, label, hint, weight} = this
    
    if startLine? and 
      (startLine <= lineNum <= endLine) 
        weight = adjustWeight weight, scopeWeight
    
    if prefixRegex
      xregex = XRegExp prefixRegex+'$', 'i'
      if (match = XRegExp.exec prefix, xregex)
        for captureName, captureSpecs of prefixCaptures
          if (captureStr = match[captureName])
            for captureSpec in captureSpecs
              if (new RegExp captureSpec[0]).test captureStr 
                weight = adjustWeight weight, captureSpec[1..2]
                break
    
    if (lastRes = resultList[-1..-1][0]) and lastRes.word is word
      lastRes.weight += weight
    else
      resultList.push {weight, word, label, hint}
    
        
