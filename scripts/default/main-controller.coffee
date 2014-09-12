angular
  .module 'lifetracker'
  .controller 'DefaultMainController', ($scope, $rootScope, store, $window, gui, moment, settings) ->

    start = null
    end = null

    $scope.chartTypes = ['line', 'stack', 'scatterplot']
    $scope.chartTypeIconClasses =
      line: 'fa fa-line-chart'
      stack: 'fa fa-area-chart'
      scatterplot: 'fa fa-circle'
    $scope.chartTypeLabels =
      scatterplot: 'Dots'
      line: 'Lines'
    $scope.chartType = settings.chartType || $scope.chartTypes[0]

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

        if moment(record.date).isBefore(start) then continue
        if moment(record.date).isAfter(end) then continue

        seriesData[record.variable_id]?.push(x: moment(record.date).valueOf(), y: record.value)

        if !minimums[record.variable_id] or record.value < minimums[record.variable_id]
         minimums[record.variable_id] = record.value
        if !maximums[record.variable_id] or record.value > maximums[record.variable_id]
         maximums[record.variable_id] = record.value

      for variable, i in variables
        scale = 'linear'
        # if variable.type is 'scale'
        #   minimums[variable.id] = 0
        #   maximums[variable.id] = 10
        series.push(
          name: variable.name
          variable: variable
          color: variable.color
          data: seriesData[variable.id]
          scale: d3
            .scale.linear()
            # .range([minimums[variable.id], maximums[variable.id]])
            .nice()
        )

      return series

    gui.Window.get().on 'resize', -> renderChart()
    gui.Window.get().on 'enterFullscreen', -> renderChart()
    gui.Window.get().on 'leaveFullscreen', -> renderChart()

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
            return series.name + ': ' + value + ' ' + units
          xFormatter: (x) ->
            return moment(x).format('dddd, MMMM DD, YYYY')
          graph: graph
        )
        new Rickshaw.Graph.Axis.Time(
          graph: graph
          timeUnit: name: '2 hour', seconds: 3600 * 2, formatter: (d) -> moment(d).format('h:mm a')
        )

    $scope.getPrettyDateRange = ->
      return start.format('MMM D') + ' - ' + end.format('MMM D')

    $scope.cycleChartType = ->
      $scope.chartType = $scope.chartTypes[$scope.chartTypes.indexOf($scope.chartType) + 1] || $scope.chartTypes[0]
      settings.chartType = $scope.chartType
      settings.save()
      renderChart()

    $scope.toggleDatePicker = ->
      $scope.showDatepicker = not $scope.showDatepicker

    $datepicker = $('.datepicker').datepicker
      inputs: $('.range-start, .range-end')

    # show one month ago until today as default date range
    
    start = moment({ h: 0, m: 0, s: 0, ms: 0 }).subtract(settings.dateRangeSize || 30, 'days')
    end = moment({ h: 0, m: 0, s: 0, ms: 0 })

    $('.range-start').datepicker('setDate', new Date(start))
    $('.range-end').datepicker('setDate', new Date(end))

    $datepicker.on 'changeDate', (event) ->
      start = moment($('.range-start').datepicker('getDate'))
      end = moment($('.range-end').datepicker('getDate'))
      settings.dateRangeSize = end.diff(start, 'days')
      settings.save()
      renderChart()
      $scope.$digest()

    $rootScope.$watch 'variables', renderChart, true
