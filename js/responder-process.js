
/*
  lib/responder/responder-process.coffee
 */

(function() {
  var Api, Provider, ResponderBuffer, api, buffer, providers, send;

  Api = require(process.argv[2]);

  Provider = require('./provider');

  ResponderBuffer = require('./responder-buffer');

  api = new Api;

  buffer = new ResponderBuffer;

  providers = [];

  send = function(msg) {
    return api.sendToParent(msg);
  };

  api.recvFromParent('responder', function(msg) {
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
      default:
        return console.log('responder, unknown msg cmd:', msg);
    }
  });

  console.log('hello');

}).call(this);
