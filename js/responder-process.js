
/*
  lib/responder/responder-process.coffee
 */

(function() {
  var Provider, ResponderBuffer, buffer, ipc, jsPath, killed, providerProcess, providers, responder, sendToAtom;

  jsPath = process.argv[2];

  ipc = new (require(jsPath + '/ipc.js'))('responder');

  ResponderBuffer = require('./responder-buffer');

  Provider = require('./provider');

  buffer = null;

  killed = false;

  providers = {};

  responder = {};

  responder.providerProcess = providerProcess = ipc.createProcess(jsPath + '/provider-process.js', 'responder', 'provider');

  sendToAtom = function(msg) {
    return ipc.sendToParent(msg);
  };

  ipc.recvFromParent('responder', function(msg) {
    var provider, providerName, startParseTask, _results;
    if (killed) {
      return;
    }
    startParseTask = function(provider) {
      if (provider.supportsGrammar('parse', buffer.getGrammar())) {
        return provider.startTask({
          serviceName: 'parse',
          sourceLines: buffer.getLines(),
          meta: {
            filePath: buffer.getPath()
          }
        });
      }
    };
    switch (msg.cmd) {
      case 'register':
        provider = new Provider(ipc, responder, msg.options);
        providers[msg.options.providerName] = provider;
        if (buffer) {
          return startParseTask(provider);
        }
        break;
      case 'newActiveEditor':
        buffer = new ResponderBuffer(msg, sendToAtom);
        _results = [];
        for (providerName in providers) {
          provider = providers[providerName];
          _results.push(startParseTask(provider));
        }
        return _results;
        break;
      case 'bufferEdit':
        if (!buffer) {
          console.log('Received bufferEdit command when no buffer');
          return;
        }
        return buffer.onBufferChange(msg);
      case 'noActiveEditor':
        return buffer = null;
      case 'kill':
        providerProcess.kill('SIGTERM');
        killed = true;
        return setTimeout((function() {
          return process.exit(0);
        }), 1000);
      default:
        return console.log('responder, unknown command:', msg);
    }
  });

  ipc.recvFromChild(providerProcess, 'provider', function(msg) {
    return providers[msg.providerName].recvFromProcess(msg);
  });

  responder.addScopesToTrie = function(filePath, scopeList) {
    return buffer != null ? buffer.addScopesToTrie(filePath, scopeList) : void 0;
  };

  console.log('hello');

}).call(this);
