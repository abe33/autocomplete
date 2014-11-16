
/*
  lib/responder/provider.coffee
 */

(function() {
  var Provider;

  module.exports = Provider = (function() {
    function Provider(api, options) {
      var services;
      this.api = api;
      services = [];
      this.name = options.providerName, this.path = options.providerPath, this.services = options.services;
      this.process = this.api.createProcess(this.path, 'responder', this.name);
      this.api.recvFromChild(this.process, this.name, (function(_this) {
        return function(message) {
          switch (message.cmd) {
            case 'registerService':
              return services.push(message.serviceName);
          }
        };
      })(this));
    }

    Provider.prototype.send = function(message) {
      return this.api.sendToChild(this.process, message);
    };

    Provider.prototype.startTask = function(serviceName, grammar, task) {
      var service;
      if ((service = this.services[serviceName]) && service.grammar === grammar) {
        console.log('provider startTask', this.name, serviceName);
        return this.send({
          cmd: 'startTask',
          serviceName: serviceName,
          task: task
        });
      }
    };

    Provider.prototype.getName = function() {
      return this.name;
    };

    Provider.prototype.destroy = function() {
      this.process.kill('SIGTERM');
      return this.process = null;
    };

    return Provider;

  })();

}).call(this);
