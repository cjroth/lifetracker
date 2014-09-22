angular
  .module 'lifetracker'
  .controller 'DefaultMainController', ($scope, $rootScope, $window, gui, moment, settings, showToday) ->

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
      }
    ]

    $scope.chart = _.findWhere(charts, name: settings.chartName) or charts[0]

    graph = {}

    formatData = (variables) ->

      seriesData = {}
      series = []
      timezoneOffset = (new Date).getTimezoneOffset() * 60

      variables = variables.filter (variable) -> variable.selected

      for variable in variables
        seriesData[variable._id] = []

      firstDataDate = null
      oneBefore = start.clone().subtract(1, 'days')
      oneAfter = end.clone().add(1, 'days')
      date = start.clone()

      while date.isAfter(oneBefore) and date.isBefore(oneAfter)
        
        for variable in variables
          record = _.findWhere(variable.records, date: date.format('YYYY-MM-DD'))
          value = if record? then record.value else null
          seriesData[variable._id].push(x: date.valueOf(), y: value)

        date.add(1, 'days')

      for variable, i in variables

        rgb = d3.rgb(variable.color)
        alpha = 1

        if $scope.chart.name is 'stack'
          alpha = 1 / variables.length

        series.push(
          name: variable.name
          variable: variable
          color: 'rgba(' + [rgb.r, rgb.g, rgb.b, alpha].join(',') + ')'
          stroke: 'rgba(' + [rgb.r, rgb.g, rgb.b, 1].join(',') + ')'
          data: seriesData[variable._id]
        )

      return series

    renderChart = ->

      console.debug('rendering main chart')

      if $rootScope.variables.length is 0 then return
        
      series = formatData($rootScope.variables)

      $chart = $('[name="chart"]')

      if not $chart.length then return

      $chart.empty()
      $chart.replaceWith('<div name="chart"></div>')
      $chart = $('[name="chart"]')

      if not series.length then return

      graph = new Rickshaw.Graph(
        element: $chart[0]
        width: $('.main').width()
        height: $('.main').height()
        renderer: $scope.chart.name
        series: series
        dotSize: 5
        interpolation: 'cardinal'
        unstack: true
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

    $scope.getPrettyDateRange = ->
      return start.format('MMM D') + ' - ' + end.format('MMM D')

    $scope.cycleChartType = ->
      $scope.chart = charts[charts.indexOf($scope.chart) + 1] || charts[0]
      renderChart()
      settings.chartName = $scope.chart.name
      settings.save()

    $scope.toggleDatePicker = ->
      $scope.showDatepicker = not $scope.showDatepicker

    $datepicker = $('.datepicker').datepicker(inputs: $('.range-start, .range-end'), format: 'yyyy-mm-dd')

    # show one month ago until today as default date range
    end = moment()
      .subtract(settings.newDayOffsetHours, 'hours')
      .set('hour', 0)
      .set('minute', 0)
      .set('second', 0)
      .set('millisecond', 0)
    if not showToday then end.subtract(1, 'days')
    start = end.clone().subtract(settings.dateRangeSize, 'days')

    $('.range-start').datepicker('setDate', start.format('YYYY-MM-DD'))
    $('.range-end').datepicker('setDate', end.format('YYYY-MM-DD'))

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
