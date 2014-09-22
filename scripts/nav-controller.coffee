angular
  .module 'lifetracker'
  .controller 'NavController', ($rootScope, $scope, $state, moment, db, settings) ->
    
    fs = require('fs')
    stringifier = require('csv-stringify')()
    parser = require('csv-parse')()

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

    $scope.openImportFromCSVFileManager = ->
      $('[name="import-csv"]').click()
      return

    $('[name="import-csv"]').on 'change', ->
      importFromCSV(@value)

    # exportToJSON = (file) ->
    #   json = JSON.stringify($rootScope.variables, null, '  ')
    #   fs.writeFile file, json, (err) ->
    #     if err then throw err

    importFromCSV = (file) ->
      csv = generateCSV($rootScope.variables)
      fs.readFile file, (err, data) ->
        if err then throw err
        importCSVData(data)

    importCSVData = (csv) ->
      rows = []
      parser.write(csv)
      variables = parser.read().splice(1)
      while row = parser.read()
        rows.push(row)
      for variable, i in variables
        units = /\ \((.*?)\)$/
        data =
          name: variable.replace(units, '').trim()
          units: variable.match(units)?[1]
          records: []
        data.type = if data.units? then 'number' else 'scale'
        for row in rows
          if row[i + 1].length then data.records.push(date: row[0], value: parseFloat(row[i + 1]))
        db.insert data, (err, variable) ->
          if err then throw err
          settings.selected.push(variable._id)
      $rootScope.reloadVariables()
      settings.save()

    exportToCSV = (file) ->
      csv = generateCSV($rootScope.variables)
      fs.writeFile file, csv, (err) ->
        if err then throw err

    generateCSV = (variables) ->

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
      stringifier.write(header)

      for date, recordsForDate of recordsByDate
        row = [date]
        for variable in $rootScope.variables
          row.push(_.findWhere(recordsForDate, variable: variable)?.value)
        stringifier.write(row)

      return stringifier.read().toString()