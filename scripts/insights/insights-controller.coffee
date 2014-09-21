angular
  .module 'lifetracker'
  .controller 'InsightsController', ($scope, $rootScope, store, pearsonCorrelation, moment, records, settings, gui) ->

    variables = angular.copy($rootScope.variables)

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

    if variables.length is 0
      # @todo show useful message here...
      return

    dataset = formatDataForPearsonCorrelations(records, variables)
    correlations = calculateCorrelations(dataset, variables)
    for correlation in correlations
      correlation.pretty = Math.round(correlation.value * 100) + '%'
      correlation.name = correlation.variables[0].name + ' ' + (if correlation.value > 0 then '&' else 'vs') + ' ' + correlation.variables[1].name
    $scope.correlations = correlations.sort (a, b) -> Math.abs(a.value) < Math.abs(b.value)

    $scope.selected = correlations[0]

    $scope.isSelected = (correlation) -> correlation is $scope.selected
    $scope.isPositive = (correlation) -> correlation.value > 0
    $scope.isNegative = (correlation) -> correlation.value < 0

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

        series.push(
          name: variable.name
          variable: variable
          color: variable.color
          data: seriesData[variable.id]
          renderer: 'line'
        )

      return series

    formatDataForScatterplotChart = (records) ->

      data = []
      timezoneOffset = (new Date).getTimezoneOffset() * 60

      date = firstDataDate.clone() or start.clone().subtract(1, 'days')
      endDate = end.clone()

      while date.isBefore(endDate)
        recordsForDate = _.where(records, date: date.format('YYYY-MM-DD'))
        x = _.findWhere(recordsForDate, variable_id: $scope.selected.variables[0].id)?.value
        y = _.findWhere(recordsForDate, variable_id: $scope.selected.variables[1].id)?.value
        if x? and y? then data.push(x: x, y: y)
        date.add(1, 'days')

      data = data.sort (a, b) ->
        return a.x - b.x

      line = calculateLineOfBestFit(data)

      return [
        {
          name: $scope.selected.name
          data: data
          renderer: 'scatterplot'
          color: '#4A89DC'
          variables: $scope.selected.variables
        }
        {
          name: $scope.selected.name
          renderer: 'line'
          data: line
          color: '#CCD1D9'
        }
      ]

    renderChart = ->
      
      console.debug('rendering insights chart')

      if $scope.chart.name is 'line'
        points = formatDataForLineChart(records)
      else
        points = formatDataForScatterplotChart(records)

      $chart = $('[name="chart-insights"]')

      if not $chart.length then return

      $chart.empty()
      $chart.replaceWith('<div name="chart-insights"></div>')
      $chart = $('[name="chart-insights"]')

      if not points.length then return

      graph = new Rickshaw.Graph(
        element: $chart[0]
        width: $('.main').width()
        height: $('.main').height()
        renderer: 'multi'
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

      round = (value) -> Math.round(value * 10) / 10 # round to 1 decimal place
      units = (variable) -> if variable.type is 'scale' then '' else variable.units

      if $scope.chart.name is 'scatterplot'

        new Rickshaw.Graph.HoverDetail(
          formatter: (series, x, y) ->
            if series.variables?
              variable = $scope.selected.variables[1]
              return variable.name + ': ' + round(y) + ' ' + units(variable)
            else
              return series.name
          xFormatter: (x) ->
            variable = $scope.selected.variables[0]
            return variable.name + ': ' + round(x) + ' ' + units(variable)
          graph: graph
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

    calculateLineOfBestFit = (points) ->
    
        if points.length < 1 then return (x: 0, y:0)
        
        n = 0
        sumX = 0
        sumY = 0
        sumXY = 0
        sumXX = 0
        minX = false
        maxX = false

        for point in points
          sumX += point.x
          sumY += point.y
          sumXY += point.x * point.y
          sumXX += point.x * point.x
          minX = if minX is false or minX > point.x then point.x else minX
          maxX = if maxX is false or maxX < point.x then point.x else maxX
          n++

        m = (sumXY - sumX * sumY / n) / (sumXX - sumX * sumX / n)
        b = (sumY - m * sumX) / n
        y1 = b + m * minX
        y2 = b + m * maxX

        return [
          { x: minX, y: y1 }
          { x: maxX, y: y2 }
        ]
