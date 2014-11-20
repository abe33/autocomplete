
/*
  lib/responder/provider.coffee
 */

(function() {
  var Provider;

  module.exports = Provider = (function() {
    function Provider(ipc, responder, registerOptions) {
      this.ipc = ipc;
      this.responder = responder;
      this.providerName = registerOptions.providerName, this.services = registerOptions.services;
      this.providerProcess = this.responder.providerProcess;
      this.ipc.sendToChild(this.providerProcess, {
        cmd: 'register',
        registerOptions: registerOptions
      });
    }

    Provider.prototype.sendToProcess = function(msg) {
      msg.providerName = this.providerName;
      return this.ipc.sendToChild(this.providerProcess, msg);
    };

    Provider.prototype.startTask = function(task) {
      return this.sendToProcess({
        cmd: 'startTask',
        task: task
      });
    };

    Provider.prototype.recvFromProcess = function(msg) {
      var meta, results, serviceName;
      switch (msg.cmd) {
        case 'taskDone':
          serviceName = msg.serviceName, meta = msg.meta, results = msg.results;
          switch (serviceName) {
            case 'parse':
              return this.responder.addScopesToTrie(meta.filePath, results);
          }
      }
    };

    Provider.prototype.getName = function() {
      return this.providerName;
    };

    Provider.prototype.hasService = function(serviceName) {
      return this.services[serviceName] != null;
    };

    Provider.prototype.supportsGrammar = function(serviceName, grammar) {
      var grammarSpec, _ref;
      return (grammarSpec = (_ref = this.services[serviceName]) != null ? _ref.grammar : void 0) && (grammarSpec === '*' || grammar === grammarSpec);
    };

    return Provider;

  })();

}).call(this);
