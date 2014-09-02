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
      maximums = {}
      minimums = {}
      series = []
      timezoneOffset = (new Date).getTimezoneOffset() * 60

      variables = $rootScope.variables.filter (variable) -> variable.selected

      for variable in variables
        seriesData[variable.id] = []

      for record in records
        seriesData[record.variable_id]?.push(x: record.timestamp / 1000 - timezoneOffset, y: record.value)
        if !maximums[record.variable_id] or record.value > maximums[record.variable_id]
         maximums[record.variable_id] = record.value
        if !minimums[record.variable_id] or record.value < minimums[record.variable_id]
         minimums[record.variable_id] = record.value

      for variable, i in variables
        series.push(
          name: variable.name
          color: variable.color
          data: seriesData[variable.id]
          scale: d3.scale.linear().domain([minimums[variable.id], maximums[variable.id]]).nice()
        )
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
