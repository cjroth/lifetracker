angular
  .module 'lifetracker'
  .controller 'NavController', ($rootScope, $scope, $state, moment, settings, $previousState) ->

    # $scope.goToWizard = ->
      # $state.go('wizard.step',
      #   variable_id: $rootScope.variables[0]._id
      #   # don't go to new day until 4am. most people will probably enter data at the end of
      #   # the day sometime after midnight
      #   date: moment().subtract(settings.newDayOffsetHours, 'hours').format('YYYY-MM-DD')
      # )

    $scope.goToWizard = ->
      $state.go('record')

    $scope.importExportPopover =
      show: false
      toggle: (show) -> @show = if show? then show else not @show
