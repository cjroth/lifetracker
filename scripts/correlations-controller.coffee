angular
  .module 'lifetracker'
  .controller 'CorrelationsController', ($scope, $rootScope, db, pearsonCorrelation, moment, settings, gui, $timeout) ->

    readyToRender = false

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

    removeVariablesThatDontHaveEnoughRecords = (variables, minimumRecordsThreshold) ->
      variablesWithEnoughRecords = []
      for variable in variables
        recordsFilteredInCurrentDaterange = variable.records.filter (record) ->
          moment(record.date).isAfter($rootScope.start.inclusive) and moment(record.date).isBefore($rootScope.end.inclusive) and record.value > 0.1
        if recordsFilteredInCurrentDaterange?.length >= minimumRecordsThreshold then variablesWithEnoughRecords.push(variable)
      return variablesWithEnoughRecords

    formatDataForPearsonCorrelations = (variables) ->

      data = {}

      for variable in variables
        data[variable._id] = []

      date = $rootScope.start.clone()

      while date.isAfter($rootScope.start.inclusive) and date.isBefore($rootScope.end.inclusive)

        for variable in variables
          record = _.findWhere(variable.records, date: date.format('YYYY-MM-DD'))
          value = if record? then record.value else null
          data[variable._id].push(value)

        date.add(1, 'days')

      return data

    calculateCorrelations = ->
      variables = removeVariablesThatDontHaveEnoughRecords($rootScope.variables, settings.minimumRecordsThreshold)
      dataset = formatDataForPearsonCorrelations(variables)
      correlations = {}
      for a in variables
        for b in variables
          if a is b then continue
          correlation = pearsonCorrelation(dataset, a._id, b._id)
          if Math.abs(correlation) > 0.5
            index = [a._id, b._id].sort().join('-')
            if !correlations[index]? or correlation > correlations[index].correlation
              correlations[index] =
                value: correlation
                absoluteValue: Math.abs(correlation)
                variables: [a, b]

      formatted = []

      for index, correlation of correlations
        formatted.push(correlation)

      for correlation in formatted
        correlation.pretty = Math.round(correlation.value * 100)
        correlation.name = correlation.variables[0].name + ' ' + (if correlation.value > 0 then '&' else 'vs') + ' ' + correlation.variables[1].name

      formatted.sort (a, b) -> Math.abs(a.value) < Math.abs(b.value)
      return formatted

    # variables = removeVariablesThatDontHaveEnoughRecords($rootScope.variables, settings.minimumRecordsThreshold)

    # if variables.length < 2
    #   # @todo show useful message here...
    #   console.debug('not enough variables with enough records to find correlations')
    #   return

    $scope.correlations = calculateCorrelations()

    if $scope.correlations.length is 0
      # @todo show useful message here...
      console.debug('no correlations found')
      return

    $scope.selected = $scope.correlations[0]

    $scope.isSelected = (correlation) -> correlation is $scope.selected
    $scope.isPositive = (correlation) -> correlation.value > 0
    $scope.isNegative = (correlation) -> correlation.value < 0

    $scope.select = (correlation) ->
      $scope.selected = correlation
      renderChart()

    formatDataForLineChart = (variables) ->

      data = {}
      series = []

      for variable in variables
        data[variable._id] = []
        max = d3.max variable.records, (record) -> record.value
        min = d3.min variable.records, (record) -> record.value
        variable.scale = d3.scale.linear().domain([min, max]).range([0.05, 0.95])

      date = $rootScope.start.clone()

      while date.isBefore($rootScope.end.inclusive)
        y0 = _.findWhere(variables[0].records, date: date.format('YYYY-MM-DD'))?.value
        y1 = _.findWhere(variables[1].records, date: date.format('YYYY-MM-DD'))?.value
        data[variables[0]._id].push(x: date.valueOf(), y: variables[0].scale(y0) || null)
        data[variables[1]._id].push(x: date.valueOf(), y: variables[1].scale(y1) || null)
        date.add(1, 'days')

      for variable, i in $scope.selected.variables
        series.push(
          name: variable.name
          variable: variable
          color: variable.color
          data: data[variable._id]
          renderer: 'line'
        )

      return series

    formatDataForScatterplotChart = (variables) ->

      data = []

      date = $rootScope.start.clone()

      while date.isBefore($rootScope.end.inclusive)
        x = _.findWhere(variables[0].records, date: date.format('YYYY-MM-DD'))?.value
        y = _.findWhere(variables[1].records, date: date.format('YYYY-MM-DD'))?.value
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

      if not readyToRender then return

      console.debug('rendering insights chart')

      if $scope.chart.name is 'line'
        points = formatDataForLineChart($scope.selected.variables)
      else
        points = formatDataForScatterplotChart($scope.selected.variables)

      $chart = $('.chart[name="chart-insights"]')

      if not $chart.length then return

      $chart.empty()
      $chart.replaceWith('<div name="chart-insights" class="chart"></div>')
      $chart = $('.chart[name="chart-insights"]')

      if not points.length then return

      graph = new Rickshaw.Graph(
        element: $chart[0]
        width: $('.main').width()
        height: $('.main').height()
        renderer: 'multi'
        series: points
        dotSize: 5
        interpolation: 'cardinal'
        min: 0 if $scope.chart.name is 'line'
        max: 1 if $scope.chart.name is 'line'
      )

      graph.render()

      if $scope.chart.name is 'line'

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

    unwatchVariables = $rootScope.$watch 'variables', onSomeEventThatRequiresTheChartToBeReRendered, true
    unwatchSelected = $scope.$watch 'selected', onSomeEventThatRequiresTheChartToBeReRendered

    $rootScope.$on "$stateChangeStart", (event, toState, toParams, fromState, fromParams) ->
      if fromState.name is not "default" then return
      gui.Window.get().removeListener 'resize', onSomeEventThatRequiresTheChartToBeReRendered
      gui.Window.get().removeListener 'enterFullscreen', onSomeEventThatRequiresTheChartToBeReRendered
      gui.Window.get().removeListener 'leaveFullscreen', onSomeEventThatRequiresTheChartToBeReRendered
      unwatchVariables()
      unwatchSelected()

    $scope.$on 'date changed', ->
      $scope.correlations = calculateCorrelations()
      renderChart()
      $scope.$digest()

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

    $timeout ->
      readyToRender = true
      renderChart()
