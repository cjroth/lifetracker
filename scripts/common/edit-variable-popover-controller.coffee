angular
  .module 'lifetracker'
  .controller 'EditVariablePopoverController', ($rootScope, $scope, store, variableSorter) ->

    $scope.form = angular.copy($scope.variable)

    $scope.save = ->

      store.updateVariable $scope.form.id, $scope.form, (err) ->
        if err then throw err
        $rootScope.reloadVariables()
        $scope.$hide()
