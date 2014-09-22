angular
  .module 'lifetracker'
  .controller 'CreateVariablePopoverController', ($rootScope, $scope, db, settings) ->

    $scope.variable = type: 'scale'

    $scope.save = ->
      $scope.submitted = true
      if $scope.form.$invalid then return
      db.insert $scope.variable, (err, variable) ->
        if err then throw err
        settings.selected.push(variable._id)
        settings.save()
        $rootScope.reloadVariables()
        $scope.$hide()
