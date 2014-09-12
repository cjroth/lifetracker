angular
  .module 'lifetracker'
  .controller 'SelectDatePopoverController', ($rootScope, $scope, $state, $stateParams, moment) ->

    $datepicker = $('.select-date-popover .datepicker').datepicker('show')

    $datepicker.on 'changeDate', (event) ->

      date = moment($datepicker.datepicker('getDate').getTime()).format('YYYY-MM-DD')
      $state.go('wizard.step',
        date: date
      )