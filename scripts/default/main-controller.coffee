angular
  .module 'lifetracker'
  .controller 'DefaultMainController', ($scope, $rootScope, store, $window, gui, moment, settings) ->

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
      {
        name: 'scatterplot'
        label: 'Dots'
        class: 'fa fa-circle'
      }
    ]

    $scope.chart = _.findWhere(charts, name: settings.chartName) or charts[0]
    $scope.stacked = settings.chartStacked

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

      maximums = {}
      minimums = {}

      while date.isAfter(oneBefore) and date.isBefore(oneAfter)
        
        recordsForDate = _.where(records, date: date.format('YYYY-MM-DD'))

        # if firstDataDate is null
        #   if recordsForDate.length is 0
        #     date.add(1, 'days')
        #     continue
        #   else
        #     firstDataDate = date

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

        scale = 'linear'
        series.push(
          name: variable.name
          variable: variable
          color: 'rgba(' + [rgb.r, rgb.g, rgb.b, alpha].join(',') + ')'
          stroke: 'rgba(' + [rgb.r, rgb.g, rgb.b, 1].join(',') + ')'
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
    
    console.log('settings.newDayOffsetHours', settings.newDayOffsetHours)

    end = moment().subtract(settings.newDayOffsetHours, 'hours').set('hour', 0).set('minute', 0).set('second', 0).set('millisecond', 0) #.set({ h: 0, m: 0, s: 0, ms: 0 })
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

    $rootScope.$watch 'variables', renderChart, true
