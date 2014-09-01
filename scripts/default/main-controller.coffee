angular
  .module 'lifetracker'
  .controller 'DefaultMainController', ($scope, $rootScope, store, $window) ->

    formatData = (records) ->

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
          name: variable.name
          color: variable.color
          data: seriesData[variable.id]

      return series

    store.getRecords (err, records) ->

      if not $('#chart').length then return

      graph = new Rickshaw.Graph(
        element: $('#chart')[0]
        width: $('.main').width()
        height: $('.main').height()
        renderer: 'scatterplot'
        series: formatData(records)
        dotSize: 5
      )

      # @todo access this through dependency injection
      gui = require('nw.gui');
      win = gui.Window.get().on 'resize', ->

        graph.configure(
          width: $('.main').width()
          height: $('.main').height()
        )

        graph.render()

      new Rickshaw.Graph.Axis.Time(graph: graph)

      graph.render()

      new Rickshaw.Graph.HoverDetail(graph: graph)


      $rootScope.$watch 'variables', ->

        store.getRecords (err, records) ->
          
          $chart = $('#chart')

          if not $chart.length then return

          $chart.empty()
          $chart.replaceWith('<div id="chart"></div>')
          $chart = $('#chart')

          graph = new Rickshaw.Graph(
            element: $chart[0]
            width: $('.main').width()
            height: $('.main').height()
            renderer: 'scatterplot'
            series: formatData(records)
            dotSize: 5
          )

          graph.render()

          new Rickshaw.Graph.HoverDetail(graph: graph)


        # if not $rootScope.variables.length
          # @todo show no vars message

      , true

    return