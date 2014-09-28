angular
  .module 'lifetracker'
  .controller 'RecordController', ($scope, $state, $rootScope, $stateParams, moment, db) ->

    $scope.toggleSelectDatePopover = ->
      $scope.showSelectDatePopover = not $scope.showSelectDatePopover

    $scope.variables = $rootScope.variables
    $scope.variable = _.findWhere($scope.variables, _id: $stateParams.variable)
    $scope.date = moment($stateParams.date)
    $scope.done = false

    $scope.onInputLoaded = ->
      $('[name="record"]').on 'change slideStop', ->
        $scope.record.value = parseFloat($scope.record.value) || null
        if $scope.record.value?
          save()
          $scope.$digest()
        # else
        #   console.info('deleting ' + variable.name + ' record (' + record.id + ')')
        #   if record.id? then store.deleteRecord(record.id, onDeleteComplete)
        # @todo @nedb
      return

    save = ->
      console.info('saving ' + $scope.variable.name + ' record: ' + $scope.record.value)
      query = _id: $scope.variable._id
      $scope.record.date ?= $scope.date.format('YYYY-MM-DD')
      update = $addToSet: records: $scope.record
      options = {}
      db.update query, update, options, (err) ->
        if err then throw err
        $rootScope.reloadVariables()

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
      $scope.inputType = if $scope.variable.units? then 'number-input-with-units' else $scope.variable.type + '-input'

      if $scope.variable.type is 'scale' and not $scope.record.value?
        $scope.record.value = 5

    $scope.goTo($scope.variable, $scope.date)
