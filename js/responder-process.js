
/*
  lib/responder/responder-process.coffee
 */

(function() {
  var Provider, ResponderBuffer, buffer, ipc, providers, send;

  ipc = new (require(process.argv[2]))('responder');

  ResponderBuffer = require('./responder-buffer');

  Provider = require('./provider');

  buffer = null;

  providers = [];

  send = function(msg) {
    return ipc.sendToParent(msg);
  };

  ipc.recvFromParent('responder', function(msg) {
    var options, provider, _i, _j, _len, _len1, _results;
    if (!providers) {
      return;
    }
    options = msg.options;
    console.log('----', msg.cmd, '----');
    switch (msg.cmd) {
      case 'register':
        providers.push((provider = new Provider(ipc, options)));
        if (buffer) {
          console.log('register startTask parse', provider.getName(), buffer.getGrammar(), buffer.getText().length);
          return provider.startTask('parse', buffer.getGrammar(), {
            source: buffer.getText()
          });
        }
        break;
      case 'newActiveEditor':
        buffer = new ResponderBuffer(msg);
        _results = [];
        for (_i = 0, _len = providers.length; _i < _len; _i++) {
          provider = providers[_i];
          console.log('newActiveEditor startTask parse', provider.getName(), buffer.getGrammar(), buffer.getText().length);
          _results.push(provider.startTask('parse', buffer.getGrammar(), {
            source: buffer.getText()
          }));
        }
        return _results;
        break;
      case 'bufferEdit':
        if (!buffer) {
          console.log('Received bufferEdit command when no buffer');
          return;
        }
        return buffer.applyChg(msg);
      case 'noActiveEditor':
        return buffer = null;
      case 'kill':
        for (_j = 0, _len1 = providers.length; _j < _len1; _j++) {
          provider = providers[_j];
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
