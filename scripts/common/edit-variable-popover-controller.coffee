angular
  .module 'lifetracker'
  .controller 'EditVariablePopoverController', ($rootScope, $scope, store, variableSorter) ->

    $scope.inputs = angular.copy($scope.variable)

    $scope.save = ->
      $scope.submitted = true
      if $scope.form.$invalid then return
      store.updateVariable $scope.inputs.id, $scope.inputs, (err) ->
        if err then throw err
        $rootScope.reloadVariables()
        $scope.$hide()
