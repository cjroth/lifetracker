angular
  .module 'lifetracker'
  .controller 'VariablesController', ($popover, $scope, $rootScope, $window, gui, moment, settings, showToday, $timeout) ->

    readyToRender = false

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

    getRecordValue = (record) ->
      if not record? then return null
      value = parseFloat(record.value)
      if _.isNaN(value) then return null
      return value

    fillInMissingRecords = (records, start, end) ->
      out = []
      date = start.clone().add(1, 'days')
      while date.isAfter(start) and date.isBefore(end)
        record = _.findWhere(records, date: date.format('YYYY-MM-DD'))
        value = getRecordValue(record)
        out.push(date: date.valueOf(), value: value)
        date.add(1, 'days')
      return out

    aggregateRecordsIntoWeeks = (records, start, end) ->

      date = start.clone()

      records = fillInMissingRecords(records, start, end)

      weeks = _.groupBy records, (record) -> moment(record.date).weekYear() + '-' + moment(record.date).week()

      aggregated = []
      _.each weeks, (records, week) -> 
        values = _.pluck(records, 'value')
        mean = ss.mean(_.compact(values))
        aggregated.push(week: week, value: mean)
      return aggregated

    formatData = (variables) ->

      seriesData = {}
      series = []
      timezoneOffset = (new Date).getTimezoneOffset() * 60

      variables = variables.filter (variable) -> variable.selected

      for variable in variables
        seriesData[variable._id] = []
        min = d3.min variable.records, (record) -> record.value
        max = d3.max variable.records, (record) -> record.value
        variable.scale = d3.scale.linear().domain([min, max]).range([0.05, 0.95])

      date = $rootScope.start.clone()

      if $rootScope.end.diff($rootScope.start, 'days') < 14

        while date.isAfter($rootScope.start.inclusive) and date.isBefore($rootScope.end.inclusive)
          for variable in variables
            record = _.findWhere(variable.records, date: date.format('YYYY-MM-DD'))
            value = getRecordValue(record)
            if value? then value = variable.scale(value)
            seriesData[variable._id].push(x: date.valueOf(), y: value)
          date.add(1, 'days')

      else

        for variable in variables
          weeks = aggregateRecordsIntoWeeks(variable.records, $rootScope.start.inclusive, $rootScope.end.inclusive)
          seriesData[variable._id] = weeks.map (aggregate) ->
            week = aggregate.week.split('-')
            return (x: moment([week[0]]).week(week[1] || 0).valueOf(), y: variable.scale(aggregate.value))

      for variable, i in variables

        rgb = d3.rgb(variable.color)
        alpha = 1

        if $scope.chart.name is 'stack'
          alpha = 1 / variables.length

        series.push(
          name: variable.name
          variable: variable
          renderer: $scope.chart.name
          color: 'rgba(' + [rgb.r, rgb.g, rgb.b, alpha].join(',') + ')'
          stroke: 'rgba(' + [rgb.r, rgb.g, rgb.b, 1].join(',') + ')'
          data: seriesData[variable._id]
        )

      return series

    renderChart = ->

      if not readyToRender then return

      console.debug('rendering main chart')
        
      series = formatData($rootScope.variables)

      $chart = $('.chart[name="chart"]')

      if not $chart.length then return

      $chart.empty()
      $chart.replaceWith('<div name="chart" class="chart"></div>')
      $chart = $('.chart[name="chart"]')

      if not series.length then return

      graph = new Rickshaw.Graph(
        element: $chart[0]
        width: $('.main').width()
        height: $('.main').height()
        renderer: 'multi'
        series: series
        dotSize: 5
        interpolation: 'cardinal'
        unstack: true
        min: 0
        max: 1
      )

      graph.render()

      new Rickshaw.Graph.HoverDetail(
        formatter: (series, x, y) ->
          units = if series.variable.type is 'scale' then '/ 10' else series.variable.units
          y = series.variable.scale.invert(y)
          value = Math.round(y * 100) / 100 # round to 2 decimal places
          label = series.name + ': ' + value
          return if units? then label + ' ' + units else label
        xFormatter: (x) ->
          return moment(x).format('dddd, MMMM D, YYYY')
        graph: graph
      )

    $scope.getPrettyDateRange = ->
      return $rootScope.start.format('MMM D') + ' - ' + $rootScope.end.format('MMM D')

    $scope.cycleChartType = ->
      $scope.chart = charts[charts.indexOf($scope.chart) + 1] || charts[0]
      renderChart()
      settings.chartName = $scope.chart.name
      settings.save()

    saveSelectedVariablesToSettings = ->
      selected = []
      for variable in $rootScope.variables
        if variable.selected then selected.push(variable._id)
      settings.selected = selected
      settings.save()

    $scope.selectAll = ->
      $rootScope.variables.forEach (variable) ->
        variable.selected = true
        saveSelectedVariablesToSettings()

    $scope.deselectAll = ->
      $rootScope.variables.forEach (variable) ->
        variable.selected = false
        saveSelectedVariablesToSettings()

    $scope.$on 'date changed', ->
      renderChart()

    $timeout ->
      readyToRender = true
      renderChart()

    onSomeEventThatRequiresTheChartToBeReRendered = -> renderChart()

    gui.Window.get().addListener 'resize', onSomeEventThatRequiresTheChartToBeReRendered
    gui.Window.get().addListener 'enterFullscreen', onSomeEventThatRequiresTheChartToBeReRendered
    gui.Window.get().addListener 'leaveFullscreen', onSomeEventThatRequiresTheChartToBeReRendered

    unwatchVariables = $rootScope.$watch 'variables', onSomeEventThatRequiresTheChartToBeReRendered, true

    $rootScope.$on "$stateChangeStart", (event, toState, toParams, fromState, fromParams) ->
      gui.Window.get().removeListener 'resize', onSomeEventThatRequiresTheChartToBeReRendered
      gui.Window.get().removeListener 'enterFullscreen', onSomeEventThatRequiresTheChartToBeReRendered
      gui.Window.get().removeListener 'leaveFullscreen', onSomeEventThatRequiresTheChartToBeReRendered
      unwatchVariables()

    $scope.select = (variable) ->
      variable.selected = !variable.selected
      selected = []
      for variable in $rootScope.variables
        if variable.selected then selected.push(variable._id)
      settings.selected = selected
      settings.save()
