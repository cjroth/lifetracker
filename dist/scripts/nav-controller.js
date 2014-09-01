angular.module('lifetracker').controller('NavController', function($scope, $state) {
  $scope.$state = $state;
  $('.datepicker').datepicker({
    inputs: $('.range-start, .range-end')
  });
});
