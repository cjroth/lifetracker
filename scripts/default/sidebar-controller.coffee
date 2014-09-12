angular
  .module 'lifetracker'
  .controller 'DefaultSidebarController', ($rootScope, $scope, store, settings) ->

    $scope.select = (variable) ->
      variable.selected = !variable.selected
      selected = []
      for variable in $rootScope.variables
        if variable.selected then selected.push(variable.id)
      settings.selected = selected
      settings.save()

    return