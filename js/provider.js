
/*
  lib/responder/provider.coffee
 */

(function() {
  var Provider;

  module.exports = Provider = (function() {
    function Provider(api, name, path) {
      this.api = api;
      this.name = name;
      this.path = path;
      this.process = this.api.createProcess(this.path, 'responder', this.name);
      this.api.recvFromChild(this.process, this.name, (function(_this) {
        return function(message) {
          return console.log('message from provider:', message);
        };
      })(this));
    }

    Provider.prototype.send = function(message) {
      return this.api.sendToChild(this.process, message);
    };

    Provider.prototype.destroy = function() {
      return this.process.disconnect();
    };

    return Provider;

  })();

}).call(this);
