angular
  .module 'lifetracker'
  .controller 'DefaultMainController', ($scope, $rootScope, store, $window) ->

    $rootScope.$watchCollection 'variables', ->

      console.log 'updating chart'

      if not $rootScope.variables.length
        # @todo show no vars message

      store.getRecords (err, records) ->

        if not $('#chart').length then return

        colors = ['red', 'blue', 'green']
        seriesData = {}
        series = []
        timezoneOffset = (new Date).getTimezoneOffset() * 60

        for variable in $rootScope.variables
          seriesData[variable.id] = []

        for record in records
          seriesData[record.variable_id]?.push(x: record.timestamp / 1000 - timezoneOffset, y: record.value)

        for variable, i in $rootScope.variables
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