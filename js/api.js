
/*
  lib/provider/api.coffee
  
  This is only used by providers
 */

(function() {
  var Api, Scope;

  Scope = require('./scope');

  module.exports = Api = (function() {
    function Api(ipc, registerOptions) {
      var providerModule;
      this.ipc = ipc;
      this.serviceCallbacks = {};
      this.providerName = registerOptions.providerName;
      providerModule = require(registerOptions.providerPath);
      providerModule.initialize(this);
      console.log(this.providerName, 'initialized');
    }

    Api.prototype.getScopeClass = function() {
      return Scope;
    };

    Api.prototype.on = function(serviceName, callback) {
      console.log(this.providerName, 'subscribed to', serviceName);
      return this.serviceCallbacks[serviceName] = callback;
    };

    Api.prototype.recvFromResponder = function(msg) {
      var callback;
      switch (msg.cmd) {
        case 'startTask':
          if ((callback = this.serviceCallbacks[msg.task.serviceName])) {
            return callback(msg.task);
          }
          break;
        default:
          return console.log('unknown command from responder', msg);
      }
    };

    Api.prototype.taskDone = function(task) {
      return this.ipc.sendToParent({
        cmd: 'taskDone',
        providerName: this.providerName,
        serviceName: task.serviceName,
        meta: task.meta,
        results: task.results
      });
    };

    return Api;

  })();

}).call(this);
