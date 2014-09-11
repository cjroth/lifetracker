angular
  .module 'lifetracker'
  .controller 'DeleteVariablePopoverController', ($rootScope, $scope, store) ->

    $scope.delete = ->

      store.deleteVariable $scope.variable.id, (err) ->
        if err then throw err
        $rootScope.reloadVariables()
        $scope.$hide()
