angular
  .module 'lifetracker'
  .controller 'NavController', ($rootScope, $scope, $state, moment, db, settings) ->
    
    fs = require('fs')

    $scope.goToWizard = ->
      $state.go('wizard.step',
        variable_id: $rootScope.variables[0]._id
        # don't go to new day until 4am. most people will probably enter data at the end of
        # the day sometime after midnight
        date: moment().subtract(settings.newDayOffsetHours, 'hours').format('YYYY-MM-DD')
      )

    $scope.openExportToCSVFileManager = ->
      $('[name="export-csv"]').click()
      return

    $('[name="export-csv"]').on 'change', ->
      exportToCSV(@value)

    # exportToJSON = (file) ->
    #   json = JSON.stringify($rootScope.variables, null, '  ')
    #   fs.writeFile file, json, (err) ->
    #     if err then throw err

    exportToCSV = (file) ->
      csv = generateCSV($rootScope.variables)
      fs.writeFile file, csv, (err) ->
        if err then throw err

    generateCSV = (variables) ->

      csv = require('csv-stringify')()

      records = []
      for variable in $rootScope.variables
        if not variable.records? then continue
        for record in variable.records
          record.variable = variable
          records.push(record)

      recordsByDate = _.groupBy(records, 'date')

      # first row is header with variable names
      header = ['Date']
      for variable in $rootScope.variables
        label = variable.name
        if variable.units? then label += ' (' + variable.units + ')'
        header.push(label)
      csv.write(header)

      for date, recordsForDate of recordsByDate
        row = [date]
        for variable in $rootScope.variables
          row.push(_.findWhere(recordsForDate, variable: variable)?.value)
        csv.write(row)

      return csv.read().toString()