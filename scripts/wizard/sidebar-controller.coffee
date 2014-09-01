angular
  .module 'lifetracker'
  .controller 'WizardSidebarController', ($state, $scope, variable) ->

    $scope.goTo = (variable) ->
      $state.go('wizard.step', id: variable.id)

    $scope.currentVariable = variable

    return