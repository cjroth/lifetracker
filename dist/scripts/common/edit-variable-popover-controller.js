angular.module('lifetracker').controller('EditVariablePopoverController', function($rootScope, $scope, store) {
  $scope.form = angular.copy($scope.variable);
  return $scope.save = function() {
    return store.updateVariable($scope.form.id, $scope.form, function(err) {
      if (err) {
        return;
      }
      angular.extend($scope.variable, $scope.form);
      $scope.$hide();
      return $rootScope.$digest();
    });
  };
});
