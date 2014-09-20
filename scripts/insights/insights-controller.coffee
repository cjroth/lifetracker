angular
  .module 'lifetracker'
  .controller 'InsightsSidebarController', ($scope, $rootScope, store, pearsonCorrelation, moment, variables, records, settings) ->

    start = moment().subtract(1, 'years')
    end = moment()

    removeVariablesThatDontHaveEnoughData = (variables, records, minimumRecordsThreshold) ->
      variablesWithEnoughData = []
      for variable in variables
        recordsForVariable = _.where(records, variable_id: variable.id)
        if recordsForVariable.length >= minimumRecordsThreshold
          variablesWithEnoughData.push(variable)
      return variablesWithEnoughData

    formatData = (records, variables) ->

      seriesData = {}
      series = []
      timezoneOffset = (new Date).getTimezoneOffset() * 60

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
    dataset = formatData(records, variables)
    correlations = calculateCorrelations(dataset, variables)
    for correlation in correlations
      correlation.pretty = Math.round(correlation.value * 100) + '%'
      correlation.type = if correlation.value > 0 then 'positive' else 'negative'
    $scope.correlations = correlations.sort (a, b) -> Math.abs(a.value) < Math.abs(b.value)

