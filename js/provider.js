
/*
  lib/responder/provider.coffee
 */

(function() {
  var Provider;

  module.exports = Provider = (function() {
    function Provider(ipc, options) {
      this.ipc = ipc;
      this.name = options.providerName, this.path = options.providerPath, this.services = options.services;
      this.process = this.ipc.createProcess(this.path, 'responder', this.name);
      this.ipc.recvFromChild(this.process, this.name, (function(_this) {
        return function(msg) {
          switch (msg.cmd) {
            case 'taskResults':
              switch (msg.service) {
                case 'parse':
                  return _this.buffer.addScopesToTrie(msg.filePath, msg.scopeList);
              }
          }
        };
      })(this));
    }

    Provider.prototype.send = function(message) {
      return this.ipc.sendToChild(this.process, message);
    };

    Provider.prototype.startTask = function(serviceName, buffer, task) {
      var service, _ref;
      this.buffer = buffer;
      if ((service = this.services[serviceName]) && ((_ref = service.grammar) === task.grammar || _ref === '*')) {
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
