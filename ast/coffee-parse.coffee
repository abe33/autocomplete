

fs = require 'fs'
parser = require 'coffee-script'

debugger
  
source = fs.readFileSync 'c:/apps/atom/src/pane.coffee'
ast    = fs.readFileSync '../ast/pane-ast.txt'

