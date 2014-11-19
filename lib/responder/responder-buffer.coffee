###
  lib/responder/responder-buffer.coffee  
###

_    = require 'underscore-plus'
Trie = require './trie'

module.exports =
class ResponderBuffer 
  
  constructor: (msg, @sendToAtom) ->
    {@path, text, @grammar} = msg
    @lines = (if text then text.split '\n' else [])
    # console.log '---- constructor ----\n', @lines
    
  onBufferChange: (chg) ->
    {cmd, text, event, cursor} = chg
    {row: cursorRow, column: cursorColumn} = cursor
    {start: chgdLineStart, end: chgdLineEnd, bufferDelta} = event
    
    # console.log 'buffer onBufferChange', 
    #   {text: text.length, chgdLineStart, chgdLineEnd, bufferDelta, cursorRow, cursorColumn}
    
    text = text.replace /\n$/, ''
    @chgdLines = text.split '\n'
    @lines.splice chgdLineStart, 
                  @chgdLines.length - bufferDelta,
                  @chgdLines...
    
    # console.log @chgdLines, @lines
    
    if bufferDelta is 0 and chgdLineStart is chgdLineEnd
      line = @lines[chgdLineStart]
      if (wordFragment = /[a-z\_$]+$/i.exec(line[0...cursorColumn])?[0])
        prefix = line[0...cursorColumn - wordFragment.length]
        # console.log 'prefix wordFragment:', {prefix, wordFragment}
        resultList = @trie?.getResultList chgdLineStart, prefix, wordFragment
        resultList.sort (res1, res2) -> 
          if (dif = res2.weight - res1.weight) then dif
          else res2.word.length - res1.word.length
        # console.log 'resultList', require('util').inspect resultList, depth: null
        
        console.log wordFragment
        for result in resultList
          console.log result.weight, result.label
          
        @sendToAtom
          cmd: 'suggestionList'
          list: resultList
      
  getGrammar: -> @grammar
  getLines:   -> @lines
  getPath:    -> @path
  getTrie:    -> @trie
  
  addScopesToTrie: (filePath, scopeList) -> 
    if filePath is @path then (@trie ?= new Trie).addScopes scopeList
    
    
    