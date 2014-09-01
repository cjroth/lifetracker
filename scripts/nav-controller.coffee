angular
  .module 'lifetracker'
  .controller 'NavController', ($scope, $state) ->

    $scope.$state = $state
    
