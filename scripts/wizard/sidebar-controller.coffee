angular
  .module 'lifetracker'
  .controller 'WizardSidebarController', ($state, $scope, moment, $stateParams, $rootScope) ->

    variable = _.findWhere($rootScope.variables, _id: $stateParams.variable_id)

    $scope.goTo = (variable) ->
      $state.go('wizard.step',
        variable_id: variable._id
        date: $stateParams.date
      )

    $scope.goToPreviousDate = ->
      $state.go('wizard.step',
        variable_id: $stateParams.variable_id
        date: moment($stateParams.date).subtract(1, 'days').format('YYYY-MM-DD')
      )

    $scope.goToNextDate = ->
      $state.go('wizard.step',
        variable_id: $stateParams.variable_id
        date: moment($stateParams.date).add(1, 'days').format('YYYY-MM-DD')
      )

    $scope.toggleSelectDatePopover = ->
      $scope.showSelectDatePopover = not $scope.showSelectDatePopover

    $scope.currentVariable = variable

    $scope.date = pretty: moment($stateParams.date).format('ddd, MMM D')
