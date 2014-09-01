angular.module('lifetracker').controller('DefaultSidebarController', function($rootScope, $scope, store) {
  $scope.select = function(variable) {
    return variable.selected = !variable.selected;
  };
});
