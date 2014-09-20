angular
  .module 'lifetracker'
  .controller 'InsightsController', ($scope, $rootScope, store, pearsonCorrelation, moment, variables, records, settings, gui) ->

    start = moment().subtract(1, 'years')
    end = moment()
    firstDataDate = null

    charts = [
      {
        name: 'line'
        label: 'Lines'
        class: 'fa fa-line-chart'
      }
      {
        name: 'scatterplot'
        label: 'Dots'
        class: 'fa fa-circle'
      }
    ]

    $scope.chart = charts[0]

    $scope.cycleChartType = ->
      $scope.chart = charts[charts.indexOf($scope.chart) + 1] || charts[0]
      renderChart()
      # settings.chartName = $scope.chart.name
      # settings.save()

    removeVariablesThatDontHaveEnoughData = (variables, records, minimumRecordsThreshold) ->
      variablesWithEnoughData = []
      for variable in variables
        recordsForVariable = _.where(records, variable_id: variable.id)
        if recordsForVariable.length >= minimumRecordsThreshold
          variablesWithEnoughData.push(variable)
      return variablesWithEnoughData

    formatDataForPearsonCorrelations = (records, variables) ->

      seriesData = {}
      series = []
      timezoneOffset = (new Date).getTimezoneOffset() * 60

      for variable in variables
        seriesData[variable.id] = []

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
            firstDataDate = date.clone()

        for variable in variables
          record = _.findWhere(recordsForDate, variable_id: variable.id)
          value = if record? then record.value else null
          seriesData[variable.id].push(value)

        date.add(1, 'days')

      return seriesData

    calculateCorrelations = (dataset, variables) ->
      correlations = {}
      for a in variables
        for b in variables
          correlation = pearsonCorrelation(dataset, a.id, b.id)
          if correlation != 1 and Math.abs(correlation) > 0.5
            index = [a.id, b.id].sort().join('-')
            if !correlations[index]? or correlation > correlations[index].correlation
              correlations[index] = 
                value: correlation
                variables: [a, b]
      formatted = []
      for index, correlation of correlations
        formatted.push(correlation)
      return formatted

    variables = removeVariablesThatDontHaveEnoughData(variables, records, settings.minimumRecordsThreshold)
    dataset = formatDataForPearsonCorrelations(records, variables)
    correlations = calculateCorrelations(dataset, variables)
    for correlation in correlations
      correlation.pretty = Math.round(correlation.value * 100) + '%'
      correlation.type = if correlation.value > 0 then 'positive' else 'negative'
    $scope.correlations = correlations.sort (a, b) -> Math.abs(a.value) < Math.abs(b.value)

    $scope.selected = correlations[0]

    $scope.isSelected = (correlation) ->
      return correlation is $scope.selected

    $scope.isPositive = (correlation) ->
      return correlation.type is 'positive'

    $scope.isNegative = (correlation) ->
      return correlation.type is 'negative'

    $scope.select = (correlation) ->
      $scope.selected = correlation
      renderChart()

    formatDataForLineChart = (records) ->

      seriesData = {}
      series = []
      timezoneOffset = (new Date).getTimezoneOffset() * 60

      for variable in $scope.selected.variables
        seriesData[variable.id] = []

      date = firstDataDate.clone() or start.clone().subtract(1, 'days')
      endDate = end.clone()

      while date.isBefore(endDate)
        
        recordsForDate = _.where(records, date: date.format('YYYY-MM-DD'))

        for variable in $scope.selected.variables
          record = _.findWhere(recordsForDate, variable_id: variable.id)
          value = if record? then record.value else null
          seriesData[variable.id].push(x: date.valueOf(), y: value)

        date.add(1, 'days')

      for variable, i in $scope.selected.variables

        scale = 'linear'
        series.push(
          name: variable.name
          variable: variable
          color: variable.color
          data: seriesData[variable.id]
        )

      return series

    formatDataForScatterplotChart = (records) ->

      seriesData = {}
      series = []
      timezoneOffset = (new Date).getTimezoneOffset() * 60

      for variable in $scope.selected.variables
        seriesData[variable.id] = []

      date = firstDataDate.clone() or start.clone().subtract(1, 'days')
      endDate = end.clone()

      while date.isBefore(endDate)
        
        recordsForDate = _.where(records, date: date.format('YYYY-MM-DD'))

        point = {}
        x = _.findWhere(recordsForDate, variable_id: $scope.selected.variables[0].id)?.value
        y = _.findWhere(recordsForDate, variable_id: $scope.selected.variables[1].id)?.value
        seriesData[variable.id].push(x: x, y: y)

        date.add(1, 'days')

      for variable, i in $scope.selected.variables

        scale = 'linear'
        series.push(
          name: variable.name
          variable: variable
          color: variable.color
          data: seriesData[variable.id]
        )

      return series

    renderChart = ->
      
      console.debug('rendering insights chart')

      if $scope.chart.name is 'line'
        points = formatDataForLineChart(records)
      else
        points = formatDataForScatterplotChart(records)

      console.log(points)

      $chart = $('[name="chart"]')

      if not $chart.length then return

      $chart.empty()
      $chart.replaceWith('<div name="chart"></div>')
      $chart = $('[name="chart"]')

      if not points.length then return

      graph = new Rickshaw.Graph(
        element: $chart[0]
        width: $('.main').width()
        height: $('.main').height()
        renderer: $scope.chart.name
        series: points
        dotSize: 5
        interpolation: 'cardinal'
      )

      graph.render()

      if $scope.chart.name is 'line'

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

    onSomeEventThatRequiresTheChartToBeReRendered = -> renderChart()

    gui.Window.get().addListener 'resize', onSomeEventThatRequiresTheChartToBeReRendered
    gui.Window.get().addListener 'enterFullscreen', onSomeEventThatRequiresTheChartToBeReRendered
    gui.Window.get().addListener 'leaveFullscreen', onSomeEventThatRequiresTheChartToBeReRendered

    $rootScope.$watch 'variables', onSomeEventThatRequiresTheChartToBeReRendered, true
    $scope.$watch 'selected', onSomeEventThatRequiresTheChartToBeReRendered

    $rootScope.$on "$stateChangeStart", (event, toState, toParams, fromState, fromParams) ->
      if fromState.name is not "default" then return
      gui.Window.get().removeListener 'resize', onSomeEventThatRequiresTheChartToBeReRendered
      gui.Window.get().removeListener 'enterFullscreen', onSomeEventThatRequiresTheChartToBeReRendered
      gui.Window.get().removeListener 'leaveFullscreen', onSomeEventThatRequiresTheChartToBeReRendered
