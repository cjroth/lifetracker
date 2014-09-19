angular
  .module 'lifetracker'
  .controller 'DefaultMainController', ($scope, $rootScope, store, $window, gui, moment, settings) ->

    start = null
    end = null

    # Rickshaw.namespace('Rickshaw.Graph.Renderer.UnstackedArea')
    # Rickshaw.Graph.Renderer.UnstackedArea = Rickshaw.Class.create(Rickshaw.Graph.Renderer.Area, {
    #   name: 'unstackedarea'
    #   defaults: ($super) ->
    #     return Rickshaw.extend($super(), {
    #       unstack: true
    #       fill: false
    #       stroke: false
    #     })
    # })

    $scope.chartTypes = ['line', 'stack', 'scatterplot']
    $scope.chartTypeIconClasses =
      line: 'fa fa-line-chart'
      stack: 'fa fa-area-chart'
      scatterplot: 'fa fa-circle'
    $scope.chartTypeLabels =
      line: 'Lines'
      stack: 'Area'
      scatterplot: 'Dots'
    $scope.chartType = settings.chartType || $scope.chartTypes[0]
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

      firstDataDate = null
      oneBefore = start.clone().subtract(1, 'days')
      oneAfter = end.clone().add(1, 'days')
      date = start.clone()

      while date.isAfter(oneBefore) and date.isBefore(oneAfter)
        
        recordsForDate = _.where(records, date: date.format('YYYY-MM-DD'))

        if firstDataDate is null
          if recordsForDate.length is 0
            date.add(1, 'days')
            continue
          else
            firstDataDate = date

        for variable in variables
          record = _.findWhere(recordsForDate, variable_id: variable.id)
          value = if record? then record.value else null
          seriesData[variable.id].push(x: date.valueOf(), y: value)

        date.add(1, 'days')

      for variable, i in variables
        scale = 'linear'
        series.push(
          name: variable.name
          variable: variable
          color: variable.color
          data: seriesData[variable.id]
        )

      return series

    gui.Window.get().on 'resize', -> renderChart()
    gui.Window.get().on 'enterFullscreen', -> renderChart()
    gui.Window.get().on 'leaveFullscreen', -> renderChart()

    renderChart = ->

      store.getRecords (err, records) ->
        
        records = formatData(records)

        $chart = $('#chart')

        if not $chart.length then return

        $chart.empty()
        $chart.replaceWith('<div id="chart"></div>')
        $chart = $('#chart')

        if not records.length then return

        graph = new Rickshaw.Graph(
          element: $chart[0]
          width: $('.main').width()
          height: $('.main').height()
          renderer: $scope.chartType
          series: records
          dotSize: 5
          interpolation: 'cardinal'
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
