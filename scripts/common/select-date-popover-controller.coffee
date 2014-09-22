angular
  .module 'lifetracker'
  .controller 'SelectDatePopoverController', ($state, moment) ->

    $datepicker = $('.select-date-popover .datepicker').datepicker('show')

    $datepicker.on 'changeDate', (event) ->

      date = moment($datepicker.datepicker('getDate').getTime()).format('YYYY-MM-DD')
      $state.go('wizard.step',
        date: date
      )