angular
  .module 'lifetracker'
  .controller 'CreateVariablePopoverController', ($rootScope, $scope, store, variableSorter, palette) ->

    defaults = type: 'scale'
    $scope.variable = angular.copy(defaults)

    $scope.save = ->

      variable = angular.copy($scope.variable)
      variable.selected = true
      variable.color = palette.color()

      console.log palette, variable.color

      store.createVariable variable, (err) ->

        if err
          # @todo handle error
          return

        $scope.CreateVariablePopover.visible = false
        $rootScope.variables.push(variable)
        $rootScope.variables.sort(variableSorter)
        $rootScope.$digest()
        $scope.variable = angular.copy(defaults)