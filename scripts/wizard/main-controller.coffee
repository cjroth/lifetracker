angular
  .module 'lifetracker'
  .controller 'WizardMainController', ($rootScope, $scope, $state, db, $stateParams) ->

    variable = _.findWhere($rootScope.variables, _id: $stateParams.variable_id)
    $scope.record = _.findWhere(variable.records, date: $stateParams.date) or date: $stateParams.date
    persisted = false

    variables = $rootScope.variables
    index = variables.indexOf(variable)
    next = variables[index + 1]
    previous = variables[index - 1]

    $scope.progress = index / variables.length * 100
    $scope.variable = variable

    if variable.type is 'scale' then $scope.record.value ?= 5

    goToNext = ->
      $state.go('wizard.step',
        variable_id: next._id
        date: $stateParams.date
      )

    goToPrevious = ->
      $state.go('wizard.step',
        variable_id: previous._id
        date: $stateParams.date
      )

    goToDone = ->
      $state.go('wizard.done',
        date: $stateParams.date
      )

    $scope.continue = ->
      if next
        goToNext()
      else
        goToDone()

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

      console.info('saving ' + variable.name + ' record: ' + $scope.record.value)

      query = _id: variable._id
      update = $addToSet: records: $scope.record
      options = {}
      db.update query, update, options, (err) ->
        if err then throw err
        $rootScope.reloadVariables()

    if previous
      $scope.previous = goToPrevious