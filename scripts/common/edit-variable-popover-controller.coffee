angular
  .module 'lifetracker'
  .controller 'EditVariablePopoverController', ($rootScope, $scope, store, variableSorter) ->

    $scope.form = angular.copy($scope.variable)

    $scope.save = ->

      store.updateVariable $scope.form.id, $scope.form, (err) ->

        if err
          # @todo handle error
          return

        angular.extend($scope.variable, $scope.form)
        $scope.$hide()
        $rootScope.variables.sort(variableSorter)
        $rootScope.$digest()