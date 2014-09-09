angular
  .module 'lifetracker'
  .controller 'WizardSidebarController', ($state, $scope, variable, moment, $stateParams) ->

    $scope.goTo = (variable) ->
      $state.go('wizard.step',
        variable_id: variable.id
        date: $stateParams.date
      )

    $scope.currentVariable = variable

    $scope.date = pretty: moment($stateParams.date).format('dddd, MMMM DD, YYYY')

    return