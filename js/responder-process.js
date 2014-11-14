
/*
  lib/responder/responder-process.coffee
 */

(function() {
  var Provider, api, buffer, providers, send;

  api = new (require(process.argv[2]))('responder');

  buffer = new (require('./responder-buffer'));

  Provider = require('./provider');

  providers = [];

  send = function(msg) {
    return api.sendToParent(msg);
  };

  api.recvFromParent('responder', function(msg) {
    var provider, _i, _len;
    if (!providers) {
      return;
    }
    console.log('----', msg.cmd, '----');
    switch (msg.cmd) {
      case 'register':
        return providers.push(new Provider(api, msg.options.providerName, msg.options.providerPath));
      case 'newEditor':
        return buffer = new ResponderBuffer(msg.text);
      case 'bufferEdit':
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
        return console.log('responder, unknown msg cmd:', msg);
    }
  });

  console.log('hello');

}).call(this);
