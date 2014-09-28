angular
  .module 'lifetracker'
  .controller 'CreateVariablePopoverController', ($rootScope, $scope, db, settings) ->

    $scope.variable = type: 'scale'

    $scope.save = ->
      $scope.submitted = true
      if $scope.form.$invalid then return
      variable =
        name: $scope.variable.name
        question: $scope.variable.question
        type: $scope.variable.type
        units: $scope.variable.units
        records: []
      db.insert variable, (err, variable) ->
        if err then throw err
        settings.selected.push(variable._id)
        settings.save()
        $rootScope.reloadVariables()
        $scope.$hide()
