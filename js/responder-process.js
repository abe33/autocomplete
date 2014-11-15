
/*
  lib/responder/responder-process.coffee
 */

(function() {
  var Provider, ResponderBuffer, api, buffer, providers, send;

  api = new (require(process.argv[2]))('responder');

  ResponderBuffer = require('./responder-buffer');

  Provider = require('./provider');

  buffer = null;

  providers = [];

  send = function(msg) {
    return api.sendToParent(msg);
  };

  api.recvFromParent('responder', function(msg) {
    var options, provider, _i, _len;
    if (!providers) {
      return;
    }
    options = msg.options;
    console.log('----', msg.cmd, '----');
    switch (msg.cmd) {
      case 'register':
        return providers.push(new Provider(api, options.providerName, options.providerPath));
      case 'newActiveEditor':
        console.log('Editor:', msg.title);
        return buffer = new ResponderBuffer(msg.text);
      case 'bufferEdit':
        if (!buffer) {
          console.log('Received bufferEdit command when no buffer');
          return;
        }
        return buffer.applyChg(msg);
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
