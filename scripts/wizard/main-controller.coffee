angular
  .module 'lifetracker'
  .controller 'WizardMainController', ($scope, $state, variable, variables) ->

    index = variables.indexOf(variable)
    next = variables[index + 1]
    previous = variables[index - 1]

    $scope.progress = index / variables.length * 100
    $scope.variable = variable
    $scope.record = $scope.records[variable.id] || { variable: variable }

    if variable.type is 'scale' then $scope.record.value ?= 5

    $scope.$watch 'record', ->
      $scope.records[variable.id] = $scope.record

    $scope.skip = ->
      if next
        $state.go('wizard.step', id: next.id)
      else
        $state.go('wizard.done')

    $scope.continue = ->

      if next
        $state.go('wizard.step', id: next.id)
      else
        $state.go('wizard.done')

    if previous
      $scope.previous = ->
        $state.go('wizard.step', id: previous.id)

    return

  .controller 'WizardDoneController', ($scope, $state, store, variable, variables) ->

    $scope.done = ->

      async.each _.toArray($scope.records), (record, done) ->

        data = 
          variable_id: record.variable.id
          value: if record.variable.type is 'boolean' then !!record.value else parseFloat record.value

        store.createRecord(data, done)

      , (err) ->

        $state.go('default')

    return