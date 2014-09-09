angular
  .module 'lifetracker'
  .controller 'NavController', ($rootScope, $scope, $state, moment) ->

    $scope.$state = $state
    
    $scope.goToWizard = ->
      $state.go('wizard.step',
        variable_id: $rootScope.variables[0].id
        date: moment().format('YYYY-DD-MM')
      )