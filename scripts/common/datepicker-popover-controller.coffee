angular
  .module 'lifetracker'
  .controller 'DatepickerPopoverController', ($scope, $timeout, $rootScope) ->

    $timeout ->
      $datepicker = $('.datepicker').datepicker(inputs: $('.range-start, .range-end'), format: 'yyyy-mm-dd')
      $datepicker.find('.range-start').datepicker('setDate', $rootScope.start.format('YYYY-MM-DD'))
      $datepicker.find('.range-end').datepicker('setDate', $rootScope.end.format('YYYY-MM-DD'))
      $datepicker.on 'changeDate', (event) ->
        $rootScope.start = moment($('.range-start').datepicker('getDate'))
        $rootScope.start.inclusive = $rootScope.start.clone().subtract(1, 'days')
        $rootScope.end = moment($('.range-end').datepicker('getDate'))
        $rootScope.end.inclusive = $rootScope.end.clone().add(1, 'days')
        $scope.$emit('date changed')
