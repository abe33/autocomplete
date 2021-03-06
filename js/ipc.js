
/*
  lib/ipc/ipc.coffee
  ipc means "Inter Process Communications"
  This is required in every process including the main Atom process
 */

(function() {
  var Ipc, jsPath, spawn, _,
    __slice = [].slice;

  spawn = require('child_process').spawn;

  _ = require('underscore-plus');

  jsPath = require('path').normalize(__dirname, '../../js');

  module.exports = Ipc = (function() {
    function Ipc(name) {
      this.name = name;
      process.stdin.resume();
      process.on('SIGTERM', (function(_this) {
        return function() {
          if (_this.name) {
            console.log('Exiting', _this.name + 'process');
          }
          process.exit(0);
          return _this.childProcessTerminated = true;
        };
      })(this));
      this.subs = [];
    }

    Ipc.prototype.createProcess = function(path, parentName, childName) {
      var childProcess, procEvt;
      childProcess = spawn('node', [path, jsPath]);
      procEvt = (function(_this) {
        return function(src, event, msg) {
          if (msg == null) {
            msg = event;
          }
          return _this.subs.push(src.on(event, function(data) {
            return console.log.apply(console, [parentName, 'received process', msg, 'from'].concat(__slice.call((data ? [childName + ':', data.toString()] : [childName]))));
          }));
        };
      })(this);
      procEvt(childProcess, 'error');
      procEvt(childProcess, 'message');
      procEvt(childProcess, 'disconnect');
      procEvt(childProcess, 'close');
      procEvt(childProcess.stderr, 'data', 'stderr');
      return childProcess;
    };

    Ipc.prototype.demuxMessages = function(data, partialData, badParseMsg) {
      var err, line, lines, msg, msgs, _i, _len;
      lines = data.toString().split('\n');
      if (lines.length === 1) {
        partialData += lines[0];
        return [partialData, []];
      }
      lines[0] = partialData + lines[0];
      partialData = _.last(lines);
      lines = _.initial(lines);
      msgs = [];
      for (_i = 0, _len = lines.length; _i < _len; _i++) {
        line = lines[_i];
        try {
          msg = JSON.parse(line);
        } catch (_error) {
          err = _error;
          console.log(badParseMsg + ':', line);
          continue;
        }
        msgs.push(msg.msg);
      }
      return [partialData, msgs];
    };

    Ipc.prototype.recvFromParent = function(parentName, callback) {
      var partialData;
      partialData = '';
      return this.subs.push(process.stdin.on('data', (function(_this) {
        return function(data) {
          var msg, msgs, _i, _len, _ref, _results;
          _ref = _this.demuxMessages(data, partialData, 'ipc parse error from parent process', parentName), partialData = _ref[0], msgs = _ref[1];
          _results = [];
          for (_i = 0, _len = msgs.length; _i < _len; _i++) {
            msg = msgs[_i];
            _results.push(callback(msg));
          }
          return _results;
        };
      })(this)));
    };

    Ipc.prototype.recvFromChild = function(childProcess, processName, callback) {
      var partialData;
      partialData = '';
      return this.subs.push(childProcess.stdout.on('data', (function(_this) {
        return function(data) {
          var msg, msgs, _i, _len, _ref, _results;
          _ref = _this.demuxMessages(data, partialData, processName.toUpperCase()), partialData = _ref[0], msgs = _ref[1];
          _results = [];
          for (_i = 0, _len = msgs.length; _i < _len; _i++) {
            msg = msgs[_i];
            _results.push(callback(msg));
          }
          return _results;
        };
      })(this)));
    };

    Ipc.prototype.sendToParent = function(msg) {
      var e;
      try {
        return process.stdout.write(JSON.stringify({
          msg: msg
        }) + '\n');
      } catch (_error) {
        e = _error;
        return console.log('ipc sendToParent error', e.message);
      }
    };

    Ipc.prototype.sendToChild = function(childProcess, msg) {
      var e;
      if (this.childProcessTerminated) {
        return;
      }
      try {
        return childProcess.stdin.write(JSON.stringify({
          msg: msg
        }) + '\n');
      } catch (_error) {
        e = _error;
        return console.log('ipc sendToChild error', e.message);
      }
    };

    Ipc.prototype.destroy = function() {
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

    return Ipc;

  })();

}).call(this);
