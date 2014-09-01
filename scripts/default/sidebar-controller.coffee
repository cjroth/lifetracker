angular
  .module 'lifetracker'
  .controller 'DefaultSidebarController', ($rootScope, $scope, store) ->

    $scope.select = (variable) ->
      variable.selected = !variable.selected

    return