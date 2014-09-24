angular
  .module 'lifetracker'
  .controller 'ImportExportPopoverController', ($scope, $rootScope, db, settings) ->

    fs = require('fs')
    csv = require('csv')

    $scope.openFileManager = (name)->
      $('[name="' + name + '"]').click()
      $scope.importExportPopover.toggle(false)
      return

    $('[name="import-csv"]').on 'change', -> importFromCSV(@value)
    $('[name="export-csv"]').on 'change', -> exportToCSV(@value)

    importFromCSV = (file) ->
      $('[name="import-csv"]').val('')
      fs.readFile file, (err, data) ->
        if err then throw err
        importCSVData(data)

    importCSVData = (data) ->

      parser = csv.parse()
      rows = []

      parser.on 'error', (err) ->
        console.error('error parsing csv')

      parser.write(data)
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

      stringifier = csv.stringify()

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