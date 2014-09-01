angular
  .module 'lifetracker'
  .controller 'CreateVariablePopoverController', ($rootScope, $scope, store) ->

    defaults = type: 'scale'
    $scope.variable = angular.copy(defaults)

    $scope.save = ->

      variable = angular.copy $scope.variable

      store.createVariable variable, (err) ->

        if err
          # @todo handle error
          return

        $scope.CreateVariablePopover.visible = false
        $rootScope.variables.push(variable)
        $rootScope.$digest()
        $scope.variable = angular.copy(defaults)