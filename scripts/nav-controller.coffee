angular
  .module 'lifetracker'
  .controller 'NavController', ($scope, $state) ->

    $scope.$state = $state

    # initialize the datepicker
    $('.datepicker').datepicker
      inputs: $('.range-start, .range-end')
