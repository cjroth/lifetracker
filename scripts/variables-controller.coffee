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

      firstDataDate = null
      oneBefore = $rootScope.start.clone().subtract(1, 'days')
      oneAfter = $rootScope.end.clone().add(1, 'days')
      date = $rootScope.start.clone()

      while date.isAfter(oneBefore) and date.isBefore(oneAfter)
        for variable in variables
          record = _.findWhere(variable.records, date: date.format('YYYY-MM-DD'))
          value = if record? then variable.scale(record.value) else null
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
          return series.name + ': ' + value + ' ' + units
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

    $scope.selectAll = ->
      $rootScope.variables.forEach (variable) ->
        variable.selected = true

    $scope.deselectAll = ->
      $rootScope.variables.forEach (variable) ->
        variable.selected = false

    $scope.$on 'date changed', ->
      renderChart()
      $scope.$digest()
      console.log 'i might be a memory leak'

    $timeout ->
      readyToRender = true
      renderChart()

    onSomeEventThatRequiresTheChartToBeReRendered = -> renderChart()

    gui.Window.get().addListener 'resize', onSomeEventThatRequiresTheChartToBeReRendered
    gui.Window.get().addListener 'enterFullscreen', onSomeEventThatRequiresTheChartToBeReRendered
    gui.Window.get().addListener 'leaveFullscreen', onSomeEventThatRequiresTheChartToBeReRendered

    unwatchVariables = $rootScope.$watch 'variables', onSomeEventThatRequiresTheChartToBeReRendered, true

    $rootScope.$on "$stateChangeStart", (event, toState, toParams, fromState, fromParams) ->
      if fromState.name isnt "default" then return
      if toState.name is "record" then return
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
