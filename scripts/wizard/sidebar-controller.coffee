angular
  .module 'lifetracker'
  .controller 'WizardSidebarController', ($state, $scope, variable, moment, $stateParams) ->

    $scope.goTo = (variable) ->
      $state.go('wizard.step',
        variable_id: variable.id
        date: $stateParams.date
      )

    $scope.goToPreviousDate = ->
      $state.go('wizard.step',
        variable_id: $stateParams.variable_id
        date: moment($stateParams.date).subtract(1, 'days').format('YYYY-MM-DD')
      )

    $scope.goToNextDate = ->
      $state.go('wizard.step',
        variable_id: $stateParams.variable_id
        date: moment($stateParams.date).add(1, 'days').format('YYYY-MM-DD')
      )

    $scope.currentVariable = variable

    $scope.date = pretty: moment($stateParams.date).format('ddd, MMM D')

    return