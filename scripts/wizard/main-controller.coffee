angular
  .module 'lifetracker'
  .controller 'WizardMainController', ($rootScope, $scope, $state, variable, record, store, $stateParams) ->

    variables = $rootScope.variables
    index = variables.indexOf(variable)
    next = variables[index + 1]
    previous = variables[index - 1]

    $scope.progress = index / variables.length * 100
    $scope.variable = variable
    $scope.record = record

    if variable.type is 'scale' then $scope.record.value ?= 5

    goToNext = ->
      $state.go('wizard.step',
        variable_id: next.id
        date: $stateParams.date
      )

    goToPrevious = ->
      $state.go('wizard.step',
        variable_id: previous.id
        date: $stateParams.date
      )

    goToDone = ->
      $state.go('wizard.done',
        date: $stateParams.date
      )

    $scope.skip = ->
      if next
        goToNext()
      else
        goToDone()

    onSaveComplete = (err) ->
      if err then throw err
      if next
        goToNext()
      else
        goToDone()

    $scope.continue = ->

      if record.id?
        store.updateRecord(record.id, record.value, onSaveComplete)
      else
        store.createRecord(record, onSaveComplete)

    if previous
      $scope.previous = goToPrevious