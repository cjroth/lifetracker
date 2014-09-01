angular
  .module 'lifetracker'
  .controller 'EditVariablePopoverController', ($rootScope, $scope, store) ->

    $scope.form = angular.copy($scope.variable)

    $scope.save = ->

      store.updateVariable $scope.form.id, $scope.form, (err) ->

        if err
          # @todo handle error
          return

        angular.extend($rootScope.variable, $scope.form)
        $scope.$hide()
        $rootScope.$digest()