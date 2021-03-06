angular
  .module 'lifetracker'
  .controller 'RecordPopoverController', ($scope, $rootScope, $timeout, moment, db) ->

    $scope.toggleSelectDatePopover = ->
      $scope.showSelectDatePopover = not $scope.showSelectDatePopover

    $scope.variables = $rootScope.variables
    $scope.variable = $scope.variables[0]
    $scope.date = moment()
    $scope.done = false

    $scope.onInputLoaded = ->
      $('[name="record"]').on 'change slideStop', ->
        value = parseFloat($scope.record.value)
        if _.isNaN(value) then value = null
        $scope.record.value = value
        save()
      return

    save = ->
      console.info('saving ' + $scope.variable.name + ' record: ' + $scope.record.value)
      query = _id: $scope.variable._id
      index = $scope.variable.records.indexOf($scope.record)
      if $scope.record.value?
        $scope.record.date ?= $scope.date.format('YYYY-MM-DD')
        if index < 1
          $scope.variable.records.push($scope.record)
        update = $addToSet: records: $scope.record
      else
        $scope.variable.records.splice(index, 1)
        update = $pull: records: $scope.record
      options = {}
      db.update query, update, options, (err) ->
        if err then throw err
        $rootScope.reloadVariables()
        $scope.$digest()

    $scope.goToDone = ->
      $scope.done = true
      $scope.progress = 100
      $scope.variable = null
      $scope.index = null
      $scope.previous = $scope.variables[$scope.variables.length - 1]
      $scope.next = null
      $scope.inputType = null

    $scope.goTo = (variable, date) ->
      if variable is 'done' then return $scope.goToDone()
      if not variable? then return
      $scope.done = false
      $scope.date = date
      $scope.variable = variable
      $scope.index = $scope.variables.indexOf($scope.variable)
      $scope.previous = $scope.variables[$scope.index - 1]
      $scope.next = $scope.variables[$scope.index + 1] or 'done'
      $scope.progress = $scope.index / $scope.variables.length * 100
      $scope.record = _.findWhere($scope.variable.records, date: date.format('YYYY-MM-DD')) or {}
      $scope.inputTemplate = 'templates/inputs/' + (if $scope.variable.units? then 'number-with-units' else $scope.variable.type) + '-input.html'

      if $scope.variable.type is 'scale' and not $scope.record.value?
        $scope.record.value = 5

    $scope.goTo($scope.variable, $scope.date)
