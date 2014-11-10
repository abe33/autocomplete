// Generated by CoffeeScript 1.8.0

/*
  lib/utils.coffee
 */

(function() {
  var LocalUtils, _;

  _ = require('underscore-plus');

  LocalUtils = (function() {
    function LocalUtils() {
      this.partialStreamData = '';
    }

    LocalUtils.prototype.recvDemuxObj = function(streamData, child) {
      var err, line, lines, msg, results, _i, _len;
      lines = streamData.toString().split('\n');
      if (lines.length === 1) {
        this.partialStreamData += lines[0];
        return;
      } else {
        lines[0] = this.partialStreamData + lines[0];
        this.partialStreamData = _.last(lines);
        lines = _.initial(lines);
      }
      results = [];
      for (_i = 0, _len = lines.length; _i < _len; _i++) {
        line = lines[_i];
        if (!(line)) {
          continue;
        }
        try {
          msg = JSON.parse(line);
        } catch (_error) {
          err = _error;
          if (child) {
            console.log('CHILD error line:' + '\n', line, '\n', err.message);
          } else {
            console.log('PROCIO line:', line);
          }
          continue;
        }
        results.push(msg.msg);
      }
      return results;
    };

    return LocalUtils;

  })();

  module.exports = new LocalUtils;

}).call(this);
