
/*
  lib/provider/api.coffee
  
  This is only required by providers
 */

(function() {
  var Api, ipc, spawn, _;

  spawn = require('child_process').spawn;

  _ = require('underscore-plus');

  ipc = new (require(process.argv[2]))('api');

  module.exports = Api = (function() {
    function Api(name) {
      this.name = name;
      this.subs = [];
    }

    Api.prototype.on = function(serviceName, callback) {
      if (!this.serviceCallbacks) {
        this.serviceCallbacks = {};
        ipc.recvFromParent('responder', (function(_this) {
          return function(msg) {
            console.log('msg from responder', msg.serviceName, _this.serviceCallbacks);
            switch (msg.cmd) {
              case 'startTask':
                return _this.serviceCallbacks[msg.serviceName](msg.task);
              default:
                return console.log('unknown command from responder', msg);
            }
          };
        })(this));
      }
      this.serviceCallbacks[serviceName] = callback;
      return ipc.sendToParent({
        cmd: 'registerService',
        serviceName: serviceName
      });
    };

    Api.prototype.destroy = function() {
      var subscription, _i, _len, _ref;
      _ref = this.subs;
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        subscription = _ref[_i];
        if (typeof subscription.off === "function") {
          subscription.off();
        }
        if (typeof subscription.dispose === "function") {
          subscription.dispose();
        }
      }
      return delete this.subs;
    };

    return Api;

  })();

}).call(this);
