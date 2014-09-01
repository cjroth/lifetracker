angular
  .module 'lifetracker'
  .controller 'DeleteVariablePopoverController', ($rootScope, $scope, store) ->

    $scope.delete = ->

      store.deleteVariable $scope.variable.id, (err) ->

        if err
          # @todo handle error
          return

        $rootScope.variables = _.without($rootScope.variables, $scope.variable)
        $scope.$hide()
        $rootScope.$digest()