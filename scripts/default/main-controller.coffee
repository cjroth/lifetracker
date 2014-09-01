angular
  .module 'lifetracker'
  .controller 'DefaultMainController', ($scope, store, $window) ->

    $scope.$watch 'variables', ->

      store.getRecords (err, records) ->

        colors = ['red', 'blue', 'green']
        seriesData = {}
        series = []
        timezoneOffset = (new Date).getTimezoneOffset() * 60

        $scope.variables ?= []

        for variable in $scope.variables
          seriesData[variable.id] = []

        for record in records
          seriesData[record.variable_id]?.push(x: record.timestamp / 1000 - timezoneOffset, y: record.value)

        for variable, i in $scope.variables
          series.push
            color: colors[i]
            data: seriesData[variable.id]

        graph = new Rickshaw.Graph( {
          element: document.getElementById('chart'),
          width: $('.main').width(),
          height: $('.main').height(),
          renderer: 'line',
          series: series
        } )

        # @todo access this through dependency injection
        gui = require('nw.gui');
        win = gui.Window.get().on 'resize', ->

          graph.configure({
            width: $('.main').width(),
            height: $('.main').height(),
          });
          graph.render();

        new Rickshaw.Graph.Axis.Time({
          graph: graph
        });

        graph.render()

    return