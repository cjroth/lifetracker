angular
  .module 'lifetracker'
  .controller 'DefaultMainController', ($scope, $rootScope, store, $window) ->

    formatData = (records) ->

      colors = ['red', 'blue', 'green']
      seriesData = {}
      series = []
      timezoneOffset = (new Date).getTimezoneOffset() * 60

      variables = $rootScope.variables.filter (variable) -> variable.selected

      for variable in variables
        seriesData[variable.id] = []

      for record in records
        seriesData[record.variable_id]?.push(x: record.timestamp / 1000 - timezoneOffset, y: record.value)

      for variable, i in variables
        series.push
          color: colors[i]
          data: seriesData[variable.id]

      return series

    store.getRecords (err, records) ->

      if not $('#chart').length then return

      graph = new Rickshaw.Graph( {
        element: $('#chart')[0],
        width: $('.main').width(),
        height: $('.main').height(),
        renderer: 'line',
        series: formatData(records)
      } )

      # @todo access this through dependency injection
      gui = require('nw.gui');
      win = gui.Window.get().on 'resize', ->

        graph.configure({
          width: $('.main').width(),
          height: $('.main').height(),
        });
        graph.render()

      new Rickshaw.Graph.Axis.Time({
        graph: graph
      });

      graph.render()

      $rootScope.$watch 'variables', ->

        store.getRecords (err, records) ->
          
          if not $('#chart').length then return

          $('#chart').empty()

          graph = new Rickshaw.Graph( {
            element: $('#chart')[0],
            width: $('.main').width(),
            height: $('.main').height(),
            renderer: 'line',
            series: formatData(records)
          } )

          graph.render()


        # if not $rootScope.variables.length
          # @todo show no vars message

      , true

    return