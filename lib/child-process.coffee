###
  lib/child-process.coffee
###

send = (msg) ->
  process.stdout.write JSON.stringify(msg) + '\n'
  
process.stdin.on 'data', (msgText) ->
  try
    obj = JSON.parse msgText[0..-2] # strip lf for debug
  catch err
    console.log 'child-process error parsing msg from atom:', err.message, '\n', msg
    return
  send obj

send 'child-process spawned'