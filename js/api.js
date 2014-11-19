
/*
  lib/provider/api.coffee
  
  This is only used by providers
 */

(function() {
  var Api, Scope, ipc, _;

  _ = require('underscore-plus');

  ipc = new (require(process.argv[2]))('api');

  Scope = require('./scope');

  module.exports = Api = (function() {
    function Api(name) {
      this.name = name;
    }

    Api.prototype.on = function(serviceName, callback) {
      if (!this.serviceCallbacks) {
        this.serviceCallbacks = {};
        ipc.recvFromParent('responder', (function(_this) {
          return function(msg) {
            switch (msg.cmd) {
              case 'startTask':
                return _this.serviceCallbacks[msg.serviceName](msg.task);
              default:
                return console.log('unknown command from responder', msg);
            }
          };
        })(this));
      }
      return this.serviceCallbacks[serviceName] = callback;
    };

    Api.prototype.getScopeClass = function() {
      return Scope;
    };

    Api.prototype.taskResults = function(results) {
      return ipc.sendToParent(_.extend(results, {
        cmd: 'taskResults'
      }));
    };

    return Api;

  })();

}).call(this);
