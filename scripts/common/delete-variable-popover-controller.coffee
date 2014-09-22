angular
  .module 'lifetracker'
  .controller 'DeleteVariablePopoverController', ($rootScope, $scope, db) ->

    $scope.delete = ->
      query = _id: $scope.variable._id
      options = {}
      db.remove query, options, (err) ->
        if err then throw err
        $rootScope.reloadVariables()
        $scope.$hide()
