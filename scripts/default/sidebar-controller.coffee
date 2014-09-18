angular
  .module 'lifetracker'
  .controller 'DefaultSidebarController', ($rootScope, $scope, store, settings) ->

    $scope.CreateVariablePopover = visible: false

    $scope.select = (variable) ->
      variable.selected = !variable.selected
      selected = []
      for variable in $rootScope.variables
        if variable.selected then selected.push(variable.id)
      settings.selected = selected
      settings.save()

    $scope.toggleCreateVariablePopover = ->
      $scope.CreateVariablePopover.visible = !$scope.CreateVariablePopover.visible
