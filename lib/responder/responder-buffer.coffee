###
  lib/responder/responder-buffer.coffee  
###

_ = require 'underscore-plus'

module.exports =
class ResponderBuffer 
  
  constructor: (text) ->
    @lines = (if text then text.split '\n' else [])
    # console.log '---- constructor ----\n', @lines
        
  applyChg: (chg) ->
    {cmd, text, event, cursor} = chg
    {row: cursorRow, column: cursorColumn} = cursor
    {start: chgdLineStart, end: chgdLineEnd, bufferDelta} = event
    # console.log 'buffer applyChg', 
    #   {text: text.length, chgdLineStart, chgdLineEnd, bufferDelta, cursorRow, cursorColumn}
    
    text = text.replace /\n$/, ''
    @chgdLines = text.split '\n'
    @lines.splice chgdLineStart, 
                  @chgdLines.length - bufferDelta,
                  @chgdLines...
    
    # console.log @chgdLines, @lines
    