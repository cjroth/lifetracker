angular
  .module 'lifetracker'
  .controller 'CreateVariablePopoverController', ($rootScope, $scope, store, variableSorter, palette) ->

    defaults = type: 'scale'
    $scope.variable = angular.copy(defaults)

    $scope.save = ->

      variable = angular.copy($scope.variable)
      variable.selected = true
      variable.color = $rootScope.palette.color()

      store.createVariable variable, (err) ->
        if err then throw err
        $scope.CreateVariablePopover.visible = false
        $rootScope.reloadVariables()
        $scope.variable = angular.copy(defaults)