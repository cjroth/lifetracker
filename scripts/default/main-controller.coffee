angular
  .module 'lifetracker'
  .controller 'DefaultMainController', ($scope, $rootScope, store, $window, gui, moment, settings, showToday) ->

    start = null
    end = null

    charts = [
      {
        name: 'line'
        label: 'Lines'
        class: 'fa fa-line-chart'
      }
      {
        name: 'stack'
        label: 'Area'
        class: 'fa fa-area-chart'
        stackable: true
      }
      {
        name: 'bar'
        label: 'Bars'
        class: 'fa fa-bar-chart'
        stackable: true
      }
    ]

    $scope.chart = _.findWhere(charts, name: settings.chartName) or charts[0]
    $scope.stacked = settings.chartStacked

    graph = {}

    formatData = (records) ->

      seriesData = {}
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

        for variable in variables
          record = _.findWhere(recordsForDate, variable_id: variable.id)
          value = if record? then record.value else null
          seriesData[variable.id].push(x: date.valueOf(), y: value)

        date.add(1, 'days')

      for variable, i in variables

        rgb = d3.rgb(variable.color)
        alpha = 1

        if $scope.chart.name is 'stack' and $scope.stacked is false
          alpha = 1 / variables.length

        series.push(
          name: variable.name
          variable: variable
          color: 'rgba(' + [rgb.r, rgb.g, rgb.b, alpha].join(',') + ')'
          stroke: 'rgba(' + [rgb.r, rgb.g, rgb.b, 1].join(',') + ')'
          data: seriesData[variable.id]
        )

      return series

    renderChart = ->

      console.debug('rendering main chart')

      store.getRecords (err, records) ->
        
        records = formatData(records)

        $chart = $('[name="chart"]')

        if not $chart.length then return

        $chart.empty()
        $chart.replaceWith('<div name="chart"></div>')
        $chart = $('[name="chart"]')

        if not records.length then return

        if $scope.chart.stackable
          unstack = !$scope.stacked

        graph = new Rickshaw.Graph(
          element: $chart[0]
          width: $('.main').width()
          height: $('.main').height()
          renderer: $scope.chart.name
          series: records
          dotSize: 5
          interpolation: 'cardinal'
          unstack: unstack
        )

        graph.render()

        new Rickshaw.Graph.HoverDetail(
          formatter: (series, x, y) ->
            units = if series.variable.type is 'scale' then '/ 10' else series.variable.units
            value = Math.round(y * 100) / 100 # round to 2 decimal places
            return series.name + ': ' + value + ' ' + units
          xFormatter: (x) ->
            return moment(x).format('dddd, MMMM D, YYYY')
          graph: graph
        )
        new Rickshaw.Graph.Axis.Time(
          graph: graph
          timeUnit: name: '2 hour', seconds: 3600 * 2, formatter: (d) -> moment(d).format('h:mm a')
        )

    $scope.getPrettyDateRange = ->
      return start.format('MMM D') + ' - ' + end.format('MMM D')

    $scope.cycleChartType = ->
      $scope.chart = charts[charts.indexOf($scope.chart) + 1] || charts[0]
      renderChart()
      settings.chartName = $scope.chart.name
      settings.save()

    $scope.toggleStacked = ->
      $scope.stacked = !$scope.stacked
      renderChart()
      settings.chartStacked = $scope.stacked
      settings.save()

    $scope.toggleDatePicker = ->
      $scope.showDatepicker = not $scope.showDatepicker

    $datepicker = $('.datepicker').datepicker(inputs: $('.range-start, .range-end'))

    # show one month ago until today as default date range
    end = moment()
      .subtract(settings.newDayOffsetHours, 'hours')
      .set('hour', 0)
      .set('minute', 0)
      .set('second', 0)
      .set('millisecond', 0)
    if not showToday then end.subtract(1, 'days')
    start = end.clone().subtract(settings.dateRangeSize, 'days')

    $('.range-start').datepicker('setDate', new Date(start))
    $('.range-end').datepicker('setDate', new Date(end))

    $datepicker.on 'changeDate', (event) ->
      start = moment($('.range-start').datepicker('getDate'))
      end = moment($('.range-end').datepicker('getDate'))
      settings.dateRangeSize = end.diff(start, 'days')
      settings.save()
      renderChart()
      $scope.$digest()

    onSomeEventThatRequiresTheChartToBeReRendered = -> renderChart()

    gui.Window.get().addListener 'resize', onSomeEventThatRequiresTheChartToBeReRendered
    gui.Window.get().addListener 'enterFullscreen', onSomeEventThatRequiresTheChartToBeReRendered
    gui.Window.get().addListener 'leaveFullscreen', onSomeEventThatRequiresTheChartToBeReRendered

    $rootScope.$watch 'variables', onSomeEventThatRequiresTheChartToBeReRendered, true

    $rootScope.$on "$stateChangeStart", (event, toState, toParams, fromState, fromParams) ->
      if fromState.name is not "default" then return
      gui.Window.get().removeListener 'resize', onSomeEventThatRequiresTheChartToBeReRendered
      gui.Window.get().removeListener 'enterFullscreen', onSomeEventThatRequiresTheChartToBeReRendered
      gui.Window.get().removeListener 'leaveFullscreen', onSomeEventThatRequiresTheChartToBeReRendered
