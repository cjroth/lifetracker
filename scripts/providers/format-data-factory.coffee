angular
  .module 'lifetracker'
  .factory 'formatData', ->

    return (records) ->

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

        scale = 'linear'
        series.push(
          name: variable.name
          variable: variable
          color: 'rgba(' + [rgb.r, rgb.g, rgb.b, alpha].join(',') + ')'
          stroke: 'rgba(' + [rgb.r, rgb.g, rgb.b, 1].join(',') + ')'
          data: seriesData[variable.id]
        )

      return series
