angular
  .module 'lifetracker'
  .controller 'CreateVariablePopoverController', ($rootScope, $scope, store, variableSorter, palette, settings) ->

    defaults = type: 'scale'
    $scope.variable = angular.copy(defaults)

    $scope.save = ->
      $scope.submitted = true
      if $scope.form.$invalid then return
      variable = angular.copy($scope.variable)
      variable.selected = true
      variable.color = $rootScope.palette.color()
      store.createVariable variable, (err) ->
        if err then throw err
        $scope.CreateVariablePopover.visible = false
        settings.selected.push(@lastID)
        settings.save()
        $rootScope.reloadVariables()
        $scope.$hide()
