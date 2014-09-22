angular
  .module 'lifetracker'
  .controller 'EditVariablePopoverController', ($rootScope, $scope, db) ->

    $scope.inputs = angular.copy($scope.variable)

    $scope.save = ->
      $scope.submitted = true
      if $scope.form.$invalid then return
      query = _id: $scope.variable._id
      update = $set: $scope.inputs
      options = {}
      db.update query, update, options, (err) ->
        if err then throw err
        $rootScope.reloadVariables()
        $scope.$hide()
