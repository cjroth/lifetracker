angular
  .module 'lifetracker'
  .controller 'NavController', ($rootScope, $scope, $state, moment, settings) ->
    
    $scope.goToWizard = ->
      $state.go('wizard.step',
        variable_id: $rootScope.variables[0].id
        # don't go to new day until 4am. most people will probably enter data at the end of
        # the day sometime after midnight
        date: moment().subtract(settings.newDayOffsetHours, 'hours').format('YYYY-MM-DD')
      )

    $scope.openExportToCSVFileManager = ->
      $('[name="settings-export-csv"]').click()
      return

    $('[name="settings-export-csv"]').on 'change', ->
      exportToCSV(@value)

    exportToCSV = (file) ->
      store.getRecords (err, records) ->
        if err then throw err
        csv = generateCSV($rootScope.variables, records)
        fs.writeFile file, csv, (err) ->
          if err then throw err

    generateCSV = (variables, records) ->

      csv = require('csv-stringify')()

      recordsByDate = _.groupBy(records, 'date')

      header = ['Date']
      for variable in $rootScope.variables
        label = variable.name
        if variable.units? then label += ' (' + variable.units + ')'
        header.push(label)
      csv.write(header)

      for date, recordsForDate of recordsByDate
        row = [date]
        for variable in $rootScope.variables
          value = _.findWhere(recordsForDate, variable_id: variable.id)?.value
          row.push(value)
        csv.write(row)

      return csv.read().toString()