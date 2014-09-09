angular
  .module 'lifetracker'
  .controller 'WizardSidebarController', ($state, $scope, variable, moment, $stateParams) ->

    $scope.goTo = (variable) ->
      $state.go('wizard.step', id: variable.id)

    $scope.currentVariable = variable

    $scope.date = pretty: moment($stateParams.date).format('dddd, MMMM DD, YYYY')

    return