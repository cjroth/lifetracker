angular.module('lifetracker').controller('DefaultMainController', function($scope, $rootScope, store, $window) {
  var formatData;
  formatData = function(records) {
    var colors, i, record, series, seriesData, timezoneOffset, variable, variables, _i, _j, _k, _len, _len1, _len2, _ref;
    colors = ['red', 'blue', 'green'];
    seriesData = {};
    series = [];
    timezoneOffset = (new Date).getTimezoneOffset() * 60;
    variables = $rootScope.variables.filter(function(variable) {
      return variable.selected;
    });
    for (_i = 0, _len = variables.length; _i < _len; _i++) {
      variable = variables[_i];
      seriesData[variable.id] = [];
    }
    for (_j = 0, _len1 = records.length; _j < _len1; _j++) {
      record = records[_j];
      if ((_ref = seriesData[record.variable_id]) != null) {
        _ref.push({
          x: record.timestamp / 1000 - timezoneOffset,
          y: record.value
        });
      }
    }
    for (i = _k = 0, _len2 = variables.length; _k < _len2; i = ++_k) {
      variable = variables[i];
      series.push({
        color: colors[i],
        data: seriesData[variable.id]
      });
    }
    return series;
  };
  store.getRecords(function(err, records) {
    var graph, gui, win;
    if (!$('#chart').length) {
      return;
    }
    graph = new Rickshaw.Graph({
      element: $('#chart')[0],
      width: $('.main').width(),
      height: $('.main').height(),
      renderer: 'line',
      series: formatData(records)
    });
    gui = require('nw.gui');
    win = gui.Window.get().on('resize', function() {
      graph.configure({
        width: $('.main').width(),
        height: $('.main').height()
      });
      return graph.render();
    });
    new Rickshaw.Graph.Axis.Time({
      graph: graph
    });
    graph.render();
    return $rootScope.$watch('variables', function() {
      return store.getRecords(function(err, records) {
        if (!$('#chart').length) {
          return;
        }
        $('#chart').empty();
        graph = new Rickshaw.Graph({
          element: $('#chart')[0],
          width: $('.main').width(),
          height: $('.main').height(),
          renderer: 'line',
          series: formatData(records)
        });
        return graph.render();
      });
    }, true);
  });
});
