###
  lib/provider/provider-process.coffee
###

jsPath = process.argv[2]
 
ipc = new (require(jsPath + '/ipc.js'))('provider')

providerApis = {}

ipc.recvFromParent 'responder', (msg) =>
  if msg.cmd is 'register'
    options = msg.registerOptions
    providerApi = new (require(jsPath + '/api.js'))(ipc, options)
    providerApis[options.providerName] = providerApi
  else
    providerApis[msg.providerName].recvFromResponder msg

console.log 'hello'