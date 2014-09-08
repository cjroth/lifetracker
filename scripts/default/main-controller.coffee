angular
  .module 'lifetracker'
  .controller 'DefaultMainController', ($scope, $rootScope, store, $window, gui, moment) ->

    $scope.chartTypes = ['scatterplot', 'line']
    $scope.chartTypeIconClasses =
      scatterplot: 'fa fa-area-chart'
      line: 'fa fa-line-chart'
    $scope.chartTypeLabels =
      scatterplot: 'Dots'
      line: 'Lines'
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

        if $scope.dateRange?
          if $scope.dateRange.start? and record.timestamp < $scope.dateRange.start then continue
          if $scope.dateRange.end? and record.timestamp > $scope.dateRange.end then continue

        seriesData[record.variable_id]?.push(x: record.timestamp / 1000 - timezoneOffset, y: record.value)
        if !maximums[record.variable_id] or record.value > maximums[record.variable_id]
         maximums[record.variable_id] = record.value
        if !minimums[record.variable_id] or record.value < minimums[record.variable_id]
         minimums[record.variable_id] = record.value - .5 # make minimum slightly less than actual minimum so that
                                                          # points don't get cut off of bottom

      for variable, i in variables
        series.push(
          name: variable.name
          variable: variable
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

        new Rickshaw.Graph.HoverDetail(
          formatter: (series, x, y) ->
            units = if series.variable.type is 'scale' then '/ 10' else series.variable.units
            value = Math.round(y * 100) / 100 # round to 2 decimal places
            series.name + ': ' + value + ' ' + units
          graph: graph
        )
        # new Rickshaw.Graph.Axis.Time(graph: graph)

    $scope.getPrettyDateRange = ->
      return moment($scope.dateRange.start).format('MMM Do') + ' - ' + moment($scope.dateRange.end).format('MMM Do')

    $scope.cycleChartType = ->
      $scope.chartType = $scope.chartTypes[$scope.chartTypes.indexOf($scope.chartType) + 1] || $scope.chartTypes[0]
      renderChart()

    $scope.toggleDatePicker = ->
      $scope.showDatepicker = not $scope.showDatepicker

    $datepicker = $('.datepicker').datepicker
      inputs: $('.range-start, .range-end')

    # show one month ago until today as default date range
    initialStartDate = new Date((new Date()).getTime() - 30 * 24 * 60 * 60 * 1000)
    initialStartDate.setHours(0, 0, 0, 0)
    initialEndDate = new Date()
    initialEndDate.setHours(0, 0, 0, 0)
    $('.range-start').datepicker('setDate', initialStartDate)
    $('.range-end').datepicker('setDate', initialEndDate)

    $scope.dateRange =
      start: initialStartDate.getTime()
      end: initialEndDate.getTime()

    $datepicker.on 'changeDate', (event) ->
      $scope.dateRange =
        start: $('.range-start').datepicker('getDate').getTime()
        end: $('.range-end').datepicker('getDate').getTime()
      renderChart()
      $scope.$digest()

    $rootScope.$watch 'variables', renderChart, true
