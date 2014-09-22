angular
  .module 'lifetracker'
  .controller 'SelectDatePopoverController', ($state, moment, $stateParams) ->

    $datepicker = $('.select-date-popover .datepicker')
      .datepicker(format: 'yyyy-mm-dd')
      .datepicker('setDate', $stateParams.date)

    $datepicker.on 'changeDate', (event) ->

      date = moment($datepicker.datepicker('getDate').getTime()).format('YYYY-MM-DD')
      $state.go('wizard.step',
        date: date
      )