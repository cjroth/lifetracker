angular
  .module 'lifetracker'
  .controller 'DefaultMainController', ($scope, $rootScope, store, $window, gui) ->

    $('.datepicker').datepicker
      inputs: $('.range-start, .range-end')

    $scope.chartTypes = ['scatterplot', 'line']
    $scope.chartTypeIconClasses =
      scatterplot: 'fa fa-area-chart'
      line: 'fa fa-line-chart'
    $scope.chartType = $scope.chartTypes[0]

    graph = {}

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

    gui.Window.get().on 'resize', ->
      graph.configure(
        width: $('.main').width()
        height: $('.main').height()
      )
      graph.render()

    renderChart = ->

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
          renderer: $scope.chartType
          series: formatData(records)
          dotSize: 5
        )

        graph.render()

        new Rickshaw.Graph.HoverDetail(graph: graph)
        # new Rickshaw.Graph.Axis.Time(graph: graph)

    $rootScope.$watch 'variables', renderChart, true

    $scope.cycleChartType = ->
      $scope.chartType = $scope.chartTypes[$scope.chartTypes.indexOf($scope.chartType) + 1] || $scope.chartTypes[0]
      renderChart()
