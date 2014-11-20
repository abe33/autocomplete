
/*
  lib/provider/provider-process.coffee
 */

(function() {
  var ipc, jsPath, providerApis;

  jsPath = process.argv[2];

  ipc = new (require(jsPath + '/ipc.js'))('provider');

  providerApis = {};

  ipc.recvFromParent('responder', (function(_this) {
    return function(msg) {
      var options, providerApi;
      if (msg.cmd === 'register') {
        options = msg.registerOptions;
        providerApi = new (require(jsPath + '/api.js'))(ipc, options);
        return providerApis[options.providerName] = providerApi;
      } else {
        return providerApis[msg.providerName].recvFromResponder(msg);
      }
    };
  })(this));

  console.log('hello');

}).call(this);
