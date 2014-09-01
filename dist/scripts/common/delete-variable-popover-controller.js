angular.module('lifetracker').controller('DeleteVariablePopoverController', function($rootScope, $scope, store) {
  return $scope["delete"] = function() {
    return store.deleteVariable($scope.variable.id, function(err) {
      if (err) {
        return;
      }
      $rootScope.variables = _.without($rootScope.variables, $scope.variable);
      $scope.$hide();
      return $rootScope.$digest();
    });
  };
});
