angular
  .module 'lifetracker'
  .controller 'CreateVariablePopoverController', ($rootScope, $scope, store, variableSorter) ->

    defaults = type: 'scale'
    $scope.variable = angular.copy(defaults)

    $scope.save = ->

      variable = angular.copy($scope.variable)
      variable.selected = true

      store.createVariable variable, (err) ->

        if err
          # @todo handle error
          return

        $scope.CreateVariablePopover.visible = false
        $rootScope.variables.push(variable)
        $rootScope.variables.sort(variableSorter)
        $rootScope.$digest()
        $scope.variable = angular.copy(defaults)