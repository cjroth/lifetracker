angular.module('lifetracker').controller('DefaultMainController', function($scope, store, $window) {
  $scope.$watch('variables', function() {
    return store.getRecords(function(err, records) {
      var colors, graph, gui, i, record, series, seriesData, timezoneOffset, variable, win, _i, _j, _k, _len, _len1, _len2, _ref, _ref1, _ref2;
      colors = ['red', 'blue', 'green'];
      seriesData = {};
      series = [];
      timezoneOffset = (new Date).getTimezoneOffset() * 60;
      if ($scope.variables == null) {
        $scope.variables = [];
      }
      _ref = $scope.variables;
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        variable = _ref[_i];
        seriesData[variable.id] = [];
      }
      for (_j = 0, _len1 = records.length; _j < _len1; _j++) {
        record = records[_j];
        if ((_ref1 = seriesData[record.variable_id]) != null) {
          _ref1.push({
            x: record.timestamp / 1000 - timezoneOffset,
            y: record.value
          });
        }
      }
      _ref2 = $scope.variables;
      for (i = _k = 0, _len2 = _ref2.length; _k < _len2; i = ++_k) {
        variable = _ref2[i];
        series.push({
          color: colors[i],
          data: seriesData[variable.id]
        });
      }
      graph = new Rickshaw.Graph({
        element: document.getElementById('chart'),
        width: $('.main').width(),
        height: $('.main').height(),
        renderer: 'line',
        series: series
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
      return graph.render();
    });
  });
});
