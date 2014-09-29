angular
  .module 'lifetracker'
  .controller 'DatepickerPopoverController', ($scope, $timeout, moment, $rootScope) ->

    $timeout ->
      $datepicker = $('.datepicker').datepicker(inputs: $('.range-start, .range-end'), format: 'yyyy-mm-dd')
      $datepicker.find('.range-start').datepicker('setDate', $rootScope.daterange.start.format('YYYY-MM-DD'))
      $datepicker.find('.range-end').datepicker('setDate', $rootScope.daterange.end.format('YYYY-MM-DD'))
      $datepicker.on 'changeDate', (event) ->
        start = moment($('.range-start').datepicker('getDate'))
        end = moment($('.range-end').datepicker('getDate'))
        $scope.$emit('date changed', start, end)
