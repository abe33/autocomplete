###
  lib/responder/responder-buffer.coffee  
###

_    = require 'underscore-plus'
Trie = require './trie'

module.exports =
class ResponderBuffer 
  
  constructor: (msg) ->
    {@path, text, @grammar} = msg
    @lines = (if text then text.split '\n' else [])
    # console.log '---- constructor ----\n', @lines
    
  applyChg: (chg) ->
    {cmd, text, event, cursor} = chg
    {row: cursorRow, column: cursorColumn} = cursor
    {start: chgdLineStart, end: chgdLineEnd, bufferDelta} = event
    
    # console.log 'buffer applyChg', 
    #   {text: text.length, chgdLineStart, chgdLineEnd, bufferDelta, cursorRow, cursorColumn}
    
    console.log 'buffer applyChg', {chgdLineStart, cursorRow, cursorColumn}
    
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
        console.log 'prefix wordFragment:', {prefix, wordFragment}
        resultList = @trie?.getResultList chgdLineStart, prefix, wordFragment
        
        console.log 'resultList', require('util').inspect resultList, depth: null
        
      return
      
  getGrammar: -> @grammar
  getLines:   -> @lines
  getPath:    -> @path
  getTrie:    -> @trie
  
  addScopesToTrie: (filePath, scopeList) -> 
    if filePath is @path then (@trie ?= new Trie).addScopes scopeList
    
    
    