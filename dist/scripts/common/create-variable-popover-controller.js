angular.module('lifetracker').controller('CreateVariablePopoverController', function($rootScope, $scope, store) {
  var defaults;
  defaults = {
    type: 'scale'
  };
  $scope.variable = angular.copy(defaults);
  return $scope.save = function() {
    var variable;
    variable = angular.copy($scope.variable);
    return store.createVariable(variable, function(err) {
      if (err) {
        return;
      }
      $scope.CreateVariablePopover.visible = false;
      $rootScope.variables.push(variable);
      $rootScope.$digest();
      return $scope.variable = angular.copy(defaults);
    });
  };
});
