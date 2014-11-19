
/*
  lib/responder/responder-process.coffee
 */

(function() {
  var Provider, ResponderBuffer, buffer, ipc, providers, sendToAtom;

  ipc = new (require(process.argv[2]))('responder');

  ResponderBuffer = require('./responder-buffer');

  Provider = require('./provider');

  buffer = null;

  providers = [];

  sendToAtom = function(msg) {
    return ipc.sendToParent(msg);
  };

  ipc.recvFromParent('responder', function(msg) {
    var options, provider, startParseTasks, _i, _len;
    if (!providers) {
      return;
    }
    options = msg.options;
    startParseTasks = function(providerIn) {
      var provider, _i, _len, _ref, _results;
      if (buffer) {
        _ref = (providerIn ? [providerIn] : providers);
        _results = [];
        for (_i = 0, _len = _ref.length; _i < _len; _i++) {
          provider = _ref[_i];
          _results.push(provider.startTask('parse', buffer, {
            filePath: buffer.getPath(),
            sourceLines: buffer.getLines(),
            grammar: buffer.getGrammar()
          }));
        }
        return _results;
      }
    };
    console.log('----', msg.cmd, '----');
    switch (msg.cmd) {
      case 'register':
        providers.push((provider = new Provider(ipc, options)));
        return startParseTasks(provider);
      case 'newActiveEditor':
        buffer = new ResponderBuffer(msg, sendToAtom);
        return startParseTasks();
      case 'bufferEdit':
        if (!buffer) {
          console.log('Received bufferEdit command when no buffer');
          return;
        }
        return buffer.onBufferChange(msg);
      case 'noActiveEditor':
        return buffer = null;
      case 'kill':
        for (_i = 0, _len = providers.length; _i < _len; _i++) {
          provider = providers[_i];
          console.log('Killing', provider.getName());
          provider.destroy();
        }
        providers = null;
        return setTimeout((function() {
          return process.exit(0);
        }), 300);
      default:
        return console.log('responder, unknown command:', msg);
    }
  });

  console.log('hello');

}).call(this);
