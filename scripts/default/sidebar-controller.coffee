angular
  .module 'lifetracker'
  .controller 'DefaultSidebarController', ($rootScope, $scope, settings) ->

    $scope.select = (variable) ->
      variable.selected = !variable.selected
      selected = []
      for variable in $rootScope.variables
        if variable.selected then selected.push(variable._id)
      settings.selected = selected
      settings.save()
