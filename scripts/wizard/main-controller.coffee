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

    $scope.continue = ->
      if next
        goToNext()
      else
        goToDone()

    onSaveComplete = (err) ->
      if err then throw err
      record.id ?= @lastID

    $scope.onInputLoaded = ->
      $('[name="record"]').on('change slideStop', save)
      return

    save = ->
      if record.id?
        store.updateRecord(record.id, record.value, onSaveComplete)
        console.info('updating ' + variable.name + ' record (' + record.id + '): ' + record.value)
      else
        store.createRecord(record, onSaveComplete)
        console.info('creating ' + variable.name + ' record: ' + record.value)

    if previous
      $scope.previous = goToPrevious