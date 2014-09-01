angular.module('lifetracker').controller('WizardSidebarController', function($state, $scope, variable) {
  $scope.goTo = function(variable) {
    return $state.go('wizard.step', {
      id: variable.id
    });
  };
  $scope.currentVariable = variable;
});
