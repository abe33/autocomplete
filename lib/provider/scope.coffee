###
  lib/provider/scope.coffee
###

{XRegExp} = require 'xregexp'

module.exports =
class Scope

  constructor: ({
    @word, @type, @file, @startLine, @endLine, @prefixCaptures, @weight, @label, @hint
  }) ->
  
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
      weight *= (mul ? 1)
      weight += inc
    
    {word, startLine, endLine, scopeWeight, 
    prefixRegex, prefixCaptures, label, hint, weight} = this
    
    if startLine? and 
      (startLine <= lineNum <= endLine) 
        weight = adjustWeight weight, scopeWeight
    
    if prefixRegex
      console.log 1
      if (match = (new XRegExp prefixRegex+'$', 'i').exec prefix)
        console.log 2
        for captureName, captureSpecs of prefixCaptures
          console.log 3
          if (captureStr = match[captureName]) and
             (new RegExp captureSpecs[0]).test captureStr 
            console.log 4
            weight = adjustWeight weight, captureSpecs[1..2]
    
    if (lastRes = resultList[-1..-1][0]) and lastRes[1].word is word
      lastRes[0] += weight
    else
      resultList.push [weight, {word, label, hint}]
    
        
