###
  lib/responder/responder-buffer.coffee  
###

_ = require 'underscore-plus'

module.exports =
class ResponderBuffer 
  
  constructor: (msg) ->
    {text, @grammar} = msg
    @lines = (if text then text.split '\n' else [])
    # console.log '---- constructor ----\n', @lines
    
  setScopeTree: (@scopeTree) ->
        
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
      if (wordFragment = /[a-z_\-$]+$/i.exec(@lines[chgdLineStart][0...cursorColumn])?[0])
        console.log 'wordFragment:', wordFragment
      
      return
      
  getText:    -> @lines.join '\n'
  getGrammar: -> @grammar
      
    